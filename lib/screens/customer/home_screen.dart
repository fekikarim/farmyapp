import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:farmyapp/l10n/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/worker_provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../providers/worker_wallet_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../models/product_model.dart';
import '../../models/delivery_model.dart';
import 'track_order_screen.dart';

import 'subscriptions_screen.dart';
import 'marketplace_screen.dart';
import 'product_detail_screen.dart';
import 'become_worker_screen.dart';
import '../worker/wallet/worker_wallet_screen.dart';
import '../worker/wallet/withdrawal_screen.dart';
import '../worker/wallet/earnings_history_screen.dart';
import '../worker/wallet/transaction_history_screen.dart';
import '../main_screen.dart';
import '../settings/edit_profile_screen.dart';
import '../../models/task_model.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      if (authProvider.user?.role == 'customer') {
        final workerProvider = context.read<WorkerProvider>();
        workerProvider.loadMyProfile().then((_) {
          if (workerProvider.isVerifiedWorker) {
            context.read<WorkerLifecycleProvider>().refreshWorkerDashboardLifecycle();
            context.read<WorkerWalletProvider>().fetchOverview();
            workerProvider.loadMyTasks();
          } else {
            // Customer fetches
            context.read<ProductProvider>().fetchProducts();
            context.read<WalletProvider>().fetchWalletStatus();
            context.read<DeliveryProvider>().fetchMyDeliveries(role: 'buyer');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final isVerifiedWorker = workerProvider.isVerifiedWorker;

    if (workerProvider.profileLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Loading dashboard...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (isVerifiedWorker) {
      return _buildWorkerHome(context);
    } else {
      return _buildCustomerHome(context);
    }
  }

  // ==========================================
  // WORKER HOME (Primary Experience)
  // ==========================================

  Widget _buildWorkerHome(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final workerProvider = context.watch<WorkerProvider>();
    final lifecycle = context.watch<WorkerLifecycleProvider>();
    final wallet = context.watch<WorkerWalletProvider>();

    final tasks = workerProvider.myTasks;
    final todayTasks = tasks.where((t) => !t.isCompleted && !t.isVerified).toList();
    final pendingBalance = double.tryParse(lifecycle.myBalance['pending_balance']?.toString() ?? '0') ?? 0.0;
    final walletBalance = double.tryParse(wallet.overviewData?['balance']?.toString() ?? '0') ?? 0.0;
    final monthlyEarnings = double.tryParse(wallet.overviewData?['total_earnings']?.toString() ?? '0') ?? 0.0;

    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await workerProvider.loadMyProfile();
            if (workerProvider.isVerifiedWorker) {
              await context.read<WorkerLifecycleProvider>().refreshWorkerDashboardLifecycle();
              await context.read<WorkerWalletProvider>().fetchOverview();
              await workerProvider.loadMyTasks();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, ready to work?',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? user?.email ?? l10n.user,
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildProfileAvatar(context, user, theme),
                  ],
                ),
                const SizedBox(height: 24),

                // Hero Block (KPIs)
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        context,
                        title: 'Tasks Today',
                        value: '${todayTasks.length}',
                        icon: Icons.task_alt,
                        color: Colors.blue,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        context,
                        title: 'Monthly Earnings',
                        value: '\$${monthlyEarnings.toStringAsFixed(2)}',
                        icon: Icons.trending_up,
                        color: Colors.green,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: _buildKpiCard(
                    context,
                    title: 'Escrow Balance',
                    value: '\$${pendingBalance.toStringAsFixed(2)}',
                    icon: Icons.lock_outline,
                    color: Colors.purple,
                    isDark: isDark,
                    fullWidth: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Smart Alerts
                if (lifecycle.pendingInvitations.isNotEmpty || todayTasks.isNotEmpty) ...[
                  Text(
                    'Smart Alerts',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (lifecycle.pendingInvitations.isNotEmpty)
                    _buildAlertCard(
                      context,
                      title: 'New Invitation',
                      description: 'You have ${lifecycle.pendingInvitations.length} pending job invitation(s).',
                      icon: Icons.mail_outline,
                      color: Colors.orange,
                      onTap: () => MainScreen.trySwitchToTab(context, 1), // Find Jobs
                    ),
                  if (todayTasks.isNotEmpty)
                    _buildAlertCard(
                      context,
                      title: 'Tasks Pending',
                      description: 'You have ${todayTasks.length} tasks to complete today.',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                      onTap: () => MainScreen.trySwitchToTab(context, 2), // Tasks
                    ),
                  const SizedBox(height: 32),
                ],

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickActionCard(context, 'Wallet', Icons.account_balance_wallet, Colors.green, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerWalletScreen()));
                      }),
                      _buildQuickActionCard(context, 'Withdraw', Icons.attach_money, Colors.blue, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawalScreen()));
                      }),
                      _buildQuickActionCard(context, 'Earnings', Icons.insights, Colors.indigo, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EarningsHistoryScreen()));
                      }),
                      _buildQuickActionCard(context, 'History', Icons.history, Colors.blueGrey, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()));
                      }),
                      _buildQuickActionCard(context, 'Marketplace', Icons.storefront, Colors.orange, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerMarketplaceScreen()));
                      }),
                      _buildQuickActionCard(context, 'FarmBox', Icons.local_shipping, Colors.purple, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen()));
                      }),
                      _buildQuickActionCard(context, 'Profile', Icons.person, Colors.teal, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Earnings Wallet Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Available',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        '\$${walletBalance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawalScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Task List (Core Section)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Tasks',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => MainScreen.trySwitchToTab(context, 2),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (tasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No active tasks. Take a break or find new jobs!',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ),
                  )
                else
                  ...tasks.take(3).map((task) => _buildMiniTaskCard(context, task, isDark)).toList(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required bool isDark, bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, {required String title, required String description, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTaskCard(BuildContext context, FarmTask task, bool isDark) {
    Color statusColor = Colors.grey;
    if (task.isOpen) statusColor = Colors.blue;
    if (task.isInProgress) statusColor = Colors.orange;
    if (task.isCompleted || task.isVerified) statusColor = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(task.typeIcon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.monetization_on, size: 14, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text('\$${task.reward.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${task.timeRequiredMinutes}m', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.statusLabel,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String label, IconData icon, MaterialColor color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? color.shade900.withValues(alpha: 0.3) : color.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? color.shade900.withValues(alpha: 0.5) : color.shade100),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.05 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isDark ? 0 : 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 24, color: isDark ? color.shade200 : color.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              label, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : color.shade900),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CUSTOMER HOME (Fallback Experience)
  // ==========================================

  Widget _buildCustomerHome(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final productProvider = context.watch<ProductProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final deliveryProvider = context.watch<DeliveryProvider>();

    final credits = walletProvider.credits;
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final ordersThisMonth = deliveryProvider.myDeliveries.where((d) => d.createdAt.month == currentMonth && d.createdAt.year == currentYear).length;
    
    final activeDeliveries = deliveryProvider.myDeliveries.where((d) => !d.isTerminal).toList();
    final activeDelivery = activeDeliveries.isNotEmpty ? activeDeliveries.first : null;
    
    final latestProducts = productProvider.products.take(3).toList();

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
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<ProductProvider>().fetchProducts();
            await context.read<WalletProvider>().fetchWalletStatus();
            await context.read<DeliveryProvider>().fetchMyDeliveries(role: 'buyer');
          },
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          user?.name ?? user?.email ?? l10n.user,
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildProfileAvatar(context, user, theme),
                ],
              ),
                const SizedBox(height: 32),

                // User Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Orders this month',
                        value: '$ordersThisMonth',
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.blue.shade600,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        title: 'Credits Balance',
                        value: '\$${credits.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_outlined,
                        color: Colors.green.shade600,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

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

              const SizedBox(height: 32),

                // Your FarmBox — next delivery
                Text(
                  'Your FarmBox — next delivery',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildNextDeliveryCard(context, activeDelivery, isDark),
                const SizedBox(height: 32),

                // Fresh picks for you
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fresh picks for you',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => MainScreen.trySwitchToTab(context, 1),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (latestProducts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No fresh picks right now.',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: latestProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (ctx, idx) => _buildProductCard(context, latestProducts[idx], isDark),
                    ),
                  ),

                const SizedBox(height: 32),

              Text(
                'Explore Farmy',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Marketplace Access
              _buildUpgradeCard(
                context,
                title: 'Marketplace',
                description: 'Discover fresh, organic products directly from our trusted farmers.',
                color: Colors.green.shade600,
                icon: Icons.storefront,
                price: 'Shop Now',
                onTap: () => MainScreen.trySwitchToTab(context, 1),
              ),

              // FarmBox Section
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
                    price: l10n.upgradeWithPrice('From \$29.99'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
                    ),
                  );
                },
              ),

              // Worker Entry Point
              Consumer<WorkerProvider>(
                builder: (context, workerProvider, _) {
                  if (workerProvider.isVerifiedWorker) return const SizedBox.shrink();

                  return _buildUpgradeCard(
                    context,
                    title: 'Become a Worker',
                    description: 'Join Farmy as a worker. Complete tasks, earn money, and grow with our community.',
                    color: Colors.blue.shade700,
                    icon: Icons.work,
                    price: 'Get Verified',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BecomeWorkerScreen()),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDeliveryCard(BuildContext context, DeliveryTracking? delivery, bool isDark) {
    final theme = Theme.of(context);
    
    if (delivery == null) {
      // Empty state placeholder
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3) : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_shipping_outlined, size: 32, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'No active deliveries.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Order your first FarmBox today and get fresh produce delivered right to your door!',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => MainScreen.trySwitchToTab(context, 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Shop Marketplace'),
            ),
          ],
        ),
      );
    }

    // Active delivery tracking card
    final createdDate = delivery.createdAt;
    final formattedDate = '${createdDate.day.toString().padLeft(2, '0')}/${createdDate.month.toString().padLeft(2, '0')}/${createdDate.year} at ${createdDate.hour.toString().padLeft(2, '0')}:${createdDate.minute.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrackOrderScreen(orderId: delivery.orderId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.primary.withOpacity(0.1) : theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.deliveryStatusLabel,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 48,
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, bool isDark) {
    final theme = Theme.of(context);
    final imageUrl = product.fullImages.isNotEmpty ? product.fullImages.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildProductPlaceholder(theme);
                        },
                        errorBuilder: (_, __, ___) => _buildProductPlaceholder(theme),
                      )
                    : _buildProductPlaceholder(theme),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(2)} TND',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
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

  Widget _buildUpgradeCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required String price,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              onPressed: onTap,
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
                price,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PROFILE AVATAR WITH LOADING & ERROR HANDLING
  // ==========================================

  Widget _buildProfileAvatar(BuildContext context, User? user, ThemeData theme) {
    final String? rawPictureUrl = user?.profilePicture;
    final String? resolvedUrl = _resolveProfileImageUrl(rawPictureUrl);
    final String displayName = user?.name ?? user?.email ?? 'User';
    
    // If no URL, show fallback immediately
    if (resolvedUrl == null) {
      return _buildAvatarFallback(theme, displayName);
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          resolvedUrl,
          fit: BoxFit.cover,
          width: 56,
          height: 56,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 260),
                child: child,
              );
            }
            // Show shimmer/loading state while frame is loading
            return _buildAvatarLoading(theme);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildAvatarLoading(theme);
          },
          errorBuilder: (context, error, stackTrace) {
            // Log error for debugging but don't crash
            debugPrint('Profile image failed to load: $resolvedUrl - $error');
            return _buildAvatarFallback(theme, displayName);
          },
        ),
      ),
    );
  }

  Widget _buildAvatarLoading(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(ThemeData theme, String name) {
    final initials = _getInitials(name);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                color: Colors.white.withValues(alpha: 0.9),
                size: 28,
              ),
      ),
    );
  }

  String? _resolveProfileImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return null;
    
    // If it's already a full URL with scheme, return as-is
    final uri = Uri.tryParse(rawPath);
    if (uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return rawPath;
    }
    
    // Otherwise, prepend the base URL
    final base = AuthService.baseUrl;
    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanPath = rawPath.startsWith('/') ? rawPath : '/$rawPath';
    return '$cleanBase$cleanPath';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
