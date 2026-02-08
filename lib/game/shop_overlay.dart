import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop_item_model.dart';
import '../services/shop_service.dart';
import '../services/land_rental_service.dart';
import '../models/land_rental_model.dart';
import '../providers/wallet_provider.dart';

class ShopOverlay extends StatefulWidget {
  final String? preSelectedLandId;

  const ShopOverlay({super.key, this.preSelectedLandId});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AssetCategory _currentCategory = AssetCategory.animal;
  List<ShopItemType>? _items;
  bool _isLoading = true;
  ShopItemType? _selectedItem;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AssetCategory.values.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onCategoryChanged();
      }
    });
    _loadItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchWalletStatus();
    });
  }

  void _onCategoryChanged() {
    setState(() {
      _currentCategory = AssetCategory.values[_tabController.index];
      _isLoading = true;
      _selectedItem = null;
    });
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await ShopService.getAssetTypes(_currentCategory);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                if (_selectedItem == null) _buildCategoryTabs(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedItem == null
                        ? _buildMainGrid()
                        : _buildDetailView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'FARMY STORE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Credit Display
          Consumer<WalletProvider>(
            builder: (context, wallet, child) {
              return GestureDetector(
                onTap: _handleAddCredits,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.greenAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.greenAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '\$${wallet.credits.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.add_circle,
                        color: Colors.greenAccent,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 3.0,
            color: Colors.greenAccent.withOpacity(0.8),
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        labelColor: Colors.greenAccent,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1,
        ),
        tabs: AssetCategory.values
            .map((cat) => Tab(text: cat.name.toUpperCase()))
            .toList(),
      ),
    );
  }

  Widget _buildMainGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.greenAccent),
      );
    }

    if (_items == null || _items!.isEmpty) {
      return const Center(
        child: Text(
          'Nothing found here',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Smaller items, more visible
        childAspectRatio: 0.8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _items!.length,
      itemBuilder: (context, index) {
        final item = _items![index];
        return GestureDetector(
          onTap: () async {
            setState(() => _isLoading = true);
            final detailed = await ShopService.getAssetTypeWithVariants(
              _currentCategory,
              item.id,
            );
            if (mounted) {
              setState(() {
                _selectedItem = detailed;
                _isLoading = false;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: _safeAssetImage(item.assetIconPath),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailView() {
    if (_selectedItem == null) return const SizedBox();
    final variants = _selectedItem!.variants ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedItem = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.chevron_left,
                        color: Colors.greenAccent,
                        size: 16,
                      ),
                      Text(
                        'BACK',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            children: [
              // Detailed Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _safeAssetImage(_selectedItem!.assetIconPath),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedItem!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_selectedItem!.description != null)
                            Text(
                              _selectedItem!.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'VARIANTS',
                style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              ...variants.map((v) => _buildCompactVariantCard(v)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactVariantCard(ShopItemVariant variant) {
    final attributes = variant.formattedAttributes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _safeAssetImage(variant.assetImagePath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.variantCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${variant.basePrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _handleBuyItem(variant),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'BUY',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
          if (attributes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: attributes.entries
                    .map(
                      (e) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            e.key + ': ',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            e.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleBuyItem(ShopItemVariant variant) async {
    setState(() => _isLoading = true);
    try {
      final rentals = await LandRentalService.getMyRentalsAsInvestor(
        paymentStatus: 'paid',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (rentals.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must rent a land to buy items.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      LandRental? selectedRental;

      // Use pre-selected land if available and valid
      if (widget.preSelectedLandId != null) {
        final preMatch = rentals.where((r) => r.landId == widget.preSelectedLandId);
        if (preMatch.isNotEmpty) {
          selectedRental = preMatch.first;
        }
      }

      if (selectedRental == null) {
        if (rentals.length == 1) {
          selectedRental = rentals.first;
        } else {
          selectedRental = await showDialog<LandRental>(
            context: context,
            builder: (context) => SimpleDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Text(
              'Select Land',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: rentals
                .map(
                  (r) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, r),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        r.land?.name ?? 'Unknown Land',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      }
    }

    if (selectedRental == null) return;

      setState(() => _isLoading = true);

      // ... existing imports

      // ... inside _handleBuyItem or nearby

      // Process Purchase
      final random = Random();
      final success = await ShopService.buyItem(
        landId: selectedRental.landId,
        variantId: variant.id,
        category: _currentCategory,
        positionX: random.nextInt(10),
        positionY: random.nextInt(10),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent to Farmer!'),
            backgroundColor: Colors.green,
          ),
        );
        context.read<WalletProvider>().fetchWalletStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase failed. Insufficient credits?'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _safeAssetImage(String path) {
    if (path.isEmpty) return const Icon(Icons.image, color: Colors.white10);
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.white10),
    );
  }

  Future<void> _handleAddCredits() async {
    double? selectedAmount;
    final customAmountController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.all(
              24,
            ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TOP UP CREDITS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [10, 20, 50, 100].map((amount) {
                    final isSelected = selectedAmount == amount.toDouble();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAmount = amount.toDouble();
                          customAmountController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.greenAccent
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.greenAccent
                                : Colors.white10,
                          ),
                        ),
                        child: Text(
                          '\$${amount.toString()}',
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: customAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Custom Amount',
                    labelStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(color: Colors.greenAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.greenAccent),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedAmount = double.tryParse(value);
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: selectedAmount != null && selectedAmount! > 0
                      ? () {
                          Navigator.pop(context);
                          _processCharge(selectedAmount!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    selectedAmount != null
                        ? 'PAY \$${selectedAmount!.toStringAsFixed(2)}'
                        : 'ENTER AMOUNT',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _processCharge(double amount) async {
    final success = await context.read<WalletProvider>().chargeCredits(amount);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added \$$amount!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed or cancelled.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
