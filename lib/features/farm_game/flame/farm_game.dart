import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../models/farm_grid_model.dart';
import 'components/land_grid_component.dart';
import 'components/farm_asset_component.dart';

class FarmGame extends FlameGame with HasGameRef, ScaleDetector, ScrollDetector {
  final FarmGrid grid;
  late LandGridComponent landGrid;

  FarmGame({required this.grid});

  @override
  Future<void> onLoad() async {
    // Background color
    camera.backdrop.add(
      RectangleComponent(
        size: Vector2.all(10000),
        position: Vector2.all(-5000),
        paint: Paint()..color = const Color(0xFF1A1A2E),
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
  void onScaleUpdate(ScaleUpdateInfo info) {
    // Zoom handling
    final zoomDelta = info.scale.global.y;
    if (zoomDelta != 0) {
      final newZoom = camera.viewfinder.zoom * zoomDelta;
      camera.viewfinder.zoom = newZoom.clamp(0.2, 5.0);
    }

    // Pan handling
    camera.viewfinder.position -= info.delta.global;
  }

  @override
  void onScroll(PointerScrollInfo info) {
    // Mouse scroll zoom
    final scrollDelta = info.scrollDelta.global.y;
    final zoomFactor = scrollDelta > 0 ? 0.9 : 1.1;
    final newZoom = camera.viewfinder.zoom * zoomFactor;
    camera.viewfinder.zoom = newZoom.clamp(0.2, 5.0);
  }
}
