import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/worker_provider.dart';
import 'subscriptions_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _motivationalQuote = "";


  @override
  void initState() {
    super.initState();

    // Proactively load worker profile for customers to check verification status
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final List<String> quotes = [
      l10n.quote1,
      l10n.quote2,
      l10n.quote3,
      l10n.quote4,
      l10n.quote5,
      l10n.quote6,
      l10n.quote7,
      l10n.quote8,
    ];

    if (_motivationalQuote.isEmpty) {
      _motivationalQuote = quotes[Random().nextInt(quotes.length)];
    }

    // Get time of day for greeting
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = l10n.goodMorning;
    } else if (hour < 17) {
      greeting = l10n.goodAfternoon;
    } else {
      greeting = l10n.goodEvening;
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.name ?? user?.email?.split('@')[0] ?? l10n.user,
                          style: theme.textTheme.headlineMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: user?.profilePicture != null
                        ? NetworkImage(user!.profilePicture!)
                        : null,
                    child: user?.profilePicture == null
                        ? Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                            size: 28,
                          )
                        : null,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // User Role Badge (Optional but nice)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.customerAccount,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Motivational Quote Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _motivationalQuote,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        ' ${l10n.dailyInspiration}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // TODO: Add more sections here (Quick Actions, Recent Activity, etc.)

              // Worker Plus Section for Approved Workers
              Consumer2<WorkerProvider, SubscriptionProvider>(
                builder: (context, workerProvider, subProvider, _) {
                  final workerProfile = workerProvider.myProfile;
                  // Only show Worker Plus for VERIFIED workers who don't have it yet
                  final isVerifiedWorker =
                      workerProfile != null && workerProfile.isVerified;
                  final hasWorkerPlus =
                      subProvider.currentSubscription?.plan.planKey ==
                      'worker_plus';

                  if (!isVerifiedWorker || hasWorkerPlus) {
                    return const SizedBox.shrink();
                  }

                  return _buildUpgradeCard(
                    context,
                    title: l10n.workerPlus,
                    description: l10n.workerPlusDescription,
                    color: Colors.purple,
                    icon: Icons.work_history,
                    price: '\$4.99',
                  );
                },
              ),

              // FarmBox Section for All Customers
              Consumer<SubscriptionProvider>(
                builder: (context, subProvider, _) {
                  final hasFarmBox = subProvider.hasFeature('farmbox_active');
                  if (hasFarmBox) return const SizedBox.shrink();

                  return _buildUpgradeCard(
                    context,
                    title: l10n.farmboxSubscription,
                    description: l10n.farmboxDescription,
                    color: Colors.orange.shade700,
                    icon: Icons.local_shipping_rounded,
                    price: 'From \$29.99',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required String price,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.upgradeWithPrice(price),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
