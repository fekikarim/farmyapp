import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/land_worker_model.dart';
import '../services/worker_service.dart';
import '../services/socket_service.dart';

/// Quantises a grid velocity vector into one of eight isometric direction
/// slugs that map 1:1 to the folders under `assets/game_images/sprites/worker`.
/// Ties (|dx| == |dy|) bias toward the more-horizontal slug to avoid flicker
/// during quasi-diagonal tweens.
String classifyDirection8(double dx, double dy) {
  if (dx == 0 && dy == 0) return 'forward-side';
  final double ax = dx.abs();
  final double ay = dy.abs();
  final bool horizontalDominant = ax >= ay * 1.75;
  final bool verticalDominant = ay >= ax * 1.75;

  if (horizontalDominant) {
    return dx > 0 ? 'right-side' : 'left-side';
  }
  if (verticalDominant) {
    return dy > 0 ? 'forward-side' : 'bottom-side';
  }
  // Diagonals
  if (dx > 0 && dy > 0) return 'right-forward-side';
  if (dx < 0 && dy > 0) return 'left-forward-side';
  if (dx > 0 && dy < 0) return 'right-bottom-side';
  return 'left-bottom-side';
}

/// Holds runtime state for a single worker on the map.
class WorkerState {
  final String workerId;
  final String workerName;
  final String? workerPicture;
  String availability; // mutable: 'available' | 'busy'
  double x;
  double y;
  double? targetX;
  double? targetY;
  String direction; // 8-way iso slug — see classifyDirection8
  String status; // 'idle' | 'walking'
  String action; // 'idle' | 'walk' | 'hoe' | 'plant' | 'wCan'
  Timer? movementTimer;

  WorkerState({
    required this.workerId,
    required this.workerName,
    this.workerPicture,
    this.availability = 'available',
    this.x = 1,
    this.y = 1,
    this.direction = 'forward-side',
    this.status = 'idle',
    this.action = 'idle',
  });

  void moveTo(
    double tx,
    double ty,
    VoidCallback onUpdate,
    VoidCallback onStop,
  ) {
    targetX = tx;
    targetY = ty;
    status = 'walking';
    action = 'walk';
    movementTimer?.cancel();

    const double speed = 0.05;

    movementTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      double dx = targetX! - x;
      double dy = targetY! - y;
      double distance = dx.abs() + dy.abs();

      if (distance < speed) {
        x = targetX!;
        y = targetY!;
        targetX = null;
        targetY = null;
        status = 'idle';
        action = 'idle';
        movementTimer?.cancel();
        onStop();
      } else {
        direction = classifyDirection8(dx, dy);
        double ratio = speed / distance;
        x += dx * ratio;
        y += dy * ratio;
        onUpdate();
      }
    });
  }

  void stop() {
    movementTimer?.cancel();
    targetX = null;
    targetY = null;
    status = 'idle';
    action = 'idle';
  }
}

class GameProvider with ChangeNotifier {
  bool _showEdgePanel = true;
  bool _isLoading = true;
  bool _workersLoading = false;

  List<WorkerState> _workers = [];
  List<List<bool>>? _playableMask;

  // Manual (joystick) control: at most one worker is driven manually at a
  // time. Nullable id avoids having to scan the worker list every frame to
  // answer "is anyone being controlled right now?".
  String? _manualControlWorkerId;

  bool get showEdgePanel => _showEdgePanel;
  bool get isLoading => _isLoading;
  bool get workersLoading => _workersLoading;
  List<WorkerState> get workers => _workers;
  String? get manualControlWorkerId => _manualControlWorkerId;
  bool get manualControlActive => _manualControlWorkerId != null;

  /// Returns the currently manually-controlled worker, or null.
  WorkerState? get manualControlWorker {
    final id = _manualControlWorkerId;
    if (id == null) return null;
    return _workers.where((w) => w.workerId == id).firstOrNull;
  }

  GameProvider() {
    _loadSettings();
  }

