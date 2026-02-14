import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'asset_manager.dart';

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
    // Calculate total size
    // We add padding for the background
    const int backgroundPadding = 10;
    
    // Total canvas size estimation
    final double totalWidth = (widget.gridWidth + widget.gridHeight + backgroundPadding * 2) * tileWidth / 2 + 200;
    final double totalHeight = (widget.gridWidth + widget.gridHeight + backgroundPadding * 2) * tileHeight / 2 + 200;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(500),
      minScale: 0.1,
      maxScale: 4.0,
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details, backgroundPadding),
        child: CustomPaint(
          size: Size(totalWidth, totalHeight),
          painter: IsometricMapPainter(
            gridWidth: widget.gridWidth,
            gridHeight: widget.gridHeight,
            matrix: widget.matrix,
            selectedX: _selectedX,
            selectedY: _selectedY,
            backgroundPadding: backgroundPadding,
            assetManager: AssetManager(),
          ),
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details, int padding) {
    // Constants from Painter
     final double offsetX = (widget.gridHeight * tileWidth / 2);
     const double offsetY = 100;

     // Adjust click coordinate relative to the origin of the grid drawing
     double dx = details.localPosition.dx - offsetX;
     double dy = details.localPosition.dy - offsetY;

     // Isometric projection:
     // x_screen = (x_grid - y_grid) * (W/2)
     // y_screen = (x_grid + y_grid) * (H/2)
     
     // Solving for grid coordinates:
     // dy / (H/2) = x + y
     // dx / (W/2) = x - y
     
     // let a = dx / (W/2)
     // let b = dy / (H/2)
     // x = (a + b) / 2
     // y = (b - a) / 2

     double halfW = tileWidth / 2;
     double halfH = tileHeight / 2;

     double a = dx / halfW;
     double b = dy / halfH;

     int gridX = ((a + b) / 2).floor();
     int gridY = ((b - a) / 2).floor();

     // Check bounds
     if (gridX >= 0 && gridX < widget.gridWidth && gridY >= 0 && gridY < widget.gridHeight) {
       if (widget.onTileTap != null) {
         widget.onTileTap!(gridX, gridY);
       } else {
         setState(() {
           if (_selectedX == gridX && _selectedY == gridY) {
             _selectedX = null;
             _selectedY = null;
           } else {
             _selectedX = gridX;
             _selectedY = gridY;
           }
         });
       }
     } else {
        // Tapped outside grid (background)
        // Check if existing selection needs to be cleared
        if (_selectedX != null || _selectedY != null) {
           setState(() {
             _selectedX = null;
             _selectedY = null;
           });
        }
     }
  }
}

class IsometricMapPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final List<dynamic> matrix;
  final int? selectedX;
  final int? selectedY;
  final int backgroundPadding;
  final AssetManager assetManager;

  // Constants
  static const double tileWidth = 64.0;
  static const double tileHeight = 32.0;

  IsometricMapPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.matrix,
    required this.selectedX,
    required this.selectedY,
    required this.backgroundPadding,
    required this.assetManager,
  }) : super(repaint: assetManager);

  @override
  void paint(Canvas canvas, Size size) {
    // Center offset
    double offsetX = (gridHeight * tileWidth / 2);
    double offsetY = 100;

    // We need to sort tiles by depth (x + y) to draw them in correct order
    // Since we are iterating systematically, we just need to iterate in a way that respects depth.
    // Standard double loop (y then x) works for isometric if viewed from one angle,
    // but with negative padding, we need to be careful.
    
    // Let's collect all tasks and sort them, similar to previous widget implementation, 
    // but just storing data, not widgets.
    List<_PaintTask> tasks = [];

    for (int y = -backgroundPadding; y < gridHeight + backgroundPadding; y++) {
      for (int x = -backgroundPadding; x < gridWidth + backgroundPadding; x++) {
        
        bool isForeground = (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight);
        
        // --- Logic copied from previous implementation ---
        bool isTreeRow = false;
        String? treeAsset;
        String? fenceAsset;
        double fenceDx = 0;
        double fenceDy = 0;

        if (!isForeground) {
          // 1. Forest Decoration
          bool isTopSide = (x >= -2 && x < 0) || (y >= -2 && y < 0);
          if (isTopSide) {
            int hash = (x * 7 + y * 13).abs();
            if ((hash % 5) < 2) {
              isTreeRow = true;
              int variant = (hash % 3) + 1;
              treeAsset = 'assets/game_images/3d/outside_tree/tree$variant.png';
            }
          }

          // 2. Fence Boundary
          bool isInXRange = (x >= 0 && x < gridWidth);
          bool isInYRange = (y >= 0 && y < gridHeight);

          if (y == -1 && isInXRange) {
             fenceAsset = 'assets/game_images/3d/outside_fance/fance1.png';
             fenceDx = -tileWidth / 4;
             fenceDy = -tileHeight / 4 - 12; 
          } else if (y == gridHeight && isInXRange) {
             fenceAsset = 'assets/game_images/3d/outside_fance/fance1.png';
             fenceDx = tileWidth / 4;
             fenceDy = tileHeight / 4 - 12; 
          } else if (x == -1 && isInYRange) {
             fenceAsset = 'assets/game_images/3d/outside_fance/fance2.png';
             fenceDx = tileWidth / 4;
             fenceDy = -tileHeight / 4 - 12;
          } else if (x == gridWidth && isInYRange) {
             fenceAsset = 'assets/game_images/3d/outside_fance/fance2.png';
             fenceDx = -tileWidth / 4;
             fenceDy = tileHeight / 4 - 12;
          }
        }

        double isoX = (x - y) * (tileWidth / 2) + offsetX;
        double isoY = (x + y) * (tileHeight / 2) + offsetY;

        // Get cell data if foreground
        dynamic cellData;
        if (isForeground && matrix.length > y && matrix[y].length > x) {
          cellData = matrix[y][x];
        }

        tasks.add(_PaintTask(
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
          cellData: cellData,
        ));
      }
    }

    // Sort by depth
    tasks.sort((a, b) {
      int depthA = a.x + a.y;
      int depthB = b.x + b.y;
      if (depthA != depthB) return depthA.compareTo(depthB);
      return a.x.compareTo(b.x);
    });

    // Paint all tasks
    final Paint paint = Paint();
    
    for (final task in tasks) {
      _paintTile(canvas, paint, task);
    }
  }

  void _paintTile(Canvas canvas, Paint paint, _PaintTask task) {
    // 1. Draw Base Tile
    final String assetPath = task.isForeground 
        ? 'assets/game_images/textures/grass_land.jpg'
        : 'assets/game_images/textures/soil_background.jpg';
    
    final ui.Image? baseImg = assetManager.getImage(assetPath);
    
    if (baseImg != null) {
      // Draw image in a diamond shape? 
      // For performance, we usually draw a pre-masked image or just the image if it has transparency.
      // Since our textures are square/rectangular, we might need to clip them or draw a diamond path if they are not already.
      // But typically isometric tiles are pre-drawn sprites.
      // Assuming textures are just rects, we should clip them used to behave like the widget version.
      // Widget version used `_IsoTileClipper`.
      
      canvas.save();
      canvas.translate(task.isoX, task.isoY);
      
      final Path path = Path();
      path.moveTo(tileWidth / 2, 0);
      path.lineTo(tileWidth, tileHeight / 2);
      path.lineTo(tileWidth / 2, tileHeight);
      path.lineTo(0, tileHeight / 2);
      path.close();
      
      canvas.clipPath(path);
      
      // Draw image covering the tile rect
      // paintImage fits the image into the rect
      paintImage(
        canvas: canvas,
        rect: const Rect.fromLTWH(0, 0, tileWidth, tileHeight), // Height was tileWidth in widget code? (line 214: width: tileWidth, height: tileWidth)
        // Wait, original code said: height: tileWidth (64). But container was tileHeight (32).
        // This means it was drawing a 64x64 image inside a 64x32 clipped area.
        image: baseImg,
        fit: BoxFit.cover,
      );
      
      // Selection highlight
      bool isSelected = selectedX == task.x && selectedY == task.y;
      if (isSelected) {
        canvas.drawColor(Colors.white.withOpacity(0.3), BlendMode.srcOver);
      }
      
      canvas.restore();

      // Border
      canvas.save();
      canvas.translate(task.isoX, task.isoY);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = isSelected ? 2 : 1;
      paint.color = isSelected 
          ? Colors.yellow.withOpacity(0.8) 
          : (task.isForeground ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05));
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    // 2. Draw Items (Overlay)
    if (task.cellData != null) {
       _paintItem(canvas, task);
    }

    // 3. Draw Trees (Decoration)
    if (task.hasTree && task.treeAsset != null) {
      final ui.Image? treeImg = assetManager.getImage(task.treeAsset!);
      if (treeImg != null) {
        // Positioned(bottom: tileHeight / 2 - 10, ...) in widget
        // In local tile coords (0,0 is top-left of 64x32 tile)
        // bottom is at y=32. 
        // 32/2 - 10 = 6. This is offset from bottom? No, Positioned bottom means distance from bottom.
        // So y = 32 - (16-10) = 26 from top? 
        // Let's approximate. The tree is 100x140.
        // We want it centered horizontally? Widget didn't specify left, so centered in Stack.
        
        double treeW = 100;
        double treeH = 140;
        double dx = task.isoX + (tileWidth - treeW) / 2;
        double dy = task.isoY + tileHeight - (tileHeight / 2 - 10) - treeH; 
        // bottom = 16-10 = 6. y = 32 - 6 - 140 = -114.
        
        paintImage(
           canvas: canvas,
           rect: Rect.fromLTWH(dx, dy, treeW, treeH),
           image: treeImg,
           fit: BoxFit.contain
        );
      }
    }

    // 4. Draw Fences
    if (task.fenceAsset != null) {
      // Check visibility logic
      bool hideFence = false;
      if (selectedX != null && selectedY != null) {
        if (task.y == -1 && (selectedX! - task.x).abs() <= 1 && selectedY == 0) hideFence = true;
        if (task.y == gridHeight && (selectedX! - task.x).abs() <= 1 && selectedY == gridHeight - 1) hideFence = true;
        if (task.x == -1 && (selectedY! - task.y).abs() <= 1 && selectedX == 0) hideFence = true;
        if (task.x == gridWidth && (selectedY! - task.y).abs() <= 1 && selectedX == gridWidth - 1) hideFence = true;
      }

      if (!hideFence) {
         final ui.Image? fenceImg = assetManager.getImage(task.fenceAsset!);
         if (fenceImg != null) {
            // Widget: bottom: (tileHeight / 2) + fenceDy
            // left: fenceDx
            // Height: tileHeight * 2 (64)
            // Width: tileWidth (64) implied by SizedBox width
            
            double h = tileHeight * 2;
            double w = tileWidth;
            
            double bottomDist = (tileHeight / 2) + task.fenceDy; 
            // y = tileHeight - bottomDist - h
            
            double dx = task.isoX + task.fenceDx;
            double dy = task.isoY + tileHeight - bottomDist - h;
            
            paintImage(
               canvas: canvas,
               rect: Rect.fromLTWH(dx, dy, w, h),
               image: fenceImg,
               fit: BoxFit.contain,
            );
         }
      }
    }
  }

  void _paintItem(Canvas canvas, _PaintTask task) {
    // Logic to determine sprite path
    // We can't use AnimatedSprite widget here. We need raw images.
    // OPTIMIZATION: For now, we only render the static 'idle' state or first frame.
    // Support for animation in CustomPainter requires a ticker providing frame index.
    // For this step, let's just get the static image rendering working.
    
    final Map<String, dynamic>? sprites = task.cellData['sprites'];
    final Map<String, dynamic>? state = task.cellData['state'];
    
    String status = 'idle';
    if (state != null && state['status'] != null) {
         status = state['status'];
    } else if (state != null) {
        if (state['is_harvested'] == true) status = 'harvested';
        else if (state['is_ready'] == true) status = 'ready';
        else if (state['is_cut'] == true) status = 'cut';
        else if (state['is_withered'] == true) status = 'withered';
        else if (state['is_sick'] == true) status = 'sick';
        else if (state['is_sleeping'] == true) status = 'sleeping';
        else if (state['is_eating'] == true) status = 'eating';
        else if (state['is_walking'] == true) status = 'walking';
        else if (state['is_processing'] == true) status = 'processing';
        else if (state['is_finished'] == true) status = 'finished';
        else if (state['is_broken'] == true) status = 'broken';
        else if (state['is_pending'] == true) status = 'pending';
    }

    String? spritePath = sprites?[status] ?? sprites?['idle'] ?? sprites?['unharvested'] ?? sprites?['unhavesed'];
    
    // The spritePath usually points to a folder like "assets/game_images/..." or a file prefix?
    // In previous code `AnimatedSprite`, it appended `image0.png`.
    // Let's try to load `spritePath + image0.png`.
    
    if (spritePath != null) {
       // We need to resolve the full path. The DB usually stores relative path.
       // However, AssetManager needs exact path.
       // Let's assume for now optimization Step 1 just renders, we might need to pre-load these specific item sprites too!
       // Since we didn't preload them in GameScreen, they won't render yet if not in cache.
       // But AssetManager only returns if cached.
       
       String fullPath = '$spritePath/image0.png';
       final ui.Image? img = assetManager.getImage(fullPath);
       
       if (img != null) {
          // Render item
          // Widget: width: 64, height: 80, fit: contain
          // Positioned: bottom: tileHeight / 4 (8)
          
          double w = 64;
          double h = 80;
          double dx = task.isoX + (tileWidth - w) / 2;
          double dy = task.isoY + tileHeight - (tileHeight / 4) - h;
          
          paintImage(
             canvas: canvas,
             rect: Rect.fromLTWH(dx, dy, w, h),
             image: img,
             fit: BoxFit.contain
          );
          return;
       } else {
         // Trigger load? CustomPainter shouldn't trigger side effects ideally.
         // But we can trigger it.
         assetManager.loadAssets([fullPath]); 
         // This won't repaint automatically. We need a way to notify.
         // For now, let's fallback to drawing a placeholder circle/rect if image missing
       }
    }
    
    // Fallback: Brown Circle (House placeholder)
    final Paint p = Paint()..color = Colors.brown;
    canvas.drawCircle(Offset(task.isoX + tileWidth/2, task.isoY + tileHeight/2), 16, p);
  }

  @override
  bool shouldRepaint(covariant IsometricMapPainter oldDelegate) {
    return oldDelegate.selectedX != selectedX || 
           oldDelegate.selectedY != selectedY ||
           oldDelegate.matrix != matrix;
  }
}

class _PaintTask {
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
  final dynamic cellData;

  _PaintTask({
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
    this.cellData,
  });
}

