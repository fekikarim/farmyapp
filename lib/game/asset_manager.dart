import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';

class AssetManager extends ChangeNotifier {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  final Map<String, ui.Image> _images = {};
  final Set<String> _permanentFailures = {};
  final Set<String> _loading = {};
  final Map<String, int> _spritePrefetchLevel = {};
  final Map<String, DateTime> _spritePrefetchCooldownUntil = {};
  final Map<String, int> _frameCountCache = {};
  final Map<String, int> _transientFailures = {};
  final Map<String, DateTime> _retryAfter = {};
  final Queue<Completer<void>> _decodeWaiters = Queue<Completer<void>>();
  // Per base-path pattern: 'standard' (image0.png), 'padded' (image000.png),
  // or 'spaced' (sprite (0).png — used by the new worker sheets).
  final Map<String, String?> _patternCache = {};
  AssetManifest? _manifest;
  bool _manifestLoading = false;
  bool _notifyQueued = false;
  int _activeDecodes = 0;

  static const int _kMaxTransientRetries = 3;
  static const int _kMaxConcurrentDecodes = 4;
  static const Duration _kDecodeTimeout = Duration(seconds: 4);
  static const Duration _kPrefetchCooldown = Duration(milliseconds: 1500);
  static const Duration _kMinRetryDelay = Duration(milliseconds: 250);
  static const Duration _kMaxRetryDelay = Duration(seconds: 3);

  String _normalizeBasePath(String baseAssetPath) {
    String path = baseAssetPath;
    if (path.startsWith('/')) path = path.substring(1);
    if (!path.startsWith('assets/')) path = 'assets/game_images/$path';
    if (!path.endsWith('/')) path = '$path/';
    return path;
  }

  void _safeNotify() {
    if (_notifyQueued) return;
    _notifyQueued = true;
    scheduleMicrotask(() {
      _notifyQueued = false;
      if (hasListeners) notifyListeners();
    });
  }

  Future<void> _acquireDecodeSlot() {
    if (_activeDecodes < _kMaxConcurrentDecodes) {
      _activeDecodes++;
      return Future.value();
    }
    final completer = Completer<void>();
    _decodeWaiters.addLast(completer);
    return completer.future;
  }

  void _releaseDecodeSlot() {
    if (_decodeWaiters.isNotEmpty) {
      final completer = _decodeWaiters.removeFirst();
      if (!completer.isCompleted) {
        completer.complete();
      }
      return;
    }
    if (_activeDecodes > 0) {
      _activeDecodes--;
    }
  }

  bool _isPathCoolingDown(String path) {
    final DateTime? retryAt = _retryAfter[path];
    if (retryAt == null) return false;
    final bool coolingDown = DateTime.now().isBefore(retryAt);
    if (!coolingDown) {
      _retryAfter.remove(path);
    }
    return coolingDown;
  }

  Duration _retryDelayFor(int attempt) {
    final int exponent = math.min(math.max(attempt - 1, 0), 8);
    final int factor = 1 << exponent;
    final int delayMs = _kMinRetryDelay.inMilliseconds * factor;
    return Duration(
      milliseconds: math.min(delayMs, _kMaxRetryDelay.inMilliseconds),
    );
  }

  bool _isPermanentAssetError(Object error) {
    final String message = error.toString().toLowerCase();
    return message.contains('unable to load asset') ||
        message.contains('asset does not exist') ||
        message.contains('could not load asset');
  }

  void _markTransientFailure(String path, Object error) {
    final int attempt = (_transientFailures[path] ?? 0) + 1;
    if (attempt > _kMaxTransientRetries) {
      _transientFailures.remove(path);
      _retryAfter.remove(path);
      _permanentFailures.add(path);
      debugPrint('Asset permanently failed after retries: $path ($error)');
      return;
    }

    _transientFailures[path] = attempt;
    final Duration delay = _retryDelayFor(attempt);
    _retryAfter[path] = DateTime.now().add(delay);
    debugPrint(
      'Transient asset load failure for $path (attempt $attempt/$_kMaxTransientRetries). Retrying in ${delay.inMilliseconds}ms.',
    );
  }

