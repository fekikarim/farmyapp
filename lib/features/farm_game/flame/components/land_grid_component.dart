import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/farm_grid_model.dart';
import 'dart:math' as math;

class LandGridComponent extends Component with HasGameRef {
  final FarmGrid grid;
  final double tileSize = 64.0;
  double get tileWidth => tileSize * 2;
  double get tileHeight => tileSize;
  Sprite? grassSprite;

  LandGridComponent({required this.grid});

  Vector2 getTileCenter(int x, int y) {
    return isoToScreen(x.toDouble(), y.toDouble());
  }

  @override
  Future<void> onLoad() async {
    grassSprite = await Sprite.load('tile_grass.png');
  }

  Vector2 isoToScreen(double x, double y) {
    return Vector2(
      (x - y) * tileSize,
      (x + y) * tileSize / 2,
    );
  }

  /// Converts screen/world coordinates to grid coordinates (x, y)
  Vector2 screenToIso(Vector2 worldPos) {
    double arg1 = worldPos.x / (tileSize * 2);
    double arg2 = worldPos.y / tileSize;
    return Vector2(
      (arg2 + arg1),
      (arg2 - arg1),
    );
  }

  int? selectedX;
  int? selectedY;

  void selectTile(int x, int y) {
    if (x >= 0 && x < grid.width && y >= 0 && y < grid.height) {
      selectedX = x;
      selectedY = y;
    } else {
      selectedX = null;
      selectedY = null;
    }
  }

  @override
  void render(Canvas canvas) {
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int y = 0; y < grid.height; y++) {
      for (int x = 0; x < grid.width; x++) {
        final screenPos = isoToScreen(x.toDouble(), y.toDouble());
        final isSelected = x == selectedX && y == selectedY;
        _drawTile(canvas, screenPos, x, y, linePaint, isSelected);
      }
    }
  }

  void _drawTile(Canvas canvas, Vector2 pos, int x, int y, Paint linePaint, [bool isSelected = false]) {
    final topPath = Path();
    topPath.moveTo(pos.x, pos.y);
    topPath.lineTo(pos.x + tileSize, pos.y + tileSize / 2);
    topPath.lineTo(pos.x, pos.y + tileSize);
    topPath.lineTo(pos.x - tileSize, pos.y + tileSize / 2);
    topPath.close();

    // Grass color variation (background for texture)
    final grassColor = Color.lerp(
      const Color(0xFF7C9070),
      const Color(0xFF9CA777),
      (math.sin(x * 0.5 + y * 0.3) + 1) / 2,
    )!;

    final fillPaint = Paint()..color = isSelected ? Colors.yellow.withOpacity(0.5) : grassColor;

    // Side faces for 3D effect
    final sideHeight = tileSize / 4;
    final sidePaint = Paint()
      ..color = grassColor.withBlue(math.max(0, grassColor.blue - 20)).withRed(math.max(0, grassColor.red - 20))
      ..style = PaintingStyle.fill;

    // Right Side Face
    final rightSide = Path();
    rightSide.moveTo(pos.x + tileSize, pos.y + tileSize / 2);
    rightSide.lineTo(pos.x, pos.y + tileSize);
    rightSide.lineTo(pos.x, pos.y + tileSize + sideHeight);
    rightSide.lineTo(pos.x + tileSize, pos.y + tileSize / 2 + sideHeight);
    rightSide.close();
    canvas.drawPath(rightSide, sidePaint);

    // Left Side Face
    final leftSide = Path();
    leftSide.moveTo(pos.x - tileSize, pos.y + tileSize / 2);
    leftSide.lineTo(pos.x, pos.y + tileSize);
    leftSide.lineTo(pos.x, pos.y + tileSize + sideHeight);
    leftSide.lineTo(pos.x - tileSize, pos.y + tileSize / 2 + sideHeight);
    leftSide.close();
    canvas.drawPath(leftSide, sidePaint);

    // Draw textured top
    if (grassSprite != null) {
      canvas.save();
      canvas.clipPath(topPath);
      // Draw sprite large enough to cover the tile
      grassSprite!.render(
        canvas,
        position: Vector2(pos.x - tileSize, pos.y),
        size: Vector2(tileSize * 2, tileSize),
        overridePaint: isSelected ? (Paint()..colorFilter = ColorFilter.mode(Colors.yellow.withOpacity(0.3), BlendMode.srcATop)) : null,
      );
      canvas.restore();
    } else {
      canvas.drawPath(topPath, fillPaint);
    }
    
    // Draw selection outline
    if (isSelected) {
      final highlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(topPath, highlightPaint);
    }

    canvas.drawPath(topPath, linePaint);
  }
}
