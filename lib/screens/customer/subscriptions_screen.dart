import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/subscription_service.dart';
import 'package:shimmer/shimmer.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _selectedCycle = 'monthly';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role ?? 'customer';
    final theme = Theme.of(context);

    // Filter plans relevant to the user's role
    final plans = subProvider.availablePlans.where((p) {
      if (userRole == 'farmer') return p.role == SubscriptionRole.farmer;
      if (userRole == 'investor') return p.role == SubscriptionRole.investor;
      if (userRole == 'customer')
        return p.role == SubscriptionRole.customer ||
            p.role == SubscriptionRole.worker;
      return true;
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Farmy Premium',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
                child: const Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.stars, size: 200, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCycleToggle(),
                  const SizedBox(height: 24),
                  if (subProvider.isLoading)
                    _buildShimmerLoading()
                  else if (subProvider.error != null)
                    _buildErrorState(subProvider)
                  else if (plans.isEmpty)
                    _buildEmptyState()
                  else
                    RefreshIndicator(
                      onRefresh: () => subProvider.refresh(),
                      child: Column(
                        children: plans
                            .map((plan) => _buildPlanCard(plan, subProvider))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 32),
                  _buildFAQSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleToggle() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton('Monthly', 'monthly'),
          _toggleButton('Yearly (Save 33%)', 'yearly'),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, String cycle) {
    final isSelected = _selectedCycle == cycle;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _selectedCycle = cycle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, SubscriptionProvider provider) {
    final theme = Theme.of(context);
    final isCurrent = provider.currentSubscription?.plan.id == plan.id;
    final price = _selectedCycle == 'monthly'
        ? plan.price
        : (plan.price * 8).roundToDouble(); // Simplified yearly calc

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: isCurrent
            ? Border.all(color: plan.accentColor, width: 2)
            : Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: plan.accentColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(plan.icon, color: plan.accentColor, size: 32),
              if (plan.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: plan.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plan.badge!,
                    style: TextStyle(
                      color: plan.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            plan.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$$price',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: plan.accentColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  _selectedCycle == 'monthly' ? '/ month' : '/ year',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          ...plan.features
              .map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: plan.accentColor,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(f, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent || _isProcessing
                  ? null
                  : () => _handleSubscribe(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: plan.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(isCurrent ? 'Current Plan' : 'Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(SubscriptionPlan plan) async {
    setState(() => _isProcessing = true);
    try {
      // 1. Backend: Create Checkout Session (Payment Intent)
      final result = await SubscriptionService.subscribe(
        plan.id,
        _selectedCycle,
      );
      final paymentIntentId = result['paymentIntentId'];

      // 2. Stripe UI integration would go here normally.
      // For this implementation, we simulate successful payment:
      await Future.delayed(const Duration(seconds: 2));

      // 3. Confirm with Backend
      await SubscriptionService.confirmSubscription(
        plan.id,
        _selectedCycle,
        paymentIntentId,
      );

      if (mounted) {
        context.read<SubscriptionProvider>().refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully subscribed! Welcome to Premium.'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.inbox, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No premium plans available for your role at this time.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SubscriptionProvider provider) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to load subscriptions',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(
        3,
        (index) => Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[700]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'How does the renewal work?',
          'Subscriptions are manual. You will receive an in-app notification 3 days before expiry to renew.',
        ),
        _buildFAQItem(
          'Can I cancel anytime?',
          'Yes, you can cancel at any time. Your premium benefits will remain active until the end of your billing cycle.',
        ),
        _buildFAQItem(
          'Is my payment secure?',
          'We use Stripe for all transactions. Your payment information is encrypted and never stored on our servers.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