  /// Load workers assigned to a specific land from the API.
  Future<void> loadWorkersForLand(
    String landId, {
    int gridWidth = 10,
    int gridHeight = 10,
    List<dynamic>? playableMask,
  }) async {
    _workersLoading = true;
    notifyListeners();

    currentLandId = landId; // Remember which land workers are on
    _playableMask = _normalizePlayableMask(playableMask, gridWidth, gridHeight);

    try {
      final List<LandWorker> landWorkers = await WorkerService.getLandWorkers(
        landId,
      );

      // Cancel all running movement timers
      for (var w in _workers) {
        w.stop();
      }

      // Listen for socket events to update available dynamically when a task is completed remotely
      final socketService = SocketService();
      socketService.off(
        'worker_task_completed',
      ); // Clear old listener to prevent duplicates
      socketService.on('worker_task_completed', (data) {
        if (data is Map<String, dynamic>) {
          final completedWorkerId = data['workerId'];
          final landIdEvent = data['landId'];
          if (landIdEvent == currentLandId) {
            // Verify it's for current land
            setWorkerAvailable(completedWorkerId);
          }
        }
      });

      // Load saved positions from SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      _workers = [];
      for (int i = 0; i < landWorkers.length; i++) {
        final lw = landWorkers[i];
        if (!lw.isActive) continue; // Only show active workers

        // Try to restore saved position, otherwise fall back to default spread
        final String posKey = 'worker_pos_${landId}_${lw.workerId}';
        final String? savedPos = prefs.getString(posKey);

        double startX;
        double startY;
        if (savedPos != null) {
          final parts = savedPos.split(',');
          startX = double.tryParse(parts[0]) ?? (1.0 + (i % 4));
          startY = double.tryParse(parts[1]) ?? (1.0 + (i ~/ 4));
        } else {
          // Default: spread workers in a horizontal line starting from (1, 1)
          startX = 1.0 + (i % 4).toDouble();
          startY = 1.0 + (i ~/ 4).toDouble();
        }

        final snappedStart = _findNearestPlayableCell(
          startX,
          startY,
          gridWidth,
          gridHeight,
        );
        if (snappedStart == null) {
          // Invalid or fully blocked masks should not place workers off-land.
          continue;
        }
        startX = snappedStart.$1;
        startY = snappedStart.$2;

        final workerState = WorkerState(
          workerId: lw.workerId,
          workerName: lw.workerName ?? 'Worker',
          workerPicture: lw.workerProfilePicture,
          availability: lw.workerAvailability ?? 'available',
          x: startX.clamp(0, gridWidth - 1.0),
          y: startY.clamp(0, gridHeight - 1.0),
        );

        _workers.add(workerState);
      }
    } catch (e) {
      debugPrint('Error loading workers: $e');
    } finally {
      _workersLoading = false;
      notifyListeners();
    }
  }

  /// Move the closest worker to the given isometric tile coordinates.
  /// onlyAvailable: if true (default for double-click), ignores busy workers.
  void moveClosestWorkerTo(
    double tx,
    double ty, {
    int? gridWidth,
    int? gridHeight,
    String? landId,
    bool onlyAvailable = false,
  }) {
    if (_workers.isEmpty) return;
    final effectiveLandId = landId ?? currentLandId;

    // Clamp target to grid bounds
    double clampedX = tx;
    double clampedY = ty;
    if (gridWidth != null) clampedX = clampedX.clamp(0.0, gridWidth - 0.1);
    if (gridHeight != null) clampedY = clampedY.clamp(0.0, gridHeight - 0.1);

    final int effectiveGridWidth =
        gridWidth ??
        (_playableMask?.isNotEmpty == true ? _playableMask!.first.length : 0);
    final int effectiveGridHeight =
        gridHeight ??
        (_playableMask?.isNotEmpty == true ? _playableMask!.length : 0);
    final snappedTarget = _findNearestPlayableCell(
      clampedX,
      clampedY,
      effectiveGridWidth,
      effectiveGridHeight,
    );
    if (snappedTarget == null) {
      return;
    }
    clampedX = snappedTarget.$1;
    clampedY = snappedTarget.$2;

    // Filter by availability if requested (double-click should not move busy workers)
    final eligibleWorkers = onlyAvailable
        ? _workers.where((w) => w.availability == 'available').toList()
        : _workers;
    if (eligibleWorkers.isEmpty) return;

    // Find closest eligible worker by Manhattan distance
    WorkerState closest = eligibleWorkers.first;
    double minDist = double.infinity;
    for (var w in eligibleWorkers) {
      double dist = (w.x - clampedX).abs() + (w.y - clampedY).abs();
      if (dist < minDist) {
        minDist = dist;
        closest = w;
      }
    }

    closest.moveTo(clampedX, clampedY, notifyListeners, () {
      // Save position to SharedPreferences when worker stops moving
      _saveWorkerPosition(
        effectiveLandId,
        closest.workerId,
        closest.x,
        closest.y,
      );
      notifyListeners();
    });
  }

