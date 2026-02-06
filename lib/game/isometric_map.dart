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
    // This is an approximation; InteractiveViewer handles the actual panning.
    
    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(500),
      minScale: 0.1,
      maxScale: 4.0,
      child: SizedBox(
        width: (gridWidth + gridHeight) * tileWidth / 2 + 200,
        height: (gridWidth + gridHeight) * tileHeight / 2 + 200,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ..._buildGridTiles(),
          ],
        ),
      ),
    );
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
            child: _buildTile(x, y),
          ),
        );
      }
    }
    return tiles;
  }

  Widget _buildTile(int x, int y) {
    // Check if there is an item at this position
    final dynamic cellData = (matrix.length > y && matrix[y].length > x) 
        ? matrix[y][x] 
        : null;

    return SizedBox(
      width: tileWidth,
      height: tileHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base Grass Tile - Transformed to look isometric
          // We start with a square, rotate it 45 degrees, and flatten it.
          // BUT, since we are placing them at Iso coordinates, we just need to draw a diamond shape.
          // The easiest way for a seamless texture is to use a CustomClipper or a specific Image.
          // Here we will use a Rhombus shape Container with the image pattern.
          
          ClipPath(
            clipper: _IsoTileClipper(),
            child: Image.asset(
              'assets/game_images/textures/grass_land.jpg',
              width: tileWidth,
              height: tileWidth, // Square source
              fit: BoxFit.cover,
            ),
          ),
          
          // Debug/Border to see grid
          CustomPaint(
            size: const Size(tileWidth, tileHeight),
            painter: _GridBorderPainter(),
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

class _GridBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
