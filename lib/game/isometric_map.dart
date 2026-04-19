import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:farmyapp/providers/game_provider.dart';
import 'package:farmyapp/widgets/radial_action_menu.dart';
import 'asset_manager.dart';

class IsometricMap extends StatefulWidget {
  final int gridWidth;
  final int gridHeight;
  final List<dynamic> matrix;
  final List<dynamic>? playableMask;
  final Function(int x, int y)? onTileTap;
  final Function(String actionId, int x, int y, dynamic itemData)? onItemAction;

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
    this.playableMask,
    this.onTileTap,
    this.onItemAction,
    this.placementMode = false,
    this.placementFootprint,
    this.placementItem,
    this.externalSelectionX,
    this.externalSelectionY,
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

  // Radial Menu State
  int? _menuGridX;
  int? _menuGridY;
  double? _menuPixelX;
  double? _menuPixelY;
  dynamic _menuItemData;

  // Animation is stepped on a timer to avoid 60fps full-canvas repaints.
  Timer? _animationTimer;
  double _animationValue = 0;

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() {
        _animationValue = (_animationValue + 0.04) % 1;
      });
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int backgroundPadding = 10;

    final double totalWidth =
        (widget.gridWidth + widget.gridHeight + backgroundPadding * 2) *
            tileWidth /
            2 +
        200;
    final double totalHeight =
        (widget.gridWidth + widget.gridHeight + backgroundPadding * 2) *
            tileHeight /
            2 +
        200;

    final gameProvider = Provider.of<GameProvider>(context);

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(500),
      minScale: 0.1,
      maxScale: 4.0,
      child: GestureDetector(
        onTapUp: (details) => _handleTap(
          details,
          backgroundPadding,
          gameProvider,
          isDoubleClick: false,
        ),
        onDoubleTapDown: (details) => _handleTap(
          details,
          backgroundPadding,
          gameProvider,
          isDoubleClick: true,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(totalWidth, totalHeight),
              painter: IsometricMapPainter(
                gridWidth: widget.gridWidth,
                gridHeight: widget.gridHeight,
                matrix: widget.matrix,
                playableMask: widget.playableMask,
                selectedX: widget.placementMode
                    ? widget.externalSelectionX
                    : _selectedX,
                selectedY: widget.placementMode
                    ? widget.externalSelectionY
                    : _selectedY,
                backgroundPadding: backgroundPadding,
                assetManager: AssetManager(),
                placementMode: widget.placementMode,
                placementFootprint: widget.placementFootprint,
                placementItem: widget.placementItem,
                animationValue: _animationValue,
                workers: gameProvider.workers,
              ),
            ),
            if (_menuGridX != null &&
                _menuGridY != null &&
                _menuPixelX != null &&
                _menuPixelY != null)
              Positioned(
                // canvasR = radius(75) + btnRadius(24) + 6 = 105
                left: _menuPixelX! - 105,
                top: _menuPixelY! - 105,
                child: RadialActionMenu(
                  actions: _getActionsFor(_menuItemData),
                  radius: 75,
                  onActionSelected: (actionId) {
                    if (widget.onItemAction != null) {
                      widget.onItemAction!(
                        actionId,
                        _menuGridX!,
                        _menuGridY!,
                        _menuItemData,
                      );
                    }
                    _closeMenu();
                  },
                  onDismiss: _closeMenu,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleTap(
    dynamic details,
    int padding,
    GameProvider gameProvider, {
    required bool isDoubleClick,
  }) {
    if (_menuGridX != null) {
      _closeMenu();
      return;
    }

    final double offsetX = (widget.gridHeight * tileWidth / 2);
    const double offsetY = 100;

    Offset localPos = details is TapUpDetails
        ? details.localPosition
        : (details as TapDownDetails).localPosition;

    // 1. Check for item clicks using screen-space bounding boxes
    if (!widget.placementMode && !isDoubleClick) {
      dynamic clickedItem;
      int clickedBlockX = -1;
      int clickedBlockY = -1;

      // Iterate from front to back to catch foreground items first
      for (int y = widget.gridHeight - 1; y >= 0; y--) {
        for (int x = widget.gridWidth - 1; x >= 0; x--) {
          dynamic item = widget.matrix[y][x];
          if (item != null) {
            int ox = item['origin_x'] ?? x;
            int oy = item['origin_y'] ?? y;
            int fw = item['footprint_width'] ?? 1;
            int fh = item['footprint_height'] ?? 1;

            // Only check the item once
            if (x != ox + fw - 1 || y != oy + fh - 1) continue;

            double isoX = (ox - oy) * (tileWidth / 2) + offsetX;
            double isoY = (ox + oy) * (tileHeight / 2) + offsetY;

            double scaleFactor = (fw == 1 && fh == 1) ? 1.0 : (fw + fh) / 2.0;
            double w = tileWidth * 1.3 * scaleFactor;
            double h = w * 1.5; // fallback aspect ratio

            // Get actual image dimensions if loaded
            final sprites = item['sprites'];
            final state = item['state'];
            String status = state?['status'] ?? 'idle';
            String? spriteBase = sprites?[status] ?? sprites?['idle'];
            if (spriteBase != null) {
              if (spriteBase.startsWith('/'))
                spriteBase = spriteBase.substring(1);
              String framePath = 'assets/game_images/$spriteBase/image0.png';
              ui.Image? img = AssetManager().getImage(framePath);
              if (img != null) {
                h = w * (img.height / img.width);
              }
            }

            double itemDx = 0;
            double itemDy = 0;
            if (fw == 1 && fh == 1) {
              itemDx = isoX + (tileWidth - w) / 2;
              itemDy = isoY + (tileHeight * 0.75) - h;
            } else {
              double cx = (fw - fh) * tileWidth / 4;
              double cy = (fw + fh) * tileHeight / 4;
              itemDx = isoX + cx + (tileWidth - w) / 2;
              itemDy = isoY + cy - h;
            }

            Rect hitBox = Rect.fromLTWH(itemDx, itemDy, w, h);
            if (hitBox.contains(localPos)) {
              clickedItem = item;
              clickedBlockX = ox;
              clickedBlockY = oy;
              break;
            }
          }
        }
        if (clickedItem != null) break;
      }

      if (clickedItem != null) {
        _openMenu(clickedBlockX, clickedBlockY, clickedItem, offsetX, offsetY);
        return;
      }
    }

    // 2. Gridded Tile Tap (fallback for ground clicks, worker movement)

    double dx = localPos.dx - offsetX;
    double dy = localPos.dy - offsetY;

    double a = dx / (tileWidth / 2);
    double b = dy / (tileHeight / 2);

    double gridX = (a + b) / 2;
    double gridY = (b - a) / 2;

    if (gridX >= 0 &&
        gridX < widget.gridWidth &&
        gridY >= 0 &&
        gridY < widget.gridHeight) {
      int ix = gridX.floor();
      int iy = gridY.floor();

      if (!_isPlayableCell(ix, iy)) {
        if (_selectedX != null || _selectedY != null) {
          setState(() {
            _selectedX = null;
            _selectedY = null;
          });
        }
        return;
      }

      setState(() {
        _selectedX = ix;
        _selectedY = iy;
      });

      if (isDoubleClick) {
        gameProvider.moveClosestWorkerTo(
          gridX,
          gridY,
          gridWidth: widget.gridWidth,
          gridHeight: widget.gridHeight,
          onlyAvailable: true, // Never move busy workers on double-click
        );
      } else if (!widget.placementMode) {
        // Open menu if an item is tapped
        if (widget.matrix[iy][ix] != null) {
          _openMenu(ix, iy, widget.matrix[iy][ix], offsetX, offsetY);
        }
      }

      if (widget.onTileTap != null) {
        widget.onTileTap!(ix, iy);
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

  bool _isPlayableCell(int x, int y) {
    final mask = widget.playableMask;
    if (mask == null) return true;
    if (y < 0 || y >= mask.length) return false;
    final row = mask[y];
    if (row is! List || x < 0 || x >= row.length) return false;
    return row[x] == true;
  }

  void _openMenu(
    int x,
    int y,
    dynamic itemData,
    double offsetX,
    double offsetY,
  ) {
    int ox = itemData['origin_x'] ?? x;
    int oy = itemData['origin_y'] ?? y;
    int fw = itemData['footprint_width'] ?? 1;
    int fh = itemData['footprint_height'] ?? 1;

    double isoX = (ox - oy) * (tileWidth / 2) + offsetX;
    double isoY = (ox + oy) * (tileHeight / 2) + offsetY;

    // Navigate to the visual center of the footprint
    double cx = (fw - fh) * tileWidth / 4;
    double cy = (fw + fh) * tileHeight / 4;

    double targetX = isoX + cx + tileWidth / 2;
    // Raise the menu a bit above the item's bottom
    double targetY = isoY + cy - tileHeight;

    setState(() {
      _menuGridX = x;
      _menuGridY = y;
      _menuItemData = itemData;
      _menuPixelX = targetX;
      _menuPixelY = targetY;
    });
  }

  void _closeMenu() {
    setState(() {
      _menuGridX = null;
      _menuGridY = null;
      _menuPixelX = null;
      _menuPixelY = null;
      _menuItemData = null;
    });
  }

  List<RadialMenuAction> _getActionsFor(dynamic itemData) {
    List<RadialMenuAction> actions = [];

    actions.add(
      RadialMenuAction(
        id: 'info',
        icon: Icons.info_outline,
        backgroundColor: Colors.blueAccent,
        tooltip: 'Info',
      ),
    );

    if (itemData['category'] == 'animal' ||
        itemData['category'] == 'tree' ||
        itemData['category'] == 'machine' ||
        itemData['category'] == 'structure') {
      actions.add(
        RadialMenuAction(
          id: 'tasks',
          icon: Icons.assignment_outlined,
          backgroundColor: Colors.amber,
          tooltip: 'Tasks',
        ),
      );
    }

    return actions;
  }
}

class IsometricMapPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final List<dynamic> matrix;
  final List<dynamic>? playableMask;
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
    this.playableMask,
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
    final Rect visibleBounds = canvas.getLocalClipBounds().inflate(
      tileWidth * 2.5,
    );

    List<_PaintTask> groundTasks = [];
    List<_PaintTask> objectTasks = [];

    // 1. Generate Tasks
    for (int y = -backgroundPadding; y < gridHeight + backgroundPadding; y++) {
      for (int x = -backgroundPadding; x < gridWidth + backgroundPadding; x++) {
        final bool isInGridBounds =
            (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight);
        bool isForeground = isInGridBounds && _isPlayableCell(x, y);

        bool isTreeRow = false;
        String? treeAsset;
        List<_FenceData> tileFences = [];

        if (!isForeground) {
          // Scatter the two new outside-tree sprites deterministically across
          // the entire off-land border. A hash-based seed keeps positions
          // stable between frames (no popping), and the 2-tile buffer around
          // the fence keeps the walking area clear.
          final bool nearFence =
              (x >= -1 && x <= gridWidth) && (y >= -1 && y <= gridHeight);
          if (!nearFence) {
            final int hash = (x * 73856093 ^ y * 19349663).abs();
            // ~10% density \u2014 sparse scatter for a lighter, natural look.
            if ((hash % 100) < 10) {
              isTreeRow = true;
              final int variant = (hash % 2) + 1;
              treeAsset =
                  'assets/game_images/3d/outside_tree/tree_outside_0$variant.png';
            }
          }

          bool hasPlayableNeighbor(int nx, int ny) {
            return nx >= 0 &&
                nx < gridWidth &&
                ny >= 0 &&
                ny < gridHeight &&
                _isPlayableCell(nx, ny);
          }

          if (hasPlayableNeighbor(x, y + 1)) {
            tileFences.add(
              _FenceData(
                'assets/game_images/3d/outside_fance/fance1.png',
                -tileWidth / 4,
                -tileHeight / 4 - 12,
                x,
                y + 1,
              ),
            );
          }
          if (hasPlayableNeighbor(x, y - 1)) {
            tileFences.add(
              _FenceData(
                'assets/game_images/3d/outside_fance/fance1.png',
                tileWidth / 4,
                tileHeight / 4 - 12,
                x,
                y - 1,
              ),
            );
          }
          if (hasPlayableNeighbor(x + 1, y)) {
            tileFences.add(
              _FenceData(
                'assets/game_images/3d/outside_fance/fance2.png',
                tileWidth / 4,
                -tileHeight / 4 - 12,
                x + 1,
                y,
              ),
            );
          }
          if (hasPlayableNeighbor(x - 1, y)) {
            tileFences.add(
              _FenceData(
                'assets/game_images/3d/outside_fance/fance2.png',
                -tileWidth / 4,
                tileHeight / 4 - 12,
                x - 1,
                y,
              ),
            );
          }
        }

        double isoX = (x - y) * (tileWidth / 2) + offsetX;
        double isoY = (x + y) * (tileHeight / 2) + offsetY;

        final Rect groundRect = Rect.fromLTWH(
          isoX,
          isoY,
          tileWidth,
          tileHeight,
        );
        final bool groundVisible = groundRect.overlaps(visibleBounds);

        dynamic cellData;
        if (isForeground && matrix.length > y && matrix[y].length > x) {
          cellData = matrix[y][x];
        }

        final bool hasObjectLayerEntry =
            isTreeRow || tileFences.isNotEmpty || cellData != null;
        final Rect objectRect = Rect.fromLTWH(
          isoX - tileWidth,
          isoY - tileHeight * 3.8,
          tileWidth * 3,
          tileHeight * 5,
        );
        final bool objectVisible =
            hasObjectLayerEntry && objectRect.overlaps(visibleBounds);

        if (!groundVisible && !objectVisible) {
          continue;
        }

        if (groundVisible) {
          final groundTask = _PaintTask(
            x: x,
            y: y,
            isoX: isoX,
            isoY: isoY,
            isForeground: isForeground,
            hasTree: false, // Only items/trees/fences in objectTask
          );
          groundTasks.add(groundTask);
        }

        if (objectVisible) {
          objectTasks.add(
            _PaintTask(
              x: x,
              y: y,
              isoX: isoX,
              isoY: isoY,
              isForeground: isForeground,
              hasTree: isTreeRow,
              treeAsset: treeAsset,
              fences: tileFences,
              cellData: cellData,
            ),
          );
        }
      }
    }

    // 2. Add each worker to Object Tasks
    for (final worker in workers) {
      double workerIsoX = (worker.x - worker.y) * (tileWidth / 2) + offsetX;
      double workerIsoY = (worker.x + worker.y) * (tileHeight / 2) + offsetY;
      final Rect workerRect = Rect.fromLTWH(
        workerIsoX - tileWidth,
        workerIsoY - tileHeight * 2.4,
        tileWidth * 3,
        tileHeight * 3,
      );
      if (!workerRect.overlaps(visibleBounds)) {
        continue;
      }
      objectTasks.add(
        _PaintTask(
          x: worker.x.floor(),
          y: worker.y.floor(),
          isoX: workerIsoX,
          isoY: workerIsoY,
          isForeground: true,
          hasTree: false,
          isPlayer: true,
          playerDirection: worker.direction,
          playerStatus: worker.status,
          playerAction: worker.action,
          workerName: worker.workerName,
          workerDepth: worker.x + worker.y,
          workerIsBusy: worker.availability == 'busy',
        ),
      );
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
    if (placementMode &&
        selectedX != null &&
        selectedY != null &&
        placementFootprint != null &&
        placementItem != null) {
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
      bool isOutOfBounds =
          (tx < 0 || tx >= gridWidth || ty < 0 || ty >= gridHeight);

      if (!isOutOfBounds) {
        if (!_isPlayableCell(tx, ty)) isOccupied = true;
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
        ..color = isOccupied
            ? Colors.red.withOpacity(0.5)
            : Colors.green.withOpacity(0.5)
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
    final Map<String, dynamic>? sprites =
        placementItem!['sprites'] ?? details?['sprites'];
    String status = 'idle';
    String? spriteBase = sprites?[status] ?? sprites?['idle'];

    if (spriteBase != null) {
      if (spriteBase.startsWith('/')) spriteBase = spriteBase.substring(1);
      // Draw ghost using first frame
      String fullPath = 'assets/game_images/$spriteBase/image0.png';
      final ui.Image? img = assetManager.getImage(fullPath);

      if (img != null) {
        canvas.saveLayer(null, Paint()..color = Colors.white.withOpacity(0.7));

        final squares = placementFootprint!['squares'] as List;
        // Calculate footprint dimensions from squares for accuracy
        int minX = 0, maxX = 0, minY = 0, maxY = 0;
        for (var sq in squares) {
          int sx = sq['x'] as int;
          int sy = sq['y'] as int;
          if (sx < minX) minX = sx;
          if (sx > maxX) maxX = sx;
          if (sy < minY) minY = sy;
          if (sy > maxY) maxY = sy;
        }
        final int fw = maxX - minX + 1;
        final int fh = maxY - minY + 1;

        double scaleFactor = (fw + fh) / 2.0;
        double w = tileWidth * 1.3 * scaleFactor;
        double h = w * (img.height / img.width);

        double cx = (fw - fh) * tileWidth / 4;
        double cy = (fw + fh) * tileHeight / 2 * 0.9;

        double dx = isoX + cx + (tileWidth - w) / 2;
        double dy = isoY + cy - h;

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
    canvas.drawCircle(
      Offset(isoX + tileWidth / 2, isoY + tileHeight / 2),
      10,
      Paint()..color = Colors.blue.withOpacity(0.5),
    );
  }

  bool _isPlayableCell(int x, int y) {
    if (x < 0 || x >= gridWidth || y < 0 || y >= gridHeight) {
      return false;
    }
    if (playableMask == null) return true;
    if (y >= playableMask!.length) return false;
    final row = playableMask![y];
    if (row is! List || x >= row.length) return false;
    return row[x] == true;
  }

  // Resolve a soil tile for a given ground cell.
  //   soil_0.png   -> off-land / outside playable area
  //   soil_1.png   -> default playable land
  //   soil_2.png   -> tilled (backend: cellData.state == 'tilled')
  //   plow_soil.png-> currently being plowed (backend: cellData.state == 'plowing')
  String _resolveSoilAsset(_PaintTask task) {
    if (!task.isForeground) {
      return 'assets/game_images/components/soil/soil_0.png';
    }
    final cell = task.cellData;
    String? state;
    if (cell is Map) {
      final s = cell['state'] ?? cell['soil_state'];
      if (s is String) state = s;
    }
    switch (state) {
      case 'plowing':
        return 'assets/game_images/components/soil/plow_soil.png';
      case 'tilled':
      case 'soil':
        return 'assets/game_images/components/soil/soil_2.png';
      default:
        return 'assets/game_images/components/soil/soil_1.png';
    }
  }

  void _paintGround(Canvas canvas, Paint paint, _PaintTask task) {
    final String assetPath = _resolveSoilAsset(task);
    ui.Image? baseImg = assetManager.getImage(assetPath);

    // On-demand load with a legacy grass fallback so the tile never shows a
    // raw transparent diamond while the new soil sheet is still streaming in.
    if (baseImg == null) {
      if (!assetManager.hasFailed(assetPath)) {
        unawaited(assetManager.loadAssets([assetPath]));
      }
      final String legacy = task.isForeground
          ? 'assets/game_images/textures/grass_land.jpg'
          : 'assets/game_images/textures/soil_background.jpg';
      baseImg = assetManager.getImage(legacy);
    }

    canvas.save();
    canvas.translate(task.isoX, task.isoY);

    final Path path = Path();
    path.moveTo(tileWidth / 2, 0);
    path.lineTo(tileWidth, tileHeight / 2);
    path.lineTo(tileWidth / 2, tileHeight);
    path.lineTo(0, tileHeight / 2);
    path.close();

    canvas.clipPath(path);

    if (baseImg != null) {
      // Subtle pulse on the plowing tile so the active work is visible even
      // before backend state changes stream in.
      final bool isPlowing = assetPath.endsWith('plow_soil.png');
      if (isPlowing) {
        final double pulse =
            0.85 + 0.15 * math.sin(animationValue * math.pi * 2);
        canvas.saveLayer(
          const Rect.fromLTWH(0, 0, tileWidth, tileHeight),
          Paint()
            ..colorFilter = ColorFilter.mode(
              Color.fromRGBO(255, 255, 255, pulse.clamp(0.0, 1.0)),
              BlendMode.modulate,
            ),
        );
      }
      paintImage(
        canvas: canvas,
        rect: const Rect.fromLTWH(0, 0, tileWidth, tileHeight),
        image: baseImg,
        fit: BoxFit.cover,
      );
      if (isPlowing) canvas.restore();
    } else {
      // Final fallback: flat color so the grid always renders.
      paint.style = PaintingStyle.fill;
      paint.color = task.isForeground
          ? const Color(0xFF6B8E23)
          : const Color(0xFF3C3C3C);
      canvas.drawRect(const Rect.fromLTWH(0, 0, tileWidth, tileHeight), paint);
    }

    canvas.restore();

    // Border
    canvas.save();
    canvas.translate(task.isoX, task.isoY);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    paint.color = task.isForeground
        ? Colors.white.withOpacity(0.2)
        : Colors.white.withOpacity(0.05);
    canvas.drawPath(path, paint);
    canvas.restore();
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
          fit: BoxFit.contain,
        );
      }
    }

    // 3. Draw Fences
    for (var fence in task.fences) {
      bool hideFence = false;
      if (selectedX != null && selectedY != null) {
        if (fence.asset.contains('fance1') &&
            selectedY == fence.adjacentY &&
            (selectedX! - task.x).abs() <= 1) {
          hideFence = true;
        } else if (fence.asset.contains('fance2') &&
            selectedX == fence.adjacentX &&
            (selectedY! - task.y).abs() <= 1) {
          hideFence = true;
        }
      }

      if (!hideFence) {
        final ui.Image? fenceImg = assetManager.getImage(fence.asset);
        if (fenceImg != null) {
          double h = tileHeight * 2;
          double w = tileWidth;
          double bottomDist = (tileHeight / 2) + fence.dy;
          double dx = task.isoX + fence.dx;
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
    final int fw = task.cellData['footprint_width'] ?? 1;
    final int fh = task.cellData['footprint_height'] ?? 1;
    final int ox = task.cellData['origin_x'] ?? task.x;
    final int oy = task.cellData['origin_y'] ?? task.y;

    // To ensure correct isometric depth sorting, multi-tile items must be drawn
    // when painting their bottom-most tile (highest depth).
    if (task.x != ox + fw - 1 || task.y != oy + fh - 1) return;

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

      final bool isActive = task.cellData['is_active'] != false;
      assetManager.prefetchSpriteFrames(
        spriteBase,
        frameCountHint: maxFrames,
        prefetchCount: isActive ? 8 : 1,
      );

      int hash = (task.x * 31 + task.y * 17);
      double adjustedTime = animationValue + (hash % 100) / 100.0;
      int targetFrameIndex = isActive
          ? ((adjustedTime * maxFrames) % maxFrames).floor()
          : 0;

      final String targetFramePath = assetManager.getFramePath(
        spriteBase,
        targetFrameIndex,
      );
      final String fallbackFramePath = assetManager.getFramePath(spriteBase, 0);

      ui.Image? img =
          assetManager.getImage(targetFramePath) ??
          assetManager.getImage(fallbackFramePath);

      if (img == null) {
        final missing = <String>[];
        if (!assetManager.hasFailed(targetFramePath)) {
          missing.add(targetFramePath);
        }
        if (targetFramePath != fallbackFramePath &&
            !assetManager.hasFailed(fallbackFramePath)) {
          missing.add(fallbackFramePath);
        }
        if (missing.isNotEmpty) {
          unawaited(assetManager.loadAssets(missing));
        }
        return;
      }

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
      if (isActive) {
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(dx, dy, w, h),
          image: img,
          fit: BoxFit.contain,
        );
      } else {
        // Disabled/pending: pure black silhouette, alpha preserved
        paintImage(
          canvas: canvas,
          rect: Rect.fromLTWH(dx, dy, w, h),
          image: img,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.matrix([
            0, 0, 0, 0, 0, // R → 0
            0, 0, 0, 0, 0, // G → 0
            0, 0, 0, 0, 0, // B → 0
            0, 0, 0, 1, 0, // A → original (keeps sprite shape)
          ]),
        );
      }
      return;
    }
  }

  // Valid directions that actually exist under sprites/worker/<action>/.
  static const Set<String> _kWorkerDirections = {
    'bottom-side',
    'forward-side',
    'left-side',
    'right-side',
    'left-bottom-side',
    'left-forward-side',
    'right-bottom-side',
    'right-forward-side',
  };

  // Valid actions that exist as folders under sprites/worker/.
  static const Set<String> _kWorkerActions = {
    'idle',
    'walk',
    'hoe',
    'plant',
    'wCan',
  };

  String _resolveWorkerSpriteBase(_PaintTask task) {
    final String action = _kWorkerActions.contains(task.playerAction)
        ? task.playerAction!
        : (task.playerStatus == 'walking' ? 'walk' : 'idle');
    final String direction = _kWorkerDirections.contains(task.playerDirection)
        ? task.playerDirection!
        : 'forward-side';
    return 'sprites/worker/$action/$direction';
  }

  void _paintPlayer(Canvas canvas, _PaintTask task) {
    final String spriteBase = _resolveWorkerSpriteBase(task);

    int maxFrames = assetManager.getFrameCount(spriteBase);
    if (maxFrames == 0) maxFrames = 1;

    final bool isAnimated =
        task.playerStatus == 'walking' ||
        task.playerAction == 'walk' ||
        task.playerAction == 'hoe' ||
        task.playerAction == 'plant' ||
        task.playerAction == 'wCan';
    assetManager.prefetchSpriteFrames(
      spriteBase,
      frameCountHint: maxFrames,
      prefetchCount: isAnimated ? 8 : 2,
    );

    final int frameIndex = (maxFrames > 1 && isAnimated)
        ? ((animationValue * maxFrames) % maxFrames).floor()
        : 0;
    final String currentFramePath = assetManager.getFramePath(
      spriteBase,
      frameIndex,
    );
    final String idleFramePath = assetManager.getFramePath(spriteBase, 0);

    ui.Image? img =
        assetManager.getImage(currentFramePath) ??
        assetManager.getImage(idleFramePath);

    // Graceful fallback: if the action sheet has no frames yet, try the idle
    // sheet for the same direction so the worker never disappears mid-action.
    if (img == null && !spriteBase.contains('/idle/')) {
      final String fallbackBase =
          'sprites/worker/idle/${_kWorkerDirections.contains(task.playerDirection) ? task.playerDirection : 'forward-side'}';
      final String fallbackPath = assetManager.getFramePath(fallbackBase, 0);
      img = assetManager.getImage(fallbackPath);
      if (img == null && !assetManager.hasFailed(fallbackPath)) {
        unawaited(assetManager.loadAssets([fallbackPath]));
      }
    }

    if (img == null) {
      final missing = <String>[];
      if (!assetManager.hasFailed(currentFramePath)) {
        missing.add(currentFramePath);
      }
      if (currentFramePath != idleFramePath &&
          !assetManager.hasFailed(idleFramePath)) {
        missing.add(idleFramePath);
      }
      if (missing.isNotEmpty) {
        unawaited(assetManager.loadAssets(missing));
      }
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
        _paintWorkerLabel(
          canvas,
          task.workerName!,
          task.isoX + tileWidth / 2,
          dy - 4,
          isBusy: task.workerIsBusy,
        );
      }

      // Draw busy badge overlay
      if (task.workerIsBusy) {
        _paintBusyBadge(
          canvas,
          task.isoX + tileWidth * 0.8,
          dy + fixedH * 0.05,
        );
      }
    } else {
      final Paint shadowPaint = Paint()..color = Colors.black.withOpacity(0.2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            task.isoX + tileWidth / 2,
            task.isoY + tileHeight * 0.8,
          ),
          width: tileWidth * 0.4,
          height: tileHeight * 0.2,
        ),
        shadowPaint,
      );
    }
  }

  void _paintBusyBadge(Canvas canvas, double cx, double cy) {
    // Red circle badge
    final badgePaint = Paint()..color = const Color(0xFFE53935);
    canvas.drawCircle(Offset(cx, cy), 6, badgePaint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), 6, borderPaint);

    // Hourglass icon (two triangles)
    final iconPaint = Paint()..color = Colors.white;
    final Path top = Path()
      ..moveTo(cx - 3, cy - 4)
      ..lineTo(cx + 3, cy - 4)
      ..lineTo(cx, cy)
      ..close();
    final Path bot = Path()
      ..moveTo(cx - 3, cy + 4)
      ..lineTo(cx + 3, cy + 4)
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(top, iconPaint);
    canvas.drawPath(bot, iconPaint);
  }

  void _paintWorkerLabel(
    Canvas canvas,
    String name,
    double cx,
    double topY, {
    bool isBusy = false,
  }) {
    const double fontSize = 9.0;
    const double padding = 3.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: isBusy ? '$name  ⏳' : name,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double labelW = textPainter.width + padding * 2;
    final double labelH = textPainter.height + padding;

    final Color bgColor = isBusy
        ? const Color(0xCCE53935)
        : Colors.black.withOpacity(0.55);

    final RRect bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - labelW / 2, topY - labelH - 2, labelW, labelH),
      const Radius.circular(3),
    );

    canvas.drawRRect(bgRect, Paint()..color = bgColor);
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, topY - labelH - 2 + padding / 2),
    );
  }

  @override
  bool shouldRepaint(covariant IsometricMapPainter oldDelegate) {
    return oldDelegate.selectedX != selectedX ||
        oldDelegate.selectedY != selectedY ||
        oldDelegate.matrix != matrix ||
        oldDelegate.playableMask != playableMask ||
        oldDelegate.placementMode != placementMode ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.workers != workers;
  }
}

class _FenceData {
  final String asset;
  final double dx;
  final double dy;
  final int adjacentX;
  final int adjacentY;

  _FenceData(this.asset, this.dx, this.dy, this.adjacentX, this.adjacentY);
}

class _PaintTask {
  final int x;
  final int y;
  final double isoX;
  final double isoY;
  final bool isForeground;
  final bool hasTree;
  final String? treeAsset;
  final List<_FenceData> fences;
  final dynamic cellData;
  final bool isPlayer;
  final String? playerDirection;
  final String? playerStatus;
  final String? playerAction; // 'idle' | 'walk' | 'hoe' | 'plant' | 'wCan'
  final String? workerName; // for name label
  final double? workerDepth; // fractional depth for sorting
  final bool workerIsBusy; // whether worker has an active task

  _PaintTask({
    required this.x,
    required this.y,
    required this.isoX,
    required this.isoY,
    required this.isForeground,
    required this.hasTree,
    this.treeAsset,
    this.fences = const [],
    this.cellData,
    this.isPlayer = false,
    this.playerDirection,
    this.playerStatus,
    this.playerAction,
    this.workerName,
    this.workerDepth,
    this.workerIsBusy = false,
  });
}