  /// Moves a specific worker by ID to the given target coordinates.
  /// Used after task assignment so exactly the assigned worker walks to the task.
  void moveWorkerById(
    String workerId,
    double tx,
    double ty, {
    int? gridWidth,
    int? gridHeight,
  }) {
    final worker = _workers.where((w) => w.workerId == workerId).firstOrNull;
    if (worker == null) return;

    double clampedX = tx;
    double clampedY = ty;
    if (gridWidth != null) clampedX = clampedX.clamp(0.0, gridWidth - 0.1);
    if (gridHeight != null) clampedY = clampedY.clamp(0.0, gridHeight - 0.1);

    final int effectiveGridWidth =
        gridWidth ??
        (_playableMask?.isNotEmpty == true ? _playableMask!.first.length : 0);
    final int effectiveGridHeight =
        gridHeight ??
        (_playableMask?.isNotEmpty == true ? _playableMask!.length : 0);
    final snappedTarget = _findNearestPlayableCell(
      clampedX,
      clampedY,
      effectiveGridWidth,
      effectiveGridHeight,
    );
    if (snappedTarget == null) {
      return;
    }
    clampedX = snappedTarget.$1;
    clampedY = snappedTarget.$2;

    worker.moveTo(clampedX, clampedY, notifyListeners, () {
      _saveWorkerPosition(currentLandId, worker.workerId, worker.x, worker.y);
      notifyListeners();
    });
  }

  /// Enters manual joystick-control mode for the given worker. Any in-flight
  /// auto-move tween is cancelled so the user takes over cleanly. Busy
  /// workers are rejected — tasks must not be interrupted mid-animation.
  void startManualControl(String workerId) {
    final worker = _workers.where((w) => w.workerId == workerId).firstOrNull;
    if (worker == null) return;
    if (worker.availability == 'busy') return;
    worker.stop();
    _manualControlWorkerId = workerId;
    notifyListeners();
  }

  /// Exits manual-control mode. Persists the final cell so a reload doesn't
  /// lose the player's positioning. Safe to call if no worker is active.
  void stopManualControl() {
    final worker = manualControlWorker;
    _manualControlWorkerId = null;
    if (worker != null) {
      worker.status = 'idle';
      worker.action = 'idle';
      _saveWorkerPosition(currentLandId, worker.workerId, worker.x, worker.y);
    }
    notifyListeners();
  }

