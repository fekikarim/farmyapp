import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/worker_provider.dart';
import '../../services/subscription_service.dart';
import '../../theme/app_theme.dart';

/// Mandatory Pricing Screen — shown when user has no subscription history.
/// User CANNOT leave without selecting a plan.
class MandatoryPricingScreen extends StatefulWidget {
  const MandatoryPricingScreen({super.key});

  @override
  State<MandatoryPricingScreen> createState() => _MandatoryPricingScreenState();
}

class _MandatoryPricingScreenState extends State<MandatoryPricingScreen>
    with TickerProviderStateMixin {
  String _selectedCycle = 'monthly';
  bool _isProcessing = false;
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _headerController.forward();
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _cardsController.forward();
      });

      // Load plans if not already loaded (with role context)
      final subProvider = context.read<SubscriptionProvider>();
      final authProvider = context.read<AuthProvider>();
      final userRole = authProvider.user?.role;

      subProvider.init(role: userRole);

      // Load worker profile if customer (to check worker plan eligibility)
      if (userRole == 'customer') {
        context.read<WorkerProvider>().loadMyProfile();
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  List<SubscriptionPlan> _getFilteredPlans(
    List<SubscriptionPlan> plans,
    String? userRole,
    WorkerProvider workerProvider,
  ) {
    // Role mapping: convert string role to SubscriptionRole enum for strict check
    final SubscriptionRole? currentRole = _parseRole(userRole);

    return plans.where((p) {
      // 1. If we are a customer, we can see CUSTOMER plans OR WORKER plans (if verified)
      if (userRole == 'customer') {
        if (p.planKey.startsWith('worker_')) {
          final profile = workerProvider.myProfile;
          return profile != null && profile.isVerified;
        }
        return p.role == SubscriptionRole.customer ||
            p.role == SubscriptionRole.worker;
      }

      // 2. For all other roles (Farmer, Investor), match strictly
      // This ensures we ONLY see our own role's free/paid plans
      return p.role == currentRole;
    }).toList()..sort((a, b) {
      // Free plans first, paid plans last
      if (a.isFree && !b.isFree) return -1;
      if (!a.isFree && b.isFree) return 1;
      // Within paid: sort by price ascending
      final priceA = _selectedCycle == 'monthly' ? a.price : a.priceYearly;
      final priceB = _selectedCycle == 'monthly' ? b.price : b.priceYearly;
      return priceA.compareTo(priceB);
    });
  }

  SubscriptionRole? _parseRole(String? roleName) {
    if (roleName == null) return null;
    switch (roleName.toLowerCase()) {
      case 'farmer':
        return SubscriptionRole.farmer;
      case 'investor':
        return SubscriptionRole.investor;
      case 'worker':
        return SubscriptionRole.worker;
      case 'customer':
        return SubscriptionRole.customer;
      default:
        return null;
    }
  }

  Future<void> _handleSelectPlan(SubscriptionPlan plan) async {
    if (plan.isFree) {
      await _processFreeOrCreditPlan(plan, isFree: true);
    } else {
      _showPaymentBottomSheet(plan);
    }
  }

  Future<void> _processFreeOrCreditPlan(
    SubscriptionPlan plan, {
    bool isFree = false,
  }) async {
    setState(() => _isProcessing = true);
    try {
      await context.read<SubscriptionProvider>().upgradeWithCredits(
        plan.planKey,
        _selectedCycle,
      );
      context.read<SubscriptionProvider>().markSubscribed();
      await context.read<AuthProvider>().refreshUser();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnack(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPaymentBottomSheet(SubscriptionPlan plan) {
    final price = _selectedCycle == 'monthly' ? plan.price : plan.priceYearly;
    context.read<WalletProvider>().fetchWalletStatus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Consumer<WalletProvider>(
        builder: (ctx, wallet, _) {
          final credits = wallet.credits;
          final isSufficient = credits >= price;

          return _PaymentSheet(
            plan: plan,
            price: price,
            cycle: _selectedCycle,
            credits: credits,
            isSufficient: isSufficient,
            isWalletLoading: wallet.isLoading,
            onPayWithCredits: () async {
              Navigator.pop(sheetCtx);
              if (isSufficient) {
                await _processFreeOrCreditPlan(plan);
              } else {
                _showErrorSnack(
                  'Insufficient Credits (\$${credits.toStringAsFixed(2)}). Need \$${price.toStringAsFixed(2)}.',
                );
              }
            },
            onPayWithStripe: () async {
              Navigator.pop(sheetCtx);
              await _processStripeUpgrade(plan);
            },
          );
        },
      ),
    );
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

      if (clientSecret == null || ephemeralKey == null || customerId == null) {
        throw Exception('Invalid payment data received from server');
      }

      Stripe.publishableKey = publishableKey ?? '';

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

      await Stripe.instance.presentPaymentSheet();

      // Confirm with backend
      final paymentIntentId = intentData['paymentIntentId'];
      await SubscriptionService.confirmStripePayment(paymentIntentId);

      // Update state & redirect
      await context.read<SubscriptionProvider>().refresh();
      context.read<SubscriptionProvider>().markSubscribed();
      await context.read<AuthProvider>().refreshUser();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } on StripeException catch (e) {
      if (mounted) {
        _showErrorSnack(e.error.localizedMessage ?? 'Payment cancelled');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnack(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final workerProvider = Provider.of<WorkerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userRole = authProvider.user?.role ?? 'customer';

    final filteredPlans = _getFilteredPlans(
      subProvider.availablePlans,
      userRole,
      workerProvider,
    );

    return PopScope(
      canPop: false, // Prevent back navigation
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              // Ambient background orbs
              _BackgroundOrbs(isDark: isDark),

              // Main content
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        // Animated header
                        FadeTransition(
                          opacity: _headerFade,
                          child: SlideTransition(
                            position: _headerSlide,
                            child: _Header(isDark: isDark),
                          ),
                        ),

                        // Billing toggle
                        FadeTransition(
                          opacity: _headerFade,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: _BillingToggle(
                              selected: _selectedCycle,
                              onChanged: (val) =>
                                  setState(() => _selectedCycle = val),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Plans list
                        Expanded(
                          child: subProvider.isLoading
                              ? _ShimmerLoading(isDark: isDark)
                              : subProvider.error != null
                              ? _ErrorState(
                                  message: subProvider.error!,
                                  onRetry: () =>
                                      subProvider.fetchPlans(role: userRole),
                                )
                              : filteredPlans.isEmpty
                              ? const _EmptyState()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    32,
                                  ),
                                  itemCount: filteredPlans.length,
                                  itemBuilder: (context, i) {
                                    return _AnimatedPlanCard(
                                      plan: filteredPlans[i],
                                      cycle: _selectedCycle,
                                      index: i,
                                      controller: _cardsController,
                                      isProcessing: _isProcessing,
                                      onSelect: () =>
                                          _handleSelectPlan(filteredPlans[i]),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Full-screen processing overlay
              if (_isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Background Ambient Orbs
// ─────────────────────────────────────────────

class _BackgroundOrbs extends StatelessWidget {
  final bool isDark;
  const _BackgroundOrbs({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: _Orb(
            size: 280,
            color: AppTheme.primaryColor.withOpacity(isDark ? 0.12 : 0.08),
          ),
        ),
        Positioned(
          bottom: 40,
          left: -60,
          child: _Orb(
            size: 220,
            color: AppTheme.secondaryColor.withOpacity(isDark ? 0.1 : 0.07),
          ),
        ),
        Positioned(
          top: 200,
          left: -40,
          child: _Orb(
            size: 140,
            color: Colors.amber.withOpacity(isDark ? 0.06 : 0.05),
          ),
        ),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header Section
// ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Column(
        children: [
          // Logo + lock badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo-no-bg.png', height: 36),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Premium Access',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ).createShader(bounds),
            child: const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a plan to unlock the full Farmy experience.\nOne subscription opens every door.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Billing Toggle
// ─────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _BillingToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: 'Monthly',
            isSelected: selected == 'monthly',
            onTap: () => onChanged('monthly'),
          ),
          _ToggleButton(
            label: 'Yearly',
            badge: '−33%',
            isSelected: selected == 'yearly',
            onTap: () => onChanged('yearly'),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;
  const _ToggleButton({
    required this.label,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                )
              : null,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : AppTheme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Animated Plan Card
// ─────────────────────────────────────────────

class _AnimatedPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String cycle;
  final int index;
  final AnimationController controller;
  final bool isProcessing;
  final VoidCallback onSelect;

  const _AnimatedPlanCard({
    required this.plan,
    required this.cycle,
    required this.index,
    required this.controller,
    required this.isProcessing,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Staggered entrance animation per card
    final delay = index * 0.12;
    final begin = delay.clamp(0.0, 0.8);
    final end = (begin + 0.5).clamp(0.0, 1.0);

    final slide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(begin, end, curve: Curves.easeOutCubic),
          ),
        );

    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: _PlanCard(
          plan: plan,
          cycle: cycle,
          isProcessing: isProcessing,
          onSelect: onSelect,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Plan Card
// ─────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String cycle;
  final bool isProcessing;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.cycle,
    required this.isProcessing,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final price = cycle == 'monthly' ? plan.price : plan.priceYearly;
    final isRecommended = plan.badge == 'Popular';
    final isPremium = plan.badge == 'Premium';
    final accentColor = plan.accentColor;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isRecommended || isPremium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(isDark ? 0.18 : 0.1),
                  accentColor.withOpacity(isDark ? 0.06 : 0.03),
                ],
              )
            : null,
        color: isRecommended || isPremium ? null : theme.colorScheme.surface,
        border: Border.all(
          color: isRecommended || isPremium
              ? accentColor.withOpacity(0.5)
              : (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isRecommended ? 0.15 : 0.05),
            blurRadius: isRecommended ? 24 : 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(plan.icon, color: accentColor, size: 22),
                ),
                Row(
                  children: [
                    if (plan.badge != null)
                      _Badge(
                        label: plan.badge!,
                        color: isRecommended ? Colors.orange : accentColor,
                      ),
                    if (plan.isFree)
                      _Badge(label: 'Always Free', color: Colors.teal),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Plan name
            Text(
              plan.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              plan.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Pricing
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.isFree ? 'Free' : '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: plan.isFree ? 30 : 36,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    letterSpacing: -1,
                  ),
                ),
                if (!plan.isFree) ...[
                  const SizedBox(width: 4),
                  Text(
                    cycle == 'monthly' ? '/mo' : '/yr',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),

            if (!plan.isFree && cycle == 'yearly' && plan.price > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Was \$${(plan.price * 12).toStringAsFixed(2)}/yr — save \$${((plan.price * 12) - plan.priceYearly).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 16),
            Divider(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
            ),
            const SizedBox(height: 12),

            // Features
            ...plan.features
                .take(5)
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: accentColor,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            f,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            const SizedBox(height: 20),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: plan.isFree
                  ? OutlinedButton(
                      onPressed: isProcessing ? null : onSelect,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(color: accentColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: accentColor,
                      ),
                      child: Text(
                        'Continue with Free',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: isProcessing ? null : onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Get ${plan.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Payment Bottom Sheet
// ─────────────────────────────────────────────

class _PaymentSheet extends StatelessWidget {
  final SubscriptionPlan plan;
  final double price;
  final String cycle;
  final double credits;
  final bool isSufficient;
  final bool isWalletLoading;
  final VoidCallback onPayWithCredits;
  final VoidCallback onPayWithStripe;

  const _PaymentSheet({
    required this.plan,
    required this.price,
    required this.cycle,
    required this.credits,
    required this.isSufficient,
    required this.isWalletLoading,
    required this.onPayWithCredits,
    required this.onPayWithStripe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Select Payment Method',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '\$${price.toStringAsFixed(2)} · ${cycle == 'monthly' ? 'Monthly' : 'Yearly'} · ${plan.name}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Farmy Credits option
              _PaymentOptionTile(
                icon: Icons.monetization_on_rounded,
                title: 'Pay with Farmy Credits',
                subtitle: isWalletLoading
                    ? 'Loading balance...'
                    : isSufficient
                    ? 'Balance: \$${credits.toStringAsFixed(2)} ✓'
                    : 'Balance: \$${credits.toStringAsFixed(2)} — Insufficient',
                isSufficient: !isWalletLoading && isSufficient,
                isLoading: isWalletLoading,
                onTap: onPayWithCredits,
              ),
              const SizedBox(height: 12),

              // Stripe option
              _PaymentOptionTile(
                icon: Icons.credit_card_rounded,
                title: 'Pay with Card (Stripe)',
                subtitle: 'Secure credit / debit card payment',
                isSufficient: true,
                onTap: onPayWithStripe,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSufficient;
  final bool isLoading;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSufficient,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: isSufficient ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSufficient
                ? theme.colorScheme.primary.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSufficient
              ? Colors.transparent
              : Colors.grey.withOpacity(0.04),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSufficient ? theme.colorScheme.primary : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSufficient ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (isLoading)
                    Row(
                      children: [
                        SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSufficient ? Colors.grey : Colors.red.shade400,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Loading / Error / Empty States
// ─────────────────────────────────────────────

class _ShimmerLoading extends StatefulWidget {
  final bool isDark;
  const _ShimmerLoading({required this.isDark});

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (_, __) {
          final base = widget.isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.04);
          final highlight = widget.isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08);
          final shimColor = Color.lerp(base, highlight, _shimmer.value)!;
          return Column(
            children: List.generate(2, (i) => _ShimmerCard(color: shimColor)),
          );
        },
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Color color;
  const _ShimmerCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 240,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Failed to load plans',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subscriptions_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No plans available',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Please contact support.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
