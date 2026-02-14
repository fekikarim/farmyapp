import 'package:flutter/material.dart';
import 'animated_sprite.dart';

class IsometricMap extends StatefulWidget {
  final int gridWidth;
  final int gridHeight;
  final List<dynamic> matrix;
  final Function(int x, int y)? onTileTap;

  const IsometricMap({
    super.key,
    required this.gridWidth,
    required this.gridHeight,
    required this.matrix,
    this.onTileTap,
  });

  @override
  State<IsometricMap> createState() => _IsometricMapState();
}

class _IsometricMapState extends State<IsometricMap> {
  // Constants
  static const double tileWidth = 64.0;
  static const double tileHeight = 32.0;

  // Track selected tile
  int? _selectedX;
  int? _selectedY;

  @override
  Widget build(BuildContext context) {
    // Calculate total size to center the map
    // We add padding for the background
    const int backgroundPadding = 10;
    
    // Generate ALL tiles (Background + Foreground)
    List<Widget> sortedTiles = _buildSortedTiles(backgroundPadding);

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(500),
      minScale: 0.1,
      maxScale: 4.0,
      child: SizedBox(
        width: (widget.gridWidth + widget.gridHeight + backgroundPadding * 2) * tileWidth / 2 + 200,
        height: (widget.gridWidth + widget.gridHeight + backgroundPadding * 2) * tileHeight / 2 + 200,
        child: Stack(
          clipBehavior: Clip.none,
          children: sortedTiles,
        ),
      ),
    );
  }

  List<Widget> _buildSortedTiles(int padding) {
    // We need a list of "TileData" to sort before creating Widgets
    List<_TileEntry> entries = [];
    
    // Center offset
    double offsetX = (widget.gridHeight * tileWidth / 2);
    double offsetY = 100;

    // 1. Generate Background Tiles
    for (int y = -padding; y < widget.gridHeight + padding; y++) {
      for (int x = -padding; x < widget.gridWidth + padding; x++) {
        
        bool isForeground = (x >= 0 && x < widget.gridWidth && y >= 0 && y < widget.gridHeight);
        
        // Determine if this is a "border tree" row (within 2 tiles of the main grid)
        // Only for background tiles on the TOP sides (x < 0 or y < 0)
        bool isTreeRow = false;
        String? treeAsset;
        String? fenceAsset;

        double fenceDx = 0;
        double fenceDy = 0;

        if (!isForeground) {
          // 1. Forest Decoration (Top sides only)
          bool isTopSide = (x >= -2 && x < 0) || (y >= -2 && y < 0);
          if (isTopSide) {
            int hash = (x * 7 + y * 13).abs();
            if ((hash % 5) < 2) {
              isTreeRow = true;
              int variant = (hash % 3) + 1;
              treeAsset = 'assets/game_images/3d/outside_tree/tree$variant.png';
            }
          }

          // 2. Fence Boundary Detection
          // Fence 1: Top-Right (y=-1) and Bottom-Left (y=gridHeight)
          // Fence 2: Top-Left (x=-1) and Bottom-Right (x=gridWidth)
          
          bool isInXRange = (x >= 0 && x < widget.gridWidth);
          bool isInYRange = (y >= 0 && y < widget.gridHeight);

          if (y == -1 && isInXRange) {
             fenceAsset = 'assets/game_images/3d/outside_fance/fance1.png';
             fenceDx = -tileWidth / 4;
             fenceDy = -tileHeight / 4 - 12; 
          } else if (y == widget.gridHeight && isInXRange) {
             fenceAsset = 'assets/game_images/3d/outside_fance/fance1.png';
             fenceDx = tileWidth / 4;
             fenceDy = tileHeight / 4 - 12; 
          } else if (x == -1 && isInYRange) {
             fenceAsset = 'assets/game_images/3d/outside_fance/fance2.png';
             fenceDx = tileWidth / 4;
             fenceDy = -tileHeight / 4 - 12;
          } else if (x == widget.gridWidth && isInYRange) {
             fenceAsset = 'assets/game_images/3d/outside_fance/fance2.png';
             fenceDx = -tileWidth / 4;
             fenceDy = tileHeight / 4 - 12;
          }
        }

        double isoX = (x - y) * (tileWidth / 2) + offsetX;
        double isoY = (x + y) * (tileHeight / 2) + offsetY;

        entries.add(_TileEntry(
          x: x,
          y: y,
          isoX: isoX,
          isoY: isoY,
          isForeground: isForeground,
          hasTree: isTreeRow,
          treeAsset: treeAsset,
          fenceAsset: fenceAsset,
          fenceDx: fenceDx,
          fenceDy: fenceDy,
        ));
      }
    }

    // 2. Sort by Depth
    entries.sort((a, b) {
      int depthA = a.x + a.y;
      int depthB = b.x + b.y;
      if (depthA != depthB) {
        return depthA.compareTo(depthB);
      }
      return a.x.compareTo(b.x);
    });

    // 3. Convert to Widgets
    return entries.map((e) {
      return Positioned(
        left: e.isoX,
        top: e.isoY,
        child: _buildTile(
          e.x, e.y, 
          isBackground: !e.isForeground, 
          hasTree: e.hasTree, 
          treeAsset: e.treeAsset, 
          fenceAsset: e.fenceAsset,
          fenceDx: e.fenceDx,
          fenceDy: e.fenceDy,
        ),
      );
    }).toList();
  }

  Widget _buildTile(int x, int y, {required bool isBackground, bool hasTree = false, String? treeAsset, String? fenceAsset, double fenceDx = 0, double fenceDy = 0}) {
    // Check if there is an item at this position (only for foreground)
    final dynamic cellData = (!isBackground && widget.matrix.length > y && widget.matrix[y].length > x) 
        ? widget.matrix[y][x] 
        : null;

    final String asset = isBackground 
        ? 'assets/game_images/textures/soil_background.jpg'
        : 'assets/game_images/textures/grass_land.jpg';

    // Selection Visibility Logic for Fences (Hide 3 segments: closest + left + right)
    bool hideFence = false;
    if (fenceAsset != null && _selectedX != null && _selectedY != null) {
      // If this is a Fence 1 (Horizontal borders: Top-Right or Bottom-Left)
      // Check if the selected tile's X is close to this fence's X
      if (y == -1 && (_selectedX! - x).abs() <= 1 && _selectedY == 0) hideFence = true;
      if (y == widget.gridHeight && (_selectedX! - x).abs() <= 1 && _selectedY == widget.gridHeight - 1) hideFence = true;
      
      // If this is a Fence 2 (Vertical borders: Top-Left or Bottom-Right)
      // Check if the selected tile's Y is close to this fence's Y
      if (x == -1 && (_selectedY! - y).abs() <= 1 && _selectedX == 0) hideFence = true;
      if (x == widget.gridWidth && (_selectedY! - y).abs() <= 1 && _selectedX == widget.gridWidth - 1) hideFence = true;
    }

    final bool isSelected = _selectedX == x && _selectedY == y;

    return GestureDetector(
      onTap: isBackground ? null : () {
        if (widget.onTileTap != null) {
          widget.onTileTap!(x, y);
        } else {
          setState(() {
            if (_selectedX == x && _selectedY == y) {
              _selectedX = null;
              _selectedY = null;
            } else {
              _selectedX = x;
              _selectedY = y;
            }
          });
        }
      },
      child: SizedBox(
        width: tileWidth,
        height: tileHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Base Tile
            ClipPath(
              clipper: _IsoTileClipper(),
              child: Stack(
                children: [
                   Image.asset(
                    asset,
                    width: tileWidth,
                    height: tileWidth,
                    fit: BoxFit.cover,
                  ),
                  if (isSelected)
                    Container(
                      color: Colors.white.withOpacity(0.3),
                    ),
                ],
              ),
            ),
            
            // Debug/Border
            CustomPaint(
              size: const Size(tileWidth, tileHeight),
              painter: _GridBorderPainter(isBackground: isBackground, isSelected: isSelected),
            ),
    
            // Overlay (if item exists)
            if (cellData != null)
               Positioned(
                 bottom: tileHeight / 4,
                 child: _buildItemSprite(cellData),
               ),
    
            // Tree Overlay
            if (hasTree && treeAsset != null)
              Positioned(
                bottom: tileHeight / 2 - 10,
                child: Image.asset(
                  treeAsset!,
                  width: 100,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),
    
            // Fence Overlay (Hides when adjacent grass is selected)
            if (fenceAsset != null)
               Positioned(
                 bottom: (tileHeight / 2) + fenceDy,
                 left: fenceDx,
                 width: tileWidth,
                 child: AnimatedOpacity(
                   duration: const Duration(milliseconds: 200),
                   opacity: hideFence ? 0.0 : 1.0, 
                   child: Image.asset(
                     fenceAsset!,
                     height: tileHeight * 2,
                     fit: BoxFit.contain,
                   ),
                 ),
               ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemSprite(dynamic cellData) {
    final Map<String, dynamic>? sprites = cellData['sprites'];
    final Map<String, dynamic>? state = cellData['state'];
    
    // Determine status from state or default to idle
    String status = 'idle';
    if (state != null) {
      if (state['status'] != null) {
         status = state['status']; // Direct status override
      } else {
        // Tree/Crop states
        if (state['is_harvested'] == true) status = 'harvested';
        else if (state['is_ready'] == true) status = 'ready'; // Ready to harvest
        else if (state['is_cut'] == true) status = 'cut';
        else if (state['is_withered'] == true) status = 'withered';
        
        // Animal states
        else if (state['is_sick'] == true) status = 'sick';
        else if (state['is_sleeping'] == true) status = 'sleeping';
        else if (state['is_eating'] == true) status = 'eating';
        else if (state['is_walking'] == true) status = 'walking';
        
        // Machine states
        else if (state['is_processing'] == true) status = 'processing';
        else if (state['is_finished'] == true) status = 'finished';
        else if (state['is_broken'] == true) status = 'broken';

        // General
        else if (state['is_pending'] == true) status = 'pending';
      }
    }

    // Try to find the specific sprite, fallback to idle, then fallback to unharvested if available
    final String? spritePath = sprites?[status] ?? 
                              sprites?['idle'] ?? 
                              sprites?['unharvested'] ?? // Legacy/Accessory fallback
                              sprites?['unhavesed']; // Typos in old DB?

    if (spritePath != null) {
      return AnimatedSprite(
        baseAssetPath: spritePath,
        width: 64,
        height: 80,
        fit: BoxFit.contain,
      );
    }

    // Fallback to variant image if no sprites
    return const Icon(Icons.house, color: Colors.brown, size: 32);
  }
}

class _GridBorderPainter extends CustomPainter {
  final bool isBackground;
  final bool isSelected;
  _GridBorderPainter({this.isBackground = false, this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected 
          ? Colors.yellow.withOpacity(0.8) 
          : (isBackground ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2 : 1;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GridBorderPainter oldDelegate) => 
      oldDelegate.isSelected != isSelected;
}

class _IsoTileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TileEntry {
  final int x;
  final int y;
  final double isoX;
  final double isoY;
  final bool isForeground;
  final bool hasTree;
  final String? treeAsset;
  final String? fenceAsset;
  final double fenceDx;
  final double fenceDy;

  _TileEntry({
    required this.x,
    required this.y,
    required this.isoX,
    required this.isoY,
    required this.isForeground,
    required this.hasTree,
    this.treeAsset,
    this.fenceAsset,
    this.fenceDx = 0,
    this.fenceDy = 0,
  });
}
