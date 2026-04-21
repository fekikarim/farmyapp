import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/land_worker_model.dart';
import '../services/worker_service.dart';
import '../services/socket_service.dart';

/// Quantises a **screen-space** direction vector into one of eight isometric
/// direction slugs that map 1:1 to the folders under
/// `assets/game_images/sprites/worker`.
///
/// [sx] is right-positive, [sy] is down-positive (standard screen coords).
/// Uses `atan2`-based 8-sector classification with 45° sectors centered on
/// each cardinal/diagonal direction.
String classifyDirection8(double sx, double sy) {
  if (sx == 0 && sy == 0) return 'bottom-side';
  double angle = math.atan2(sy, sx); // [-π, π], 0 = right, π/2 = down
  if (angle < 0) angle += 2 * math.pi; // [0, 2π)
  // 8 sectors of 45° each. Adding π/8 (22.5°) shifts the sector boundaries
  // so that e.g. the 'right-side' sector spans from −22.5° to +22.5°.
  const List<String> sectors = <String>[
    'right-side', // sector 0: centred at 0° (screen right)
    'right-bottom-side', // sector 1: centred at 45°
    'bottom-side', // sector 2: centred at 90° (screen down)
    'left-bottom-side', // sector 3: centred at 135°
    'left-side', // sector 4: centred at 180° (screen left)
    'left-forward-side', // sector 5: centred at 225°
    'forward-side', // sector 6: centred at 270° (screen up)
    'right-forward-side', // sector 7: centred at 315°
  ];
  final int idx = ((angle + math.pi / 8) / (math.pi / 4)).floor() % 8;
  return sectors[idx];
}

/// Converts a **grid-space** delta to a screen-space direction and classifies
/// it. Used by auto-move ([WorkerState.moveTo]) where the movement delta is
/// naturally in grid coordinates.
String classifyDirection8FromGrid(double gdx, double gdy) {
  // Isometric projection: screenX ∝ (gridX − gridY), screenY ∝ (gridX + gridY)
  // The 0.5 factor on Y compensates for the 2:1 tile aspect ratio so the
  // angle sectors align with visual screen directions.
  final double sx = gdx - gdy;
  final double sy = (gdx + gdy) * 0.5;
  return classifyDirection8(sx, sy);
}

/// How many grid cells a worker travels per full walk-cycle loop.
/// At 0.8 cells/stride, a worker moving 3.5 cells/sec (manual-control cap)
/// cycles its sprite sheet ≈ 4.4 times/sec — brisk but natural. A worker on
/// an auto-move tween (1.67 cells/sec) cycles ≈ 2.1 times/sec.
const double _kCellsPerStride = 0.8;
const double _kManualDeadZone = 0.08;
const double _kManualMaxCellsPerSecond = 3.5;
const double _kManualAcceleration = 18.0;
const double _kManualDeceleration = 24.0;
const double _kManualStopEpsilon = 0.02;

class _ResolvedJoystickVector {
  final double intensity;
  final double gridX;
  final double gridY;

  const _ResolvedJoystickVector({
    required this.intensity,
    required this.gridX,
    required this.gridY,
  });

  bool get hasDirection => gridX != 0 || gridY != 0;
}

_ResolvedJoystickVector _resolveJoystickToIsometric(double sx, double sy) {
  final double intensity = math.sqrt(sx * sx + sy * sy).clamp(0.0, 1.0);
  if (intensity <= 0) {
    return const _ResolvedJoystickVector(intensity: 0, gridX: 0, gridY: 0);
  }

  // Screen→grid basis inversion for the iso projection.
  final double gdx = sx + 2 * sy;
  final double gdy = -sx + 2 * sy;
  final double gnorm = math.sqrt(gdx * gdx + gdy * gdy);
  if (gnorm < 1e-6) {
    return _ResolvedJoystickVector(intensity: intensity, gridX: 0, gridY: 0);
  }

  // Unit vector in grid-space guarantees no diagonal speed boost.
  return _ResolvedJoystickVector(
    intensity: intensity,
    gridX: gdx / gnorm,
    gridY: gdy / gnorm,
  );
}

double _approachDouble(double current, double target, double maxDelta) {
  if ((target - current).abs() <= maxDelta) return target;
  return current + (target > current ? maxDelta : -maxDelta);
}

