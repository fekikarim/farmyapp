import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/land_model.dart';
import 'isometric_map.dart';
import 'land_grid_service.dart';
import 'shop_overlay.dart';
import 'inventory_overlay.dart';
import '../services/shop_service.dart';
import 'asset_manager.dart';

class GameScreen extends StatefulWidget {
  final Land land;

  const GameScreen({super.key, required this.land});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Map<String, dynamic>? _gridData;
  bool _isLoading = true;
  String _loadingMessage = 'Initializing...';
  double? _loadingProgress;

  @override
  void initState() {
    super.initState();
    // Force portrait for vertical shop as requested
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // 1. Fetch Grid Data
    _updateLoading('Fetching Farm Data...', null);

    try {
      final futures = await Future.wait([
        LandGridService.fetchLandGrid(widget.land.id),
        _precacheAssets(),
      ]);

      if (mounted) {
        setState(() {
          _gridData = futures[0] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing game: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = 'Failed to load farm.';
        });
      }
    }
  }

  Future<bool> _precacheAssets() async {
    _updateLoading('Loading Assets...', null);
    try {
      final assetManager = AssetManager();
      await assetManager.loadAssets([
        'assets/game_images/textures/grass_land.jpg',
        'assets/game_images/textures/soil_background.jpg',
        'assets/game_images/3d/outside_tree/tree1.png',
        'assets/game_images/3d/outside_tree/tree2.png',
        'assets/game_images/3d/outside_tree/tree3.png',
        'assets/game_images/3d/outside_fance/fance1.png',
        'assets/game_images/3d/outside_fance/fance2.png',
      ]);
      return true;
    } catch (e) {
      print('Asset load error: $e');
      return false;
    }
  }

  void _updateLoading(String message, double? progress) {
    if (mounted) {
      setState(() {
        _loadingMessage = message;
        _loadingProgress = progress;
      });
    }
  }

  // Placement State
  bool _isPlacing = false;
  Map<String, dynamic>? _placementItem;
  Map<String, dynamic>? _placementFootprint; // Store footprint data
  int? _pendingX;
  int? _pendingY;
  bool _isPendingValid = false;

  void _startPlacement(dynamic item) async {
    // 1. Enter placement mode immediately
    setState(() {
      _isPlacing = true;
      _placementItem = item;
      _placementFootprint = null; // Loading
    });

    // 2. Fetch footprint
    final category = item['asset_category']; // e.g., 'animal'
    final variantId = item['variant_id'];

    if (category != null && variantId != null) {
       final footprint = await ShopService.getAssetFootprint(category: category, variantId: variantId);
       if (mounted && _isPlacing && _placementItem == item) {
         setState(() {
           _placementFootprint = footprint;
         });
       }
    }
  }

  void _cancelPlacement() {
    setState(() {
      _isPlacing = false;
      _placementItem = null;
      _placementFootprint = null;
      _pendingX = null;
      _pendingY = null;
      _isPendingValid = false;
    });
  }

  void _onMapTap(int x, int y) {
    if (!_isPlacing) return;
    
    setState(() {
      _pendingX = x;
      _pendingY = y;
      _isPendingValid = _validatePlacement(x, y);
    });
  }

  bool _validatePlacement(int x, int y) {
    if (_placementFootprint == null) return false;
    final grid = _gridData?['matrix'] as List?;
    if (grid == null) return false;

    final squares = _placementFootprint!['squares'] as List;
    final int width = _gridData?['grid_width'] ?? widget.land.gridWidth;
    final int height = _gridData?['grid_height'] ?? widget.land.gridHeight;

    for (var sq in squares) {
      int tx = x + (sq['x'] as int);
      int ty = y + (sq['y'] as int);

      if (tx < 0 || tx >= width || ty < 0 || ty >= height) return false;
      if (grid[ty][tx] != null) return false;
    }
    return true;
  }

  Future<void> _handlePlacement() async {
    if (_placementItem == null || _pendingX == null || _pendingY == null || !_isPendingValid) return;

    final requestId = _placementItem!['id'];
    final x = _pendingX!;
    final y = _pendingY!;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Placing item...'), duration: Duration(milliseconds: 500)),
    );

    final success = await ShopService.placeItem(
      requestId: requestId,
      x: x,
      y: y,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isPlacing = false;
        _placementItem = null;
        _placementFootprint = null;
        // Refresh grid
        _updateLoading('Updating...', null);
        _isLoading = true; // Trigger reload
      });
      _initializeApp(); // Reload grid
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item placed successfully!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place item. Try elsewhere.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D231E), // Fallback Dark Soil
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_loadingMessage),
                ],
              ),
            )
          : _gridData == null
          ? _buildErrorScreen()
          : IsometricMap(
              gridWidth: _gridData!['grid_width'] ?? widget.land.gridWidth,
              gridHeight: _gridData!['grid_height'] ?? widget.land.gridHeight,
              matrix: _gridData!['matrix'], 
              onTileTap: _isPlacing ? _onMapTap : null,
              // Pass placement data to map
              placementMode: _isPlacing,
              placementFootprint: _placementFootprint,
              placementItem: _placementItem,
              externalSelectionX: _pendingX,
              externalSelectionY: _pendingY,
            ),
      floatingActionButton: !_isLoading && !_isPlacing
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'close_game',
                  child: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'open_shop',
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  child: const Icon(Icons.shopping_basket),
                  onPressed: () => _showShop(context),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'open_inventory',
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  child: const Icon(Icons.inventory_2),
                  onPressed: () => _showInventory(context),
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomSheet: _isPlacing
          ? Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Expanded(
                      child: Column(
                         mainAxisSize: MainAxisSize.min,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                             Text(
                              'Placing: ${_placementItem?['details']?['name'] ?? 'Item'}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (_placementFootprint == null)
                               const Text(
                                 'Loading footprint...',
                                 style: TextStyle(color: Colors.grey, fontSize: 12),
                               )
                            else 
                               Text(
                                 'Size: ${_placementFootprint!['base_size']['width']}x${_placementFootprint!['base_size']['height']}',
                                 style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                               ),
                         ]
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: (_isPlacing && _isPendingValid) ? _handlePlacement : null,
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(0, 56),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _cancelPlacement,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _showShop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ShopOverlay(preSelectedLandId: widget.land.id),
      ),
    );
  }

  void _showInventory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder:
            (context) => InventoryOverlay(
              initialLandId: widget.land.id,
              onPlaceItem: _startPlacement,
            ),
      ),
    );
  }



  Widget _buildLoadingScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF2C3E50), // Dark nice background
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo or Icon
          const Icon(Icons.landscape, size: 80, color: Colors.greenAccent),
          const SizedBox(height: 20),

          Text(
            'FARMY',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),

          // Loading Bar
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              value: _loadingProgress, // null for indeterminate
              backgroundColor: Colors.white10,
              color: Colors.greenAccent,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            _loadingMessage,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text(
            'Failed to load farm',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _initializeApp();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Keep portrait when leaving (app default)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
