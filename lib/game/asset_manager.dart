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
  Map<String, dynamic> _manifest = {};
  bool _manifestLoaded = false;

  Future<void> _loadManifest() async {
    if (_manifestLoaded) return;
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      _manifest = json.decode(manifestContent);
      _manifestLoaded = true;
    } catch (e) {
      print('Failed to load AssetManifest: $e');
    }
  }

  int getFrameCount(String baseAssetPath) {
    if (!_manifestLoaded) {
       _loadManifest(); // Trigger lazy load
       return 0; // Return 0 until loaded, or we could return a safe default
    }
    
    // Normalize path
    String path = baseAssetPath;
    if (path.startsWith('/')) path = path.substring(1);
    if (!path.startsWith('assets/')) path = 'assets/game_images/$path';
    if (!path.endsWith('/')) path = '$path/';

    int count = 0;
    while (_manifest.containsKey('${path}image$count.png')) {
      count++;
    }
    return count;
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