double _stepVelocityAxis(double current, double target, double dt) {
  final bool sameDirection =
      current == 0 || target == 0 || current.sign == target.sign;
  final bool accelerating = target.abs() > current.abs() && sameDirection;
  final double rate = accelerating
      ? _kManualAcceleration
      : _kManualDeceleration;
  return _approachDouble(current, target, rate * dt);
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

  /// Walk-cycle phase in [0, 1). Advances proportionally to actual distance
  /// travelled (both auto-moves and manual-control steps) so the painter can
  /// pick a frame that matches the worker's real velocity rather than a
  /// fixed wall-clock cadence. Preserved across stop/start so the sprite
  /// doesn't snap back to frame 0 on brief pauses.
  double animPhase = 0.0;

  // Continuous analog movement velocity in grid cells/second.
  double manualVelocityX = 0.0;
  double manualVelocityY = 0.0;

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

  /// Advances [animPhase] by the Euclidean distance of a single movement
  /// step, normalised by the stride length. Callers should pass the *actual*
  /// delta applied this tick — not the intended step — so collision slides
  /// produce correspondingly-slower animation.
  void advanceAnimPhase(double stepCells) {
    if (stepCells <= 0) return;
    animPhase = (animPhase + stepCells / _kCellsPerStride) % 1.0;
  }

  double get manualSpeed {
    return math.sqrt(
      manualVelocityX * manualVelocityX + manualVelocityY * manualVelocityY,
    );
  }

  void resetManualVelocity() {
    manualVelocityX = 0.0;
    manualVelocityY = 0.0;
  }

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
    resetManualVelocity();
    movementTimer?.cancel();

    const double speed = 0.05;

    movementTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      double dx = targetX! - x;
      double dy = targetY! - y;
      double distance = dx.abs() + dy.abs();

      if (distance < speed) {
        final double finalStep = math.sqrt(dx * dx + dy * dy);
        x = targetX!;
        y = targetY!;
        advanceAnimPhase(finalStep);
        targetX = null;
        targetY = null;
        status = 'idle';
        action = 'idle';
        resetManualVelocity();
        movementTimer?.cancel();
        onStop();
      } else {
        direction = classifyDirection8FromGrid(dx, dy);
        double ratio = speed / distance;
        final double sx = dx * ratio;
        final double sy = dy * ratio;
        x += sx;
        y += sy;
        advanceAnimPhase(math.sqrt(sx * sx + sy * sy));
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
    resetManualVelocity();
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
    worker.resetManualVelocity();
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
      worker.resetManualVelocity();
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

    final double oldX = worker.x;
    final double oldY = worker.y;
    final String oldDirection = worker.direction;
    final String oldStatus = worker.status;
    final String oldAction = worker.action;
    final double oldAnimPhase = worker.animPhase;
    final double oldVelX = worker.manualVelocityX;
    final double oldVelY = worker.manualVelocityY;

    final _ResolvedJoystickVector input = _resolveJoystickToIsometric(sx, sy);
    final bool hasIntent =
        input.intensity >= _kManualDeadZone && input.hasDirection;

    final double targetSpeed = hasIntent
        ? input.intensity * _kManualMaxCellsPerSecond
        : 0.0;
    final double targetVelX = hasIntent ? input.gridX * targetSpeed : 0.0;
    final double targetVelY = hasIntent ? input.gridY * targetSpeed : 0.0;

    worker.manualVelocityX = _stepVelocityAxis(
      worker.manualVelocityX,
      targetVelX,
      dt,
    );
    worker.manualVelocityY = _stepVelocityAxis(
      worker.manualVelocityY,
      targetVelY,
      dt,
    );

    // Stabilize tiny tails so idle transition is deterministic.
    if (worker.manualVelocityX.abs() < _kManualStopEpsilon) {
      worker.manualVelocityX = 0.0;
    }
    if (worker.manualVelocityY.abs() < _kManualStopEpsilon) {
      worker.manualVelocityY = 0.0;
    }

    // Direction classification uses SCREEN-space vectors so sprite folder
    // names (which correspond to visual screen directions) are selected
    // correctly. Movement physics still use grid-space velocity.
    double headingX = 0.0;
    double headingY = 0.0;
    if (hasIntent) {
      // Raw joystick deflection IS screen-space.
      headingX = sx;
      headingY = sy;
    } else if (worker.manualSpeed > _kManualStopEpsilon) {
      // Grid velocity → screen-space for direction while coasting.
      headingX = worker.manualVelocityX - worker.manualVelocityY;
      headingY = (worker.manualVelocityX + worker.manualVelocityY) * 0.5;
    }

    final bool hasHeading = headingX.abs() > 1e-6 || headingY.abs() > 1e-6;
    final String nextDir = hasHeading
        ? _stableClassifyDirection(worker.direction, headingX, headingY)
        : worker.direction;

    final int gridW = _playableMask?.isNotEmpty == true
        ? _playableMask!.first.length
        : 0;
    final int gridH = _playableMask?.length ?? 0;
    if (gridW == 0 || gridH == 0) {
      if (worker.manualSpeed <= _kManualStopEpsilon) {
        worker.status = 'idle';
        worker.action = 'idle';
      }
      if (_workerChanged(
        worker,
        oldX,
        oldY,
        oldDirection,
        oldStatus,
        oldAction,
        oldAnimPhase,
        oldVelX,
        oldVelY,
      )) {
        notifyListeners();
      }
      return;
    }

    final double stepX = worker.manualVelocityX * dt;
    final double stepY = worker.manualVelocityY * dt;

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

    final double actualStep = ok
        ? math.sqrt(
            (nextX - worker.x) * (nextX - worker.x) +
                (nextY - worker.y) * (nextY - worker.y),
          )
        : 0.0;

    if (actualStep > 1e-6) {
      worker.x = nextX;
      worker.y = nextY;
      worker.direction = nextDir;
      worker.status = 'walking';
      worker.action = 'walk';
      worker.advanceAnimPhase(actualStep);
    } else {
      worker.direction = nextDir;
      worker.status = 'idle';
      worker.action = 'idle';
      if (hasIntent) {
        // Prevent in-place jitter against hard boundaries.
        worker.resetManualVelocity();
      }
    }

    if (_workerChanged(
      worker,
      oldX,
      oldY,
      oldDirection,
      oldStatus,
      oldAction,
      oldAnimPhase,
      oldVelX,
      oldVelY,
    )) {
      notifyListeners();
    }
  }

  bool _workerChanged(
    WorkerState worker,
    double oldX,
    double oldY,
    String oldDirection,
    String oldStatus,
    String oldAction,
    double oldAnimPhase,
    double oldVelX,
    double oldVelY,
  ) {
    return (worker.x - oldX).abs() > 1e-6 ||
        (worker.y - oldY).abs() > 1e-6 ||
        worker.direction != oldDirection ||
        worker.status != oldStatus ||
        worker.action != oldAction ||
        (worker.animPhase - oldAnimPhase).abs() > 1e-6 ||
        (worker.manualVelocityX - oldVelX).abs() > 1e-6 ||
        (worker.manualVelocityY - oldVelY).abs() > 1e-6;
  }

  /// Returns true iff (x, y) is inside the grid *and* the cell containing it
  /// is playable. Used by [applyJoystickInput] for per-axis slide collision.
  bool _acceptManualTarget(double x, double y, int gridW, int gridH) {
    if (x < 0 || y < 0) return false;
    if (x >= gridW - 0.01 || y >= gridH - 0.01) return false;
    return _isPlayableCell(x.floor(), y.floor(), gridW, gridH);
  }

  /// Hysteresis wrapper around [classifyDirection8]. Widens the angular band
  /// around the currently-faced direction so small stick wobbles near a
  /// sector boundary don't cause single-frame slug flips (which would make
  /// the walk sprite visibly stutter).
  ///
  /// Input is **screen-space** (sx right+, sy down+) — matching the new
  /// screen-space convention of [classifyDirection8].
  ///
  /// Rules (ax, ay = |sx|, |sy|):
  ///   - If previous was horizontal (right/left-side), stay horizontal until
  ///     ax/ay drops below 1.4 (vs the raw ~1.73 sector boundary).
  ///   - If previous was vertical (forward/bottom-side), stay vertical until
  ///     ay/ax drops below 1.4.
  ///   - If previous was diagonal, require ax/ay (or ay/ax) to clearly exceed
  ///     2.2 before committing to a cardinal slug.
  /// When the candidate slug matches the previous one, returns immediately —
  /// no work done on the hot path.
  String _stableClassifyDirection(String previous, double sx, double sy) {
    final String candidate = classifyDirection8(sx, sy);
    if (candidate == previous) return candidate;
    final double ax = sx.abs();
    final double ay = sy.abs();
    if (ax < 1e-6 && ay < 1e-6) return previous;

    final bool prevHorizontal =
        previous == 'right-side' || previous == 'left-side';
    final bool prevVertical =
        previous == 'forward-side' || previous == 'bottom-side';
    final bool prevDiagonal = !prevHorizontal && !prevVertical;

    // Ratio of dominant to subordinate axis, with divide-by-zero guard.
    final double hRatio = ay == 0 ? double.infinity : ax / ay;
    final double vRatio = ax == 0 ? double.infinity : ay / ax;

    if (prevHorizontal) {
      // Hold the horizontal slug until the stick clearly tilts diagonal.
      if (hRatio > 1.4) {
        return sx > 0 ? 'right-side' : 'left-side';
      }
    } else if (prevVertical) {
      if (vRatio > 1.4) {
        // Screen-space: sy > 0 = down = bottom-side, sy < 0 = up = forward-side
        return sy > 0 ? 'bottom-side' : 'forward-side';
      }
    } else if (prevDiagonal) {
      // From a diagonal, require a strong cardinal dominance to leave.
      if (hRatio > 2.2 || vRatio > 2.2) return candidate;
      // Otherwise keep the diagonal family: only commit if the candidate is
      // also diagonal AND crosses a quadrant (sign flip).
      final bool candidateDiagonal =
          candidate.contains('-bottom-') || candidate.contains('-forward-');
      if (!candidateDiagonal) return previous;
    }
    return candidate;
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
