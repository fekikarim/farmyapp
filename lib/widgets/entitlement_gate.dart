import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../screens/customer/subscriptions_screen.dart';

class EntitlementGate extends StatelessWidget {
  final String entitlementKey;
  final Widget child;
  final Widget? fallback;

  const EntitlementGate({
    super.key,
    required this.entitlementKey,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, _) {
        // While entitlements are still loading, show the child optimistically
        // to avoid flashing a "locked" state for users who actually have access.
        if (provider.isLoading || provider.isAnyLoading) {
          return child;
        }

        if (provider.hasEntitlement(entitlementKey)) {
          return child;
        }

        if (fallback != null) {
          return fallback!;
        }

        // Default fallback UI
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, color: Colors.amber, size: 32),
              const SizedBox(height: 8),
              Text(
                'Premium Feature',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Upgrade your subscription to unlock this feature.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionsScreen(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                child: const Text('Upgrade Now'),
              ),
            ],
          ),
        );
      },
    );
  }
}
