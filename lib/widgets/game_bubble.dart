import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';

class GameBubbleOverlay extends StatefulWidget {
  final Widget child;

  const GameBubbleOverlay({super.key, required this.child});

  @override
  State<GameBubbleOverlay> createState() => _GameBubbleOverlayState();
}

class _GameBubbleOverlayState extends State<GameBubbleOverlay> {
  Offset? _position; // Null initially, set in post-frame callback
  final double _bubbleSize = 60.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        setState(() {
          // Bottom right, with some padding
          _position = Offset(size.width - _bubbleSize - 20, size.height - _bubbleSize - 120);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);

    // Only show for investors who have the setting enabled
    final shouldShow = authProvider.user?.role == 'investor' &&
        gameProvider.shouldShowBubble &&
        !gameProvider.isLoading &&
        _position != null;

    return Stack(
      children: [
        // The main app content
        widget.child,

        // The Bubble
        if (shouldShow)
          Positioned(
            left: _position!.dx,
            top: _position!.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _isDragging = true;
                  _position = _position! + details.delta;
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
                _handleDragEnd(context);
              },
              onTap: () {
                // TODO: Handle bubble tap action (open game view)
                print('Game Bubble Tapped!');
              },
              child: Container(
                width: _bubbleSize,
                height: _bubbleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/game_images/land-red-location.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

        // Delete Zone (only visible while dragging)
        if (_isDragging && shouldShow)
          Positioned(
            bottom: 30, // Centered at bottom with some margin
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleDragEnd(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if dropped near the bottom center (delete zone)
    // We define "delete zone" as dropping it within the bottom 100px area
    if (_position!.dy > screenHeight - 100) {
      // Hide the bubble via provider
      context.read<GameProvider>().setBubbleVisibility(false);
      
      // Reset position for next time it's enabled
      setState(() {
        _position = Offset(screenWidth - _bubbleSize - 20, screenHeight - _bubbleSize - 120);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game bubble hidden. Restore it in Settings.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Keep within screen bounds
      double x = _position!.dx.clamp(0.0, screenWidth - _bubbleSize);
      double y = _position!.dy.clamp(MediaQuery.of(context).padding.top, screenHeight - _bubbleSize);
      
      setState(() {
        _position = Offset(x, y);
      });
    }
  }
}
