import 'package:flutter/material.dart';
import 'dart:async';
import 'asset_manager.dart';

class AnimatedSprite extends StatefulWidget {
  final String baseAssetPath;
  final Duration frameDuration;
  final double width;
  final double height;
  final BoxFit fit;

  const AnimatedSprite({
    super.key,
    required this.baseAssetPath,
    this.frameDuration = const Duration(milliseconds: 200),
    this.width = 64.0,
    this.height = 64.0,
    this.fit = BoxFit.contain,
  });

  @override
  State<AnimatedSprite> createState() => _AnimatedSpriteState();
}

class _AnimatedSpriteState extends State<AnimatedSprite> {
  int _currentFrame = 0;
  Timer? _timer;
  final List<ImageProvider> _frames = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadFrames();
  }

  @override
  void didUpdateWidget(AnimatedSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseAssetPath != widget.baseAssetPath) {
      _loadFrames();
    }
  }

  Future<void> _loadFrames() async {
    _stopTimer();
    setState(() {
      _loading = true;
      _error = false;
      _frames.clear();
      _currentFrame = 0;
    });

    int frameIndex = 0;
    bool hasMoreFrames = true;

    // Sanitize path: flutter app will use assets/<link from data base>
    String path = widget.baseAssetPath;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    final String fullBasePath = 'assets/game_images/$path';

    int maxFrames = AssetManager().getFrameCount(path);
    if (maxFrames == 0) maxFrames = 20; // Fallback if manifest not loaded or empty

    while (hasMoreFrames && frameIndex < maxFrames) {
      final String framePath = '$fullBasePath/image$frameIndex.png';
      final ImageProvider provider = AssetImage(framePath);
      
      try {
        // We need to check if asset exists. 
        // In Flutter, checking asset existence is tricky without platform channels or looking at AssetManifest.
        // For simplicity, we assume images are named image0, image1... and we try to load them.
        
        final completer = Completer<void>();
        final stream = provider.resolve(const ImageConfiguration());
        
        late ImageStreamListener listener;
        listener = ImageStreamListener(
          (ImageInfo info, bool synchronousCall) {
            if (!completer.isCompleted) completer.complete();
            stream.removeListener(listener);
          },
          onError: (dynamic exception, StackTrace? stackTrace) {
            if (!completer.isCompleted) completer.completeError(exception);
            stream.removeListener(listener);
          },
        );
        stream.addListener(listener);
        
        await completer.future;
        _frames.add(provider);
        frameIndex++;
      } catch (e) {
        hasMoreFrames = false;
      }
    }

    if (_frames.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    if (_frames.length <= 1) return;
    _timer = Timer.periodic(widget.frameDuration, (timer) {
      if (mounted) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % _frames.length;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_error || _frames.isEmpty) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    return Image(
      image: _frames[_currentFrame],
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
    );
  }
}