  Future<void> _loadManifest() async {
    if (_manifest != null || _manifestLoading) return;
    _manifestLoading = true;
    try {
      print('Attempting to load AssetManifest...');
      _manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      print('AssetManifest loaded successfully.');
    } catch (e) {
      print('Detailed Failed to load AssetManifest: $e');
    } finally {
      _manifestLoading = false;
      _safeNotify();
    }
  }

  int getFrameCount(String baseAssetPath) {
    final String path = _normalizeBasePath(baseAssetPath);

    if (_frameCountCache.containsKey(path)) {
      return _frameCountCache[path]!;
    }

    if (_manifest == null) {
      _loadManifest();
      _discoverFrames(path);
      return 0;
    }

    final allAssets = _manifest!.listAssets();
    int count = 0;
    String? foundPattern;

    // Detect naming convention — order matters (most specific first).
    if (allAssets.contains('${path}sprite (0).png')) {
      foundPattern = 'spaced';
    } else if (allAssets.contains('${path}image0.png')) {
      foundPattern = 'standard';
    } else if (allAssets.contains('${path}image000.png')) {
      foundPattern = 'padded';
    }

    if (foundPattern != null) {
      // Tolerate up to 2 consecutive gaps before declaring the cycle over
      // (a few worker sheets ship with missing intermediate frames).
      int probe = 0;
      int gaps = 0;
      while (probe < 128) {
        final String candidate = _buildFramePath(path, probe, foundPattern);
        if (allAssets.contains(candidate)) {
          count = probe + 1;
          gaps = 0;
        } else {
          gaps++;
          if (gaps > 2) break;
        }
        probe++;
      }
    }

    _frameCountCache[path] = count;
    _patternCache[path] = foundPattern;
    return count;
  }

  void ensureSpriteSetDiscovery(String baseAssetPath) {
    // getFrameCount triggers manifest/discovery side effects when unknown.
    getFrameCount(baseAssetPath);
  }

  Future<int> ensureFrameCount(String baseAssetPath) async {
    await _loadManifest();
    return getFrameCount(baseAssetPath);
  }

  bool spriteSetExists(String baseAssetPath) {
    return getFrameCount(baseAssetPath) > 0;
  }

  Future<Map<String, int>> validateSpriteSets(
    Iterable<String> baseAssetPaths,
  ) async {
    await _loadManifest();
    final Map<String, int> results = <String, int>{};
    for (final base in baseAssetPaths.toSet()) {
      results[base] = getFrameCount(base);
    }
    return results;
  }

  Future<int> preloadFullSpriteSet(String baseAssetPath) async {
    final int frameCount = await ensureFrameCount(baseAssetPath);
    if (frameCount <= 0) return 0;
    final List<String> paths = List<String>.generate(
      frameCount,
      (i) => getFramePath(baseAssetPath, i),
      growable: false,
    );
    await loadAssets(paths);
    return frameCount;
  }

  String _buildFramePath(String normalizedPath, int index, String? pattern) {
    switch (pattern) {
      case 'padded':
        return '${normalizedPath}image${index.toString().padLeft(3, '0')}.png';
      case 'spaced':
        return '${normalizedPath}sprite ($index).png';
      case 'standard':
      default:
        return '${normalizedPath}image$index.png';
    }
  }

  String getFramePath(String baseAssetPath, int index) {
    final String path = _normalizeBasePath(baseAssetPath);
    return _buildFramePath(path, index, _patternCache[path]);
  }

