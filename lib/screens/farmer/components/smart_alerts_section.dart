import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../../models/farmer_dashboard_model.dart';
import '../../../providers/farmer_dashboard_provider.dart';

class SmartAlertsSection extends StatelessWidget {
  final Function(SmartAlert)? onAlertTap;
  final Function(SmartAlert)? onRepairTap;

  const SmartAlertsSection({super.key, this.onAlertTap, this.onRepairTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<FarmerDashboardProvider>();
    final alerts = provider.alerts;

    if (provider.isLoading && alerts.isEmpty) {
      return _buildSkeleton(context);
    }

    if (alerts.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.notificationsTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (provider.criticalAlerts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.criticalAlerts.length} ${l10n.alertCritical}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth * 0.72).clamp(
                210.0,
                290.0,
              );

              return SizedBox(
                height: 112,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return _AlertCard(
                      width: cardWidth.toDouble(),
                      alert: alerts[index],
                      isFirst: index == 0,
                      onTap: () => onAlertTap?.call(alerts[index]),
                      onActionTap: () => onRepairTap?.call(alerts[index]),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 60, height: 20, color: Colors.white),
            const SizedBox(height: 12),
            SizedBox(
              height: 112,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(3, (index) {
                  return Container(
                    width: 220,
                    margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.allSystemsOperational,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.noAlertsMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final double width;
  final SmartAlert alert;
  final bool isFirst;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  const _AlertCard({
    required this.width,
    required this.alert,
    required this.isFirst,
    this.onTap,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Color getPriorityColor() {
      switch (alert.priority) {
        case AlertPriority.critical:
          return Colors.red;
        case AlertPriority.warning:
          return Colors.orange;
        case AlertPriority.info:
          return Colors.blue;
      }
    }

    IconData getPriorityIcon() {
      switch (alert.priority) {
        case AlertPriority.critical:
          return Icons.error;
        case AlertPriority.warning:
          return Icons.warning;
        case AlertPriority.info:
          return Icons.info;
      }
    }

    String getLocalizedTitle() {
      if (alert.id.startsWith('durability-critical') ||
          alert.title == 'Low Durability Alert') {
        return l10n.lowDurabilityAlert;
      }
      if (alert.id.startsWith('durability-warning') ||
          alert.title == 'Durability Warning') {
        return l10n.durabilityWarning;
      }
      if (alert.id.startsWith('harvest-ready') ||
          alert.title == 'Harvest Ready Soon') {
        return l10n.harvestReadySoon;
      }
      if (alert.id.startsWith('harvest-overdue') ||
          alert.title == 'Harvest Overdue') {
        return l10n.harvestOverdue;
      }

      return alert.title;
    }

    return Container(
      width: width,
      margin: EdgeInsets.only(left: isFirst ? 0 : 12),
      child: Material(
        color: getPriorityColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: getPriorityColor().withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      getPriorityIcon(),
                      color: getPriorityColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        getLocalizedTitle(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (alert.actionRoute != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onActionTap,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        alert.priority == AlertPriority.critical
                            ? l10n.repair
                            : l10n.check,
                        style: TextStyle(
                          fontSize: 12,
                          color: getPriorityColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
