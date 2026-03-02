import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

/// A beautiful, modern progress bar widget that shows the user's
/// current usage against their plan limit (e.g., "2/2 Rentals Used").
/// Includes an upgrade CTA when the limit is reached.
class SubscriptionLimitBar extends StatelessWidget {
  final String limitKey;
  final int currentCount;
  final String label;
  final IconData icon;
  final Color? accentColor;
  final String? upgradePlanName;

  const SubscriptionLimitBar({
    super.key,
    required this.limitKey,
    required this.currentCount,
    required this.label,
    this.icon = Icons.bar_chart_rounded,
    this.accentColor,
    this.upgradePlanName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subProvider, _) {
        // While entitlements are still loading, hide the bar to avoid
        // showing incorrect limits (default 0) before data arrives.
        if (subProvider.isLoading || subProvider.isAnyLoading) {
          return const SizedBox.shrink();
        }

        final limit = subProvider.getLimit(limitKey, 0);

        // -1 means unlimited — don't show bar
        if (limit == -1) return const SizedBox.shrink();

        final maxLimit = limit.toInt();
        final isAtLimit = currentCount >= maxLimit;
        final progress = maxLimit > 0
            ? (currentCount / maxLimit).clamp(0.0, 1.0)
            : 0.0;
        final color = accentColor ?? (isAtLimit ? Colors.amber : Colors.green);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAtLimit
                  ? color.withOpacity(0.3)
                  : (isDark ? Colors.white : Colors.black).withOpacity(0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subProvider.planName,
                          style: TextStyle(
                            color: isDark ? Colors.white30 : Colors.black38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isAtLimit
                          ? color.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isAtLimit
                          ? null
                          : Border.all(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.08),
                            ),
                    ),
                    child: Text(
                      '$currentCount / $maxLimit',
                      style: TextStyle(
                        color: isAtLimit
                            ? color
                            : (isDark ? Colors.white60 : Colors.black54),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isAtLimit ? color : color.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              // Upgrade CTA when at limit
              if (isAtLimit) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/subscriptions');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.rocket_launch_rounded,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Upgrade${upgradePlanName != null ? ' to $upgradePlanName' : ''} for unlimited access',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: color.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A compact inline upgrade banner shown when a specific limit is reached.
/// Use this inside bottom sheets / action areas to replace disabled buttons.
class UpgradeBanner extends StatelessWidget {
  final String message;
  final String? upgradePlanName;
  final Color accentColor;

  const UpgradeBanner({
    super.key,
    required this.message,
    this.upgradePlanName,
    this.accentColor = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/subscriptions'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withOpacity(0.15),
              accentColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to view plans →',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
