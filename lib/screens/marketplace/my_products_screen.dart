import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/subscription_limit_bar.dart';
import 'add_product_screen.dart';
import '../../models/product_model.dart';
import '../investment_agent_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().fetchMyProducts());
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProduct),
        content: Text(AppLocalizations.of(context)!.deleteProductConfirmation(product.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final success = await context.read<ProductProvider>().deleteProduct(
        product.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? AppLocalizations.of(context)!.productDeleted : AppLocalizations.of(context)!.failedToDeleteProduct,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isFarmer = authProvider.user?.role == 'farmer';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myProducts),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.green),
            onPressed: () {
              final products = context.read<ProductProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvestmentAgentScreen(
                    initialMessage: AppLocalizations.of(context)!.analyzeInventoryPrompt,
                    initialContext: {
                      'inventory': products.myProducts.map((p) => {
                        'title': p.title,
                        'price': p.price,
                        'quantity': p.quantity,
                        'status': p.status.name,
                      }).toList(),
                    },
                  ),
                ),
              );
            },
            tooltip: AppLocalizations.of(context)!.analyzeInventory,
          ),
        ],
      ),
      floatingActionButton: Consumer<SubscriptionProvider>(
        builder: (context, subProvider, _) {
          final productCount = productProvider.myProducts.length;
          // Apply product limits ONLY for farmers as per subscription plan logic
          final isAtLimit =
              isFarmer &&
              !subProvider.isWithinLimit('product_limit', productCount);

          return FloatingActionButton(
            heroTag: 'add_product_fab',
            backgroundColor: isAtLimit ? Colors.amber.shade700 : null,
            onPressed: isAtLimit
                ? () => _showProductLimitDialog(context, subProvider.planName)
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddProductScreen(),
                      ),
                    );
                    if (mounted) {
                      context.read<ProductProvider>().fetchMyProducts();
                    }
                  },
            child: Icon(isAtLimit ? Icons.lock_outline : Icons.add),
          );
        },
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productProvider.error != null
          ? _buildErrorPlaceholder(context, productProvider.error!)
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<ProductProvider>().fetchMyProducts(),
              child: productProvider.myProducts.isEmpty && !isFarmer
                  ? _buildEmptyPlaceholder(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      // Only show limit bar for farmers
                      itemCount: isFarmer
                          ? productProvider.myProducts.length + 1
                          : productProvider.myProducts.length,
                      itemBuilder: (ctx, i) {
                        if (isFarmer && i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: SubscriptionLimitBar(
                              limitKey: 'product_limit',
                              currentCount: productProvider.myProducts.length,
                              label: AppLocalizations.of(context)!.productListingsUsed,
                              icon: Icons.inventory_2_outlined,
                              accentColor: Colors.green,
                              upgradePlanName: AppLocalizations.of(context)!.upgradePlanName,
                            ),
                          );
                        }
                        final product = isFarmer
                            ? productProvider.myProducts[i - 1]
                            : productProvider.myProducts[i];
                        return _buildProductCard(context, product);
                      },
                    ),
            ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.oopsSomethingWentWrong,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<ProductProvider>().fetchMyProducts(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.retry),
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

  Widget _buildEmptyPlaceholder(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noProductsFound,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.addProductFirst,
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: product.fullImages.isNotEmpty
                      ? Image.network(
                          product.fullImages[0],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.shade100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    color: theme.primaryColor.withOpacity(0.3),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context)!.imageUnavailable,
                                    style: TextStyle(
                                      color: theme.disabledColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Container(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey.shade100,
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            size: 48,
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getStatusLabel(context, product.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${product.price} ${AppLocalizations.of(context)!.credits}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.quantity} ${product.unit} ${AppLocalizations.of(context)!.available}',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: Text(AppLocalizations.of(context)!.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddProductScreen(product: product),
                            ),
                          );
                          if (mounted) {
                            context.read<ProductProvider>().fetchMyProducts();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          foregroundColor: theme.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteProduct(product),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProductLimitDialog(BuildContext context, String planName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Colors.amber,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.productLimitReached,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.productLimitMessage(planName),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed('/subscriptions');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.viewPlans,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppLocalizations.of(context)!.maybeLater,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getStatusLabel(BuildContext context, ProductStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ProductStatus.available:
        return l10n.availableUpper;
      case ProductStatus.sold:
        return l10n.soldUpper;
      case ProductStatus.hidden:
        return l10n.hiddenUpper;
      default:
        return status.name.toUpperCase();
    }
  }
}
