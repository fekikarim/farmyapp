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
          children: [
             // Background Tiles (Soil)
             ..._buildBackgroundTiles(backgroundPadding),

             // Foreground Tiles (Grass/Farm)
            ..._buildGridTiles(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundTiles(int padding) {
    List<Widget> tiles = [];
    
    // We want to draw a larger grid around the main grid.
    // Main grid is from (0,0) to (gridWidth, gridHeight)
    // Background grid is from (-padding, -padding) to (gridWidth+padding, gridHeight+padding)
    
    // Center offset (same as main grid)
    double offsetX = (gridHeight * tileWidth / 2);
    double offsetY = 100;

    for (int y = -padding; y < gridHeight + padding; y++) {
      for (int x = -padding; x < gridWidth + padding; x++) {
        
        // Skip if inside the main grid (because main grid renders Grass)
        if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
          continue;
        }

        double isoX = (x - y) * (tileWidth / 2) + offsetX;
        double isoY = (x + y) * (tileHeight / 2) + offsetY;

        // Add Soil Tile
         tiles.add(
          Positioned(
            left: isoX,
            top: isoY,
            child: _buildTile(x, y, isBackground: true),
          ),
        );
      }
    }
    return tiles;
  }

  List<Widget> _buildGridTiles() {
    List<Widget> tiles = [];

    // Center offset
    double offsetX = (gridHeight * tileWidth / 2); // Shift right so (0,0) isn't cut off
    double offsetY = 100; // Top padding

    // Iterate to build tiles
    // Painter's algorithm: Draw furest tiles first (low x + y)
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        // Isometric coordinate transformation
        double isoX = (x - y) * (tileWidth / 2) + offsetX;
        double isoY = (x + y) * (tileHeight / 2) + offsetY;

        tiles.add(
          Positioned(
            left: isoX,
            top: isoY,
            child: _buildTile(x, y, isBackground: false),
          ),
        );
      }
    }
    return tiles;
  }

  Widget _buildTile(int x, int y, {required bool isBackground}) {
    // Check if there is an item at this position (only for foreground)
    final dynamic cellData = (!isBackground && matrix.length > y && matrix[y].length > x) 
        ? matrix[y][x] 
        : null;

    final String asset = isBackground 
        ? 'assets/game_images/textures/soil_background.png'
        : 'assets/game_images/textures/grass_land.jpg';

    return SizedBox(
      width: tileWidth,
      height: tileHeight,
      child: Stack(
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
          
          // Debug/Border to see grid (Optional, maybe lighter for background)
          CustomPaint(
            size: const Size(tileWidth, tileHeight),
            painter: _GridBorderPainter(isBackground: isBackground),
          ),

          // Overlay (if item exists)
          if (cellData != null)
             Positioned(
               bottom: tileHeight / 4, // Adjust for "standing" items
               child: const Icon(Icons.house, color: Colors.brown, size: 32), // Placeholder
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


