import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../../providers/farmer_dashboard_provider.dart';

class HeroMetricsBlock extends StatelessWidget {
  final VoidCallback? onItemRequestsTap;
  final VoidCallback? onLandsTap;
  final VoidCallback? onRevenueTap;

  const HeroMetricsBlock({
    super.key,
    this.onItemRequestsTap,
    this.onLandsTap,
    this.onRevenueTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<FarmerDashboardProvider>();
    final heroMetrics = provider.heroMetrics;

    if (provider.isLoading && heroMetrics == null) {
      return _buildSkeleton(context);
    }

    if (heroMetrics == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 430;
          final cardItems = [
            _MetricCard(
              icon: Icons.landscape,
              iconColor: Colors.green,
              value: heroMetrics.activeLands.toString(),
              label: l10n.activeLands,
              subtitle:
                  '${provider.ownedLandsCount} ${l10n.statusOwned} • ${provider.rentedLandsCount} ${l10n.statusRented}',
              isSmallScreen: isCompact,
              onTap: onLandsTap,
            ),
            _MetricCard(
              icon: Icons.inbox,
              iconColor: Colors.orange,
              value: heroMetrics.pendingItemRequests.toString(),
              label: l10n.itemRequests,
              subtitle: heroMetrics.pendingItemRequests > 0
                  ? l10n.needsReview
                  : l10n.onTrack,
              subtitleColor: heroMetrics.pendingItemRequests > 0
                  ? Colors.orange
                  : Colors.green,
              isSmallScreen: isCompact,
              onTap: onItemRequestsTap,
            ),
            _MetricCard(
              icon: Icons.trending_up,
              iconColor: Colors.blue,
              value: '\$${heroMetrics.monthlyRevenue.toStringAsFixed(0)}',
              label: l10n.monthlyRevenue,
              subtitle: heroMetrics.revenueTrend >= 0
                  ? '↑ ${heroMetrics.revenueTrend.toStringAsFixed(1)}%'
                  : '↓ ${heroMetrics.revenueTrend.abs().toStringAsFixed(1)}%',
              subtitleColor: heroMetrics.revenueTrend >= 0
                  ? Colors.green
                  : Colors.red,
              isSmallScreen: isCompact,
              onTap: onRevenueTap,
            ),
          ];

          if (isCompact) {
            final cardWidth = (constraints.maxWidth * 0.72)
                .clamp(186.0, 250.0)
                .toDouble();
            return SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: cardItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(width: cardWidth, child: cardItems[index]);
                },
              ),
            );
          }

          return Row(
            children: [
              for (int i = 0; i < cardItems.length; i++) ...[
                Expanded(child: cardItems[i]),
                if (i < cardItems.length - 1) const SizedBox(width: 12),
              ],
            ],
          );
        },
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                height: 132,
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String subtitle;
  final Color? subtitleColor;
  final bool isSmallScreen;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.subtitle,
    this.subtitleColor,
    required this.isSmallScreen,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Create gradient based on icon color
    final gradientColors = [
      iconColor.withOpacity(0.15),
      iconColor.withOpacity(0.05),
    ];

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: isSmallScreen ? 16 : 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      (subtitleColor ?? colorScheme.onSurface.withOpacity(0.6))
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 11,
                    color:
                        subtitleColor ?? colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
