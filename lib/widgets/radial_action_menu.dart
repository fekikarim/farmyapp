import 'dart:math';
import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class RadialMenuAction {
  final String id;
  final IconData icon;
  final Color backgroundColor;
  final String tooltip;

  RadialMenuAction({
    required this.id,
    required this.icon,
    required this.backgroundColor,
    required this.tooltip,
  });
}

class RadialActionMenu extends StatefulWidget {
  final List<RadialMenuAction> actions;
  final Function(String actionId) onActionSelected;
  final VoidCallback onDismiss;

  /// Distance from center to the middle of each button (= circle outline radius)
  final double radius;

  const RadialActionMenu({
    super.key,
    required this.actions,
    required this.onActionSelected,
    required this.onDismiss,
    this.radius = 75.0,
  });

  @override
  State<RadialActionMenu> createState() => _RadialActionMenuState();
}

class _RadialActionMenuState extends State<RadialActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() => _controller.reverse().then((_) => widget.onDismiss());
  void _select(String id) =>
      _controller.reverse().then((_) => widget.onActionSelected(id));

  @override
  Widget build(BuildContext context) {
    // All items = dismiss button + action buttons
    final int total = widget.actions.length + 1;

    // Buttons are spread evenly around the FULL circle
    final double step = (2 * pi) / total;

    // Canvas size: diameter + button diameter + small padding
    const double btnRadius = 24.0; // half of 48
    final double canvasR = widget.radius + btnRadius + 6;
    final double size = canvasR * 2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Translucent ring outline only ────────────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _RingPainter(
                    radius: widget.radius * _scale.value,
                    opacity: _scale.value,
                  ),
                ),
              ),

              // ── Dismiss button + action buttons on the ring ──────────────
              for (int i = 0; i < total; i++) ...[
                Builder(
                  builder: (context) {
                    // Start at top (-π/2) and go clockwise
                    final double angle = -pi / 2 + step * i;
                    final double dx = cos(angle) * widget.radius * _scale.value;
                    final double dy = sin(angle) * widget.radius * _scale.value;

                    final bool isDismiss = (i == 0);
                    final RadialMenuAction? action = isDismiss
                        ? null
                        : widget.actions[i - 1];

                    return Positioned(
                      left: canvasR + dx - btnRadius,
                      top: canvasR + dy - btnRadius,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: _CircleButton(
                          icon: isDismiss ? Icons.close : action!.icon,
                          color: isDismiss
                              ? Colors.redAccent
                              : action!.backgroundColor,
                          tooltip: isDismiss
                              ? AppLocalizations.of(context)!.closeTip
                              : action!.tooltip,
                          onTap: isDismiss
                              ? _dismiss
                              : () => _select(action!.id),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Thin ring painter ─────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double radius;
  final double opacity;
  _RingPainter({required this.radius, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.radius != radius || old.opacity != opacity;
}

// ── Single circular icon button ───────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
