import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';

class AssetManager extends ChangeNotifier {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  final Map<String, ui.Image> _images = {};
  final Set<String> _loading = {};

  Future<void> loadAssets(List<String> paths) async {
    await Future.wait(paths.map(_loadImage));
  }

  Future<void> _loadImage(String path) async {
    if (_images.containsKey(path) || _loading.contains(path)) return;

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
      print('Failed to load asset: $path, error: $e');
    } finally {
      _loading.remove(path);
    }
  }

  ui.Image? getImage(String path) {
    return _images[path];
  }
}
