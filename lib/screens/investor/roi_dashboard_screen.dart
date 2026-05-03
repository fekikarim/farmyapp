import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class _RoiDashboardScreenState extends State<RoiDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RoiProvider>().fetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roiProvider = context.watch<RoiProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      body: SafeArea(
        child: roiProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : roiProvider.error != null
                ? _buildErrorState(theme, roiProvider.error!)
                : roiProvider.dashboardData == null
                    ? const Center(child: Text('No data available'))
                    : RefreshIndicator(
                        onRefresh: roiProvider.fetchDashboardData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(context, user, theme),
                              const SizedBox(height: 32),
                              _buildOverviewHeader(context, theme, roiProvider.dashboardData!.overview),
                              const SizedBox(height: 32),
                              _buildQuickActions(context, theme),
                            const SizedBox(height: 32),
                            _buildSimpleChart(context, theme, roiProvider.dashboardData!.overview),
                            const SizedBox(height: 32),
                            Text(
                              'Land Breakdowns',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (roiProvider.dashboardData!.rentals.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    'No active rentals found.',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: roiProvider.dashboardData!.rentals.length,
                                itemBuilder: (context, index) {
                                  final rental = roiProvider.dashboardData!.rentals[index];
                                  return RoiRentalCard(
                                    rental: rental,
                                    onTap: () {
                                      _showRentalDetails(context, rental);
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
        ),
    );
  }

  Widget _buildOverviewHeader(BuildContext context, ThemeData theme, RoiOverview overview) {
    final isProfitable = overview.netProfit >= 0;
    return Container(
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
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Net Profit',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${isProfitable ? '+' : ''}${overview.netProfit.toStringAsFixed(2)} TND',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
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

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<RoiProvider>().fetchDashboardData(),
              child: const Text('Retry'),
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
                child: _buildPremiumDetailRow(
                  context, 
                  icon: Icons.monetization_on_outlined, 
                  iconColor: theme.colorScheme.primary,
                  label: 'Total Revenue', 
                  value: '${rental.revenue.toStringAsFixed(2)} TND',
                  isBold: true,
                  valueColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
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
