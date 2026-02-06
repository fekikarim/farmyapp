import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import '../models/farm_grid_model.dart';
import 'components/land_grid_component.dart';
import 'components/farm_asset_component.dart';

class FarmGame extends FlameGame with HasGameRef, ScaleCallbacks, ScrollDetector, TapCallbacks {
  final FarmGrid grid;
  late LandGridComponent landGrid;

  // Inertia / Momentum properties
  Vector2 _velocity = Vector2.zero();
  final double _damping = 0.92; // How fast it slows down
  final double _minVelocity = 0.1;

  FarmGame({required this.grid});

  @override
  Future<void> onLoad() async {
    // Parallax Sky & Clouds - Optimized for Mobile Scale
    try {
      final skyParallax = await loadParallaxComponent(
        [
          ParallaxImageData('sky_bg.png'),
          ParallaxImageData('cloud_01.png'),
        ],
        baseVelocity: Vector2(10, 0), // Faster clouds
        velocityMultiplierDelta: Vector2(1.8, 1.0),
        repeat: ImageRepeat.repeatX,
        alignment: Alignment.center,
        fill: LayerFill.height, // Fill height for landscape
      );
      camera.backdrop.add(skyParallax);
    } catch (e) {
      debugPrint('Error loading parallax: $e');
    }

    // Atmospheric Ground Plane (covers the black void)
    camera.backdrop.add(
      RectangleComponent(
        size: Vector2.all(20000),
        position: Vector2.zero(),
        anchor: Anchor.center,
        paint: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E), // Dark sky horizon
              Color(0xFF2D5A27), // Soft grass ground
              Color(0xFF1E3C1A), // Deep ground
            ],
            stops: [0.0, 0.5, 1.0],
          ).createShader(const Rect.fromLTWH(-10000, -10000, 20000, 20000)),
      ),
    );

    // Initialize Grid
    landGrid = LandGridComponent(grid: grid);
    world.add(landGrid);

    // Add Assets
    for (int y = 0; y < grid.height; y++) {
      for (int x = 0; x < grid.width; x++) {
        final cell = grid.matrix[y][x];
        if (cell != null) {
          final screenPos = landGrid.isoToScreen(x.toDouble(), y.toDouble());
          world.add(FarmAssetComponent(cell: cell, position: screenPos));
        }
      }
    }

    // Initial camera position
    camera.viewfinder.position = Vector2.zero();
    camera.viewfinder.anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply inertia
    if (_velocity.length > _minVelocity) {
      camera.viewfinder.position -= _velocity * dt;
      _velocity *= _damping;
    } else {
      _velocity = Vector2.zero();
    }

    // Camera clamping (Grid Bounds)
    _clampCamera();
  }

  void _clampCamera() {
    // Clamping optimized for landscape
    final halfWidth = (grid.width * landGrid.tileSize) * 1.5;
    final halfHeight = (grid.height * landGrid.tileSize) * 1.5;

    camera.viewfinder.position.x = camera.viewfinder.position.x.clamp(-halfWidth, halfWidth);
    camera.viewfinder.position.y = camera.viewfinder.position.y.clamp(-halfHeight, halfHeight);
  }

  // Gesture tracking for stability
  double _baseZoom = 1.0;
  double _baseAngle = 0.0;
  Vector2 _basePosition = Vector2.zero();

  @override
  void onScaleStart(ScaleStartEvent event) {
    _baseZoom = camera.viewfinder.zoom;
    _baseAngle = camera.viewfinder.angle;
    _basePosition = camera.viewfinder.position.clone();
    _velocity = Vector2.zero(); // Stop inertia on touch
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    // 1-Finger Panning & 2-Finger Rotation/Zoom
    
    // 1. Rotation (2-finger) - Apply sensitivity
    if (event.pointerCount >= 2 && event.rotation != 0) {
      const rotationSensitivity = 0.5;
      camera.viewfinder.angle = _baseAngle + (event.rotation * rotationSensitivity);
    }

    // 2. Zoom handling - Relative to baseZoom
    final scaleFactor = event.scale;
    if (scaleFactor != 1.0) {
      const zoomSensitivity = 0.4;
      final adjustedScale = 1.0 + (scaleFactor - 1.0) * zoomSensitivity;
      final newZoom = _baseZoom * adjustedScale;
      camera.viewfinder.zoom = newZoom.clamp(0.2, 5.0);
    }

    // 3. Pan handling (uses deltas which are already relative to last frame)
    final panDelta = event.focalPointDelta;
    camera.viewfinder.position -= panDelta;
    
    // Tracking velocity for inertia
    _velocity = panDelta / 0.016; 
  }

  @override
  void onScroll(PointerScrollInfo info) {
    // Mouse scroll zoom
    final scrollDelta = info.scrollDelta.global.y;
    final zoomFactor = scrollDelta > 0 ? 0.9 : 1.1;
    final newZoom = camera.viewfinder.zoom * zoomFactor;
    camera.viewfinder.zoom = newZoom.clamp(0.2, 5.0);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Convert tap to world coordinates
    final worldPos = camera.viewfinder.position + (event.localPosition - size / 2) / camera.viewfinder.zoom;
    
    // Convert world coordinates to isometric grid
    final gridPos = landGrid.screenToIso(worldPos);
    
    // Select the tile
    landGrid.selectTile(gridPos.x.round(), gridPos.y.round());
  }
}
