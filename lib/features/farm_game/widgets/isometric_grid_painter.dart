import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/farm_grid_model.dart';

class IsometricGridPainter extends CustomPainter {
  final FarmGrid grid;
  final double scale;
  final Offset offset;
  final double tileSize;

  IsometricGridPainter({
    required this.grid,
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.tileSize = 40.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2 + offset.dx, size.height / 4 + offset.dy);
    canvas.scale(scale);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cellPaint = Paint()
      ..style = PaintingStyle.fill;

    // Draw grid from back to front
    // We draw rows from 0 to height and cols from 0 to width
    for (int y = 0; y < grid.height; y++) {
      for (int x = 0; x < grid.width; x++) {
        final screenPos = _isoToScreen(x.toDouble(), y.toDouble());
        
        _drawTile(canvas, screenPos, linePaint);

        final cell = grid.matrix[y][x];
        if (cell != null) {
          _drawCellContent(canvas, screenPos, cell, cellPaint);
        }
      }
    }

    canvas.restore();
  }

  void _drawTile(Canvas canvas, Offset pos, Paint paint) {
    final path = Path();
    path.moveTo(pos.dx, pos.dy); // Top
    path.lineTo(pos.dx + tileSize, pos.dy + tileSize / 2); // Right
    path.lineTo(pos.dx, pos.dy + tileSize); // Bottom
    path.lineTo(pos.dx - tileSize, pos.dy + tileSize / 2); // Left
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCellContent(Canvas canvas, Offset pos, FarmCell cell, Paint paint) {
    // Basic representation for now: colored diamond on top of the tile
    // Different colors for different categories
    switch (cell.category) {
      case 'animal':
        paint.color = Colors.orange.withOpacity(0.7);
        break;
      case 'vegetation':
        paint.color = Colors.green.withOpacity(0.7);
        break;
      case 'tree':
        paint.color = Colors.teal.withOpacity(0.7);
        break;
      case 'structure':
        paint.color = Colors.brown.withOpacity(0.7);
        break;
      case 'machine':
        paint.color = Colors.blueGrey.withOpacity(0.7);
        break;
      default:
        paint.color = Colors.white.withOpacity(0.5);
    }

    final path = Path();
    // Slightly smaller than the tile
    const padding = 2.0;
    path.moveTo(pos.dx, pos.dy + padding);
    path.lineTo(pos.dx + tileSize - padding * 2, pos.dy + tileSize / 2);
    path.lineTo(pos.dx, pos.dy + tileSize - padding);
    path.lineTo(pos.dx - tileSize + padding * 2, pos.dy + tileSize / 2);
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw variant code text (very small)
    final textPainter = TextPainter(
      text: TextSpan(
        text: cell.variantCode,
        style: const TextStyle(color: Colors.white, fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, pos.translate(-textPainter.width / 2, tileSize / 4));
  }

  Offset _isoToScreen(double x, double y) {
    // Isometric formula:
    // screenX = (x - y) * tileWidth / 2
    // screenY = (x + y) * tileHeight / 2
    return Offset(
      (x - y) * tileSize,
      (x + y) * tileSize / 2,
    );
  }

  @override
  bool shouldRepaint(covariant IsometricGridPainter oldDelegate) {
    return oldDelegate.grid != grid || 
           oldDelegate.scale != scale || 
           oldDelegate.offset != offset;
  }
}