  /// Applies one frame of joystick input to the manually-controlled worker.
  ///
  /// [sx], [sy] are the stick deflection in screen space, each in [-1, 1]
  /// (right / down positive). [dt] is the elapsed seconds since the previous
  /// call — passing actual frame delta keeps movement frame-rate independent.
  ///
  /// Zero vector ⇒ worker eases back to `idle` while preserving its last
  /// facing direction, so the sprite doesn't snap to a default pose.
  void applyJoystickInput(double sx, double sy, double dt) {
    final worker = manualControlWorker;
    if (worker == null || dt <= 0) return;

    final double intensity = math.sqrt(sx * sx + sy * sy).clamp(0.0, 1.0);
    if (intensity < 0.08) {
      // Dead-zone: release the "walk" pose but keep direction as the last
      // facing so the idle sprite picks up the correct slug.
      bool changed = false;
      if (worker.action != 'idle') {
        worker.action = 'idle';
        changed = true;
      }
      if (worker.status != 'idle') {
        worker.status = 'idle';
        changed = true;
      }
      if (changed) notifyListeners();
      return;
    }

    // Screen→grid basis inversion for the iso projection
    //   isoX = (x - y) * tw/2, isoY = (x + y) * th/2
    // Solved for (x, y) given (isoX, isoY):
    //   x =  isoX/tw + isoY/th
    //   y = -isoX/tw + isoY/th
    // With tw = 2*th the vertical stick weighs twice the horizontal in grid
    // units, which matches the taller iso "depth" axis.
    final double gdx = sx + 2 * sy;
    final double gdy = -sx + 2 * sy;
    final double gnorm = math.sqrt(gdx * gdx + gdy * gdy);
    if (gnorm < 1e-4) return;
    final double ugx = gdx / gnorm;
    final double ugy = gdy / gnorm;

    const double kMaxCellsPerSecond = 3.5;
    final double stepX = ugx * intensity * kMaxCellsPerSecond * dt;
    final double stepY = ugy * intensity * kMaxCellsPerSecond * dt;

    final int gridW = _playableMask?.isNotEmpty == true
        ? _playableMask!.first.length
        : 0;
    final int gridH = _playableMask?.length ?? 0;
    if (gridW == 0 || gridH == 0) return;

    // Axis-separated collision: try full step, then X-only, then Y-only. This
    // allows sliding along a wall of non-playable cells instead of locking up
    // when the desired vector points into it diagonally.
    double nextX = worker.x + stepX;
    double nextY = worker.y + stepY;
    bool ok = _acceptManualTarget(nextX, nextY, gridW, gridH);
    if (!ok) {
      nextX = worker.x + stepX;
      nextY = worker.y;
      ok = _acceptManualTarget(nextX, nextY, gridW, gridH);
    }
    if (!ok) {
      nextX = worker.x;
      nextY = worker.y + stepY;
      ok = _acceptManualTarget(nextX, nextY, gridW, gridH);
    }
    if (!ok) {
      // Fully blocked this frame — still flip to walk pose so the sprite
      // animates in place rather than looking frozen.
      worker.direction = classifyDirection8(gdx, gdy);
      worker.action = 'walk';
      worker.status = 'walking';
      notifyListeners();
      return;
    }

    worker.x = nextX;
    worker.y = nextY;
    worker.direction = classifyDirection8(gdx, gdy);
    worker.action = 'walk';
    worker.status = 'walking';
    notifyListeners();
  }

  /// Returns true iff (x, y) is inside the grid *and* the cell containing it
  /// is playable. Used by [applyJoystickInput] for per-axis slide collision.
  bool _acceptManualTarget(double x, double y, int gridW, int gridH) {
    if (x < 0 || y < 0) return false;
    if (x >= gridW - 0.01 || y >= gridH - 0.01) return false;
    return _isPlayableCell(x.floor(), y.floor(), gridW, gridH);
  }

  String currentLandId = '';

  /// Saves a worker's position to SharedPreferences.
  Future<void> _saveWorkerPosition(
    String landId,
    String workerId,
    double x,
    double y,
  ) async {
    if (landId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('worker_pos_${landId}_$workerId', '$x,$y');
    } catch (e) {
      debugPrint('Failed to save worker position: $e');
    }
  }

  /// Finds and returns the ID of the closest available worker to a given point.
  String? getClosestAvailableWorkerId(double tx, double ty) {
    final availableWorkers = _workers
        .where((w) => w.availability == 'available')
        .toList();
    if (availableWorkers.isEmpty) return null;

    WorkerState closest = availableWorkers.first;
    double minDist = double.infinity;

    for (var w in availableWorkers) {
      double dist = (w.x - tx).abs() + (w.y - ty).abs(); // Manhattan distance
      if (dist < minDist) {
        minDist = dist;
        closest = w;
      }
    }

    return closest.workerId;
  }

