import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/basket_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/marketplace/basket_item_tile.dart';
import 'my_orders_screen.dart';
import 'track_order_screen.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basket = context.watch<BasketProvider>();
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myBasket),
        centerTitle: false,
        titleTextStyle: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
        actions: [
          if (!basket.isEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(context, basket),
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              label: Text(AppLocalizations.of(context)!.clear),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            ),
        ],
      ),
      body: basket.isEmpty
          ? _buildEmptyState(context, theme)
          : Column(
              children: [
                // ── Items List ──
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    itemCount: basket.items.length,
                    itemBuilder: (ctx, i) {
                      final item = basket.items[i];
                      return BasketItemTile(
                        item: item,
                        onIncrement: () =>
                            basket.incrementQuantity(item.product.id),
                        onDecrement: () =>
                            basket.decrementQuantity(item.product.id),
                        onRemove: () =>
                            basket.removeFromBasket(item.product.id),
                      );
                    },
                  ),
                ),

                // ── Price Breakdown + Checkout ──
                _buildCheckoutSection(context, theme, basket, wallet),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.yourBasketIsEmpty,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.browseMarketplaceDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.storefront_rounded, size: 20),
            label: Text(AppLocalizations.of(context)!.browseProducts),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    ThemeData theme,
    BasketProvider basket,
    WalletProvider wallet,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Price breakdown
            _PriceRow(
              label: AppLocalizations.of(context)!.subtotal,
              value: '${basket.subtotalTND.toStringAsFixed(2)} TND',
              theme: theme,
            ),
            const SizedBox(height: 8),
            _PriceRow(
              label: AppLocalizations.of(context)!.tva,
              value: '${basket.taxTND.toStringAsFixed(2)} TND',
              theme: theme,
            ),
            const SizedBox(height: 8),
            Divider(color: theme.colorScheme.onSurface.withOpacity(0.08)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.total,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${basket.totalTND.toStringAsFixed(2)} TND',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                AppLocalizations.of(context)!.balanceWithCredits(wallet.credits.toStringAsFixed(2)),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: basket.isCheckingOut
                    ? null
                    : () => _handleCheckout(context, basket, wallet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: theme.colorScheme.primary
                      .withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: basket.isCheckingOut
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_checkout_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.checkoutWithItems(basket.itemCount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Error message
            if (basket.checkoutError != null) ...[
              const SizedBox(height: 8),
              Text(
                basket.checkoutError!,
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    BasketProvider basket,
    WalletProvider wallet,
  ) async {
    // Check balance
    if (wallet.credits < basket.totalTND) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.insufficientFunds),
          content: Text(
            AppLocalizations.of(context)!.insufficientFundsDescription(wallet.credits.toStringAsFixed(2), basket.totalTND.toStringAsFixed(2)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );
      return;
    }

    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.confirmPurchase),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.itemsCount(basket.itemCount)),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.total}: ${basket.totalTND.toStringAsFixed(2)} TND',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.includingTva(basket.taxTND.toStringAsFixed(2)),
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    final result = await basket.checkout();

    if (!context.mounted) return;

    // Refresh wallet and products after purchase
    wallet.fetchWalletStatus();
    context.read<ProductProvider>().fetchProducts(status: 'available');

    final successCount = result['successCount'] as int;
    final failCount = result['failCount'] as int;

    ScaffoldMessenger.of(context).clearSnackBars();
    if (failCount == 0) {
      // Collect purchase IDs for tracking
      final purchaseIds = <String>[];
      final details = result['details'] as Map<String, dynamic>;
      for (final entry in details.values) {
        if (entry['success'] == true && entry['purchase_id'] != null) {
          purchaseIds.add(entry['purchase_id'] as String);
        }
      }

      // Show success dialog with tracking option
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.orderPlaced,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.itemsPurchasedSuccess(successCount),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                if (purchaseIds.length == 1)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TrackOrderScreen(orderId: purchaseIds.first),
                          ),
                        );
                      },
                      icon: const Icon(Icons.local_shipping_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)!.trackOrder),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  )
                else if (purchaseIds.length > 1)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)!.viewMyOrders),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.backToMarketplace,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.checkoutResultFeedback(successCount, failCount),
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _confirmClear(BuildContext context, BasketProvider basket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.clearBasketTitle),
        content: Text(AppLocalizations.of(context)!.clearBasketDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              basket.clearBasket();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.clearAll),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
