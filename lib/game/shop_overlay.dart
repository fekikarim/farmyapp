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
        _onCategoryChanged();
      }
    });
    _loadItems();
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
    // Force a Material context and a background
    return Material(
      color: Colors.black.withOpacity(0.85),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'FARM SHOP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
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
              unselectedLabelColor: Colors.white38,
              tabs: AssetCategory.values.map((cat) => Tab(text: cat.name.toUpperCase())).toList(),
            ),

            const SizedBox(height: 10),

            // Main Content Area
            Expanded(
              child: _selectedItem == null ? _buildMainCategoryView() : _buildDetailView(),
            ),
          ],
        ),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: _safeAssetImage(item.assetIconPath),
                ),
                const SizedBox(height: 12),
                Text(
                  item.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _selectedItem = null),
          icon: const Icon(Icons.arrow_back, color: Colors.greenAccent),
          label: const Text('Back to items', style: TextStyle(color: Colors.greenAccent)),
        ),
        const SizedBox(height: 20),
        
        // Item Info Header
        Row(
          children: [
            Container(
              width: 90,
              height: 90,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _safeAssetImage(_selectedItem!.assetIconPath),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedItem!.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (_selectedItem!.description != null)
                    Text(
                      _selectedItem!.description!,
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),
        const Text(
          'AVAILABLE VARIANTS',
          style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2),
        ),
        const SizedBox(height: 15),

        if (variants.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('No variations for this species.', style: TextStyle(color: Colors.white38)),
          ),

        ...variants.map((v) => _buildVariantCard(v)),
      ],
    );
  }

  Widget _buildVariantCard(ShopItemVariant variant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: _safeAssetImage(variant.assetImagePath),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variant.variantCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  '\$${variant.basePrice.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(60, 36),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('BUY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
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
}
