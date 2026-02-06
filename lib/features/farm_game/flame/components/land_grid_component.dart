import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/farm_grid_model.dart';
import 'dart:math' as math;

class LandGridComponent extends Component {
  final FarmGrid grid;
  final double tileSize = 64.0;

  LandGridComponent({required this.grid});

  @override
  void render(Canvas canvas) {
    final cellPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int y = 0; y < grid.height; y++) {
      for (int x = 0; x < grid.width; x++) {
        final screenPos = isoToScreen(x.toDouble(), y.toDouble());
        _drawTile(canvas, screenPos, x, y, cellPaint, linePaint);
      }
    }
  }

  void _drawTile(Canvas canvas, Vector2 pos, int x, int y, Paint fillPaint, Paint linePaint) {
    final topPath = Path();
    topPath.moveTo(pos.x, pos.y);
    topPath.lineTo(pos.x + tileSize, pos.y + tileSize / 2);
    topPath.lineTo(pos.x, pos.y + tileSize);
    topPath.lineTo(pos.x - tileSize, pos.y + tileSize / 2);
    topPath.close();

    // Grass color variation
    final grassColor = Color.lerp(
      const Color(0xFF7C9070),
      const Color(0xFF9CA777),
      (math.sin(x * 0.5 + y * 0.3) + 1) / 2,
    )!;

    fillPaint.color = grassColor;

    // Side faces for 3D effect
    final sideHeight = tileSize / 4;
    final leftSide = Path();
    leftSide.moveTo(pos.x - tileSize, pos.y + tileSize / 2);
    leftSide.lineTo(pos.x, pos.y + tileSize);
    leftSide.lineTo(pos.x, pos.y + tileSize + sideHeight);
    leftSide.lineTo(pos.x - tileSize, pos.y + tileSize / 2 + sideHeight);
    leftSide.close();

    final rightSide = Path();
    rightSide.moveTo(pos.x + tileSize, pos.y + tileSize / 2);
    rightSide.lineTo(pos.x, pos.y + tileSize);
    rightSide.lineTo(pos.x, pos.y + tileSize + sideHeight);
    rightSide.lineTo(pos.x + tileSize, pos.y + tileSize / 2 + sideHeight);
    rightSide.close();

    final sidePaint = Paint()
      ..color = grassColor.withBlue(math.max(0, grassColor.blue - 20)).withRed(math.max(0, grassColor.red - 20))
      ..style = PaintingStyle.fill;

    canvas.drawPath(leftSide, sidePaint);
    canvas.drawPath(rightSide, sidePaint);
    canvas.drawPath(topPath, fillPaint);
    canvas.drawPath(topPath, linePaint);
  }

  Vector2 isoToScreen(double x, double y) {
    return Vector2(
      (x - y) * tileSize,
      (x + y) * tileSize / 2,
    );
  }
}
