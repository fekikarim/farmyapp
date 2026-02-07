import 'package:flutter/material.dart';
import '../models/shop_item_model.dart';
import '../services/shop_service.dart';

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
        setState(() {
          _currentCategory = AssetCategory.values[_tabController.index];
          _isLoading = true;
          _selectedItem = null;
        });
        _loadItems();
      }
    });
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await ShopService.getAssetTypes(_currentCategory);
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FARM SHOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white54,
            tabs: AssetCategory.values.map((cat) {
              return Tab(
                text: cat.name.toUpperCase(),
                icon: _getCategoryIcon(cat),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _selectedItem != null 
                ? _buildVariantSelection() 
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(AssetCategory cat) {
    switch (cat) {
      case AssetCategory.animal: return const Icon(Icons.pets, size: 20);
      case AssetCategory.vegetation: return const Icon(Icons.grass, size: 20);
      case AssetCategory.tree: return const Icon(Icons.park, size: 20);
      case AssetCategory.structure: return const Icon(Icons.home, size: 20);
      case AssetCategory.machine: return const Icon(Icons.settings, size: 20);
    }
  }

  Widget _buildGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    if (_items == null || _items!.isEmpty) {
      return const Center(
        child: Text(
          'No items found in this category.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _items!.length,
      itemBuilder: (context, index) {
        final item = _items![index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(ShopItemType item) {
    return InkWell(
      onTap: () async {
        setState(() => _isLoading = true);
        final detailedItem = await ShopService.getAssetTypeWithVariants(_currentCategory, item.id);
        if (mounted) {
          setState(() {
            _selectedItem = detailedItem;
            _isLoading = false;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Hero(
                  tag: 'item_${item.id}',
                  child: _buildAssetImage(item.assetIconPath, isIcon: true),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantSelection() {
    if (_selectedItem == null) return const SizedBox();

    final variants = _selectedItem!.variants ?? [];

    return Column(
      children: [
        // Back Button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _selectedItem = null),
            icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
            label: const Text('Back to items', style: TextStyle(color: Colors.greenAccent)),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: _buildAssetImage(_selectedItem!.assetIconPath, isIcon: true),
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedItem!.description != null)
                            Text(
                              _selectedItem!.description!,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'SELECT VARIANT',
                  style: TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                ...variants.map((v) => _buildVariantCard(v)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVariantCard(ShopItemVariant variant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildAssetImage(variant.assetImagePath),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.variantCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '\$${variant.basePrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Buying ${variant.variantCode}... Coming Soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('BUY'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetImage(String path, {bool isIcon = false}) {
    if (path.isEmpty) {
      return Icon(
        isIcon ? Icons.image_not_supported : Icons.broken_image, 
        color: Colors.white24, 
        size: isIcon ? 40 : 24,
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          isIcon ? Icons.image_not_supported : Icons.broken_image, 
          color: Colors.white24,
        );
      },
    );
  }
}
