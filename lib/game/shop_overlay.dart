import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shop_item_model.dart';
import '../services/shop_service.dart';
import '../providers/wallet_provider.dart';

class ShopOverlay extends StatefulWidget {
  const ShopOverlay({super.key});

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AssetCategory _currentCategory = AssetCategory.animal;
  List<ShopItemType>? _items;
  bool _isLoading = true;
  ShopItemType? _selectedItem;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: AssetCategory.values.length, vsync: this);
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
      backgroundColor: const Color(0xFF0F172A), // Deep navy/slate game background
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),
          
          // Floating Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildCategoryTabs(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedItem == null ? _buildMainCategoryView() : _buildDetailView(),
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
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'FARMY STORE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Credit Display
          Consumer<WalletProvider>(
            builder: (context, wallet, child) {
              return GestureDetector(
                onTap: _handleAddCredits,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent.withOpacity(0.2),
                        Colors.blueAccent.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        '\$${wallet.credits.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.add_circle, color: Colors.greenAccent, size: 18),
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
      height: 50,
      margin: const EdgeInsets.only(bottom: 10),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        physics: const BouncingScrollPhysics(),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.greenAccent.withOpacity(0.1),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.greenAccent,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        tabs: AssetCategory.values.map((cat) {
          return Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(cat.name.toUpperCase()),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainCategoryView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    if (_items == null || _items!.isEmpty) {
      return const Center(child: Text('Nothing found here yet', style: TextStyle(color: Colors.white38)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
      ),
      itemCount: _items!.length,
      itemBuilder: (context, index) {
        final item = _items![index];
        return GestureDetector(
          onTap: () async {
            setState(() => _isLoading = true);
            final detailed = await ShopService.getAssetTypeWithVariants(_currentCategory, item.id);
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
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: _safeAssetImage(item.assetIconPath),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_currentCategory.name} type',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
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
        // Top Back Button & Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _selectedItem = null),
                icon: const Icon(Icons.chevron_left, color: Colors.greenAccent),
                label: const Text('Back', style: TextStyle(color: Colors.greenAccent)),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            children: [
              // Detailed Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _safeAssetImage(_selectedItem!.assetIconPath),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedItem!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_selectedItem!.description != null)
                            Text(
                              _selectedItem!.description!,
                              style: const TextStyle(color: Colors.white60, fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'COLLECTIONS & VARIANTS',
                style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 20),

              if (variants.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text('No variations available.', style: TextStyle(color: Colors.white38)),
                  ),
                ),

              ...variants.map((v) => _buildVariantCard(v)),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVariantCard(ShopItemVariant variant) {
    final attributes = variant.formattedAttributes;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Column
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: _safeAssetImage(variant.assetImagePath),
                    ),
                    const SizedBox(width: 20),
                    // Title/Price Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            variant.variantCode.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '\$${variant.basePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Buy Button
                  ],
                ),
                
                // Attributes Grid
                if (attributes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: attributes.entries.map((entry) {
                      return Container(
                        width: (MediaQuery.of(context).size.width - 92) / 2, // 2 items per row
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              entry.value,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'PURCHASE ASSET',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _safeAssetImage(String path) {
    if (path.isEmpty) return const Icon(Icons.image, color: Colors.white10);
    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white10),
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
            padding: EdgeInsets.all(24).copyWith(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
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
                const SizedBox(height: 24),
                const Text(
                  'Select Amount',
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                const SizedBox(height: 12),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.greenAccent : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? Colors.greenAccent : Colors.white10,
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
                const SizedBox(height: 24),
                TextField(
                  controller: customAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Custom Amount',
                    labelStyle: const TextStyle(color: Colors.white38),
                    prefixText: '\$ ',
                    prefixStyle: const TextStyle(color: Colors.greenAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
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
                const SizedBox(height: 32),
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
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    selectedAmount != null
                        ? 'PAY \$${selectedAmount!.toStringAsFixed(2)}'
                        : 'ENTER AMOUNT',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
