import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/subscription_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _selectedCycle = 'monthly';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user?.role == 'customer') {
        context.read<WorkerProvider>().loadMyProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final workerProvider = Provider.of<WorkerProvider>(context);
    final userRole = authProvider.user?.role ?? 'customer';
    final theme = Theme.of(context);

    // Filter plans relevant to the user's role
    final filteredPlans = subProvider.availablePlans.where((p) {
      if (userRole == 'farmer') return p.role == SubscriptionRole.farmer;
      if (userRole == 'investor') return p.role == SubscriptionRole.investor;
      if (userRole == 'customer') {
        if (p.planKey.startsWith('worker_')) {
          final workerProfile = workerProvider.myProfile;
          return workerProfile != null && workerProfile.isVerified;
        }
        return p.role == SubscriptionRole.customer ||
            p.role == SubscriptionRole.worker;
      }
      return true;
    }).toList();

    // Sort: current plan first, then paid plans, then free plans
    final currentPlanKey = subProvider.currentSubscription?.plan.planKey;
    filteredPlans.sort((a, b) {
      if (a.planKey == currentPlanKey && b.planKey != currentPlanKey) return -1;
      if (b.planKey == currentPlanKey && a.planKey != currentPlanKey) return 1;
      if (a.isFree && !b.isFree) return 1;
      if (!a.isFree && b.isFree) return -1;
      return 0;
    });

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
                  if (subProvider.isLoading ||
                      (userRole == 'customer' && workerProvider.profileLoading))
                    _buildShimmerLoading()
                  else if (subProvider.error != null)
                    _buildErrorState(
                      title: 'Failed to load subscriptions',
                      message: subProvider.error!,
                      onRetry: () => subProvider.refresh(),
                    )
                  else if (userRole == 'customer' &&
                      workerProvider.profileError != null)
                    _buildErrorState(
                      title: 'Failed to load worker profile',
                      message: workerProvider.profileError!,
                      onRetry: () => workerProvider.loadMyProfile(),
                    )
                  else if (filteredPlans.isEmpty)
                    _buildEmptyState()
                  else
                    Column(
                      children: filteredPlans
                          .map((plan) => _buildPlanCard(plan, subProvider))
                          .toList(),
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
    final currentSub = provider.currentSubscription;
    final isSamePlanFamily = currentSub?.plan.planKey == plan.planKey;
    final isCurrentCycle =
        isSamePlanFamily &&
        (plan.isFree || currentSub?.billingCycle == _selectedCycle);
    final isCurrent = isCurrentCycle;

    // Dynamic pricing from backend
    final price = _selectedCycle == 'monthly' ? plan.price : plan.priceYearly;

    // Determine button text
    String buttonText;
    if (isSamePlanFamily) {
      if (isCurrentCycle) {
        buttonText = 'Current Plan';
      } else if (_selectedCycle == 'yearly') {
        buttonText = 'Upgrade to Yearly';
      } else {
        buttonText = 'Switch to Monthly';
      }
    } else if (plan.isFree) {
      buttonText = 'Downgrade to Free';
    } else {
      buttonText = 'Get Started';
    }

    final isButtonDisabled = isCurrent || _isProcessing;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: isCurrentCycle
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
              Row(
                children: [
                  if (isCurrentCycle)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    )
                  else if (isSamePlanFamily)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active on ${currentSub?.billingCycle ?? 'monthly'}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
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
                plan.isFree ? 'Free' : '\$${price.toStringAsFixed(2)}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: plan.accentColor,
                ),
              ),
              if (!plan.isFree)
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
            child: plan.isFree && !isSamePlanFamily
                ? OutlinedButton(
                    onPressed: isButtonDisabled
                        ? null
                        : () => _handleSubscribe(plan),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(buttonText),
                  )
                : ElevatedButton(
                    onPressed: isButtonDisabled
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
                        : Text(buttonText),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleSubscribe(SubscriptionPlan plan) {
    if (plan.isFree) {
      _showDowngradeConfirmation(plan);
    } else {
      _showPaymentBottomSheet(plan);
    }
  }

  void _showDowngradeConfirmation(SubscriptionPlan plan) {
    final theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Confirm Downgrade',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Are you sure you want to downgrade to ${plan.name}? You will lose your premium features and active perks associated with your current plan.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _processCreditUpgrade(plan, isDowngrade: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Downgrade'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  void _showPaymentBottomSheet(SubscriptionPlan plan) {
    final price = _selectedCycle == 'monthly' ? plan.price : plan.priceYearly;

    // Fetch fresh wallet balance when sheet opens
    context.read<WalletProvider>().fetchWalletStatus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Consumer<WalletProvider>(
        builder: (ctx, walletProvider, _) {
          final credits = walletProvider.credits;
          final isSufficient = credits >= price;
          final isWalletLoading = walletProvider.isLoading;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(sheetContext).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Select Payment Method',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: \$${price.toStringAsFixed(2)} · ${_selectedCycle == 'monthly' ? 'Monthly' : 'Yearly'}',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildPaymentOption(
                  icon: Icons.monetization_on,
                  title: 'Pay with Farmy Credits',
                  subtitle: isWalletLoading
                      ? 'Loading balance...'
                      : 'Balance: \$${credits.toStringAsFixed(2)}',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (isSufficient) {
                      _processCreditUpgrade(plan);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Insufficient Credits (\$${credits.toStringAsFixed(2)}). Need \$${price.toStringAsFixed(2)}.',
                          ),
                          backgroundColor: Colors.red.shade400,
                        ),
                      );
                    }
                  },
                  isSufficient: !isWalletLoading && isSufficient,
                  isLoading: isWalletLoading,
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  icon: Icons.credit_card,
                  title: 'Pay with Card (Stripe)',
                  subtitle: 'Secure credit card payment',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _processStripeUpgrade(plan);
                  },
                  isSufficient: true,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isSufficient,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: isSufficient ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
          color: isSufficient
              ? Colors.transparent
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSufficient ? theme.colorScheme.primary : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSufficient ? null : Colors.grey,
                    ),
                  ),
                  if (isLoading)
                    Row(
                      children: [
                        SizedBox(
                          height: 12,
                          width: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSufficient ? Colors.grey : Colors.red,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _processCreditUpgrade(
    SubscriptionPlan plan, {
    bool isDowngrade = false,
  }) async {
    setState(() => _isProcessing = true);
    try {
      await context.read<SubscriptionProvider>().upgradeWithCredits(
        plan.planKey,
        _selectedCycle,
      );
      await context.read<AuthProvider>().refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDowngrade
                  ? 'Successfully downgraded to ${plan.name}.'
                  : 'Successfully upgraded with credits! Welcome to Premium.',
            ),
          ),
        );
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

  Future<void> _processStripeUpgrade(SubscriptionPlan plan) async {
    setState(() => _isProcessing = true);
    try {
      // 1. Create PaymentIntent on backend (returns clientSecret, ephemeralKey, customer, publishableKey)
      final intentData = await SubscriptionService.createStripePaymentIntent(
        plan.planKey,
        _selectedCycle,
      );

      final clientSecret = intentData['clientSecret'];
      final ephemeralKey = intentData['ephemeralKey'];
      final customerId = intentData['customer'];
      final publishableKey = intentData['publishableKey'];

      if (clientSecret == null ||
          ephemeralKey == null ||
          customerId == null ||
          publishableKey == null) {
        throw Exception('Invalid payment data received from server');
      }

      // 2. Set the publishable key
      Stripe.publishableKey = publishableKey;

      // 3. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Farmy',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.system,
        ),
      );

      // 4. Present Payment Sheet (user enters card details here)
      await Stripe.instance.presentPaymentSheet();

      // 5. Payment succeeded! Confirm with backend to activate the subscription immediately.
      final paymentIntentId = intentData['paymentIntentId'];
      await SubscriptionService.confirmStripePayment(paymentIntentId);

      // 6. Refresh subscription state to reflect the activated subscription.
      await context.read<SubscriptionProvider>().refresh();
      await context.read<AuthProvider>().refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment Successful! Your subscription is now active.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on StripeException catch (e) {
      // User cancelled or Stripe error
      if (mounted) {
        final message = e.error.localizedMessage ?? 'Payment cancelled';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

  Widget _buildErrorState({
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
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
