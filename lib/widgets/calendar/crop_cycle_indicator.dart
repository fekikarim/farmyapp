import 'package:flutter/material.dart';
import '../../models/crop_cycle_model.dart';
import '../../models/crop_plan_model.dart';
import '../../theme/app_theme.dart';

/// Small indicator dot/bar showing crop status
class CropCycleIndicator extends StatelessWidget {
  final dynamic item;
  final double size;
  final bool showTooltip;

  const CropCycleIndicator({
    super.key,
    required this.item,
    this.size = 12,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String tooltip;
    bool isOutlined = false;

    if (item is CropCycle) {
      final cycle = item as CropCycle;
      color = cycle.getStatusColor(context);
      tooltip = '${cycle.variantName} - ${cycle.status.getLabel()}';
    } else if (item is CropPlan) {
      final plan = item as CropPlan;
      color = plan.getStatusColor(context);
      tooltip = '${plan.variantName} - ${plan.status.getLabel()}';
      isOutlined = plan.status == CropPlanStatus.planned;
    } else {
      color = Colors.grey;
      tooltip = 'Unknown';
    }

    final indicator = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOutlined ? null : color,
        shape: BoxShape.circle,
        border: isOutlined ? Border.all(color: color, width: 2) : null,
        boxShadow: !isOutlined
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );

    if (showTooltip) {
      return Tooltip(message: tooltip, child: indicator);
    }

    return indicator;
  }
}

/// Horizontal bar showing crop cycle duration with progress
class CropCycleBar extends StatelessWidget {
  final CropCycle cycle;
  final double height;
  final bool showLabel;

  const CropCycleBar({
    super.key,
    required this.cycle,
    this.height = 24,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = cycle.getStatusColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Stack(
          children: [
            // Progress fill
            FractionallySizedBox(
              widthFactor: cycle.progressPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),

            // Label
            if (showLabel)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cycle.assetCategory == 'tree'
                          ? Icons.forest
                          : Icons.local_florist,
                      size: 14,
                      color: cycle.progressPercentage > 0.5
                          ? Colors.white
                          : color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(cycle.progressPercentage * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: cycle.progressPercentage > 0.5
                            ? Colors.white
                            : color,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Timeline showing multiple crop cycles
class CropCycleTimeline extends StatelessWidget {
  final List<CropCycle> cycles;
  final DateTime startDate;
  final DateTime endDate;

  const CropCycleTimeline({
    super.key,
    required this.cycles,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays = endDate.difference(startDate).inDays;

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          // Background grid lines
          Row(
            children: List.generate(12, (index) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.black.withOpacity(0.05)),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Cycle bars
          ...cycles.map((cycle) {
            final daysFromStart = cycle.placedAt.difference(startDate).inDays;
            final growthDays = cycle.growthDays ?? cycle.cycleDays;

            final left = (daysFromStart / totalDays).clamp(0.0, 1.0);
            final width = (growthDays / totalDays).clamp(0.0, 1.0 - left);

            return Positioned(
              left: left * MediaQuery.of(context).size.width,
              top: cycles.indexOf(cycle) * 20.0,
              child: Container(
                width: width * MediaQuery.of(context).size.width,
                height: 16,
                decoration: BoxDecoration(
                  color: cycle.getStatusColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    cycle.variantName,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Day cell content showing crop indicators
class DayCropIndicators extends StatelessWidget {
  final List<dynamic> items;
  final double maxHeight;

  const DayCropIndicators({
    super.key,
    required this.items,
    this.maxHeight = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.all(2),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        alignment: WrapAlignment.center,
        children: items.take(8).map((item) {
          return CropCycleIndicator(item: item, size: 8, showTooltip: true);
        }).toList(),
      ),
    );
  }
}
