import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:farmyapp/providers/game_provider.dart';
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
       duration: const Duration(milliseconds: 3000),
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

    final gameProvider = Provider.of<GameProvider>(context);

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(500),
      minScale: 0.1,
      maxScale: 4.0,
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details, backgroundPadding, gameProvider, isDoubleClick: false),
        onDoubleTapDown: (details) => _handleTap(details, backgroundPadding, gameProvider, isDoubleClick: true),
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
                workers: gameProvider.workers,
              ),
            );
          }
        ),
      ),
    );
  }

  void _handleTap(dynamic details, int padding, GameProvider gameProvider, {required bool isDoubleClick}) {
     final double offsetX = (widget.gridHeight * tileWidth / 2);
     const double offsetY = 100;

     Offset localPos = details is TapUpDetails ? details.localPosition : (details as TapDownDetails).localPosition;

     double dx = localPos.dx - offsetX;
     double dy = localPos.dy - offsetY;

     double a = dx / (tileWidth / 2);
     double b = dy / (tileHeight / 2);

     double gridX = (a + b) / 2;
     double gridY = (b - a) / 2;

     if (gridX >= 0 && gridX < widget.gridWidth && gridY >= 0 && gridY < widget.gridHeight) {
       setState(() {
          _selectedX = gridX.floor();
          _selectedY = gridY.floor();
       });

       if (isDoubleClick) {
         gameProvider.moveClosestWorkerTo(
           gridX,
           gridY,
           gridWidth: widget.gridWidth,
           gridHeight: widget.gridHeight,
         );
       }

       if (widget.onTileTap != null) {
         widget.onTileTap!(gridX.floor(), gridY.floor());
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

  // Workers
  final List<WorkerState> workers;

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
    required this.workers,
  }) : super(repaint: assetManager);

  @override
  void paint(Canvas canvas, Size size) {
    double offsetX = (gridHeight * tileWidth / 2);
    double offsetY = 100;

    List<_PaintTask> groundTasks = [];
    List<_PaintTask> objectTasks = [];

    // 1. Generate Tasks
    for (int y = -backgroundPadding; y < gridHeight + backgroundPadding; y++) {
      for (int x = -backgroundPadding; x < gridWidth + backgroundPadding; x++) {
        
        bool isForeground = (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight);
        
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

        final groundTask = _PaintTask(
          x: x,
          y: y,
          isoX: isoX,
          isoY: isoY,
          isForeground: isForeground,
          hasTree: false, // Only items/trees/fences in objectTask
        );
        groundTasks.add(groundTask);

        if (isTreeRow || fenceAsset != null || cellData != null) {
          objectTasks.add(_PaintTask(
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
    }

    // 2. Add each worker to Object Tasks
    for (final worker in workers) {
      double workerIsoX = (worker.x - worker.y) * (tileWidth / 2) + offsetX;
      double workerIsoY = (worker.x + worker.y) * (tileHeight / 2) + offsetY;
      objectTasks.add(_PaintTask(
        x: worker.x.floor(),
        y: worker.y.floor(),
        isoX: workerIsoX,
        isoY: workerIsoY,
        isForeground: true,
        hasTree: false,
        isPlayer: true,
        playerDirection: worker.direction,
        playerStatus: worker.status,
        workerName: worker.workerName,
        workerDepth: worker.x + worker.y,
      ));
    }

    // Sort object tasks by depth
    objectTasks.sort((a, b) {
      double depthA = a.workerDepth ?? (a.x + a.y).toDouble();
      double depthB = b.workerDepth ?? (b.x + b.y).toDouble();
      if ((depthA - depthB).abs() > 0.001) return depthA.compareTo(depthB);
      return a.x.compareTo(b.x);
    });

    final Paint paint = Paint();
    
    // 3. Paint Ground Layer first
    for (final task in groundTasks) {
      _paintGround(canvas, paint, task);
    }

    // 4. Paint Object Layer
    for (final task in objectTasks) {
      if (task.isPlayer) {
        _paintPlayer(canvas, task);
      } else {
        _paintObject(canvas, paint, task);
      }
    }
    
    // 5. Draw Placement Overlay (On Top)
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

  void _paintGround(Canvas canvas, Paint paint, _PaintTask task) {
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
      paint.strokeWidth = 1; 
      paint.color = task.isForeground ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _paintObject(Canvas canvas, Paint paint, _PaintTask task) {
    // 1. Draw Items (Overlay)
    if (task.cellData != null) {
       _paintItem(canvas, task);
    }

    // 2. Draw Trees (Decoration)
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

    // 3. Draw Fences
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
    if (task.cellData['is_origin'] == false) return;

    final Map<String, dynamic>? sprites = task.cellData['sprites'];
    final Map<String, dynamic>? state = task.cellData['state'];
    
    String status = 'idle';
    if (state != null && state['status'] != null) {
         status = state['status'];
    }

    String? spriteBase = sprites?[status];
    if (spriteBase == null) spriteBase = sprites?['idle'];

    if (spriteBase != null) {
       if (spriteBase.startsWith('/')) spriteBase = spriteBase.substring(1);
       int maxFrames = assetManager.getFrameCount(spriteBase);
       if (maxFrames == 0) maxFrames = 24;

       Map<int, ui.Image> loadedFrames = {};
       List<String> missingPaths = [];
       for (int i = 0; i < maxFrames; i++) {
           String p = assetManager.getFramePath(spriteBase, i);
           ui.Image? img = assetManager.getImage(p);
           if (img != null) loadedFrames[i] = img;
           else if (!assetManager.hasFailed(p)) missingPaths.add(p);
       }
       if (missingPaths.isNotEmpty) assetManager.loadAssets(missingPaths);
       
       if (loadedFrames.isNotEmpty) {
           final bool isActive = task.cellData['is_active'] != false;
           int hash = (task.x * 31 + task.y * 17);
           double adjustedTime = animationValue + (hash % 100) / 100.0;
           int targetFrameIndex = isActive ? ((adjustedTime * maxFrames) % maxFrames).floor() : 0;
           ui.Image? img = loadedFrames[targetFrameIndex] ?? loadedFrames.values.first;

           if (img != null) {
               int fw = task.cellData['footprint_width'] ?? 1;
               int fh = task.cellData['footprint_height'] ?? 1;
               double w, h, dx, dy;
               if (fw == 1 && fh == 1) {
                   w = tileWidth * 1.3;
                   h = w * (img.height / img.width);
                   dx = task.isoX + (tileWidth - w) / 2;
                   dy = task.isoY + (tileHeight * 0.75) - h;
               } else {
                   double scaleFactor = (fw + fh) / 2.0;
                   w = tileWidth * 1.3 * scaleFactor; 
                   h = w * (img.height / img.width);
                   double cx = (fw - fh) * tileWidth / 4;
                   double cy = (fw + fh) * tileHeight / 4; 
                   dx = task.isoX + cx + (tileWidth - w) / 2;
                   dy = task.isoY + cy - h;
               }
               paintImage(canvas: canvas, rect: Rect.fromLTWH(dx, dy, w, h), image: img, fit: BoxFit.contain, colorFilter: isActive ? null : ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.multiply));
               return;
           }
       }
    }
  }

  void _paintPlayer(Canvas canvas, _PaintTask task) {
    String subPath = task.playerStatus == 'walking' 
        ? 'walk/${task.playerDirection}' 
        : 'idle';
    String spriteBase = 'sprites/player/$subPath';

    int maxFrames = assetManager.getFrameCount(spriteBase);
    if (maxFrames == 0 && task.playerStatus == 'idle') maxFrames = 9;
    if (maxFrames == 0) maxFrames = 1;

    Map<int, ui.Image> loadedFrames = {};
    List<String> missingPaths = [];

    for (int i = 0; i < maxFrames; i++) {
        String p = assetManager.getFramePath(spriteBase, i);
        ui.Image? img = assetManager.getImage(p);
        if (img != null) loadedFrames[i] = img;
        else if (!assetManager.hasFailed(p)) missingPaths.add(p);
    }

    if (missingPaths.isNotEmpty) assetManager.loadAssets(missingPaths);

    ui.Image? img;
    if (loadedFrames.isNotEmpty) {
        // Slowed down animation: Use * 5 instead of * 10
        int frameIndex = ((animationValue * 5 * maxFrames) % maxFrames).floor();
        img = loadedFrames[frameIndex] ?? loadedFrames.values.first;
    }

    if (img != null) {
        // Fixed height so idle & walk are always the same visual size
        const double fixedH = tileHeight * 2.2;
        double w = fixedH * (img.width / img.height);
        double dx = task.isoX + (tileWidth - w) / 2;
        // Ground feet at ~90% of tile depth
        double dy = task.isoY + (tileHeight * 0.9) - fixedH;

        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(dx, dy, w, fixedH),
          image: img,
          fit: BoxFit.contain,
        );

        // Draw worker name label above sprite
        if (task.workerName != null) {
          _paintWorkerLabel(canvas, task.workerName!, task.isoX + tileWidth / 2, dy - 4);
        }
    } else {
        final Paint shadowPaint = Paint()..color = Colors.black.withOpacity(0.2);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(task.isoX + tileWidth / 2, task.isoY + tileHeight * 0.8),
            width: tileWidth * 0.4,
            height: tileHeight * 0.2,
          ),
          shadowPaint,
        );
    }
  }

  void _paintWorkerLabel(Canvas canvas, String name, double cx, double topY) {
    const double fontSize = 9.0;
    const double padding = 3.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double labelW = textPainter.width + padding * 2;
    final double labelH = textPainter.height + padding;

    final RRect bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - labelW / 2, topY - labelH - 2, labelW, labelH),
      const Radius.circular(3),
    );

    canvas.drawRRect(bgRect, Paint()..color = Colors.black.withOpacity(0.55));
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, topY - labelH - 2 + padding / 2));
  }


  @override
  bool shouldRepaint(covariant IsometricMapPainter oldDelegate) {
    return oldDelegate.selectedX != selectedX || 
           oldDelegate.selectedY != selectedY ||
           oldDelegate.matrix != matrix ||
           oldDelegate.placementMode != placementMode ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.workers != workers;
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
  final bool isPlayer;
  final String? playerDirection;
  final String? playerStatus;
  final String? workerName;   // for name label
  final double? workerDepth;  // fractional depth for sorting

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
    this.isPlayer = false,
    this.playerDirection,
    this.playerStatus,
    this.workerName,
    this.workerDepth,
  });
}

