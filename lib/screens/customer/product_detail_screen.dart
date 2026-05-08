import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/basket_provider.dart';
import '../../widgets/profile_preview_sheet.dart';
import '../../services/auth_service.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedQuantity = 1;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  Product get product => widget.product;
  bool get _isOutOfStock =>
      product.quantity <= 0 || product.status != ProductStatus.available;
  int get _maxQuantity => product.quantity.toInt();

  @override
  void initState() {
    super.initState();
    final basket = context.read<BasketProvider>();
    final existingQty = basket.getQuantityInBasket(product.id);
    if (existingQty > 0) {
      _selectedQuantity = existingQty;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basket = context.watch<BasketProvider>();
    final inBasket = basket.isInBasket(product.id);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Image App Bar ──
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image gallery
                  product.images.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: product.fullImages.length,
                          onPageChanged: (i) =>
                              setState(() => _currentImageIndex = i),
                          itemBuilder: (_, i) => Image.network(
                            product.fullImages[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholder(theme),
                          ),
                        )
                      : _buildPlaceholder(theme),

                  // Image indicators
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          product.images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: i == _currentImageIndex ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i == _currentImageIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Out of stock overlay
                  if (_isOutOfStock)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.outOfStock,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Product Details ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${product.price.toStringAsFixed(2)} TND',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stock + unit info
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.inventory_2_outlined,
                        label: AppLocalizations.of(context)!.availableCount(
                          product.quantity.toInt(),
                          product.unit,
                        ),
                        color: product.quantity > 5
                            ? theme.colorScheme.primary
                            : Colors.orange.shade700,
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      if (inBasket)
                        _InfoChip(
                          icon: Icons.shopping_basket,
                          label: AppLocalizations.of(context)!.inBasket,
                          color: theme.colorScheme.primary,
                          theme: theme,
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context)!.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                  ],

                  // Product Origin
                  if (product.land != null || product.landRental != null) ...[
                    _buildProductOrigin(context, theme),
                    const SizedBox(height: 24),
                  ],

                  // Quantity selector
                  if (!_isOutOfStock) ...[
                    Text(
                      AppLocalizations.of(context)!.quantity,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildQtyButton(
                            icon: Icons.remove,
                            onTap: _selectedQuantity > 1
                                ? () => setState(() => _selectedQuantity--)
                                : null,
                            theme: theme,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$_selectedQuantity',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          _buildQtyButton(
                            icon: Icons.add,
                            onTap: _selectedQuantity < _maxQuantity
                                ? () => setState(() => _selectedQuantity++)
                                : null,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppLocalizations.of(context)!.subtotalLabel(
                          (product.price * _selectedQuantity).toStringAsFixed(
                            2,
                          ),
                        ),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Seller info
                  if (product.owner != null) ...[
                    Text(
                      AppLocalizations.of(context)!.seller,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => ProfilePreviewSheet.show(
                        context,
                        product.ownerId,
                        initialUser: product.owner,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.06,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              backgroundImage:
                                  product.owner?.profile?.picture != null
                                  ? NetworkImage(
                                      '${AuthService.baseUrl}${product.owner!.profile!.picture}',
                                    )
                                  : null,
                              child: product.owner?.profile?.picture == null
                                  ? Icon(
                                      Icons.person,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.owner?.profile?.name ??
                                        product.owner?.email.split('@').first ??
                                        AppLocalizations.of(context)!.farmer,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.verifiedSeller,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom CTA ──
      bottomNavigationBar: _isOutOfStock
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Price summary
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.totalLabel,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${(product.price * _selectedQuantity).toStringAsFixed(2)} TND',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add to basket button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAddToBasket(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_basket_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              inBasket
                                  ? AppLocalizations.of(context)!.updateBasket
                                  : AppLocalizations.of(context)!.addToBasket,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.08),
      child: Center(
        child: Icon(
          Icons.eco_rounded,
          size: 80,
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback? onTap,
    required ThemeData theme,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isEnabled
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.onSurface.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
    );
  }

  void _handleAddToBasket(BuildContext context) {
    final basket = context.read<BasketProvider>();

    // If already in basket, update to selected quantity
    if (basket.isInBasket(product.id)) {
      basket.updateQuantity(product.id, _selectedQuantity);
    } else {
      basket.addToBasket(product, quantity: _selectedQuantity);
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              basket.isInBasket(product.id)
                  ? AppLocalizations.of(
                      context,
                    )!.qtySetTo(product.title, _selectedQuantity)
                  : AppLocalizations.of(context)!.addedToBasket(product.title),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildProductOrigin(BuildContext context, ThemeData theme) {
    final isFarmerOwned = product.land != null;
    final landName = isFarmerOwned
        ? product.land!.name
        : (product.landRental!.land?.name ?? 'Unknown Land');
    final ownershipType = isFarmerOwned ? 'Farmer-owned' : 'Investor-managed';
    final icon = isFarmerOwned
        ? Icons.landscape_rounded
        : Icons.real_estate_agent_rounded;
    final color = isFarmerOwned
        ? theme.colorScheme.primary
        : Colors.orange.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Origin',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      landName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ownershipType,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final ThemeData theme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
