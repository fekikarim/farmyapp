import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'asset_manager.dart';

class IsometricMap extends StatefulWidget {
  final int gridWidth;
  final int gridHeight;
  final List<dynamic> matrix;
  final Function(int x, int y)? onTileTap;
  
  // Placement Mode Props
  final bool placementMode;
  final Map<String, dynamic>? placementFootprint;
  final Map<String, dynamic>? placementItem;
  final int? externalSelectionX;
  final int? externalSelectionY;

  const IsometricMap({
    super.key,
    required this.gridWidth,
    required this.gridHeight,
    required this.matrix,
    this.onTileTap,
    this.placementMode = false,
    this.placementFootprint,
    this.placementItem,
    this.externalSelectionX,
    this.externalSelectionY,
  });

  @override
  State<IsometricMap> createState() => _IsometricMapState();
}

class _IsometricMapState extends State<IsometricMap> with SingleTickerProviderStateMixin {
  // Constants
  static const double tileWidth = 64.0;
  static const double tileHeight = 32.0;

  // Track selected tile
  int? _selectedX;
  int? _selectedY;
  
  // Animation
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 3000), // Slower animation (3s cycle)
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int backgroundPadding = 10;
    
    final double totalWidth = (widget.gridWidth + widget.gridHeight + backgroundPadding * 2) * tileWidth / 2 + 200;
    final double totalHeight = (widget.gridWidth + widget.gridHeight + backgroundPadding * 2) * tileHeight / 2 + 200;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(500),
      minScale: 0.1,
      maxScale: 4.0,
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details, backgroundPadding),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              size: Size(totalWidth, totalHeight),
              painter: IsometricMapPainter(
                gridWidth: widget.gridWidth,
                gridHeight: widget.gridHeight,
                matrix: widget.matrix,
                selectedX: widget.placementMode ? widget.externalSelectionX : _selectedX,
                selectedY: widget.placementMode ? widget.externalSelectionY : _selectedY,
                backgroundPadding: backgroundPadding,
                assetManager: AssetManager(),
                placementMode: widget.placementMode,
                placementFootprint: widget.placementFootprint,
                placementItem: widget.placementItem,
                animationValue: _animationController.value,
              ),
            );
          }
        ),
      ),
    );
  }

  void _handleTap(TapUpDetails details, int padding) {
     final double offsetX = (widget.gridHeight * tileWidth / 2);
     const double offsetY = 100;

     double dx = details.localPosition.dx - offsetX;
     double dy = details.localPosition.dy - offsetY;

     double halfW = tileWidth / 2;
     double halfH = tileHeight / 2;

     double a = dx / halfW;
     double b = dy / halfH;

     int gridX = ((a + b) / 2).floor();
     int gridY = ((b - a) / 2).floor();

     if (gridX >= 0 && gridX < widget.gridWidth && gridY >= 0 && gridY < widget.gridHeight) {
       setState(() {
          _selectedX = gridX;
          _selectedY = gridY;
       });

       if (widget.onTileTap != null) {
         // During placement mode, we ALWAYS call back so parent can move the ghost.
         // Validation visuals are handled in the painter.
         widget.onTileTap!(gridX, gridY);
       } 
     } else {
        if (_selectedX != null || _selectedY != null) {
           setState(() {
             _selectedX = null;
             _selectedY = null;
           });
        }
     }
  }

  bool _isPlacementValid(int x, int y) {
      if (!widget.placementMode || widget.placementFootprint == null) return true;
      
      final squares = widget.placementFootprint!['squares'] as List;
      
      for (var sq in squares) {
          int tx = x + (sq['x'] as int);
          int ty = y + (sq['y'] as int);
          
          if (tx < 0 || tx >= widget.gridWidth || ty < 0 || ty >= widget.gridHeight) {
              return false;
          }
          if (widget.matrix[ty][tx] != null) {
              return false;
          }
      }
      return true;
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
  
  // Placement Props
  final bool placementMode;
  final Map<String, dynamic>? placementFootprint;
  final Map<String, dynamic>? placementItem;
  
  // Animation
  final double animationValue;

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
    this.placementMode = false,
    this.placementFootprint,
    this.placementItem,
    required this.animationValue,
  }) : super(repaint: assetManager);

  @override
  void paint(Canvas canvas, Size size) {
    double offsetX = (gridHeight * tileWidth / 2);
    double offsetY = 100;

    List<_PaintTask> tasks = [];

    // 1. Generate Tasks for Ground & Existing Objects
    for (int y = -backgroundPadding; y < gridHeight + backgroundPadding; y++) {
      for (int x = -backgroundPadding; x < gridWidth + backgroundPadding; x++) {
        
        bool isForeground = (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight);
        
        // ... (Logic for trees/fences same as before) ...
        bool isTreeRow = false;
        String? treeAsset;
        String? fenceAsset;
        double fenceDx = 0;
        double fenceDy = 0;

        if (!isForeground) {
          bool isTopSide = (x >= -2 && x < 0) || (y >= -2 && y < 0);
          if (isTopSide) {
            int hash = (x * 7 + y * 13).abs();
            if ((hash % 5) < 2) {
              isTreeRow = true;
              int variant = (hash % 3) + 1;
              treeAsset = 'assets/game_images/3d/outside_tree/tree$variant.png';
            }
          }

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
    
    // 3. Draw Placement Overlay (On Top)
    if (placementMode && selectedX != null && selectedY != null && placementFootprint != null && placementItem != null) {
       _paintPlacementOverlay(canvas, offsetX, offsetY);
    }
  }

  void _paintPlacementOverlay(Canvas canvas, double offsetX, double offsetY) {
     final squares = placementFootprint!['squares'] as List;
     
     // 1. Draw Footprint Grid
     
     for (var sq in squares) {
          int tx = selectedX! + (sq['x'] as int);
          int ty = selectedY! + (sq['y'] as int);
          
          bool isOccupied = false;
          bool isOutOfBounds = (tx < 0 || tx >= gridWidth || ty < 0 || ty >= gridHeight);
          
          if (!isOutOfBounds) {
              if (matrix[ty][tx] != null) isOccupied = true;
          } else {
              isOccupied = true; // Treat OOB as occupied
          }
          
          // Compute Screen Coords for this tile
          double isoX = (tx - ty) * (tileWidth / 2) + offsetX;
          double isoY = (tx + ty) * (tileHeight / 2) + offsetY;
          
          // Draw Diamond overlay
          final Path path = Path();
          path.moveTo(isoX + tileWidth / 2, isoY);
          path.lineTo(isoX + tileWidth, isoY + tileHeight / 2);
          path.lineTo(isoX + tileWidth / 2, isoY + tileHeight);
          path.lineTo(isoX, isoY + tileHeight / 2);
          path.close();
          
          final Paint p = Paint()
             ..color = isOccupied ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5)
             ..style = PaintingStyle.fill;
          
          canvas.drawPath(path, p);
          
          final Paint border = Paint()
             ..color = isOccupied ? Colors.red : Colors.green
             ..style = PaintingStyle.stroke
             ..strokeWidth = 2;
          canvas.drawPath(path, border);
     }
     
     // 2. Draw Ghost Item (Use idle sprite)
     double isoX = (selectedX! - selectedY!) * (tileWidth / 2) + offsetX;
     double isoY = (selectedX! + selectedY!) * (tileHeight / 2) + offsetY;
     
     final Map<String, dynamic>? details = placementItem!['details'];
     final Map<String, dynamic>? sprites = placementItem!['sprites'] ?? details?['sprites'];
     String status = 'idle';
     String? spriteBase = sprites?[status] ?? sprites?['idle'];
     
     if (spriteBase != null) {
         if (spriteBase.startsWith('/')) spriteBase = spriteBase.substring(1);
         // Draw ghost using first frame
         String fullPath = 'assets/game_images/$spriteBase/image0.png';
         final ui.Image? img = assetManager.getImage(fullPath);
         
         if (img != null) {
             canvas.saveLayer(null, Paint()..color = Colors.white.withOpacity(0.7));
             
             double w = 64;
             double h = 80;
             double dx = isoX + (tileWidth - w) / 2;
             double dy = isoY + tileHeight - (tileHeight / 4) - h;
          
             paintImage(
                canvas: canvas,
                rect: Rect.fromLTWH(dx, dy, w, h),
                image: img,
                fit: BoxFit.contain,
             );
             
             canvas.restore();
             return;
         } else if (!assetManager.hasFailed(fullPath)) {
             assetManager.loadAssets([fullPath]);
         }
     }
     
     // Ghost Fallback
     canvas.drawCircle(Offset(isoX + tileWidth/2, isoY + tileHeight/2), 10, Paint()..color = Colors.blue.withOpacity(0.5));
  }

  void _paintTile(Canvas canvas, Paint paint, _PaintTask task) {
    // ... (Base tile painting same as before) ...
        // 1. Draw Base Tile
    final String assetPath = task.isForeground 
        ? 'assets/game_images/textures/grass_land.jpg'
        : 'assets/game_images/textures/soil_background.jpg';
    
    final ui.Image? baseImg = assetManager.getImage(assetPath);
    
    if (baseImg != null) {
      canvas.save();
      canvas.translate(task.isoX, task.isoY);
      
      final Path path = Path();
      path.moveTo(tileWidth / 2, 0);
      path.lineTo(tileWidth, tileHeight / 2);
      path.lineTo(tileWidth / 2, tileHeight);
      path.lineTo(0, tileHeight / 2);
      path.close();
      
      canvas.clipPath(path);
      
      paintImage(
        canvas: canvas,
        rect: const Rect.fromLTWH(0, 0, tileWidth, tileHeight), 
        image: baseImg,
        fit: BoxFit.cover,
      );
      
      canvas.restore();

      // Border
      canvas.save();
      canvas.translate(task.isoX, task.isoY);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1; // Default
      paint.color = task.isForeground ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05);
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    // 2. Draw Items (Overlay)
    if (task.cellData != null) {
       _paintItem(canvas, task);
    }

    // 3. Draw Trees (Decoration) - unchanged
    if (task.hasTree && task.treeAsset != null) {
      final ui.Image? treeImg = assetManager.getImage(task.treeAsset!);
      if (treeImg != null) {
        double treeW = 100;
        double treeH = 140;
        double dx = task.isoX + (tileWidth - treeW) / 2;
        double dy = task.isoY + tileHeight - (tileHeight / 2 - 10) - treeH; 
        
        paintImage(
           canvas: canvas,
           rect: Rect.fromLTWH(dx, dy, treeW, treeH),
           image: treeImg,
           fit: BoxFit.contain
        );
      }
    }

    // 4. Draw Fences - unchanged
    if (task.fenceAsset != null) {
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
            double h = tileHeight * 2;
            double w = tileWidth;
            double bottomDist = (tileHeight / 2) + task.fenceDy; 
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
    if (task.cellData['is_origin'] == false) return; // Only draw at the origin of a multi-tile footprint

    final Map<String, dynamic>? sprites = task.cellData['sprites'];
    final Map<String, dynamic>? state = task.cellData['state'];
    
    String status = 'idle';
    if (state != null && state['status'] != null) {
         status = state['status'];
    } else if (state != null) {
        // Fallback checks
        if (state['is_harvested'] == true) status = 'harvested';
        else if (state['is_ready'] == true) status = 'ready';
        else if (state['is_walking'] == true) status = 'walking';
        else if (state['is_processing'] == true) status = 'processing';
        else if (state['is_finished'] == true) status = 'finished';
    }

    String? spriteBase = sprites?[status];
    
    // Fallback logic: if specific status is missing or failed to load, try 'idle'
    bool needsFallback = spriteBase == null;
    if (spriteBase != null) {
      String cleanPath = spriteBase;
      if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
      if (assetManager.hasFailed('assets/game_images/$cleanPath/image0.png')) {
        needsFallback = true;
      }
    }

    if (needsFallback) {
      if (status != 'idle') {
        spriteBase = sprites?['idle'] ?? sprites?['unharvested'];
      } else {
        spriteBase = sprites?['unharvested'];
      }
    }

    if (spriteBase != null) {
       if (spriteBase.startsWith('/')) spriteBase = spriteBase.substring(1);
       // Determine available frames
       int frameCount = 0;
       List<ui.Image> frames = [];
       List<String> missingPaths = [];
       
        int maxFrames = assetManager.getFrameCount(spriteBase);
        if (maxFrames == 0) maxFrames = 24; // Increased fallback for cow sprite

        Map<int, ui.Image> loadedFrames = {};
         for (int i = 0; i < maxFrames; i++) {
             String p = assetManager.getFramePath(spriteBase, i);
             ui.Image? img = assetManager.getImage(p);
             if (img != null) {
                 loadedFrames[i] = img;
                 frameCount++;
             } else {
                if (!assetManager.hasFailed(p)) {
                    missingPaths.add(p);
                }
            }
        }
        
        // Trigger load for missing
        if (missingPaths.isNotEmpty) {
            assetManager.loadAssets(missingPaths);
        }
       
        if (loadedFrames.isNotEmpty) {
            final bool isActive = task.cellData['is_active'] != false; // Support both bool and 0/1 from JSON

            // Use maxFrames for timing if available, otherwise fallback to 1 to avoid division by zero
            int totalExpected = maxFrames > 0 ? maxFrames : 24; 
            
            int hash = (task.x * 31 + task.y * 17);
            double adjustedTime = animationValue + (hash % 100) / 100.0;

            // Calculate which frame we SHOULD be showing based on the full expected count
            int targetFrameIndex = isActive 
                ? ((adjustedTime * totalExpected) % totalExpected).floor()
                : 0; // Lock to frame 0 for inactive
            
            // Try to find the image for this specific index if it's loaded
            ui.Image? img = loadedFrames[targetFrameIndex];
            
            // Fallback: if target frame not loaded, use the closest available one or first frame
            if (img == null && loadedFrames.isNotEmpty) {
                img = loadedFrames.values.first; 
            }

            if (img != null) {
                // Dynamic sizing based on image aspect ratio and footprint
                int fw = task.cellData['footprint_width'] ?? 1;
                int fh = task.cellData['footprint_height'] ?? 1;
                
                double w, h, dx, dy;
                
                if (fw == 1 && fh == 1) {
                    // OLD LOGIC for 1x1: Place feet at ~75% down the tile depth for exact grounding
                    w = tileWidth * 1.3;
                    h = w * (img.height / img.width);
                    dx = task.isoX + (tileWidth - w) / 2;
                    dy = task.isoY + (tileHeight * 0.75) - h;
                } else {
                    // NEW LOGIC for multi-tile: Center exactly across the footprint
                    double scaleFactor = (fw + fh) / 2.0;
                    w = tileWidth * 1.3 * scaleFactor; 
                    h = w * (img.height / img.width);
                    
                    double cx = (fw - fh) * tileWidth / 4;
                    double cy = (fw + fh) * tileHeight / 4; 
                    
                    dx = task.isoX + cx + (tileWidth - w) / 2;
                    dy = task.isoY + cy - h;
                }
                
                paintImage(
                   canvas: canvas,
                   rect: Rect.fromLTWH(dx, dy, w, h),
                   image: img,
                   fit: BoxFit.contain,
                   colorFilter: isActive ? null : const ColorFilter.matrix(<double>[
                      // Darkened Grayscale (values multiplied by ~0.2 for shadow look)
                      0.0425, 0.1430, 0.0144, 0, 0,
                      0.0425, 0.1430, 0.0144, 0, 0,
                      0.0425, 0.1430, 0.0144, 0, 0,
                      0,      0,      0,      0.7, 0, // Slightly transparent
                   ]),
                );
                return;
            }
        }
    }
    
    // Fallback if no frames loaded yet
    final Paint p = Paint()..color = Colors.brown;
    canvas.drawCircle(Offset(task.isoX + tileWidth/2, task.isoY + tileHeight/2), 16, p);
  }

  @override
  bool shouldRepaint(covariant IsometricMapPainter oldDelegate) {
    return oldDelegate.selectedX != selectedX || 
           oldDelegate.selectedY != selectedY ||
           oldDelegate.matrix != matrix ||
           oldDelegate.placementMode != placementMode ||
           oldDelegate.animationValue != animationValue; // Repaint on animation
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

