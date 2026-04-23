import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight analog joystick for worker manual-control mode.
///
/// The widget is a pure UI + gesture component: it tracks the thumb's current
/// deflection and reports it through [onChanged] as a normalised screen-space
/// vector in the range [-1, 1] on each axis (right / down positive). It
/// deliberately does **not** drive a timer itself — the parent is expected to
/// own a `Ticker` so joystick input is applied in lock-step with the main
/// render loop, guaranteeing frame-rate-independent movement.
class VirtualJoystick extends StatefulWidget {
  final double size;
  final double thumbSize;
  final ValueChanged<Offset> onChanged;
  final VoidCallback? onReleased;

  const VirtualJoystick({
    super.key,
    required this.onChanged,
    this.onReleased,
    this.size = 140.0,
    this.thumbSize = 56.0,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _thumb = Offset.zero;

  double get _radius => widget.size / 2;
  double get _maxThumbTravel => _radius - widget.thumbSize / 2;

  void _setFromLocal(Offset localPos) {
    // Centre is (radius, radius); local deflection is pointer - centre.
    final Offset raw = localPos - Offset(_radius, _radius);
    final double dist = raw.distance;
    final double clampedDist = dist > _maxThumbTravel ? _maxThumbTravel : dist;
    final double angle = math.atan2(raw.dy, raw.dx);
    final Offset clamped = dist == 0
        ? Offset.zero
        : Offset(math.cos(angle) * clampedDist, math.sin(angle) * clampedDist);
    setState(() => _thumb = clamped);

    // Normalise deflection to [-1, 1] regardless of joystick size.
    final double nx = _maxThumbTravel == 0 ? 0 : clamped.dx / _maxThumbTravel;
    final double ny = _maxThumbTravel == 0 ? 0 : clamped.dy / _maxThumbTravel;
    widget.onChanged(Offset(nx, ny));
  }

  void _release() {
    setState(() => _thumb = Offset.zero);
    widget.onChanged(Offset.zero);
    widget.onReleased?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) => _setFromLocal(d.localPosition),
      onPanUpdate: (d) => _setFromLocal(d.localPosition),
      onPanEnd: (_) => _release(),
      onPanCancel: _release,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          children: [
            // Base ring
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Centre crosshair (subtle, helps aim)
            Positioned(
              left: _radius - 2,
              top: _radius - 2,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            // Thumb
            Positioned(
              left: _radius + _thumb.dx - widget.thumbSize / 2,
              top: _radius + _thumb.dy - widget.thumbSize / 2,
              child: IgnorePointer(
                child: Container(
                  width: widget.thumbSize,
                  height: widget.thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.85),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
