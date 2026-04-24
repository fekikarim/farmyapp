import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A widget that conditionally renders its [child] based on the user's
/// entitlements. If the feature is locked, it shows [lockedChild] or
/// a default lock overlay.
class FeatureGate extends StatelessWidget {
  /// The entitlement key to check (e.g., 'ai_crop_planner', 'premium_assets').
  final String featureKey;

  /// The child to render if the feature is unlocked.
  final Widget child;

  /// Optional widget to show when the feature is locked.
  /// If null, the child is hidden entirely.
  final Widget? lockedChild;

  /// If true, tapping the locked area opens an upgrade dialog.
  final bool showUpgradeOnTap;

  const FeatureGate({
    super.key,
    required this.featureKey,
    required this.child,
    this.lockedChild,
    this.showUpgradeOnTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subProvider, _) {
        // While entitlements are still loading, show the child optimistically
        // to avoid flashing a "locked" state for users who actually have access.
        if (subProvider.isLoading || subProvider.isAnyLoading) {
          return child;
        }

        final hasFeature = subProvider.hasEntitlement(featureKey);

        if (hasFeature) {
          return child;
        }

        // Feature is locked
        if (lockedChild != null) {
          return GestureDetector(
            onTap: showUpgradeOnTap
                ? () => _showUpgradeDialog(context, featureKey)
                : null,
            child: lockedChild!,
          );
        }

        // Default: hide entirely
        return const SizedBox.shrink();
      },
    );
  }

  static void _showUpgradeDialog(BuildContext context, String featureKey) {
    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(l10n.upgradeRequired),
            ],
          ),
          content: Text(l10n.upgradeRequiredDesc(featureKey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.laterButton),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed('/subscriptions');
              },
              child: Text(l10n.viewPlans),
            ),
          ],
        );
      },
    );
  }
}

/// A widget that conditionally renders its [child] based on the user's
/// numeric limit. If the limit is reached, it shows [lockedChild] or
/// a default lock overlay.
class LimitGate extends StatelessWidget {
  /// The limit key to check (e.g., 'land_limit', 'rental_limit').
  final String limitKey;

  /// The current usage count.
  final int currentCount;

  /// The child to render if within limits.
  final Widget child;

  /// Optional widget to show when the limit is reached.
  final Widget? lockedChild;

  const LimitGate({
    super.key,
    required this.limitKey,
    required this.currentCount,
    required this.child,
    this.lockedChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subProvider, _) {
        // While entitlements are still loading, allow access optimistically
        if (subProvider.isLoading || subProvider.isAnyLoading) {
          return child;
        }

        final limit = subProvider.getLimit(limitKey, 0);

        // -1 means unlimited
        if (limit == -1 || currentCount < limit) {
          return child;
        }

        // Limit reached
        if (lockedChild != null) {
          return lockedChild!;
        }

        return GestureDetector(
          onTap: () => FeatureGate._showUpgradeDialog(context, limitKey),
          child: Opacity(opacity: 0.5, child: AbsorbPointer(child: child)),
        );
      },
    );
  }
}
