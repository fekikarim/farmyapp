import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/basket_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/marketplace/basket_item_tile.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basket = context.watch<BasketProvider>();
    final wallet = context.watch<WalletProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Basket'),
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
              label: const Text('Clear'),
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
            'Your basket is empty',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse the marketplace and add\nsome fresh products!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.storefront_rounded, size: 20),
            label: const Text('Browse Products'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, ThemeData theme,
      BasketProvider basket, WalletProvider wallet) {
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
              label: 'Subtotal',
              value: '${basket.subtotalTND.toStringAsFixed(2)} TND',
              theme: theme,
            ),
            const SizedBox(height: 8),
            _PriceRow(
              label: 'TVA (19%)',
              value: '${basket.taxTND.toStringAsFixed(2)} TND',
              theme: theme,
            ),
            const SizedBox(height: 8),
            Divider(
              color: theme.colorScheme.onSurface.withOpacity(0.08),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
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
                'Balance: ${wallet.credits.toStringAsFixed(2)} Credits',
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
                  disabledBackgroundColor:
                      theme.colorScheme.primary.withOpacity(0.5),
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_checkout_rounded,
                              size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Checkout (${basket.itemCount} items)',
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

  Future<void> _handleCheckout(BuildContext context, BasketProvider basket,
      WalletProvider wallet) async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${basket.itemCount} item(s)'),
            const SizedBox(height: 8),
            Text(
              'Total: ${basket.totalTND.toStringAsFixed(2)} TND',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '(including 19% TVA: ${basket.taxTND.toStringAsFixed(2)} TND)',
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    final result = await basket.checkout();

    if (!context.mounted) return;

    // Refresh wallet after purchase
    wallet.fetchWalletStatus();

    final successCount = result['successCount'] as int;
    final failCount = result['failCount'] as int;

    ScaffoldMessenger.of(context).clearSnackBars();
    if (failCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('$successCount item(s) purchased successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$successCount purchased, $failCount failed. Failed items remain in basket.',
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: const Text('Clear Basket?'),
        content: const Text('This will remove all items from your basket.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              basket.clearBasket();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
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
