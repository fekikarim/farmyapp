import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../providers/roi_provider.dart';
import '../../models/roi_model.dart';
import '../../widgets/investor/roi_rental_card.dart';
import '../investment_agent_screen.dart';
import '../../widgets/my_lands_sheet.dart';
import '../customer/subscriptions_screen.dart';
import '../worker/wallet/worker_wallet_screen.dart';
import 'dart:math';

class RoiDashboardScreen extends StatefulWidget {
  const RoiDashboardScreen({super.key});

  @override
  State<RoiDashboardScreen> createState() => _RoiDashboardScreenState();
}

class _RoiDashboardScreenState extends State<RoiDashboardScreen> with WidgetsBindingObserver {
  DateTime? _lastRefreshTime;
  static const Duration _minRefreshInterval = Duration(seconds: 3);
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final provider = context.read<RoiProvider>();
    provider.initialize();
    _initialLoad();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app resumes (user returns to app)
    if (state == AppLifecycleState.resumed) {
      _refreshIfNeeded();
    }
  }
  
  void _initialLoad() {
    final provider = context.read<RoiProvider>();
    Future.microtask(() async {
      await provider.fetchDashboardData();
      _lastRefreshTime = DateTime.now();
    });
  }
  
  void _refreshIfNeeded() {
    if (_lastRefreshTime == null) return;
    
    final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
    if (timeSinceLastRefresh < _minRefreshInterval) return;
    
    final provider = context.read<RoiProvider>();
    if (!provider.isLoading) {
      provider.fetchDashboardData(forceRefresh: true);
      _lastRefreshTime = DateTime.now();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<RoiProvider>().stopAutoSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roiProvider = context.watch<RoiProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildBody(theme, roiProvider, user),
      ),
    );
  }
  
  Widget _buildBody(ThemeData theme, RoiProvider roiProvider, User? user) {
    // Show full skeleton during initial load
    if (roiProvider.loadingState == RoiLoadingState.initial) {
      return _buildSkeletonLoading(theme);
    }
    
    // Show error state
    if (roiProvider.hasError && !roiProvider.hasData) {
      return _buildErrorState(theme, roiProvider.error!, onRetry: () => roiProvider.retry());
    }
    
    // Show main content with optional refresh indicator
    return RefreshIndicator(
      onRefresh: () => roiProvider.fetchDashboardData(forceRefresh: true),
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, user, theme),
            const SizedBox(height: 32),
            
            // Overview with loading overlay if refreshing
            Stack(
              children: [
                if (roiProvider.hasData)
                  _buildOverviewHeader(context, theme, roiProvider.dashboardData!.overview),
                if (roiProvider.loadingState == RoiLoadingState.refreshing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildQuickActions(context, theme),
            const SizedBox(height: 32),
            
            if (roiProvider.hasData) ...[
              _buildSimpleChart(context, theme, roiProvider.dashboardData!.overview),
              const SizedBox(height: 32),
              _buildLandBreakdownsSection(context, theme, roiProvider),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSkeletonLoading(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 200, height: 28, color: Colors.white),
                    ],
                  ),
                ),
                Container(width: 56, height: 56, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 32),
            // Overview card skeleton
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 32),
            // Quick actions skeleton
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: List.generate(4, (index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              )),
            ),
            const SizedBox(height: 32),
            // Chart skeleton
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLandBreakdownsSection(BuildContext context, ThemeData theme, RoiProvider roiProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Land Breakdowns',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (roiProvider.isBackgroundSyncing)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (roiProvider.dashboardData!.rentals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.landscape_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active rentals found.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start investing in lands to see your ROI.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: roiProvider.dashboardData!.rentals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rental = roiProvider.dashboardData!.rentals[index];
              return RoiRentalCard(
                rental: rental,
                onTap: () => _showRentalDetails(context, rental),
              );
            },
          ),
      ],
    );
  }

  Widget _buildOverviewHeader(BuildContext context, ThemeData theme, RoiOverview overview) {
    final isProfitable = overview.netProfit >= 0;
    final profitSummary = context.read<RoiProvider>().profitSummary;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfitable 
            ? [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ]
            : [
                Colors.red.shade400,
                Colors.orange.shade400,
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isProfitable ? theme.colorScheme.primary : Colors.red).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profit Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isProfitable ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isProfitable ? 'Profitable' : 'At Risk',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total Net Profit',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              '${isProfitable ? '+' : ''}${overview.netProfit.toStringAsFixed(2)} TND',
              key: ValueKey(overview.netProfit),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildHeaderMetric(
                  'Investment',
                  '${overview.totalInvestment.toStringAsFixed(0)} TND',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _buildHeaderMetric(
                  'Revenue',
                  '${overview.totalRevenue.toStringAsFixed(0)} TND',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
              Expanded(
                child: _buildHeaderMetric(
                  'ROI',
                  '${overview.roiPercentage > 0 ? '+' : ''}${overview.roiPercentage.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          // Product Revenue Breakdown
          if (overview.productRevenue > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Product Revenue',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '+${overview.productRevenue.toStringAsFixed(0)} TND',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (overview.productRevenueContribution / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.9),
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${overview.productRevenueContribution.toStringAsFixed(1)}% of total revenue',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${overview.totalProductsSold} products sold',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleChart(BuildContext context, ThemeData theme, RoiOverview overview) {
    final maxVal = max(overview.totalInvestment, overview.totalRevenue);
    if (maxVal == 0) return const SizedBox.shrink();

    final investmentHeight = (overview.totalInvestment / maxVal) * 150;
    final revenueHeight = (overview.totalRevenue / maxVal) * 150;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue vs Costs',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(
                label: 'Costs',
                height: investmentHeight.isNaN ? 0 : investmentHeight,
                color: Colors.orange.shade500,
                value: overview.totalInvestment,
                theme: theme,
              ),
              _buildBar(
                label: 'Revenue',
                height: revenueHeight.isNaN ? 0 : revenueHeight,
                color: Colors.blue.shade500,
                value: overview.totalRevenue,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required String label, required double height, required Color color, required double value, required ThemeData theme}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          height: height.clamp(0.0, 150.0),
          width: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme, String error, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline, 
                size: 48, 
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRentalDetails(BuildContext context, RoiRentalBreakdown rental) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isProfitable = rental.netProfit >= 0;
        
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${rental.landName} Breakdown',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isProfitable ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${isProfitable ? '+' : ''}${rental.netProfit.toStringAsFixed(2)} TND',
                        style: TextStyle(
                          color: isProfitable ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              
              // Costs Section
              Text(
                'Operational Costs',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPremiumDetailRow(
                      context, 
                      icon: Icons.home_work_outlined, 
                      iconColor: Colors.orange.shade500,
                      label: 'Rent Paid', 
                      value: '${rental.costs.rent.toStringAsFixed(2)} TND',
                    ),
                    Divider(height: 1, indent: 64, endIndent: 24, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                    _buildPremiumDetailRow(
                      context, 
                      icon: Icons.shopping_basket_outlined, 
                      iconColor: Colors.purple.shade500,
                      label: 'Item Purchases', 
                      value: '${rental.costs.items.toStringAsFixed(2)} TND',
                    ),
                    Divider(height: 1, indent: 64, endIndent: 24, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                    _buildPremiumDetailRow(
                      context, 
                      icon: Icons.people_outline, 
                      iconColor: Colors.red.shade400,
                      label: 'Worker Salaries', 
                      value: '${rental.costs.workers.toStringAsFixed(2)} TND',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Revenue Section
              Text(
                'Generated Income',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildPremiumDetailRow(
                      context, 
                      icon: Icons.monetization_on_outlined, 
                      iconColor: theme.colorScheme.primary,
                      label: 'Base Revenue', 
                      value: '${rental.revenue.toStringAsFixed(2)} TND',
                    ),
                    // Product Revenue Row
                    if (rental.productRevenue > 0) ...[
                      Divider(height: 1, indent: 64, endIndent: 24, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                      _buildPremiumDetailRow(
                        context, 
                        icon: Icons.shopping_bag_outlined, 
                        iconColor: Colors.green.shade500,
                        label: 'Product Sales (${rental.productsSoldCount})', 
                        value: '+${rental.productRevenue.toStringAsFixed(2)} TND',
                        valueColor: Colors.green.shade600,
                      ),
                    ],
                    Divider(height: 1, indent: 64, endIndent: 24, color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                    _buildPremiumDetailRow(
                      context, 
                      icon: Icons.account_balance_wallet_outlined, 
                      iconColor: theme.colorScheme.primary,
                      label: 'Total Revenue', 
                      value: '${rental.totalRevenueWithProducts.toStringAsFixed(2)} TND',
                      isBold: true,
                      valueColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              
              // Product Breakdown List
              if (rental.productBreakdown.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Product Sales Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: rental.productBreakdown.length,
                    itemBuilder: (context, index) {
                      final product = rental.productBreakdown[index];
                      return _buildProductRow(context, product);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildProductRow(BuildContext context, ProductRevenue product) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.local_offer_outlined,
            color: Colors.green.shade600,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.productName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${product.quantitySold} × ${product.unitPrice.toStringAsFixed(2)} TND',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.totalRevenue.toStringAsFixed(2)} TND',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            Text(
              '${product.profitMargin.toStringAsFixed(1)}% margin',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
              ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDetailRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildActionCard(
              context,
              title: 'Strategic AI',
              icon: Icons.smart_toy_rounded,
              color: theme.colorScheme.primary,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InvestmentAgentScreen())),
            ),
            _buildActionCard(
              context,
              title: 'My Lands',
              icon: Icons.landscape_rounded,
              color: Colors.orange.shade500,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const MyLandsBottomSheet(),
                );
              },
            ),
            _buildActionCard(
              context,
              title: 'Subscriptions',
              icon: Icons.subscriptions_rounded,
              color: Colors.blue.shade500,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen())),
            ),
            _buildActionCard(
              context,
              title: 'Wallet',
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.purple.shade500,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkerWalletScreen())),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HEADER
  // ==========================================
  
  Widget _buildHeader(BuildContext context, User? user, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = l10n.goodMorning;
    } else if (hour < 17) {
      greeting = l10n.goodAfternoon;
    } else {
      greeting = l10n.goodEvening;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
    );
  }

  // ==========================================
  // PROFILE AVATAR WITH LOADING & ERROR HANDLING
  // ==========================================

  Widget _buildProfileAvatar(BuildContext context, User? user, ThemeData theme) {
    final String? rawPictureUrl = user?.profilePicture;
    final String? resolvedUrl = _resolveProfileImageUrl(rawPictureUrl);
    final String displayName = user?.name ?? user?.email ?? 'User';
    
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
            return _buildAvatarLoading(theme);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildAvatarLoading(theme);
          },
          errorBuilder: (context, error, stackTrace) {
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
      width: 56,
      height: 56,
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
    
    final uri = Uri.tryParse(rawPath);
    if (uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return rawPath;
    }
    
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
