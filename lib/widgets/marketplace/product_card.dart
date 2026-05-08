import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/basket_provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  bool get _isOutOfStock =>
      product.quantity <= 0 || product.status != ProductStatus.available;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basket = context.watch<BasketProvider>();
    final inBasket = basket.isInBasket(product.id);
    final qtyInBasket = basket.getQuantityInBasket(product.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section ──
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Product Image
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.fullImages[0],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderIcon(theme),
                            )
                          : _buildPlaceholderIcon(theme),
                    ),
                  ),

                  // Out of stock overlay
                  if (_isOutOfStock)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.outOfStock,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                  // Stock badge
                  if (!_isOutOfStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.quantity > 5
                              ? theme.colorScheme.primary
                              : Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${product.quantity.toInt()} ${product.unit}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Basket quantity badge
                  if (inBasket)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shopping_basket,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '×$qtyInBasket',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info Section ──
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(2)} TND',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    // Add to basket button
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: _isOutOfStock
                          ? OutlinedButton(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.unavailable,
                                style: const TextStyle(fontSize: 12),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () =>
                                  _handleAddToBasket(context, basket),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: inBasket
                                    ? theme.colorScheme.primary.withOpacity(
                                        0.15,
                                      )
                                    : theme.colorScheme.primary,
                                foregroundColor: inBasket
                                    ? theme.colorScheme.primary
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                minimumSize: Size.zero,
                              ),
                              icon: Icon(
                                inBasket
                                    ? Icons.add
                                    : Icons.add_shopping_cart_rounded,
                                size: 16,
                              ),
                              label: Text(
                                inBasket
                                    ? AppLocalizations.of(context)!.addMore
                                    : AppLocalizations.of(context)!.addToBasket,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
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

  Widget _buildPlaceholderIcon(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.eco_rounded,
        size: 48,
        color: theme.colorScheme.primary.withOpacity(0.3),
      ),
    );
  }

  void _handleAddToBasket(BuildContext context, BasketProvider basket) {
    final added = basket.addToBasket(product);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    if (added) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  basket.isInBasket(product.id) &&
                          basket.getQuantityInBasket(product.id) > 1
                      ? AppLocalizations.of(context)!.qtyUpdatedTo(
                          product.title,
                          basket.getQuantityInBasket(product.id).toString(),
                        )
                      : AppLocalizations.of(
                          context,
                        )!.addedToBasket(product.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.maximumStockReached),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
