import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart'; // Ensure correct import

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

    final double totalSales = productProvider.myProducts
        .where((p) => p.status == ProductStatus.sold)
        .fold(0.0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
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
                    const Text(
                      'Total Earnings (Wallet)',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${walletProvider.credits.toStringAsFixed(2)} Credits',
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
                    const Text(
                      'Total Sales Value',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${totalSales.toStringAsFixed(2)} Credits',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${productProvider.myProducts.where((p) => p.status == ProductStatus.sold).length} Items Sold',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
