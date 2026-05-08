import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/product_model.dart';
import '../../features/ai_assistant/ai_screen.dart';

class FarmerAnalyticsScreen extends StatefulWidget {
  const FarmerAnalyticsScreen({super.key});

  @override
  State<FarmerAnalyticsScreen> createState() => _FarmerAnalyticsScreenState();
}

class _FarmerAnalyticsScreenState extends State<FarmerAnalyticsScreen> {
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
    final hasAdvancedAnalytics = subProvider.hasFeature('advanced_analytics');

    final double totalSales = productProvider.myProducts
        .where((p) => p.status == ProductStatus.sold)
        .fold(0.0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.analytics)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalEarningsWallet,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${walletProvider.credits.toStringAsFixed(2)} ${AppLocalizations.of(context)!.credits}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.totalSalesValue,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${totalSales.toStringAsFixed(2)} ${AppLocalizations.of(context)!.credits}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.nItemsSold(
                        productProvider.myProducts
                            .where((p) => p.status == ProductStatus.sold)
                            .length,
                      ),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Advanced Analytics Section
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.advancedAnalytics,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (!hasAdvancedAnalytics)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_rounded, size: 12, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.premium,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasAdvancedAnalytics)
              _buildAdvancedAnalyticsContent()
            else
              _buildLockedPremiumCard(
                AppLocalizations.of(context)!.unlockDeepInsights,
                AppLocalizations.of(context)!.unlockDeepInsightsDescription,
                AppLocalizations.of(context)!.upgradePlanName,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedAnalyticsContent() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 24, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.productionStrategy,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.productionStrategyDescription,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AiAssistantScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.psychology),
                label: Text(
                  AppLocalizations.of(context)!.consultProductionGuru,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
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
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_graph_rounded, size: 40, color: Colors.amber),
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
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
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