  List<List<bool>>? _normalizePlayableMask(
    List<dynamic>? rawMask,
    int gridWidth,
    int gridHeight,
  ) {
    if (rawMask == null || rawMask.isEmpty) return null;

    final normalized = <List<bool>>[];
    for (final row in rawMask) {
      if (row is! List) return null;
      normalized.add(row.map((cell) => cell == true).toList());
    }

    final hasExpectedShape =
        normalized.length == gridHeight &&
        normalized.every((row) => row.length == gridWidth);
    if (!hasExpectedShape) return null;

    return normalized;
  }

  bool _isPlayableCell(int x, int y, int gridWidth, int gridHeight) {
    if (x < 0 || x >= gridWidth || y < 0 || y >= gridHeight) return false;
    if (_playableMask == null) return true;
    if (y >= _playableMask!.length) return false;
    final row = _playableMask![y];
    if (x >= row.length) return false;
    return row[x];
  }

  (double, double)? _findNearestPlayableCell(
    double x,
    double y,
    int gridWidth,
    int gridHeight,
  ) {
    if (gridWidth <= 0 || gridHeight <= 0) return null;
    if (_playableMask == null) {
      return (x.clamp(0.0, gridWidth - 0.1), y.clamp(0.0, gridHeight - 0.1));
    }

    final int targetX = x.floor().clamp(0, gridWidth - 1);
    final int targetY = y.floor().clamp(0, gridHeight - 1);
    if (_isPlayableCell(targetX, targetY, gridWidth, gridHeight)) {
      return (x.clamp(0.0, gridWidth - 0.1), y.clamp(0.0, gridHeight - 0.1));
    }

    final int maxRadius = math.max(gridWidth, gridHeight);
    int? bestX;
    int? bestY;
    double bestDistance = double.infinity;

    for (int radius = 1; radius <= maxRadius; radius++) {
      final int minY = math.max(0, targetY - radius);
      final int maxY = math.min(gridHeight - 1, targetY + radius);
      final int minX = math.max(0, targetX - radius);
      final int maxX = math.min(gridWidth - 1, targetX + radius);

      for (int yy = minY; yy <= maxY; yy++) {
        for (int xx = minX; xx <= maxX; xx++) {
          final bool onRing =
              xx == minX || xx == maxX || yy == minY || yy == maxY;
          if (!onRing) continue;
          if (!_isPlayableCell(xx, yy, gridWidth, gridHeight)) continue;

          final distance =
              (xx - targetX).abs().toDouble() + (yy - targetY).abs().toDouble();
          if (distance < bestDistance) {
            bestDistance = distance;
            bestX = xx;
            bestY = yy;
          }
        }
      }

      if (bestX != null && bestY != null) {
        return (bestX + 0.5, bestY + 0.5);
      }
    }

    return null;
  }

  /// Marks a worker as busy locally (after task assignment) so the UI updates immediately.
  void setWorkerBusy(String workerId) {
    final worker = _workers.where((w) => w.workerId == workerId).firstOrNull;
    if (worker != null) {
      worker.availability = 'busy';
      notifyListeners();
    }
  }

  /// Marks a worker as available locally (after task completion).
  void setWorkerAvailable(String workerId) {
    final worker = _workers.where((w) => w.workerId == workerId).firstOrNull;
    if (worker != null) {
      worker.availability = 'available';
      notifyListeners();
    }
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _showEdgePanel = prefs.getBool('enable_edge_panel') ?? true;
    } catch (e) {
      debugPrint('Error loading game settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setEdgePanelVisibility(bool visible) async {
    _showEdgePanel = visible;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enable_edge_panel', visible);
    } catch (e) {
      debugPrint('Error saving game settings: $e');
    }
  }

  @override
  void dispose() {
    for (var w in _workers) {
      w.stop();
    }
    super.dispose();
  }
}
