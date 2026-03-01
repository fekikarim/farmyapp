import 'package:flutter/material.dart';
import '../../models/delivery_model.dart';

/// A map placeholder that shows driver & customer location in a
/// stylised card. Uses a visual representation since we don't have
/// Google Maps SDK integrated. Gracefully hides when no coordinates.
class DeliveryMapSection extends StatelessWidget {
  final DeliveryTracking tracking;

  const DeliveryMapSection({super.key, required this.tracking});

  @override
  Widget build(BuildContext context) {
    // Only show when OUT_FOR_DELIVERY or NEARBY with coordinates
    if (!tracking.showMap) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final coords = tracking.coordinates!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Map visual placeholder ──
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Grid pattern
                CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _GridPainter(
                    color: Colors.blue.shade100.withOpacity(0.5),
                  ),
                ),

                // Driver marker
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          tracking.deliveryStatus == DeliveryStatus.nearby
                              ? 'Driver Nearby!'
                              : 'On the way',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Destination pin (bottom-right)
                if (tracking.destination != null)
                  Positioned(
                    right: 30,
                    bottom: 20,
                    child: Column(
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: Colors.green.shade600,
                          size: 22,
                        ),
                        Text(
                          'You',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Coordinates info ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _LocationChip(
                  icon: Icons.local_shipping_rounded,
                  label:
                      '${coords.latitude.toStringAsFixed(4)}, ${coords.longitude.toStringAsFixed(4)}',
                  color: Colors.blue.shade600,
                  theme: theme,
                ),
                const SizedBox(width: 8),
                if (tracking.destination != null)
                  _LocationChip(
                    icon: Icons.flag_rounded,
                    label:
                        '${tracking.destination!.latitude.toStringAsFixed(4)}, ${tracking.destination!.longitude.toStringAsFixed(4)}',
                    color: Colors.green.shade600,
                    theme: theme,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ThemeData theme;

  const _LocationChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple grid pattern painter for the map placeholder
class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
