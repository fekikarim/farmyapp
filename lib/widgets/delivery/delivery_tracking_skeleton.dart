import 'package:flutter/material.dart';

/// Skeleton loading placeholder for the tracking screen.
class DeliveryTrackingSkeleton extends StatefulWidget {
  const DeliveryTrackingSkeleton({super.key});

  @override
  State<DeliveryTrackingSkeleton> createState() =>
      _DeliveryTrackingSkeletonState();
}

class _DeliveryTrackingSkeletonState extends State<DeliveryTrackingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status card skeleton
              _SkeletonCard(
                height: 120,
                theme: theme,
                shimmerValue: _shimmerController.value,
              ),
              const SizedBox(height: 20),

              // Info card skeleton
              _SkeletonCard(
                height: 180,
                theme: theme,
                shimmerValue: _shimmerController.value,
              ),
              const SizedBox(height: 20),

              // Timeline skeleton
              ...List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      _SkeletonCircle(
                        size: 28,
                        theme: theme,
                        shimmerValue: _shimmerController.value,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SkeletonRect(
                              width: 120,
                              height: 14,
                              theme: theme,
                              shimmerValue: _shimmerController.value,
                            ),
                            const SizedBox(height: 6),
                            _SkeletonRect(
                              width: 80,
                              height: 10,
                              theme: theme,
                              shimmerValue: _shimmerController.value,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Helper skeleton shapes ──────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  final double height;
  final ThemeData theme;
  final double shimmerValue;

  const _SkeletonCard({
    required this.height,
    required this.theme,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment(-1 + 2 * shimmerValue, 0),
          end: Alignment(-1 + 2 * shimmerValue + 1, 0),
          colors: [
            theme.colorScheme.onSurface.withOpacity(0.04),
            theme.colorScheme.onSurface.withOpacity(0.08),
            theme.colorScheme.onSurface.withOpacity(0.04),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;
  final ThemeData theme;
  final double shimmerValue;

  const _SkeletonCircle({
    required this.size,
    required this.theme,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(-1 + 2 * shimmerValue, 0),
          end: Alignment(-1 + 2 * shimmerValue + 1, 0),
          colors: [
            theme.colorScheme.onSurface.withOpacity(0.04),
            theme.colorScheme.onSurface.withOpacity(0.08),
            theme.colorScheme.onSurface.withOpacity(0.04),
          ],
        ),
      ),
    );
  }
}

class _SkeletonRect extends StatelessWidget {
  final double width;
  final double height;
  final ThemeData theme;
  final double shimmerValue;

  const _SkeletonRect({
    required this.width,
    required this.height,
    required this.theme,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment(-1 + 2 * shimmerValue, 0),
          end: Alignment(-1 + 2 * shimmerValue + 1, 0),
          colors: [
            theme.colorScheme.onSurface.withOpacity(0.04),
            theme.colorScheme.onSurface.withOpacity(0.08),
            theme.colorScheme.onSurface.withOpacity(0.04),
          ],
        ),
      ),
    );
  }
}
