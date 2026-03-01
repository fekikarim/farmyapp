import 'package:flutter/material.dart';

/// Skeleton loading state for the vendor delivery dashboard.
class VendorDashboardSkeleton extends StatefulWidget {
  const VendorDashboardSkeleton({super.key});

  @override
  State<VendorDashboardSkeleton> createState() =>
      _VendorDashboardSkeletonState();
}

class _VendorDashboardSkeletonState extends State<VendorDashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: _controller,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat cards
              Row(
                children: [
                  Expanded(child: _buildStatSkeleton()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatSkeleton()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatSkeleton()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatSkeleton()),
                ],
              ),
              const SizedBox(height: 24),

              // Filter chips
              _buildShimmerBox(width: double.infinity, height: 42),
              const SizedBox(height: 20),

              // List items
              for (int i = 0; i < 4; i++) ...[
                _buildListItemSkeleton(),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatSkeleton() {
    return _buildShimmerBox(width: double.infinity, height: 100, radius: 18);
  }

  Widget _buildListItemSkeleton() {
    return _buildShimmerBox(width: double.infinity, height: 96, radius: 16);
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double radius = 12,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white10 : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.white24 : Colors.grey.shade100;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(_animation.value - 1, 0),
          end: Alignment(_animation.value + 1, 0),
          colors: [baseColor, highlightColor, baseColor],
        ),
      ),
    );
  }
}

/// Reimplementation of AnimatedBuilder since it might not exist in all versions
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, null);
}
