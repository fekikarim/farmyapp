import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
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
  // When non-null, the item at (placingAtX, placingAtY) is being committed
  // to the backend. Tree ghosts swap to add_tree_loading.png until the
  // matrix reload resolves the real sprite.
  final bool placingInFlight;

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
    this.placingInFlight = false,
    this.externalSelectionX,
    this.externalSelectionY,
  });

  @override
  State<IsometricMap> createState() => IsometricMapState();
}

class IsometricMapState extends State<IsometricMap> {
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

  // Ambient animation clock for crops, machines, and idle workers. Walking
  // workers ignore this and drive their own phase from velocity (see
  // WorkerState.animPhase) so stride speed tracks the joystick. The 60 ms
  // cadence (≈16 fps) is a compromise: fast enough that ambient sprites don't
  // look choppy next to velocity-coupled worker sprites, slow enough to avoid
  // full-canvas repaints on every frame when the map is otherwise idle.
  Timer? _animationTimer;
  double _animationValue = 0;
  final AssetManager _assetManager = AssetManager();

  // Camera controller for smooth follow system
  final TransformationController _cameraController = TransformationController();
  bool _userInteracting = false;

  // Smooth camera interpolation constants - 60fps with responsive 0.20 lerp
  static const double _kCameraLerpFactor = 0.20; // Fast but smooth (60fps)
  static const double _kCameraLerpFast = 0.30; // For initial catch-up

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 60), (_) {
      if (!mounted) return;
      setState(() {
        _animationValue = (_animationValue + 0.02) % 1;
      });
      // Camera follow update now driven by _gameLoopTicker for 60fps sync
    });
  }

  /// Updates camera position when follow mode is active (called at 60fps from GameScreen)
  void onCameraTick(double dt) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (!gameProvider.isCameraFollowing) return;
    if (!gameProvider.manualControlActive) return;
    if (_userInteracting) return; // Don't fight user interaction

    final worker = gameProvider.manualControlWorker;
    if (worker == null) return;

    final targetPos = _gridToScreenPosition(worker.x, worker.y);
    _centerCameraOn(targetPos, dt: dt);
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  /// Convert grid coordinates to screen position (isometric projection)
  Offset _gridToScreenPosition(double gridX, double gridY) {
    final double offsetX = (widget.gridHeight * tileWidth / 2);
    const double offsetY = 100;

    final double isoX = (gridX - gridY) * (tileWidth / 2) + offsetX;
    final double isoY = (gridX + gridY) * (tileHeight / 2) + offsetY;

    return Offset(isoX, isoY);
  }

  /// Smoothly center camera on target position with delta-time lerp interpolation
  /// [dt] is elapsed seconds since last frame for frame-rate independent smoothing
  void _centerCameraOn(
    Offset targetPos, {
    double? lerpFactor,
    double dt = 0.016,
  }) {
    final Matrix4 current = _cameraController.value;
    final Vector3 translation = current.getTranslation();
    final double currentX = translation.x;
    final double currentY = translation.y;
    final double scale = current.getMaxScaleOnAxis();

    // Get viewport size
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Size viewport = renderBox.size;

    // Calculate target translation to center the point
    final double targetX = (viewport.width / 2) - (targetPos.dx * scale);
    final double targetY = (viewport.height / 2) - (targetPos.dy * scale);

    // Delta-time aware interpolation for consistent speed at any frame rate
    // lerp = 1 - (1 - baseLerp)^(dt * 60) where 60 is reference fps
    final double baseLerp = lerpFactor ?? _kCameraLerpFactor;
    final double lerp = 1.0 - math.pow(1.0 - baseLerp, dt * 60.0).toDouble();

    // Lerp current to target for smooth motion
    final double newX = currentX + (targetX - currentX) * lerp;
    final double newY = currentY + (targetY - currentY) * lerp;

    // Apply with scale preserved
    final Matrix4 newMatrix = Matrix4.identity()
      ..translate(newX, newY)
      ..scale(scale);

    _cameraController.value = newMatrix;
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

    return Stack(
      children: [
        // Main map with InteractiveViewer (at bottom of stack)
        GestureDetector(
          // Detect user camera interaction to disable follow mode
          onPanStart: (_) {
            if (gameProvider.isCameraFollowing) {
              _userInteracting = true;
              gameProvider.disableCameraFollow();
            }
          },
          onPanEnd: (_) => _userInteracting = false,
          onPanCancel: () => _userInteracting = false,
          child: InteractiveViewer(
            transformationController: _cameraController,
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
                      assetManager: _assetManager,
                      placementMode: widget.placementMode,
                      placementFootprint: widget.placementFootprint,
                      placementItem: widget.placementItem,
                      placingInFlight: widget.placingInFlight,
                      animationValue: _animationValue,
                      workers: gameProvider.workers,
                      workerVisualHash: _computeWorkersVisualHash(
                        gameProvider.workers,
                      ),
                      showCollisionDebug: gameProvider.collisionDebugEnabled,
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
          ),
        ),

        // Camera follow button (top-left, shows when manual control active)
        // Placed at end of Stack to render on top of everything
        // Aligned with exit joystick button (top: 40) with SafeArea padding
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          top: gameProvider.manualControlActive ? 40 : -80,
          left: 16,
          child: AnimatedOpacity(
            opacity: gameProvider.manualControlActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: SafeArea(
              child: Material(
                elevation: gameProvider.isCameraFollowing ? 8 : 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => gameProvider.toggleCameraFollow(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: gameProvider.isCameraFollowing
                          ? const Color(0xFF4CAF50) // Green when active
                          : const Color(0xFF424242), // Grey when inactive
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      gameProvider.isCameraFollowing
                          ? Icons.center_focus_strong
                          : Icons.center_focus_weak,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

    // 1a. Worker hit-testing — runs before item/tile dispatch so a single tap
    // on a worker sprite surfaces the worker radial menu instead of the tile
    // underneath. Skipped in placement mode (placement UI owns the tap) and
    // on double-tap (existing double-tap semantics: "send closest worker here").
    if (!widget.placementMode && !isDoubleClick) {
      final WorkerState? hitWorker = _workerAtLocal(
        localPos,
        gameProvider.workers,
        offsetX,
        offsetY,
      );
      if (hitWorker != null) {
        _openWorkerMenu(hitWorker, offsetX, offsetY);
        return;
      }
    }

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
            ui.Image? img;
            if (item['category'] == 'tree') {
              img = _assetManager.getImage(
                IsometricMapPainter._treeAssetForVariant(item['variant_code']),
              );
            } else {
              final sprites = item['sprites'];
              final state = item['state'];
              String status = state?['status'] ?? 'idle';
              String? spriteBase = sprites?[status] ?? sprites?['idle'];
              if (spriteBase != null) {
                if (spriteBase.startsWith('/'))
                  spriteBase = spriteBase.substring(1);
                final String framePath =
                    'assets/game_images/$spriteBase/image0.png';
                img = _assetManager.getImage(framePath);
              }
            }
            if (img != null) {
              h = w * (img.height / img.width);
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

  /// Screen-space hit-test for workers. Must mirror the bounding rect used by
  /// [IsometricMapPainter._paintPlayer] (fixedH = tileHeight * 2.2, anchored
  /// with feet at isoY + tileHeight*0.9). Front-to-back iteration (higher
  /// y/x first) picks the worker visually on top when multiple overlap.
  WorkerState? _workerAtLocal(
    Offset localPos,
    List<WorkerState> workers,
    double offsetX,
    double offsetY,
  ) {
    if (workers.isEmpty) return null;
    // Sort a shallow copy by draw-order depth so overlapping sprites pick the
    // front-most one first. Cheap — worker counts are typically < 10.
    final List<WorkerState> ordered = List<WorkerState>.from(workers)
      ..sort((a, b) => (b.x + b.y).compareTo(a.x + a.y));

    const double fixedH = tileHeight * 2.2;
    // Approximate sprite width (real value depends on loaded image aspect).
    // Using 0.75 * tileWidth keeps the hit area generous but still worker-
    // shaped so ground taps aren't hijacked near but outside the sprite.
    const double hitW = tileWidth * 0.75;

    for (final w in ordered) {
      final double isoX = (w.x - w.y) * (tileWidth / 2) + offsetX;
      final double isoY = (w.x + w.y) * (tileHeight / 2) + offsetY;
      final double dx = isoX + (tileWidth - hitW) / 2;
      final double dy = isoY + (tileHeight * 0.9) - fixedH;
      final Rect hit = Rect.fromLTWH(dx, dy, hitW, fixedH);
      if (hit.contains(localPos)) return w;
    }
    return null;
  }

  /// Opens the radial menu anchored above a worker's current sprite head.
  /// Uses the worker's fractional (x, y) so the menu tracks smoothly if the
  /// player re-taps mid-move. Item data is tagged with `__worker: true` so
  /// [_getActionsFor] and the onActionSelected callback can distinguish it
  /// from placed grid items.
  void _openWorkerMenu(WorkerState w, double offsetX, double offsetY) {
    final double isoX = (w.x - w.y) * (tileWidth / 2) + offsetX;
    final double isoY = (w.x + w.y) * (tileHeight / 2) + offsetY;
    // Anchor roughly at the sprite's head — fixedH above ground line.
    const double fixedH = tileHeight * 2.2;
    final double targetX = isoX + tileWidth / 2;
    final double targetY = isoY + tileHeight * 0.9 - fixedH + 8;

    setState(() {
      _menuGridX = w.x.floor();
      _menuGridY = w.y.floor();
      _menuItemData = <String, dynamic>{
        '__worker': true,
        'worker_id': w.workerId,
        'worker_name': w.workerName,
        'is_busy': w.availability == 'busy',
      };
      _menuPixelX = targetX;
      _menuPixelY = targetY;
    });
  }

  int _computeWorkersVisualHash(List<WorkerState> workers) {
    int hash = workers.length;
    for (final worker in workers) {
      hash = 0x1fffffff & (hash * 31 + worker.workerId.hashCode);
      hash = 0x1fffffff & (hash * 31 + (worker.x * 1000).round());
      hash = 0x1fffffff & (hash * 31 + (worker.y * 1000).round());
      hash = 0x1fffffff & (hash * 31 + worker.direction.hashCode);
      hash = 0x1fffffff & (hash * 31 + worker.status.hashCode);
      hash = 0x1fffffff & (hash * 31 + worker.action.hashCode);
      hash = 0x1fffffff & (hash * 31 + worker.availability.hashCode);
      // Walk-cycle phase quantised to 64 buckets — fine enough that every
      // sprite-frame change produces a distinct hash, coarse enough that
      // sub-frame jitter doesn't trigger gratuitous repaints.
      hash = 0x1fffffff & (hash * 31 + (worker.animPhase * 64).round());
    }
    return hash;
  }

  List<RadialMenuAction> _getActionsFor(dynamic itemData) {
    List<RadialMenuAction> actions = [];

    // Worker-tagged menu: emit an Info + Move pair. Move toggles manual
    // joystick control via the GameProvider and is suppressed on busy workers
    // so in-flight tasks aren't hijacked mid-animation.
    if (itemData is Map && itemData['__worker'] == true) {
      actions.add(
        RadialMenuAction(
          id: 'info',
          icon: Icons.person_outline,
          backgroundColor: Colors.blueAccent,
          tooltip: 'Info',
        ),
      );
      if (itemData['is_busy'] != true) {
        actions.add(
          RadialMenuAction(
            id: 'move',
            icon: Icons.control_camera,
            backgroundColor: Colors.green,
            tooltip: 'Move',
          ),
        );
      }
      return actions;
    }

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
  final bool placingInFlight;

  // Animation
  final double animationValue;

  // Workers
  final List<WorkerState> workers;
  final int workerVisualHash;

  // Debug
  final bool showCollisionDebug;

  // Constants
  static const double tileWidth = 64.0;
  static const double tileHeight = 32.0;

  // Fence rendering tunables.
  //
  // The horizontal screen span of one isometric tile edge is exactly
  // tileWidth / 2 (= 32 px). _kFenceWidthFactor sizes the sprite's render
  // width relative to tileWidth: at 0.55 the sprite is 35.2 px wide, giving
  // a ~3 px per-corner overlap that lets neighbouring fence sprites blend
  // into a continuous line without stacking visibly at intersections.
  //
  // _kFenceGroundLiftRatio buries the sprite's bottom edge into the off-land
  // tile by that fraction of the rendered fence height. Expressed as a ratio
  // (not a fixed pixel offset) so planting depth stays visually consistent
  // if _kFenceWidthFactor — and therefore sprite height — is retuned, and so
  // any transparent bottom padding baked into the PNGs is hidden below the
  // boundary regardless of sprite scale.
  static const double _kFenceWidthFactor = 0.55;
  static const double _kFenceTargetWidth = tileWidth * _kFenceWidthFactor;
  static const double _kFenceGroundLiftRatio = 0.24;
  static const double _kFenceBoundaryNudgePx = 0.8;

  // Per-asset aspect ratio cache (height / width). The intrinsic ratio of the
  // PNG is constant across frames, so we decode it once and reuse — avoiding
  // per-frame division and keeping the paint path at 60 fps. Only finite,
  // positive ratios are cached, so a transiently bad decode can't poison the
  // entry for the rest of the session.
  static final Map<String, double> _fenceAspectCache = <String, double>{};

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
    this.placingInFlight = false,
    required this.animationValue,
    required this.workers,
    required this.workerVisualHash,
    this.showCollisionDebug = false,
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

          // Fence perimeter tracing: for every off-land tile that sits on the
          // boundary, emit one fence sprite per shared edge with a playable
          // neighbor. This walks the land outline dynamically, so arbitrary
          // shapes and any grid size produce a correct continuous perimeter.
          //
          // (dx, dy) -> fence sprite:
          //   fance_001 = edges on the NE/SW axis (y±1 neighbors)
          //   fance_002 = edges on the NW/SE axis (x±1 neighbors)
          const String fance001 =
              'assets/game_images/3d/outside_fance/fance_001.png';
          const String fance002 =
              'assets/game_images/3d/outside_fance/fance_002.png';
          const List<List<int>> kNeighborOffsets = [
            [0, 1], // bottom-left edge  -> fance_001
            [0, -1], // top-right edge    -> fance_001
            [1, 0], // bottom-right edge -> fance_002
            [-1, 0], // top-left edge     -> fance_002
          ];
          for (final offset in kNeighborOffsets) {
            final int dx = offset[0];
            final int dy = offset[1];
            if (!hasPlayableNeighbor(x + dx, y + dy)) continue;
            final String asset = (dy != 0) ? fance001 : fance002;
            tileFences.add(_FenceData(asset, x + dx, y + dy));
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
          playerAnimPhase: worker.animPhase,
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

    // 6. Draw Collision Debug (On Top)
    if (showCollisionDebug) {
      _paintCollisionDebug(canvas, offsetX, offsetY);
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
    final String? category =
        (placementItem!['category'] ?? placementItem!['asset_category'])
            as String?;

    // Trees: render the static apple/orange PNG (or the loading sprite while
    // the placement request is in flight) as the ghost.
    if (category == 'tree') {
      final String treePath = placingInFlight
          ? _kTreeLoadingAsset
          : _treeAssetForVariant(
              placementItem!['variant_code'] ?? details?['variant_name'],
            );
      final _PaintTask ghostTask = _PaintTask(
        x: selectedX!,
        y: selectedY!,
        isoX: isoX,
        isoY: isoY,
        isForeground: true,
        hasTree: false,
      );
      _paintStaticTreeImage(canvas, ghostTask, treePath, opacity: 0.7);
      return;
    }

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

  void _paintCollisionDebug(Canvas canvas, double offsetX, double offsetY) {
    // Import collision constants from game_provider.dart
    // These are duplicated here for debug visualization
    const double collisionRadius = 0.35; // _kWorkerCollisionRadius
    const double padding = 0.60; // _kOffLandCollisionPadding
    const double boundaryOffset =
        collisionRadius + padding; // _kBoundaryMinOffset = 0.95

    final Paint boundaryPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Paint radiusPaint = Paint()
      ..color = Colors.orange.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final Paint fullBoundPaint = Paint()
      ..color = Colors.purple.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw boundary lines along the edge of playable area
    for (int y = -1; y <= gridHeight; y++) {
      for (int x = -1; x <= gridWidth; x++) {
        final bool isPlayable = _isPlayableCell(x, y);
        if (!isPlayable) {
          // Check if any neighbor is playable (this is a boundary edge)
          bool hasPlayableNeighbor = false;
          const List<List<int>> neighbors = [
            [0, 1],
            [0, -1],
            [1, 0],
            [-1, 0],
          ];
          for (final n in neighbors) {
            if (_isPlayableCell(x + n[0], y + n[1])) {
              hasPlayableNeighbor = true;
              break;
            }
          }
          if (hasPlayableNeighbor) {
            // Draw boundary line
            double isoX = (x - y) * (tileWidth / 2) + offsetX;
            double isoY = (x + y) * (tileHeight / 2) + offsetY;
            final Path path = Path();
            path.moveTo(isoX + tileWidth / 2, isoY);
            path.lineTo(isoX + tileWidth, isoY + tileHeight / 2);
            path.lineTo(isoX + tileWidth / 2, isoY + tileHeight);
            path.lineTo(isoX, isoY + tileHeight / 2);
            path.close();
            canvas.drawPath(path, boundaryPaint);
          }
        }
      }
    }

    // Draw worker collision circles
    for (final worker in workers) {
      double isoX = (worker.x - worker.y) * (tileWidth / 2) + offsetX;
      double isoY = (worker.x + worker.y) * (tileHeight / 2) + offsetY;

      // Convert grid collision radius to screen pixels
      // In isometric: X moves (tileWidth/2) per grid unit, Y moves (tileHeight/2) per grid unit
      final double screenRadiusX = collisionRadius * (tileWidth / 2);
      final double screenRadiusY = collisionRadius * (tileHeight / 2);

      // Draw collision radius (orange)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(isoX + tileWidth / 2, isoY + tileHeight / 2),
          width: screenRadiusX * 2,
          height: screenRadiusY * 2,
        ),
        radiusPaint,
      );

      // Draw full boundary offset (purple - including padding)
      final double screenBoundX = boundaryOffset * (tileWidth / 2);
      final double screenBoundY = boundaryOffset * (tileHeight / 2);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(isoX + tileWidth / 2, isoY + tileHeight / 2),
          width: screenBoundX * 2,
          height: screenBoundY * 2,
        ),
        fullBoundPaint,
      );

      // Draw center point
      canvas.drawCircle(
        Offset(isoX + tileWidth / 2, isoY + tileHeight / 2),
        3,
        Paint()..color = Colors.yellow,
      );
    }
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
        if (fence.asset.contains('fance_001') &&
            selectedY == fence.adjacentY &&
            (selectedX! - task.x).abs() <= 1) {
          hideFence = true;
        } else if (fence.asset.contains('fance_002') &&
            selectedX == fence.adjacentX &&
            (selectedY! - task.y).abs() <= 1) {
          hideFence = true;
        }
      }

      if (!hideFence) {
        final ui.Image? fenceImg = assetManager.getImage(fence.asset);
        if (fenceImg == null) {
          // Kick off async load; next frame will paint it.
          if (!assetManager.hasFailed(fence.asset)) {
            unawaited(assetManager.loadAssets([fence.asset]));
          }
          continue;
        }
        _paintFenceSprite(canvas, task, fence, fenceImg);
      }
    }
  }

  // Draws a single fence sprite aligned to the shared edge between the
  // off-land tile (task.x, task.y) and its playable neighbor
  // (fence.adjacentX, fence.adjacentY).
  //
  // Size is derived from the PNG's intrinsic aspect so whichever art pack is
  // shipped looks correct without stretching. The bottom-center of the sprite
  // is anchored on the tile-edge midpoint so the fence line visually sits on
  // the land boundary rather than floating inside/outside the tile.
  void _paintFenceSprite(
    Canvas canvas,
    _PaintTask task,
    _FenceData fence,
    ui.Image img,
  ) {
    // Defensive: a corrupted or partially-decoded texture can surface with
    // zero or non-finite dimensions. Skip painting rather than crashing or
    // poisoning the aspect cache — the missing frame will fill in on the
    // next paint pass once the AssetManager replaces the bad entry.
    final int imgW = img.width;
    final int imgH = img.height;
    if (imgW <= 0 || imgH <= 0) return;

    final _FenceEdge edge = _FenceEdge.fromDelta(
      fence.adjacentX - task.x,
      fence.adjacentY - task.y,
    );
    final Offset midLocal = edge.midpoint(tileWidth, tileHeight);
    final Offset seamNudge = edge.playableSideNudge(_kFenceBoundaryNudgePx);

    final double aspect = _fenceAspectCache.putIfAbsent(
      fence.asset,
      () => imgH / imgW,
    );
    if (!aspect.isFinite || aspect <= 0) {
      // Evict the bad entry so a subsequent, valid decode can repopulate it.
      _fenceAspectCache.remove(fence.asset);
      return;
    }

    final double w = _kFenceTargetWidth;
    final double h = w * aspect;
    final double lift = h * _kFenceGroundLiftRatio;

    // Anchor: bottom-center of the sprite lands on the edge midpoint, then
    // shifted down by `lift` (a fraction of sprite height) so the posts are
    // planted into the off-land side of the boundary instead of hovering
    // above the land texture. Using a height-proportional offset keeps the
    // rooted look consistent across both fence assets and any future tweaks
    // to _kFenceWidthFactor.
    final double paintDx = task.isoX + midLocal.dx - w / 2 + seamNudge.dx;
    final double paintDy = task.isoY + midLocal.dy - h + lift + seamNudge.dy;

    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(paintDx, paintDy, w, h),
      image: img,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.low,
    );
  }

  void _paintItem(Canvas canvas, _PaintTask task) {
    final int fw = task.cellData['footprint_width'] ?? 1;
    final int fh = task.cellData['footprint_height'] ?? 1;
    final int ox = task.cellData['origin_x'] ?? task.x;
    final int oy = task.cellData['origin_y'] ?? task.y;

    // To ensure correct isometric depth sorting, multi-tile items must be drawn
    // when painting their bottom-most tile (highest depth).
    if (task.x != ox + fw - 1 || task.y != oy + fh - 1) return;

    // Trees are rendered from a curated set of single-PNG sprites rather than
    // animated frame folders. Route them through the static painter.
    if (task.cellData['category'] == 'tree') {
      final String path = _resolveTreeAsset(task.cellData);
      _paintStaticTreeImage(canvas, task, path, fw: fw, fh: fh);
      return;
    }

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

  // ---------------------------------------------------------------------------
  // Tree sprite resolution
  //
  // Tree variants come from the backend as single PNGs rather than animated
  // folders. The mapping is driven by variant_code:
  //   apple_*  -> tree_001.png
  //   orange_* -> tree_101.png
  // Any pending/planting state (or an in-flight placement request for this
  // cell) resolves to the loading sprite.
  // ---------------------------------------------------------------------------
  static const String _kTreeAppleAsset =
      'assets/game_images/3d/outside_tree/tree_001.png';
  static const String _kTreeOrangeAsset =
      'assets/game_images/3d/outside_tree/tree_101.png';
  static const String _kTreeLoadingAsset =
      'assets/game_images/3d/outside_tree/add_tree_loading.png';
  static const Set<String> _kTreeLoadingStatuses = {
    'pending',
    'planting',
    'loading',
  };

  String _resolveTreeAsset(Map<String, dynamic> cellData) {
    final dynamic stateField = cellData['state'];
    String? status;
    if (stateField is Map) {
      final dynamic s = stateField['status'] ?? stateField['state'];
      if (s is String) status = s;
    }
    final bool inFlight =
        placingInFlight &&
        placementItem != null &&
        placementItem!['id'] == cellData['id'];
    if (inFlight ||
        (status != null && _kTreeLoadingStatuses.contains(status))) {
      return _kTreeLoadingAsset;
    }
    return _treeAssetForVariant(cellData['variant_code']);
  }

  static String _treeAssetForVariant(dynamic variantCode) {
    if (variantCode is String) {
      final String code = variantCode.toLowerCase();
      if (code.startsWith('orange')) return _kTreeOrangeAsset;
      if (code.startsWith('apple')) return _kTreeAppleAsset;
    }
    return _kTreeAppleAsset;
  }

  void _paintStaticTreeImage(
    Canvas canvas,
    _PaintTask task,
    String assetPath, {
    int fw = 1,
    int fh = 1,
    double opacity = 1.0,
  }) {
    final ui.Image? img = assetManager.getImage(assetPath);
    if (img == null) {
      if (!assetManager.hasFailed(assetPath)) {
        unawaited(assetManager.loadAssets([assetPath]));
      }
      return;
    }

    final double scaleFactor = (fw == 1 && fh == 1) ? 1.0 : (fw + fh) / 2.0;
    final double w = tileWidth * 1.3 * scaleFactor;
    final double h = w * (img.height / img.width);

    double dx, dy;
    if (fw == 1 && fh == 1) {
      dx = task.isoX + (tileWidth - w) / 2;
      dy = task.isoY + (tileHeight * 0.75) - h;
    } else {
      final double cx = (fw - fh) * tileWidth / 4;
      final double cy = (fw + fh) * tileHeight / 4;
      dx = task.isoX + cx + (tileWidth - w) / 2;
      dy = task.isoY + cy - h;
    }

    if (opacity < 1.0) {
      canvas.saveLayer(
        null,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(dx, dy, w, h),
      image: img,
      fit: BoxFit.contain,
    );
    if (opacity < 1.0) canvas.restore();
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

  static final Set<String> _warnedMissingWorkerSpriteBases = <String>{};

  void _warnMissingWorkerSpriteBase(String requested, String fallback) {
    final String key = '$requested->$fallback';
    if (_warnedMissingWorkerSpriteBases.add(key)) {
      debugPrint(
        'Worker sprite set "$requested" missing; falling back to "$fallback".',
      );
    }
  }

  bool _hasUsableWorkerSpriteSet(String basePath) {
    assetManager.ensureSpriteSetDiscovery(basePath);
    return assetManager.spriteSetExists(basePath);
  }

  String _resolveWorkerSpriteBase(_PaintTask task) {
    final String action = _kWorkerActions.contains(task.playerAction)
        ? task.playerAction!
        : (task.playerStatus == 'walking' ? 'walk' : 'idle');
    final String direction = _kWorkerDirections.contains(task.playerDirection)
        ? task.playerDirection!
        : 'forward-side';

    final String requested = 'sprites/worker/$action/$direction';
    final List<String> candidates = <String>[
      requested,
      if (direction != 'forward-side') 'sprites/worker/$action/forward-side',
      'sprites/worker/idle/$direction',
      'sprites/worker/idle/forward-side',
    ];

    for (final base in candidates) {
      if (_hasUsableWorkerSpriteSet(base)) {
        if (base != requested) {
          _warnMissingWorkerSpriteBase(requested, base);
        }
        return base;
      }
    }

    const String hardFallback = 'sprites/worker/idle/forward-side';
    _warnMissingWorkerSpriteBase(requested, hardFallback);
    return hardFallback;
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

    // Pick the walk-cycle phase: velocity-coupled if the provider supplied
    // one (manual control + auto-move workers both populate this now), else
    // fall back to the ambient timer so action-animations on stationary
    // workers (hoe, plant, wCan) still advance at the global cadence.
    final double phase = task.playerAnimPhase ?? animationValue;
    final int frameIndex = (maxFrames > 1 && isAnimated)
        ? ((phase * maxFrames) % maxFrames).floor().clamp(0, maxFrames - 1)
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
        oldDelegate.placingInFlight != placingInFlight ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.workers != workers ||
        oldDelegate.workerVisualHash != workerVisualHash ||
        oldDelegate.showCollisionDebug != showCollisionDebug;
  }
}

class _FenceData {
  final String asset;
  final int adjacentX;
  final int adjacentY;

  _FenceData(this.asset, this.adjacentX, this.adjacentY);
}

// Identifies which of the four isometric edges of an off-land tile is shared
// with its playable neighbor. The name reflects where the edge visually sits
// on the screen-space diamond of the owning tile.
//
// Tile-local corner coordinates (origin at the top-left of the diamond's
// bounding box) for reference:
//   top    = (tW/2, 0)
//   right  = (tW,   tH/2)
//   bottom = (tW/2, tH)
//   left   = (0,    tH/2)
enum _FenceEdge {
  bottomLeft, // shared with neighbor at (x,   y+1) — runs top→left corner
  topRight, // shared with neighbor at (x,   y-1) — runs top→right corner
  bottomRight, // shared with neighbor at (x+1, y)   — runs right→bottom
  topLeft; // shared with neighbor at (x-1, y)   — runs top→left corner

  // Maps a neighbor-delta (dx, dy) in grid coordinates to the corresponding
  // tile edge. Exactly one of the deltas is ±1 for the four neighbors we
  // generate fences for; the priority ordering below mirrors the generation
  // loop so any future diagonal deltas degrade gracefully.
  static _FenceEdge fromDelta(int dx, int dy) {
    if (dy > 0) return _FenceEdge.bottomLeft;
    if (dy < 0) return _FenceEdge.topRight;
    if (dx > 0) return _FenceEdge.bottomRight;
    return _FenceEdge.topLeft;
  }

  // Midpoint of the shared edge in tile-local pixel space.
  Offset midpoint(double tW, double tH) {
    switch (this) {
      case _FenceEdge.bottomLeft:
        return Offset(tW / 4, 3 * tH / 4);
      case _FenceEdge.topRight:
        return Offset(3 * tW / 4, tH / 4);
      case _FenceEdge.bottomRight:
        return Offset(3 * tW / 4, 3 * tH / 4);
      case _FenceEdge.topLeft:
        return Offset(tW / 4, tH / 4);
    }
  }

  // Small nudge toward the playable side of the boundary to hide any
  // anti-aliased seam that can appear between soil_1 and fence posts.
  Offset playableSideNudge(double pixels) {
    if (pixels <= 0) return Offset.zero;
    const double major = 0.8944271909999159; // 2 / sqrt(5)
    const double minor = 0.4472135954999579; // 1 / sqrt(5)
    switch (this) {
      case _FenceEdge.bottomLeft:
        return Offset(-major * pixels, minor * pixels);
      case _FenceEdge.topRight:
        return Offset(major * pixels, -minor * pixels);
      case _FenceEdge.bottomRight:
        return Offset(major * pixels, minor * pixels);
      case _FenceEdge.topLeft:
        return Offset(-major * pixels, -minor * pixels);
    }
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
  final List<_FenceData> fences;
  final dynamic cellData;
  final bool isPlayer;
  final String? playerDirection;
  final String? playerStatus;
  final String? playerAction; // 'idle' | 'walk' | 'hoe' | 'plant' | 'wCan'
  final String? workerName; // for name label
  final double? workerDepth; // fractional depth for sorting
  final bool workerIsBusy; // whether worker has an active task
  // Velocity-coupled walk-cycle phase in [0, 1). When non-null the painter
  // uses this instead of the ambient [animationValue] so stride cadence
  // tracks actual movement speed (critical for joystick control).
  final double? playerAnimPhase;

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
    this.playerAnimPhase,
  });
}
