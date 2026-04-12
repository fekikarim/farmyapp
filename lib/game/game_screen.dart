import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../models/land_model.dart';
import '../../models/land_rental_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/land_provider.dart';
import '../screens/investor/widgets/investor_workforce_screen.dart';
import 'isometric_map.dart';
import 'land_grid_service.dart';
import 'shop_overlay.dart';
import 'inventory_overlay.dart';
import '../../widgets/task_assignment_sheet.dart';
import '../../widgets/worker_tasks_sheet.dart';
import '../screens/investment_agent_screen.dart';
import '../services/shop_service.dart';
import '../../services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'asset_manager.dart';

class GameScreen extends StatefulWidget {
  final Land land;

  const GameScreen({super.key, required this.land});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _gridData;
  bool _isLoading = true;
  String _loadingMessage = 'Initializing...';
  double? _loadingProgress;

  // Animation for Floating Menu
  late AnimationController _menuController;
  late Animation<double> _menuAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutBack,
    );

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
    _updateLoading('Fetching farm data...', 0.1);

    try {
      final landProvider = context.read<LandProvider>();
      final authProvider = context.read<AuthProvider>();
      final gameProvider = context.read<GameProvider>();

      final baseAssetsFuture = _precacheAssets();
      final rentalsFuture = authProvider.user?.role == 'investor'
          ? landProvider.fetchMyRentals(true)
          : null;

      final gridData = await LandGridService.fetchLandGrid(widget.land.id);
      _updateLoading('Preparing land geometry...', 0.4);

      await _precacheGridAssets(gridData);
      _updateLoading('Finalizing world...', 0.8);

      await baseAssetsFuture;
      if (rentalsFuture != null) {
        await rentalsFuture;
      }

      if (mounted) {
        final int gw = gridData['grid_width'] ?? widget.land.gridWidth;
        final int gh = gridData['grid_height'] ?? widget.land.gridHeight;
        final playableMask = _resolvePlayableMask(
          gridData['playable_mask'],
          gw,
          gh,
        );

        gridData['playable_mask'] = playableMask;

        setState(() {
          _gridData = gridData;
          _loadingProgress = 1.0;
          _isLoading = false;
        });

        unawaited(_warmupRemainingGridAssets(gridData));

        // Load workers assigned to this land
        gameProvider.loadWorkersForLand(
          widget.land.id,
          gridWidth: gw,
          gridHeight: gh,
          playableMask: playableMask,
        );
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

  Future<void> _precacheGridAssets(Map<String, dynamic> gridData) async {
    final matrix = gridData['matrix'];
    if (matrix is! List) return;

    _updateLoading('Warming up nearby assets...', 0.6);
    final allPaths = _collectGridWarmupPaths(matrix);
    if (allPaths.isEmpty) return;

    // Prioritize a fast first paint, then continue warming in background.
    final critical = allPaths.take(64).toList(growable: false);
    await AssetManager().loadAssets(critical);
  }

  Future<void> _warmupRemainingGridAssets(Map<String, dynamic> gridData) async {
    final matrix = gridData['matrix'];
    if (matrix is! List) return;

    final allPaths = _collectGridWarmupPaths(matrix).toList(growable: false);
    if (allPaths.length <= 64) return;

    final remaining = allPaths.sublist(
      64,
      allPaths.length > 260 ? 260 : allPaths.length,
    );
    if (remaining.isEmpty) return;
    await AssetManager().loadAssets(remaining);
  }

  Set<String> _collectGridWarmupPaths(List<dynamic> matrix) {
    final paths = <String>{
      'assets/game_images/textures/grass_land.jpg',
      'assets/game_images/textures/soil_background.jpg',
      'assets/game_images/3d/outside_tree/tree1.png',
      'assets/game_images/3d/outside_tree/tree2.png',
      'assets/game_images/3d/outside_tree/tree3.png',
      'assets/game_images/3d/outside_fance/fance1.png',
      'assets/game_images/3d/outside_fance/fance2.png',
    };

    final seenOrigins = <String>{};

    for (final row in matrix) {
      if (row is! List) continue;
      for (final cell in row) {
        if (cell is! Map) continue;

        final originX = cell['origin_x'];
        final originY = cell['origin_y'];
        final variantId = cell['variant_id'];
        final dedupeKey = '$variantId@$originX:$originY';
        if (!seenOrigins.add(dedupeKey)) {
          continue;
        }

        final sprites = cell['sprites'];
        if (sprites is! Map) continue;

        for (final value in sprites.values) {
          if (value is! String || value.isEmpty) continue;
          final normalizedBase = value.startsWith('/')
              ? value.substring(1)
              : value;
          final prefixed = normalizedBase.startsWith('assets/')
              ? normalizedBase
              : 'assets/game_images/$normalizedBase';
          final basePath = prefixed.endsWith('/')
              ? prefixed.substring(0, prefixed.length - 1)
              : prefixed;

          paths.add('$basePath/image0.png');
          paths.add('$basePath/image1.png');
          paths.add('$basePath/image2.png');
        }
      }
    }

    const workerBases = <String>[
      'assets/game_images/sprites/player/idle',
      'assets/game_images/sprites/player/walk/front_left',
      'assets/game_images/sprites/player/walk/front_right',
      'assets/game_images/sprites/player/walk/back_left',
      'assets/game_images/sprites/player/walk/back_right',
    ];
    for (final base in workerBases) {
      paths.add('$base/image0.png');
      paths.add('$base/image1.png');
      paths.add('$base/image2.png');
    }

    return paths;
  }

  Future<bool> _precacheAssets() async {
    _updateLoading('Loading base assets...', 0.25);
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

  List<List<bool>> _resolvePlayableMask(
    dynamic rawMask,
    int width,
    int height,
  ) {
    if (rawMask is List) {
      final parsed = <List<bool>>[];
      for (final row in rawMask) {
        if (row is! List) {
          parsed.clear();
          break;
        }
        parsed.add(row.map((cell) => cell == true).toList());
      }

      final hasExpectedShape =
          parsed.length == height && parsed.every((row) => row.length == width);
      if (hasExpectedShape) {
        return parsed;
      }
    }

    // Fallback keeps backward compatibility with old grid payloads.
    return List<List<bool>>.generate(
      height,
      (_) => List<bool>.filled(width, true),
    );
  }

  bool _isMaskCellPlayable(List<dynamic>? mask, int x, int y) {
    if (mask == null) return true;
    if (y < 0 || y >= mask.length) return false;
    final row = mask[y];
    if (row is! List || x < 0 || x >= row.length) return false;
    return row[x] == true;
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
      final footprint = await ShopService.getAssetFootprint(
        category: category,
        variantId: variantId,
      );
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
    final playableMask = _gridData?['playable_mask'] as List?;
    if (grid == null) return false;

    final squares = _placementFootprint!['squares'] as List;
    final int width = _gridData?['grid_width'] ?? widget.land.gridWidth;
    final int height = _gridData?['grid_height'] ?? widget.land.gridHeight;

    for (var sq in squares) {
      int tx = x + (sq['x'] as int);
      int ty = y + (sq['y'] as int);

      if (tx < 0 || tx >= width || ty < 0 || ty >= height) return false;
      if (!_isMaskCellPlayable(playableMask, tx, ty)) return false;
      if (grid[ty][tx] != null) return false;
    }
    return true;
  }

  void _onItemAction(String actionId, int x, int y, dynamic itemData) {
    if (actionId == 'info') {
      _showItemInfoSheet(itemData, x, y);
    } else if (actionId == 'tasks') {
      final category = itemData['category'] as String? ?? '';
      final variantId = itemData['variant_id'] as String? ?? '';

      if (category.isEmpty || variantId.isEmpty) return;

      final int gridW = _gridData?['grid_width'] ?? widget.land.gridWidth;
      final int gridH = _gridData?['grid_height'] ?? widget.land.gridHeight;
      // Use land_id from item data (now included by backend) or fall back to current land
      final String landId = (itemData['land_id'] as String?)?.isNotEmpty == true
          ? itemData['land_id'] as String
          : widget.land.id;

      // Capture the existing GameProvider BEFORE opening the modal,
      // so the sheet operates on the SAME instance (not a new detached one).
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      showModalBottomSheet(
        context: context,
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        builder: (ctx) => ChangeNotifierProvider<GameProvider>.value(
          value: gameProvider,
          child: TaskAssignmentSheet(
            itemData: itemData,
            category: category,
            variantId: variantId,
            gridWidth: gridW,
            gridHeight: gridH,
            landId: landId,
          ),
        ),
      );
    }
  }

  void _showItemInfoSheet(dynamic itemData, int x, int y) {
    // Grid cell keys from backend: category, variant_id, variant_code, state,
    // sprites, is_active, origin_x, origin_y, footprint_width, footprint_height
    final String category = itemData['category'] as String? ?? 'unknown';
    final String variantId = itemData['variant_id'] as String? ?? '';
    final String variantCode = itemData['variant_code'] as String? ?? '';
    final state = itemData['state'] as Map<String, dynamic>?;
    final bool isActive = itemData['is_active'] != false;
    final int fw = itemData['footprint_width'] ?? 1;
    final int fh = itemData['footprint_height'] ?? 1;

    final String status =
        state?['status'] ?? (isActive ? 'active' : 'inactive');
    final Color statusColor = status == 'active' || status == 'idle'
        ? Colors.green
        : status == 'working'
        ? Colors.blue
        : Colors.orange;

    final String categoryLabel = category
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _fetchVariantDetails(category, variantId),
          builder: (ctx, snap) {
            final variant = snap.data;
            // Name: from type.name; fallback to variant_code
            final String name = variant?['type']?['name'] ?? variantCode;
            final String description = variant?['type']?['description'] ?? '';
            final Map<String, dynamic> attrs = Map<String, dynamic>.from(
              variant?['attributes'] ?? {},
            );

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _categoryIcon(category),
                          color: Colors.green.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            snap.connectionState == ConnectionState.waiting
                                ? const SizedBox(
                                    height: 20,
                                    child: LinearProgressIndicator(
                                      minHeight: 3,
                                    ),
                                  )
                                : Text(
                                    name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                            const SizedBox(height: 2),
                            Text(
                              categoryLabel,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Stats
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _statChip(Icons.grid_3x3, 'Position', '($x, $y)'),
                      _statChip(Icons.aspect_ratio, 'Size', '${fw}×$fh tiles'),
                      if (variant?['base_price'] != null)
                        _statChip(
                          Icons.monetization_on_outlined,
                          'Base price',
                          '${variant!['base_price']}',
                        ),
                      // Render any extra attributes from the variant
                      for (final entry in attrs.entries)
                        if (entry.value != null)
                          _statChip(
                            Icons.info_outline,
                            entry.key.replaceAll('_', ' '),
                            '${entry.value}',
                          ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.check),
                      label: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchVariantDetails(
    String category,
    String variantId,
  ) async {
    if (variantId.isEmpty) return null;
    try {
      final baseUrl = dotenv.get(
        'API_BASE_URL',
        fallback: 'http://192.168.0.133:3001',
      );
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$baseUrl/api/v1/assets/$category/variants/$variantId'),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('_fetchVariantDetails error: $e');
    }
    return null;
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'animal':
        return Icons.pets;
      case 'tree':
        return Icons.park;
      case 'vegetation':
        return Icons.grass;
      case 'machine':
        return Icons.agriculture;
      case 'structure':
        return Icons.home_work;
      default:
        return Icons.category;
    }
  }

  Future<void> _handlePlacement() async {
    if (_placementItem == null ||
        _pendingX == null ||
        _pendingY == null ||
        !_isPendingValid)
      return;

    final requestId = _placementItem!['id'];
    final x = _pendingX!;
    final y = _pendingY!;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Placing item...'),
        duration: Duration(milliseconds: 500),
      ),
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
        const SnackBar(
          content: Text('Item placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place item. Try elsewhere.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final landProvider = context.watch<LandProvider>();
    final currentUser = authProvider.user;
    final myRentals = landProvider.myRentals;

    bool canManageWorkforce = false;
    // Farmers who own the land can always manage workforce
    if (currentUser?.role == 'farmer' &&
        widget.land.ownerId == currentUser?.id) {
      canManageWorkforce = true;
    }
    // Investors with an active rental can also manage workforce
    if (currentUser?.role == 'investor') {
      final activeRental = myRentals
          .where((r) => r.landId == widget.land.id)
          .firstOrNull;
      if (activeRental != null &&
          activeRental.paymentStatus != PaymentStatus.cancelled &&
          (activeRental.rentalEndDate == null ||
              activeRental.rentalEndDate!.isAfter(DateTime.now()))) {
        canManageWorkforce = true;
      }
    }

    return PopScope(
      canPop: !_isMenuOpen && !_isPlacing,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (_isMenuOpen) {
          _toggleMenu();
          return;
        }

        if (_isPlacing) {
          _cancelPlacement();
          return;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2D231E), // Fallback Dark Soil
        body: _isLoading
            ? _buildLoadingScreen()
            : _gridData == null
            ? _buildErrorScreen()
            : Stack(
                children: [
                  IsometricMap(
                    gridWidth:
                        _gridData!['grid_width'] ?? widget.land.gridWidth,
                    gridHeight:
                        _gridData!['grid_height'] ?? widget.land.gridHeight,
                    matrix: _gridData!['matrix'],
                    playableMask: _gridData!['playable_mask'],
                    onTileTap: _isPlacing ? _onMapTap : null,
                    onItemAction: _onItemAction,
                    // Pass placement data to map
                    placementMode: _isPlacing,
                    placementFootprint: _placementFootprint,
                    placementItem: _placementItem,
                    externalSelectionX: _pendingX,
                    externalSelectionY: _pendingY,
                  ),
                ],
              ),
        floatingActionButton: !_isLoading && !_isPlacing
            ? _buildAnimatedFloatingMenu(canManageWorkforce)
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (_placementFootprint == null)
                              const Text(
                                'Loading footprint...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              )
                            else
                              Text(
                                'Size: ${_placementFootprint!['base_size']['width']}x${_placementFootprint!['base_size']['height']}',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: (_isPlacing && _isPendingValid)
                            ? _handlePlacement
                            : null,
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
      ),
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
        builder: (context) => InventoryOverlay(
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

  Widget _buildAnimatedFloatingMenu(bool canManageWorkforce) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isMenuOpen) ...[
          // Workforce Button
          if (canManageWorkforce)
            _buildMenuItem(
              label: 'Workforce',
              icon: Icons.engineering,
              color: Colors.blue.shade600,
              delay: 0,
              onTap: () {
                _toggleMenu();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvestorWorkforceScreen(
                      landId: widget.land.id,
                      landName: widget.land.name,
                    ),
                  ),
                );
              },
            ),

          if (context.read<AuthProvider>().user?.role == 'worker')
            _buildMenuItem(
              label: 'My Tasks',
              icon: Icons.assignment_rounded,
              color: Colors.amberAccent,
              textColor: Colors.black,
              delay: 0,
              onTap: () {
                _toggleMenu();
                showWorkerTasksSheet(context, landId: widget.land.id);
              },
            ),

          // AI Advisor Button
          if (context.read<AuthProvider>().user?.role != 'worker')
            _buildMenuItem(
              label: 'AI Advisor',
              icon: Icons.auto_awesome,
              color: Colors.purpleAccent,
              textColor: Colors.white,
              delay: 25,
              onTap: () {
                _toggleMenu();
                final auth = context.read<AuthProvider>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvestmentAgentScreen(
                      initialMessage:
                          "Analyse my current farm and wallet. What should be my next strategic move in this game session?",
                      initialContext: {
                        'landId': widget.land.id,
                        'credits': auth.user?.credits ?? 0,
                      },
                    ),
                  ),
                );
              },
            ),

          // Inventory Button
          if (context.read<AuthProvider>().user?.role != 'worker')
            _buildMenuItem(
              label: 'Inventory',
              icon: Icons.inventory_2_rounded,
              color: Colors.orangeAccent,
              textColor: Colors.black,
              delay: 50,
              onTap: () {
                _toggleMenu();
                _showInventory(context);
              },
            ),

          // Shop Button
          if (context.read<AuthProvider>().user?.role != 'worker')
            _buildMenuItem(
              label: 'Shop',
              icon: Icons.storefront_rounded,
              color: Colors.greenAccent,
              textColor: Colors.black,
              delay: 100,
              onTap: () {
                _toggleMenu();
                _showShop(context);
              },
            ),

          // Exit Button
          _buildMenuItem(
            label: 'Exit Game',
            icon: Icons.exit_to_app_rounded,
            color: Colors.redAccent,
            delay: 150,
            onTap: () => Navigator.pop(context),
          ),
        ],

        const SizedBox(height: 16),

        // Main Toggle Button
        FloatingActionButton(
          heroTag: 'menu_toggle',
          onPressed: _toggleMenu,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _menuController,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    int delay = 0,
  }) {
    return ScaleTransition(
      scale: _menuAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              heroTag: 'menu_item_$label',
              onPressed: onTap,
              backgroundColor: color,
              foregroundColor: textColor,
              child: Icon(icon),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    // Keep portrait when leaving (app default)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
