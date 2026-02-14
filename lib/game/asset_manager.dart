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
  AssetManifest? _manifest;
  bool _manifestLoading = false;

  Future<void> _loadManifest() async {
    if (_manifest != null || _manifestLoading) return;
    _manifestLoading = true;
    try {
      print('Attempting to load AssetManifest...');
      _manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      print('AssetManifest loaded successfully.');
    } catch (e) {
      print('Detailed Failed to load AssetManifest: $e');
      // If manifest fails, we'll rely on the brute force fallback in getFrameCount
    } finally {
      _manifestLoading = false;
      notifyListeners();
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
       _loadManifest(); // Trigger lazy load
       // Brute force detection for the first time if manifest isn't ready
       _discoverFramesBruteForce(path);
       return 0; 
    }
    
    final allAssets = _manifest!.listAssets();
    int count = 0;
    while (allAssets.contains('${path}image$count.png')) {
      count++;
    }
    
    _frameCountCache[path] = count;
    return count;
  }

  Future<void> _discoverFramesBruteForce(String path) async {
    if (_loading.contains(path + '_discovery')) return;
    _loading.add(path + '_discovery');
    
    int count = 0;
    bool exists = true;
    // Check up to 100 frames as a safe brute-force limit
    while (exists && count < 100) {
      final String framePath = '${path}image$count.png';
      try {
        await rootBundle.load(framePath);
        count++;
      } catch (e) {
        exists = false;
      }
    }
    
    _frameCountCache[path] = count;
    _loading.remove(path + '_discovery');
    print('Brute-force discovered $count frames for $path');
    notifyListeners();
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
      notifyListeners();
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
