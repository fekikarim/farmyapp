import 'package:flutter/material.dart';
import '../../models/subscription_plan.dart';

class CustomerSubscriptionsScreen extends StatelessWidget {
  const CustomerSubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = SubscriptionPlan.mockPlans;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Farmy Subscriptions'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Farmer Pro', icon: Icon(Icons.agriculture)),
              Tab(text: 'Investor Plus', icon: Icon(Icons.trending_up)),
              Tab(text: 'FarmBox', icon: Icon(Icons.shopping_basket)),
              Tab(text: 'Worker Plus', icon: Icon(Icons.work)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SubscriptionList(
              plans: plans
                  .where((p) => p.role == SubscriptionRole.farmer)
                  .toList(),
            ),
            _SubscriptionList(
              plans: plans
                  .where((p) => p.role == SubscriptionRole.investor)
                  .toList(),
            ),
            _SubscriptionList(
              plans: plans
                  .where((p) => p.role == SubscriptionRole.customer)
                  .toList(),
            ),
            _SubscriptionList(
              plans: plans
                  .where((p) => p.role == SubscriptionRole.worker)
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionList extends StatelessWidget {
  final List<SubscriptionPlan> plans;

  const _SubscriptionList({required this.plans});

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const Center(child: Text('No plans available for this role yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return SubscriptionPlanCard(plan: plans[index]);
      },
    );
  }
}

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;

  const SubscriptionPlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              plan.accentColor.withOpacity(0.05),
              plan.accentColor.withOpacity(0.2),
            ],
          ),
          border: Border.all(color: plan.accentColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: plan.accentColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            _buildFeatures(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: plan.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(plan.icon, color: plan.accentColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (plan.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: plan.accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          plan.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${plan.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'per ${plan.interval}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: plan.features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: plan.accentColor, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: ElevatedButton(
        onPressed: () {
          _showStaticUpgradeDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: plan.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Upgrade Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showStaticUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to ${plan.name}'),
        content: Text(
            'This is a static demonstration. In a production environment, this would initiate a Stripe/Hedera payment flow for \$${plan.price.toStringAsFixed(2)} per ${plan.interval}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