  void prefetchSpriteFrames(
    String baseAssetPath, {
    int? frameCountHint,
    int prefetchCount = 6,
  }) {
    if (prefetchCount <= 0) return;

    final String normalizedPath = _normalizeBasePath(baseAssetPath);
    final DateTime now = DateTime.now();
    final DateTime? cooldownUntil =
        _spritePrefetchCooldownUntil[normalizedPath];

    final int resolvedCount = frameCountHint ?? getFrameCount(normalizedPath);
    final int requestedLevel = resolvedCount > 0
        ? math.min(prefetchCount, resolvedCount)
        : prefetchCount;
    final int currentLevel = _spritePrefetchLevel[normalizedPath] ?? 0;

    if (requestedLevel <= currentLevel) {
      return;
    }
    if (cooldownUntil != null && now.isBefore(cooldownUntil)) {
      return;
    }

    _spritePrefetchLevel[normalizedPath] = requestedLevel;
    _spritePrefetchCooldownUntil[normalizedPath] = now.add(_kPrefetchCooldown);

    final List<String> paths = List.generate(
      requestedLevel,
      (i) => getFramePath(normalizedPath, i),
    );
    unawaited(loadAssets(paths));
  }

  Future<void> _discoverFrames(String path) async {
    // Check cache and loading state to avoid redundant work
    if (_frameCountCache.containsKey(path) ||
        _loading.contains(path + '_discovery'))
      return;
    _loading.add(path + '_discovery');

    int count = 0;
    String? foundPattern;

    // Probe patterns in order of specificity.
    if (await _checkExists('${path}sprite (0).png')) {
      foundPattern = 'spaced';
    } else if (await _checkExists('${path}image0.png')) {
      foundPattern = 'standard';
    } else if (await _checkExists('${path}image000.png')) {
      foundPattern = 'padded';
    }

    if (foundPattern != null) {
      int probe = 0;
      int gaps = 0;
      while (probe < 128) {
        final String framePath = _buildFramePath(path, probe, foundPattern);
        if (await _checkExists(framePath)) {
          count = probe + 1;
          gaps = 0;
        } else {
          gaps++;
          if (gaps > 2) break;
        }
        probe++;
      }
    }

    _frameCountCache[path] = count;
    _patternCache[path] = foundPattern;
    _loading.remove(path + '_discovery');
    print('Discovered $count frames for $path (pattern: $foundPattern)');
    _safeNotify();
  }

  Future<bool> _checkExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadAssets(List<String> paths) async {
    if (paths.isEmpty) return;
    final List<String> uniquePaths = paths.toSet().toList(growable: false);
    await Future.wait(uniquePaths.map(_loadImage));
  }

  Future<void> _loadImage(String path) async {
    if (_images.containsKey(path) ||
        _loading.contains(path) ||
        _permanentFailures.contains(path) ||
        _isPathCoolingDown(path))
      return;

    _loading.add(path);
    bool decodeSlotAcquired = false;

    try {
      final ByteData data = await rootBundle
          .load(path)
          .timeout(_kDecodeTimeout);
      await _acquireDecodeSlot();
      decodeSlotAcquired = true;

      final Completer<ui.Image> completer = Completer<ui.Image>();
      ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
        if (!completer.isCompleted) {
          completer.complete(img);
        }
      });

      final ui.Image image = await completer.future.timeout(_kDecodeTimeout);
      if (image.width <= 0 || image.height <= 0) {
        throw StateError('Decoded image has invalid dimensions for $path');
      }

      _images[path] = image;
      _transientFailures.remove(path);
      _retryAfter.remove(path);
      _permanentFailures.remove(path);
      _safeNotify();
    } catch (e) {
      if (_isPermanentAssetError(e)) {
        _transientFailures.remove(path);
        _retryAfter.remove(path);
        _permanentFailures.add(path);
        debugPrint('Permanent asset failure: $path');
      } else {
        _markTransientFailure(path, e);
      }
    } finally {
      if (decodeSlotAcquired) {
        _releaseDecodeSlot();
      }
      _loading.remove(path);
    }
  }

  ui.Image? getImage(String path) {
    return _images[path];
  }

  bool hasFailed(String path) {
    return _permanentFailures.contains(path);
  }
}
