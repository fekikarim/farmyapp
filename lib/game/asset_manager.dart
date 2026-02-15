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
    // Check cache and loading state to avoid redundant work
    if (_frameCountCache.containsKey(path) || _loading.contains(path + '_discovery')) return;
    _loading.add(path + '_discovery');
    
    int count = 0;
    bool exists = true;
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
    _safeNotify();
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
