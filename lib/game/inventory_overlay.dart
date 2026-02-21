import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/shop_service.dart';
import '../services/land_rental_service.dart';
import '../models/land_rental_model.dart';
import 'shop_overlay.dart';

class InventoryOverlay extends StatefulWidget {
  final String? initialLandId;
  final Function(dynamic item)? onPlaceItem;

  const InventoryOverlay({
    super.key,
    this.initialLandId,
    this.onPlaceItem,
  });

  @override
  State<InventoryOverlay> createState() => _InventoryOverlayState();
}

class _InventoryOverlayState extends State<InventoryOverlay>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _inventory = [];
  List<LandRental> _rentedLands = [];
  LandRental? _selectedLand;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Rented Lands
      final lands = await LandRentalService.getMyRentalsAsInvestor();

      // 2. Set Default Land
      if (mounted) {
        setState(() {
          _rentedLands = lands;
          if (widget.initialLandId != null) {
            _selectedLand = _rentedLands.firstWhere(
              (r) => r.landId == widget.initialLandId,
              orElse: () => _rentedLands.isNotEmpty
                  ? _rentedLands.first
                  : _rentedLands.first, // Placeholder fallback
            );
            // Re-check if firstWhere found something or fallback to null (All Lands)
            if (_selectedLand?.landId != widget.initialLandId) {
              _selectedLand = null;
            }
          }
        });
      }

      // 3. Load Inventory
      await _loadInventory();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data. Please try again.';
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await ShopService.getInvestorInventory(
        landId: _selectedLand?.landId,
      );
      if (mounted) {
        setState(() {
          _inventory = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load inventory. Please try again.';
        });
      }
    }
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
                _buildTabBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.greenAccent,
                          ),
                        )
                      : _errorMessage != null
                      ? _buildErrorView()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildInventoryGrid('ALL'),
                            _buildInventoryGrid('PENDING'),
                            _buildInventoryGrid('APPROVED'),
                            _buildInventoryGrid('REJECTED'),
                          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Row(
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
              Expanded(
                child: Text(
                  'MY INVENTORY',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (_rentedLands.isNotEmpty)
                Flexible(
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<LandRental>(
                        isExpanded: true,
                        value: _selectedLand,
                        hint: const Text(
                          'All Lands',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.greenAccent,
                        ),
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        items: [
                          const DropdownMenuItem<LandRental>(
                            value: null,
                            child: Text('All Lands'),
                          ),
                          ..._rentedLands.map((land) {
                            return DropdownMenuItem<LandRental>(
                              value: land,
                              child: Text(
                                land.land?.name ?? 'Unknown',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (LandRental? newValue) {
                          if (_selectedLand != newValue) {
                            setState(() {
                              _selectedLand = newValue;
                            });
                            _loadInventory();
                          }
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 45,
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
        tabs: const [
          Tab(text: 'ALL'),
          Tab(text: 'PENDING'),
          Tab(text: 'APPROVED'),
          Tab(text: 'REJECTED'),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid(String filterStatus) {
    // Filter items based on status
    final filteredItems = _inventory.where((item) {
      if (filterStatus == 'ALL') return true;
      final status = (item['status'] ?? 'PENDING').toString().toUpperCase();
      return status == filterStatus;
    }).toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'No $filterStatus items found',
              style: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6, // Taller card to prevent overflow
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final land = item['land'] ?? {};
        final details = item['details'] ?? {};
        final status = (item['status'] ?? 'PENDING').toString().toUpperCase();
        final bool isPlaced = item['placed_item'] != null;

        return GestureDetector(
          onTap: () {
            if (status == 'APPROVED') {
              _showItemActions(context, item);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E293B), // Slate-800
                  const Color(0xFF0F172A), // Slate-900
                ],
              ),
              borderRadius: BorderRadius.circular(16), // More formal radius
              border: Border.all(
                color: status == 'APPROVED'
                    ? const Color(0xFF4ADE80).withOpacity(0.5)
                    : Colors.white.withOpacity(0.08),
                width: status == 'APPROVED' ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section with Status Badge
                Expanded(
                  flex: 4, // Give more prominence to the image area
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          24,
                        ), // More breathing room
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: _buildItemImage(
                          details['image_url'],
                          category: item['asset_category'],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _buildStatusBadge(status),
                      ),
                      // Hedera verification badge
                      if (item['hedera_transaction_id'] != null)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _buildHederaBadge(item['hedera_transaction_id'].toString()),
                        ),
                      if (isPlaced)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PLACED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Info Section
                Expanded(
                  flex: 3, // Adjusted ratio
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (details['name'] ??
                                      item['asset_category'] ??
                                      'Item')
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF4ADE80), // Green-400
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatVariantName(
                                details['variant_name'] ??
                                    item['variant_id'] ??
                                    'Unknown',
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize:
                                    14, // Reduced from 16 to prevent overflow
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Location / Footer
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  land['name'] ?? 'Unplaced',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
      },
    );
  }

  String _formatVariantName(String rawName) {
    if (rawName.isEmpty) return rawName;
    return rawName
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'APPROVED':
        color = const Color(0xFF4ADE80); // Green-400
        icon = Icons.check_circle_rounded;
        break;
      case 'REJECTED':
        color = const Color(0xFFF87171); // Red-400
        icon = Icons.cancel_rounded;
        break;
      case 'PENDING':
      default:
        color = const Color(0xFFFBBF24); // Amber-400
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 10, color: color),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHederaBadge(String txId) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.verified, color: Color(0xFF9B59B6), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'TxID: ${txId.length > 20 ? '${txId.substring(0, 20)}...' : txId}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.6), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 9, color: Color(0xFF9B59B6)),
                SizedBox(width: 3),
                Text(
                  'HEDERA',
                  style: TextStyle(
                    color: Color(0xFF9B59B6),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInventory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Builds an enhanced image widget with shimmer loading, error handling,
  /// and smooth transitions for a polished user experience.
  Widget _buildItemImage(String? url, {String? category}) {
    if (url == null || url.isEmpty) {
      return _buildImagePlaceholder(category);
    }

    // Check if it's a network URL
    if (url.startsWith('http')) {
      return _NetworkItemImage(url: url, category: category);
    }

    // Handle database paths like '/icons/animals/cow.png'
    // Map to 'assets/game_images/icons/animals/cow.png'
    String assetPath = url;
    if (url.startsWith('/')) {
      assetPath = 'assets/game_images$url';
    } else if (!url.startsWith('assets/')) {
      assetPath = 'assets/game_images/$url';
    }

    // Local asset handling with shimmer-like loading
    return _LocalAssetImage(assetPath: assetPath, category: category);
  }

  /// Builds a category-aware placeholder icon
  Widget _buildImagePlaceholder(String? category) {
    IconData icon;
    switch (category?.toLowerCase()) {
      case 'animal':
        icon = Icons.pets_rounded;
        break;
      case 'vegetation':
        icon = Icons.grass_rounded;
        break;
      case 'tree':
        icon = Icons.park_rounded;
        break;
      case 'structure':
        icon = Icons.home_work_rounded;
        break;
      case 'machine':
        icon = Icons.precision_manufacturing_rounded;
        break;
      default:
        icon = Icons.inventory_2_outlined;
    }
    return Icon(icon, size: 64, color: Colors.white24);
  }

  void _showItemActions(BuildContext context, dynamic item) {
    final itemLandId = (item['land_id'] ?? item['land']?['id'])?.toString();
    final bool isPlaced = item['placed_item'] != null;
    final isMatchingLand =
        widget.initialLandId != null && itemLandId == widget.initialLandId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Item Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                context,
                isPlaced ? 'Already Placed' : (isMatchingLand ? 'Add to Land' : 'Wrong Land'),
                Icons.landscape_rounded,
              (isMatchingLand && !isPlaced)
                  ? () {
                      Navigator.pop(context); // Close sheet
                      if (widget.onPlaceItem != null) {
                        Navigator.pop(context); // Close inventory
                        widget.onPlaceItem!(item);
                      } else {
                        _showComingSoonDialog(context);
                      }
                    }
                  : null, // Disabled
              isPrimary: isMatchingLand && !isPlaced,
                subtitle: isPlaced 
                    ? 'This item is already on the map.'
                    : (isMatchingLand ? null : 'This item belongs to another land.'),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                context,
                'Buy More',
                Icons.shopping_cart_outlined,
                () {
                  Navigator.pop(context); // Close sheet
                  Navigator.pop(context); // Close inventory
                  // Open Shop, passing the current selected land if any
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ShopOverlay(preSelectedLandId: _selectedLand?.landId),
                  ).then((_) {
                    // Refresh inventory when returning from shop
                    _loadInventory();
                  });
                },
                isPrimary: false,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback? onTap, {
    bool isPrimary = true,
    String? subtitle,
  }) {
    final bool isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary
              ? (isDisabled
                    ? Colors.grey.withOpacity(0.1)
                    : const Color(0xFF4ADE80))
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary
                      ? (isDisabled ? Colors.white38 : const Color(0xFF0F172A))
                      : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary
                        ? (isDisabled
                              ? Colors.white38
                              : const Color(0xFF0F172A))
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Coming Soon', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This feature is under development. You will be able to place items on your land soon!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF4ADE80))),
          ),
        ],
      ),
    );
  }
}

/// A StatefulWidget that handles network image loading with:
/// - Shimmer loading animation
/// - Smooth fade-in transition when loaded
/// - Error handling with retry capability
/// - Category-aware placeholder fallbacks
class _NetworkItemImage extends StatefulWidget {
  final String url;
  final String? category;

  const _NetworkItemImage({required this.url, this.category});

  @override
  State<_NetworkItemImage> createState() => _NetworkItemImageState();
}

class _NetworkItemImageState extends State<_NetworkItemImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleImageError() {
    if (_retryCount < _maxRetries) {
      setState(() {
        _retryCount++;
        _hasError = false;
        _isLoading = true;
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category?.toLowerCase()) {
      case 'animal':
        return Icons.pets_rounded;
      case 'vegetation':
        return Icons.grass_rounded;
      case 'tree':
        return Icons.park_rounded;
      case 'structure':
        return Icons.home_work_rounded;
      case 'machine':
        return Icons.precision_manufacturing_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getCategoryIcon(), size: 48, color: Colors.white24),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _retryCount = 0;
                _hasError = false;
                _isLoading = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 12, color: Colors.white38),
                  SizedBox(width: 4),
                  Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Shimmer loading placeholder
        if (_isLoading)
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                    stops: [0.0, _shimmerController.value, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  size: 32,
                  color: Colors.white.withOpacity(0.2),
                ),
              );
            },
          ),

        // Actual image with fade-in animation
        AnimatedOpacity(
          opacity: _isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Image.network(
            // Add cache-busting for retries if needed
            _retryCount > 0
                ? '${widget.url}${widget.url.contains('?') ? '&' : '?'}retry=$_retryCount'
                : widget.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                // Image loaded successfully
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _isLoading) {
                    setState(() => _isLoading = false);
                  }
                });
                return child;
              }
              // Still loading - shimmer handles this
              return const SizedBox.shrink();
            },
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _handleImageError();
              });
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

/// A StatefulWidget that handles local asset image loading with:
/// - Shimmer loading animation
/// - Smooth fade-in transition when loaded
/// - Error handling with category-aware placeholders
class _LocalAssetImage extends StatefulWidget {
  final String assetPath;
  final String? category;

  const _LocalAssetImage({required this.assetPath, this.category});

  @override
  State<_LocalAssetImage> createState() => _LocalAssetImageState();
}

class _LocalAssetImageState extends State<_LocalAssetImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Pre-check asset availability
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    // Small delay for shimmer effect visibility
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon() {
    switch (widget.category?.toLowerCase()) {
      case 'animal':
        return Icons.pets_rounded;
      case 'vegetation':
        return Icons.grass_rounded;
      case 'tree':
        return Icons.park_rounded;
      case 'structure':
        return Icons.home_work_rounded;
      case 'machine':
        return Icons.precision_manufacturing_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Icon(_getCategoryIcon(), size: 48, color: Colors.white24);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Shimmer loading placeholder
        if (_isLoading)
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.05),
                    ],
                    stops: [0.0, _shimmerController.value, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  size: 32,
                  color: Colors.white.withOpacity(0.2),
                ),
              );
            },
          ),

        // Actual image with fade-in animation
        AnimatedOpacity(
          opacity: _isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Image.asset(
            widget.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_hasError) {
                  setState(() => _hasError = true);
                }
              });
              return Icon(_getCategoryIcon(), size: 48, color: Colors.white24);
            },
          ),
        ),
      ],
    );
  }
}
