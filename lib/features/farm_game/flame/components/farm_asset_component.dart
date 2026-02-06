import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/farm_grid_model.dart';
import 'dart:math' as math;

class FarmAssetComponent extends PositionComponent with TapCallbacks {
  final FarmCell cell;
  final double tileSize = 64.0;

  double _scaleFactor = 1.0;
  double _bounceTimer = 0;

  FarmAssetComponent({required this.cell, required Vector2 position}) {
    this.position = position;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_bounceTimer > 0) {
      _bounceTimer -= dt;
      // Oscillate scale based on sine wave for "bounce"
      _scaleFactor = 1.0 + (math.sin(_bounceTimer * 30) * 0.2 * (_bounceTimer / 0.3));
    } else {
      _scaleFactor = 1.0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _bounceTimer = 0.3; // Trigger 300ms bounce
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.scale(_scaleFactor);
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Placeholder representation based on category
    switch (cell.category) {
      case 'animal':
        paint.color = Colors.orange;
        _drawDiamond(canvas, paint, 20);
        break;
      case 'vegetation':
        paint.color = Colors.green;
        _drawCircle(canvas, paint, 15);
        break;
      case 'tree':
        paint.color = Colors.teal;
        _drawTriangle(canvas, paint, 25);
        break;
      case 'structure':
        paint.color = Colors.brown;
        _drawRect(canvas, paint, 30);
        break;
      default:
        paint.color = Colors.white70;
        _drawCircle(canvas, paint, 10);
    }

    // Draw variant code text
    final textPainter = TextPainter(
      text: TextSpan(
        text: cell.variantCode,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    
    canvas.restore();
  }

  void _drawDiamond(Canvas canvas, Paint paint, double size) {
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size, 0)
      ..lineTo(0, size)
      ..lineTo(-size, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawCircle(Canvas canvas, Paint paint, double radius) {
    canvas.drawCircle(Offset.zero, radius, paint);
  }

  void _drawTriangle(Canvas canvas, Paint paint, double size) {
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size, size)
      ..lineTo(-size, size)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawRect(Canvas canvas, Paint paint, double size) {
    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size, height: size), paint);
  }
}
