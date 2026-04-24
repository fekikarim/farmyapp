import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/product_model.dart';
import '../investment_agent_screen.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class InvestorRevenueScreen extends StatefulWidget {
  const InvestorRevenueScreen({super.key});

  @override
  State<InvestorRevenueScreen> createState() => _InvestorRevenueScreenState();
}

class _InvestorRevenueScreenState extends State<InvestorRevenueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WalletProvider>().fetchWalletStatus();
      context.read<ProductProvider>().fetchMyProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final productProvider = context.watch<ProductProvider>();
    final subProvider = context.watch<SubscriptionProvider>();
    final hasPremiumAnalytics = subProvider.hasFeature('roi_analytics');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double totalSales = productProvider.myProducts
        .where((p) => p.status == ProductStatus.sold)
        .fold(0.0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.revenueTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.green),
            onPressed: () {
              final wallet = context.read<WalletProvider>();
              final products = context.read<ProductProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvestmentAgentScreen(
                    initialMessage: AppLocalizations.of(context)!.revenueAnalysisPrompt,
                    initialContext: {
                      'revenue': wallet.credits,
                      'inventory_value': products.myProducts.fold(0.0, (sum, p) => sum + p.price),
                      'sold_count': products.myProducts.where((p) => p.status == ProductStatus.sold).length,
                    },
                  ),
                ),
              );
            },
            tooltip: AppLocalizations.of(context)!.analyzeRevenueTooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Revenue Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalDetailsRevenue,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${walletProvider.credits.toStringAsFixed(2)} ${AppLocalizations.of(context)!.creditsLabel}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Secondary Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      AppLocalizations.of(context)!.productSales,
                      '${totalSales.toStringAsFixed(2)}',
                      AppLocalizations.of(context)!.creditsLabel,
                      Icons.storefront_rounded,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      AppLocalizations.of(context)!.itemsSold,
                      '${productProvider.myProducts.where((p) => p.status == ProductStatus.sold).length}',
                      AppLocalizations.of(context)!.unitsLabel,
                      Icons.shopping_bag_rounded,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Investment Revenue (Simple Link)
              GestureDetector(
                onTap: () {
                  // Logic to switch tab or navigate
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(
                        0.05,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.investmentRevenue,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.viewInvestmentBreakdown,
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Premium Investor Features Header
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.portfolioInsights,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (!hasPremiumAnalytics)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.premiumLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasPremiumAnalytics)
                _buildPremiumInsightsContent()
              else
                _buildLockedPremiumCard(
                  AppLocalizations.of(context)!.unlockPortfolioMaster,
                  AppLocalizations.of(context)!.premiumPortfolioDesc,
                  AppLocalizations.of(context)!.investorPlus,
                ),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          Text(
            '$unit $label',
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumInsightsContent() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.pie_chart_rounded, size: 48, color: Colors.blue),
              SizedBox(height: 12),
              Text(AppLocalizations.of(context)!.portfolioAnalyticsLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedPremiumCard(String title, String desc, String planName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, size: 40, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed('/subscriptions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(AppLocalizations.of(context)!.upgradeToPlan(planName)),
          ),
        ],
      ),
    );
  }
}
