import 'package:flutter/material.dart';
import '../../models/subscription_plan.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final SubscriptionPlan plan;

  const SubscriptionDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceSection(context),
                  const SizedBox(height: 32),
                  const Text(
                    'What\'s Included',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...plan.extendedFeatures.map((feature) => _buildFeatureItem(feature)),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: plan.accentColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          plan.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                plan.accentColor,
                plan.accentColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              plan.icon,
              size: 100,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: plan.accentColor.withOpacity(isDark ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.accentColor.withOpacity(isDark ? 0.3 : 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plan Price',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${plan.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: plan.accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Per ${plan.interval.toUpperCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, color: plan.accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            offset: const Offset(0, -5),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _showUpgradeConfirmation(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: plan.accentColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Confirm Upgrade - \$${plan.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showUpgradeConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Subscription'),
        content: Text('Would you like to subscribe to ${plan.name} for \$${plan.price.toStringAsFixed(2)}/${plan.interval}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully subscribed to ${plan.name}!'),
                  backgroundColor: plan.accentColor,
                ),
              );
              Navigator.pop(context); // Back to list
            },
            style: ElevatedButton.styleFrom(backgroundColor: plan.accentColor),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
