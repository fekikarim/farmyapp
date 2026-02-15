import 'dart:async';
import 'dart:convert';
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
  final Map<String, int> _frameCountCache = {};
  final Map<String, String?> _patternCache = {}; // Store 'standard' or 'padded'
  AssetManifest? _manifest;
  bool _manifestLoading = false;

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
    // Normalize path
    String path = baseAssetPath;
    if (path.startsWith('/')) path = path.substring(1);
    if (!path.startsWith('assets/')) path = 'assets/game_images/$path';
    if (!path.endsWith('/')) path = '$path/';

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
    
    // Try different naming conventions
    String pattern = 'image';
    if (allAssets.contains('${path}${pattern}0.png')) {
       // Simple pattern (image0.png)
       while (allAssets.contains('${path}${pattern}$count.png')) count++;
    } else if (allAssets.contains('${path}${pattern}000.png')) {
       // Padded pattern (image000.png)
       while (allAssets.contains('${path}${pattern}${count.toString().padLeft(3, '0')}.png')) count++;
    }
    
    _frameCountCache[path] = count;
    
    // Determine pattern for this path if not cached
    if (!_patternCache.containsKey(path)) {
      if (allAssets.contains('${path}${pattern}000.png')) _patternCache[path] = 'padded';
      else if (allAssets.contains('${path}${pattern}0.png')) _patternCache[path] = 'standard';
    }
    
    return count;
  }

  String getFramePath(String baseAssetPath, int index) {
    String path = baseAssetPath;
    if (path.startsWith('/')) path = path.substring(1);
    if (!path.startsWith('assets/')) path = 'assets/game_images/$path';
    if (!path.endsWith('/')) path = '$path/';

    String? pattern = _patternCache[path];
    if (pattern == 'padded') {
      return '${path}image${index.toString().padLeft(3, '0')}.png';
    }
    return '${path}image$index.png';
  }

  Future<void> _discoverFrames(String path) async {
    // Check cache and loading state to avoid redundant work
    if (_frameCountCache.containsKey(path) || _loading.contains(path + '_discovery')) return;
    _loading.add(path + '_discovery');
    
    int count = 0;
    bool exists = true;
    String? foundPattern;

    // Try finding the pattern first
    if (await _checkExists('${path}image0.png')) foundPattern = 'standard';
    else if (await _checkExists('${path}image000.png')) foundPattern = 'padded';

    if (foundPattern != null) {
        while (exists && count < 100) {
          final String framePath = foundPattern == 'padded' 
              ? '${path}image${count.toString().padLeft(3, '0')}.png'
              : '${path}image$count.png';
          if (await _checkExists(framePath)) {
            count++;
          } else {
            exists = false;
          }
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
    if (_images.containsKey(path) || _loading.contains(path) || _failed.contains(path)) return;

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
