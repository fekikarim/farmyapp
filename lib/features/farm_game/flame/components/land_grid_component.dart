import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/farm_grid_model.dart';
import 'dart:math' as math;

class LandGridComponent extends Component with HasGameRef {
  final FarmGrid grid;
  final double tileSize = 64.0;
  Sprite? grassSprite;

  LandGridComponent({required this.grid});

  @override
  Future<void> onLoad() async {
    grassSprite = await Sprite.load('tile_grass.png');
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
        _drawTile(canvas, screenPos, x, y, linePaint);
      }
    }
  }

  void _drawTile(Canvas canvas, Vector2 pos, int x, int y, Paint linePaint) {
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

    final fillPaint = Paint()..color = grassColor;

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
      );
      canvas.restore();
    } else {
      canvas.drawPath(topPath, fillPaint);
    }
    
    canvas.drawPath(topPath, linePaint);
  }

  Vector2 isoToScreen(double x, double y) {
    return Vector2(
      (x - y) * tileSize,
      (x + y) * tileSize / 2,
    );
  }
}
