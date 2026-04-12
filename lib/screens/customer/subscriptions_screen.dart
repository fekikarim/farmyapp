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

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCycle = 'monthly';
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Loads all subscription data — plans + current subscription + worker profile.
  Future<void> _loadData() async {
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final subProvider = context.read<SubscriptionProvider>();
    final userRole = authProvider.user?.role ?? 'customer';

    // Load worker profile for customers (needed for worker plan filtering)
    if (userRole == 'customer') {
      context.read<WorkerProvider>().loadMyProfile();
    }

    // Full refresh to ensure fresh data from backend
    await subProvider.fullRefresh(role: userRole);

    if (mounted) {
      _animationController.forward(from: 0);
    }
  }

  /// Pull-to-refresh handler.
  Future<void> _onRefresh() async {
    final authProvider = context.read<AuthProvider>();
    final subProvider = context.read<SubscriptionProvider>();
    final userRole = authProvider.user?.role ?? 'customer';

    if (userRole == 'customer') {
      context.read<WorkerProvider>().loadMyProfile();
    }

    await subProvider.fullRefresh(role: userRole);

    if (mounted) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final workerProvider = Provider.of<WorkerProvider>(context);
    final userRole = authProvider.user?.role ?? 'customer';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

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

    // Determine overall loading state
    final isInitialLoading =
        (subProvider.isLoading || subProvider.isAnyLoading) &&
        subProvider.availablePlans.isEmpty;
    final isWorkerLoading =
        userRole == 'customer' &&
        workerProvider.profileLoading &&
        subProvider.availablePlans.isEmpty;

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
            displacement: 60,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  stretch: true,
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
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: Opacity(
                              opacity: 0.08,
                              child: Icon(
                                Icons.stars,
                                size: 200,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Current plan indicator in header
                          if (subProvider.currentSubscription != null)
                            Positioned(
                              bottom: 56,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Current: ${subProvider.currentSubscription!.plan.name}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? 40 : 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Billing cycle toggle
                        _buildCycleToggle(),
                        const SizedBox(height: 24),

                        // Content area with state handling
                        if (isInitialLoading || isWorkerLoading)
                          _buildShimmerLoading(isDark)
                        else if (subProvider.error != null &&
                            subProvider.availablePlans.isEmpty)
                          _buildErrorState(
                            title: 'Failed to load subscriptions',
                            message: _friendlyErrorMessage(subProvider.error!),
                            onRetry: _loadData,
                            isNetwork:
                                subProvider.error!.contains('internet') ||
                                subProvider.error!.contains('timed out'),
                          )
                        else if (userRole == 'customer' &&
                            workerProvider.profileError != null &&
                            subProvider.availablePlans.isEmpty)
                          _buildErrorState(
                            title: 'Failed to load worker profile',
                            message: _friendlyErrorMessage(
                              workerProvider.profileError!,
                            ),
                            onRetry: () => workerProvider.loadMyProfile(),
                          )
                        else if (filteredPlans.isEmpty)
                          _buildEmptyState()
                        else ...[
                          // Stale data banner
                          if (subProvider.plansError != null ||
                              subProvider.subscriptionError != null)
                            _buildStaleBanner(theme),

                          // Plan cards with staggered animation
                          ...List.generate(filteredPlans.length, (index) {
                            final interval = Interval(
                              (index * 0.15).clamp(0.0, 0.7),
                              ((index * 0.15) + 0.4).clamp(0.3, 1.0),
                              curve: Curves.easeOutCubic,
                            );
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                final value = interval.transform(
                                  _animationController.value,
                                );
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildPlanCard(
                                filteredPlans[index],
                                subProvider,
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 32),
                        _buildFAQSection(),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Cycle Toggle ──────────────────────────────────────────────────

  Widget _buildCycleToggle() {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toggleButton('Monthly', 'monthly'),
            _toggleButton('Yearly (Save 33%)', 'yearly'),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String text, String cycle) {
    final isSelected = _selectedCycle == cycle;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _selectedCycle = cycle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ─── Plan Card ─────────────────────────────────────────────────────

  Widget _buildPlanCard(SubscriptionPlan plan, SubscriptionProvider provider) {
    final theme = Theme.of(context);
    final currentSub = provider.currentSubscription;
    final isSamePlanFamily = currentSub?.plan.planKey == plan.planKey;
    final isCurrentCycle =
        isSamePlanFamily &&
        (plan.isFree || currentSub?.billingCycle == _selectedCycle);
    final isCurrent = isCurrentCycle;

    final price = _selectedCycle == 'monthly' ? plan.price : plan.priceYearly;

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
            color: plan.accentColor.withOpacity(isCurrent ? 0.1 : 0.05),
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
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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

  // ─── Subscribe Flow ────────────────────────────────────────────────

  void _handleSubscribe(SubscriptionPlan plan) {
    if (_isProcessing) return;
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
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(sheetContext).padding.bottom + 24,
            ),
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
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
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

  // ─── Processing ────────────────────────────────────────────────────

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
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isDowngrade
                        ? 'Successfully downgraded to ${plan.name}.'
                        : 'Successfully upgraded! Welcome to ${plan.name}.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on SubscriptionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: e.isNetworkError ? Colors.orange : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: e.isRetryable
                ? SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () =>
                        _processCreditUpgrade(plan, isDowngrade: isDowngrade),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_friendlyErrorMessage(e.toString())}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _processStripeUpgrade(SubscriptionPlan plan) async {
    setState(() => _isProcessing = true);
    try {
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
        throw const SubscriptionException(
          'Invalid payment data received from server. Please try again.',
          code: 'invalid_response',
          statusCode: 500,
        );
      }

      Stripe.publishableKey = publishableKey;
      Stripe.urlScheme = 'farmyapp';
      await Stripe.instance.applySettings();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Farmy',
          returnURL: 'farmyapp://stripe-redirect',
          allowsDelayedPaymentMethods: true,
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
            address: AddressCollectionMode.full,
          ),
          applePay: null,
          googlePay: null,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Payment succeeded — confirm with backend
      final paymentIntentId = intentData['paymentIntentId'];
      await SubscriptionService.confirmStripePayment(paymentIntentId);

      // Refresh subscription state
      await context.read<SubscriptionProvider>().refresh();
      await context.read<AuthProvider>().refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment Successful! Your subscription is now active.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on StripeException catch (e) {
      if (mounted) {
        final message = e.error.localizedMessage ?? 'Payment cancelled';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on SubscriptionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment Error: ${_friendlyErrorMessage(e.toString())}',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ─── UI States ─────────────────────────────────────────────────────

  /// Banner shown when displaying stale/cached data after a refresh error.
  Widget _buildStaleBanner(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Showing cached data. Pull down to refresh.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ),
          InkWell(
            onTap: _onRefresh,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.refresh, color: Colors.orange, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No premium plans available for your role at this time.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Check Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String title,
    required String message,
    required VoidCallback onRetry,
    bool isNetwork = false,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isNetwork ? Colors.orange : theme.colorScheme.error)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetwork ? Icons.wifi_off_rounded : Icons.error_outline,
                size: 48,
                color: isNetwork ? Colors.orange : theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (index) => Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 150,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  ...List.generate(
                    3,
                    (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── FAQ ───────────────────────────────────────────────────────────

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

  // ─── Helpers ───────────────────────────────────────────────────────

  /// Makes raw exception messages more user-friendly.
  String _friendlyErrorMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') || lower.contains('no internet')) {
      return 'No internet connection. Please check your network.';
    }
    if (lower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }
    // Strip 'Exception: ' prefix
    if (raw.startsWith('Exception: ')) {
      return raw.substring(11);
    }
    return raw;
  }
}
