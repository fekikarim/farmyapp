import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';

class AssetManager extends ChangeNotifier {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  final Map<String, ui.Image> _images = {};
  final Set<String> _failed = {};
  final Set<String> _loading = {};
  final Set<String> _spritePrefetchRequested = {};
  final Map<String, int> _frameCountCache = {};
  // Per base-path pattern: 'standard' (image0.png), 'padded' (image000.png),
  // or 'spaced' (sprite (0).png — used by the new worker sheets).
  final Map<String, String?> _patternCache = {};
  AssetManifest? _manifest;
  bool _manifestLoading = false;

  String _normalizeBasePath(String baseAssetPath) {
    String path = baseAssetPath;
    if (path.startsWith('/')) path = path.substring(1);
    if (!path.startsWith('assets/')) path = 'assets/game_images/$path';
    if (!path.endsWith('/')) path = '$path/';
    return path;
  }

  void _safeNotify() {
    scheduleMicrotask(() {
      if (hasListeners) notifyListeners();
    });
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
    final String cacheKey =
        '$normalizedPath|$prefetchCount|${frameCountHint ?? 0}';
    if (_spritePrefetchRequested.contains(cacheKey)) return;
    _spritePrefetchRequested.add(cacheKey);

    final int resolvedCount = frameCountHint ?? getFrameCount(normalizedPath);
    final int loadCount = resolvedCount > 0
        ? math.min(prefetchCount, resolvedCount)
        : prefetchCount;

    final List<String> paths = List.generate(
      loadCount,
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
    await Future.wait(paths.map(_loadImage));
  }

  Future<void> _loadImage(String path) async {
    if (_images.containsKey(path) ||
        _loading.contains(path) ||
        _failed.contains(path))
      return;

    _loading.add(path);

    try {
      final ByteData data = await rootBundle.load(path);
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
        completer.complete(img);
      });
      final image = await completer.future;
      _images[path] = image;
      _safeNotify();
    } catch (e) {
      print('Failed to load asset: $path');
      _failed.add(path);
    } finally {
      _loading.remove(path);
    }
  }

  ui.Image? getImage(String path) {
    return _images[path];
  }

  bool hasFailed(String path) {
    return _failed.contains(path);
  }
}
