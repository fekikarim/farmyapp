import 'package:flutter/material.dart';

class IsometricMap extends StatelessWidget {
  final int gridWidth;
  final int gridHeight;
  final List<dynamic> matrix;

  // Constants
  static const double tileWidth = 64.0;
  static const double tileHeight = 32.0;

  const IsometricMap({
    super.key,
    required this.gridWidth,
    required this.gridHeight,
    required this.matrix,
  });

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
        width: (gridWidth + gridHeight + backgroundPadding * 2) * tileWidth / 2 + 200,
        height: (gridWidth + gridHeight + backgroundPadding * 2) * tileHeight / 2 + 200,
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
    double offsetX = (gridHeight * tileWidth / 2);
    double offsetY = 100;

    // 1. Generate Background Tiles
    for (int y = -padding; y < gridHeight + padding; y++) {
      for (int x = -padding; x < gridWidth + padding; x++) {
        
        // Skip if inside the main grid (Foreground handled later? No, let's handle everything in one loop if possible, 
        // OR just add everything to the list and sort.)
        
        bool isForeground = (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight);
        
        // Determine if this is a "border tree" row (within 2 tiles of the main grid)
        // Only for background tiles on the TOP sides (x < 0 or y < 0)
        bool isTreeRow = false;
        String? treeAsset;

        if (!isForeground) {
          // Top-Left border (x is negative) or Top-Right border (y is negative)
          bool isTopSide = (x >= -2 && x < 0) || (y >= -2 && y < 0);
          
          if (isTopSide) {
            // Pseudo-random placement based on coordinates to keep it stable
            // 40% chance of a tree
            int hash = (x * 7 + y * 13).abs();
            if ((hash % 5) < 2) {
              isTreeRow = true;
              // Pick one of 3 trees
              int variant = (hash % 3) + 1;
              treeAsset = 'assets/game_images/3d/outside_tree/tree$variant.png';
            }
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
        ));
      }
    }

    // 2. Sort by Depth (Painter's Algorithm for Isometric)
    // In isometric, depth is roughly (x + y). Lower values are "behind" higher values.
    // We want to draw background first? No, we want to draw back-to-front.
    // So distinct (x+y) sums.
    entries.sort((a, b) {
      int depthA = a.x + a.y;
      int depthB = b.x + b.y;
      if (depthA != depthB) {
        return depthA.compareTo(depthB);
      }
      // Secondary sort to prevent flickering (arbitrary but consistent)
      return a.x.compareTo(b.x);
    });

    // 3. Convert to Widgets
    return entries.map((e) {
      return Positioned(
        left: e.isoX,
        top: e.isoY,
        child: _buildTile(e.x, e.y, isBackground: !e.isForeground, hasTree: e.hasTree, treeAsset: e.treeAsset),
      );
    }).toList();
  }

  Widget _buildTile(int x, int y, {required bool isBackground, bool hasTree = false, String? treeAsset}) {
    // Check if there is an item at this position (only for foreground)
    final dynamic cellData = (!isBackground && matrix.length > y && matrix[y].length > x) 
        ? matrix[y][x] 
        : null;

    final String asset = isBackground 
        ? 'assets/game_images/textures/soil_background.jpg'
        : 'assets/game_images/textures/grass_land.jpg';

    return SizedBox(
      width: tileWidth,
      height: tileHeight, // The base tile height
      child: Stack(
        clipBehavior: Clip.none, // Allow tree to overflow upwards
        alignment: Alignment.center,
        children: [
          // Base Tile - Transformed to look isometric
          ClipPath(
            clipper: _IsoTileClipper(),
            child: Image.asset(
              asset,
              width: tileWidth,
              height: tileWidth, // Square source
              fit: BoxFit.cover,
            ),
          ),
          
          // Debug/Border
          CustomPaint(
            size: const Size(tileWidth, tileHeight),
            painter: _GridBorderPainter(isBackground: isBackground),
          ),

          // Overlay (if item exists)
          if (cellData != null)
             Positioned(
               bottom: tileHeight / 4,
               child: const Icon(Icons.house, color: Colors.brown, size: 32),
             ),

          // Tree Overlay (if background border)
          if (hasTree && treeAsset != null)
            Positioned(
              bottom: tileHeight / 2 - 10, // Adjust vertical position to stand on tile
              child: Image.asset(
                treeAsset!,
                width: 100, // Adjust size as needed
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}

class _GridBorderPainter extends CustomPainter {
  final bool isBackground;
  _GridBorderPainter({this.isBackground = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isBackground ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GridBorderPainter oldDelegate) => false;
}

class _IsoTileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Return a Rhombus shape
    // Center is (w/2, h/2)
    // Top: (w/2, 0)
    // Right: (w, h/2)
    // Bottom: (w/2, h)
    // Left: (0, h/2)
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

  _TileEntry({
    required this.x,
    required this.y,
    required this.isoX,
    required this.isoY,
    required this.isForeground,
    required this.hasTree,
    this.treeAsset,
  });
}


