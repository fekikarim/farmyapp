import 'package:flutter/material.dart';

class AboutHubSkeleton extends StatefulWidget {
  const AboutHubSkeleton({super.key});

  @override
  State<AboutHubSkeleton> createState() => _AboutHubSkeletonState();
}

class _AboutHubSkeletonState extends State<AboutHubSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

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
      animation: _controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerBox(width: double.infinity, height: 170, radius: 20),
              const SizedBox(height: 16),
              _shimmerBox(width: 180, height: 20, radius: 8),
              const SizedBox(height: 12),
              for (int i = 0; i < 4; i++) ...[
                _shimmerBox(width: double.infinity, height: 84, radius: 16),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 6),
              _shimmerBox(width: 140, height: 20, radius: 8),
              const SizedBox(height: 12),
              _shimmerBox(width: double.infinity, height: 110, radius: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox({
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
