import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/land_model.dart';
import 'isometric_map.dart';
import 'land_grid_service.dart';
import 'shop_overlay.dart';

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
      await precacheImage(
        const AssetImage('assets/game_images/textures/grass_land.jpg'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/game_images/textures/soil_background.jpg'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/game_images/3d/outside_tree/tree1.png'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/game_images/3d/outside_tree/tree2.png'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/game_images/3d/outside_tree/tree3.png'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/game_images/3d/outside_fance/fance1.png'),
        context,
      );
      await precacheImage(
        const AssetImage('assets/game_images/3d/outside_fance/fance2.png'),
        context,
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D231E), // Fallback Dark Soil
      body: _isLoading
          ? _buildLoadingScreen()
          : _gridData == null
              ? _buildErrorScreen()
              : IsometricMap(
                  gridWidth: _gridData!['grid_width'],
                  gridHeight: _gridData!['grid_height'],
                  matrix: _gridData!['matrix'],
                ),
      floatingActionButton: !_isLoading
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
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _showShop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ShopOverlay(),
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
          )
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
