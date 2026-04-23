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
const double _kWorkerCollisionRadius = 0.35;
// Extra keep-out distance for non-playable cells (fence boundary).
// Stronger buffer (0.60) ensures worker stays well away from fence visually.
const double _kOffLandCollisionPadding = 0.60;
const double _kCollisionSweepStep = 0.12;
// Combined offset for hard boundary clamping (radius + padding).
const double _kBoundaryMinOffset = _kWorkerCollisionRadius + _kOffLandCollisionPadding;
const double _kCollisionEpsilon = 1e-6;
const double _kCollisionSettleEpsilon = 1e-4;

class _CollisionMoveResult {
  final double nextX;
  final double nextY;
  final double movedDistance;
  final bool blockedX;
  final bool blockedY;

  const _CollisionMoveResult({
    required this.nextX,
    required this.nextY,
    required this.movedDistance,
    this.blockedX = false,
    this.blockedY = false,
  });
}

typedef WorkerCollisionResolver =
    _CollisionMoveResult Function(
      WorkerState worker,
      double desiredDx,
      double desiredDy,
    );

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
    VoidCallback onStop, {
    WorkerCollisionResolver? collisionResolver,
  }) {
    targetX = tx;
    targetY = ty;
    status = 'walking';
    action = 'walk';
    resetManualVelocity();
    movementTimer?.cancel();

    const double speed = 0.05;

    movementTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (targetX == null || targetY == null) {
        movementTimer?.cancel();
        status = 'idle';
        action = 'idle';
        resetManualVelocity();
        onStop();
        return;
      }
      final double goalX = targetX ?? x;
      final double goalY = targetY ?? y;
      double dx = targetX! - x;
      double dy = targetY! - y;
      double distance = dx.abs() + dy.abs();

      _CollisionMoveResult resolve(double desiredDx, double desiredDy) {
        if (collisionResolver != null) {
          return collisionResolver(this, desiredDx, desiredDy);
        }
        final double nextX = x + desiredDx;
        final double nextY = y + desiredDy;
        final double step = math.sqrt(
          desiredDx * desiredDx + desiredDy * desiredDy,
        );
        return _CollisionMoveResult(
          nextX: nextX,
          nextY: nextY,
          movedDistance: step,
        );
      }

      if (distance < speed) {
        final _CollisionMoveResult resolved = resolve(dx, dy);
        final double appliedDx = resolved.nextX - x;
        final double appliedDy = resolved.nextY - y;
        final double finalStep = math.sqrt(
          appliedDx * appliedDx + appliedDy * appliedDy,
        );
        if (finalStep > _kCollisionEpsilon) {
          direction = classifyDirection8FromGrid(appliedDx, appliedDy);
          x = resolved.nextX;
          y = resolved.nextY;
          advanceAnimPhase(finalStep);
          onUpdate();
        }
        targetX = null;
        targetY = null;
        status = 'idle';
        action = 'idle';
        resetManualVelocity();
        movementTimer?.cancel();
        onStop();
      } else {
        double ratio = speed / distance;
        final _CollisionMoveResult resolved = resolve(dx * ratio, dy * ratio);
        final double appliedDx = resolved.nextX - x;
        final double appliedDy = resolved.nextY - y;
        final double appliedStep = math.sqrt(
          appliedDx * appliedDx + appliedDy * appliedDy,
        );
        if (appliedStep <= _kCollisionSettleEpsilon) {
          targetX = null;
          targetY = null;
          status = 'idle';
          action = 'idle';
          resetManualVelocity();
          movementTimer?.cancel();
          onStop();
          return;
        }
        direction = classifyDirection8FromGrid(appliedDx, appliedDy);
        x = resolved.nextX;
        y = resolved.nextY;
        advanceAnimPhase(appliedStep);

        final bool reachedGoal =
            (goalX - x).abs() + (goalY - y).abs() <= _kCollisionSettleEpsilon;
        if (reachedGoal) {
          targetX = null;
          targetY = null;
          status = 'idle';
          action = 'idle';
          resetManualVelocity();
          movementTimer?.cancel();
          onStop();
          return;
        }
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
  List<List<bool>>? _obstacleMask;
  int _gridWidth = 0;
  int _gridHeight = 0;
  bool _collisionDebugEnabled = false;

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
  bool get collisionDebugEnabled => _collisionDebugEnabled;

  // Camera follow state
  bool _isCameraFollowing = false;
  bool get isCameraFollowing => _isCameraFollowing;

  void setCollisionDebugEnabled(bool enabled) {
    if (_collisionDebugEnabled == enabled) return;
    _collisionDebugEnabled = enabled;
    notifyListeners();
  }

  /// Toggle camera follow mode. Called by UI button.
  void toggleCameraFollow() {
    _isCameraFollowing = !_isCameraFollowing;
    debugPrint('Camera follow: $_isCameraFollowing');
    notifyListeners();
  }

  /// Disable camera follow when user manually interacts with camera.
  void disableCameraFollow() {
    if (_isCameraFollowing) {
      _isCameraFollowing = false;
      debugPrint('Camera follow disabled (user interaction)');
      notifyListeners();
    }
  }

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
    List<dynamic>? matrix,
  }) async {
    _workersLoading = true;
    notifyListeners();

    currentLandId = landId; // Remember which land workers are on
    _gridWidth = gridWidth;
    _gridHeight = gridHeight;
    _playableMask = _normalizePlayableMask(playableMask, gridWidth, gridHeight);
    _obstacleMask = _normalizeObstacleMask(matrix, gridWidth, gridHeight);

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

        // Find valid spawn position with fallback chain
        (double, double)? finalPos = _findValidWorkerSpawnPosition(
          startX,
          startY,
          gridWidth,
          gridHeight,
          workerId: lw.workerId,
        );

        if (finalPos == null) {
          debugPrint(
            'Failed to find valid spawn for worker ${lw.workerId} on land $landId. '
            'Grid: ${gridWidth}x$gridHeight, Mask: ${_playableMask != null ? "custom" : "null"}',
          );
          // Fallback: place at center of land with minimum safe offset
          finalPos = _calculateEmergencySpawnPosition(gridWidth, gridHeight);
          if (finalPos == null) {
            debugPrint('Emergency spawn also failed for worker ${lw.workerId}. Skipping.');
            continue;
          }
        }

        final workerState = WorkerState(
          workerId: lw.workerId,
          workerName: lw.workerName ?? 'Worker',
          workerPicture: lw.workerProfilePicture,
          availability: lw.workerAvailability ?? 'available',
          x: finalPos.$1,
          y: finalPos.$2,
        );

        _workers.add(workerState);
        debugPrint(
          'Worker ${lw.workerId} loaded at (${workerState.x.toStringAsFixed(2)}, ${workerState.y.toStringAsFixed(2)})'
        );
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

    final int effectiveGridWidth = gridWidth ?? _gridWidth;
    final int effectiveGridHeight = gridHeight ?? _gridHeight;
    if (effectiveGridWidth <= 0 || effectiveGridHeight <= 0) return;
    final snappedTarget = _findNearestNavigableCell(
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

    final WorkerCollisionResolver resolver = _buildWorkerCollisionResolver(
      effectiveGridWidth,
      effectiveGridHeight,
    );
    closest.moveTo(clampedX, clampedY, notifyListeners, () {
      // Save position to SharedPreferences when worker stops moving
      _saveWorkerPosition(
        effectiveLandId,
        closest.workerId,
        closest.x,
        closest.y,
      );
      notifyListeners();
    }, collisionResolver: resolver);
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

    final int effectiveGridWidth = gridWidth ?? _gridWidth;
    final int effectiveGridHeight = gridHeight ?? _gridHeight;
    if (effectiveGridWidth <= 0 || effectiveGridHeight <= 0) return;
    final snappedTarget = _findNearestNavigableCell(
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

    final WorkerCollisionResolver resolver = _buildWorkerCollisionResolver(
      effectiveGridWidth,
      effectiveGridHeight,
    );
    worker.moveTo(clampedX, clampedY, notifyListeners, () {
      _saveWorkerPosition(currentLandId, worker.workerId, worker.x, worker.y);
      notifyListeners();
    }, collisionResolver: resolver);
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

    final int gridW = _gridWidth;
    final int gridH = _gridHeight;
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

    final _CollisionMoveResult resolved = _resolveCollisionSweep(
      fromX: worker.x,
      fromY: worker.y,
      desiredDx: stepX,
      desiredDy: stepY,
      movingWorkerId: worker.workerId,
      gridW: gridW,
      gridH: gridH,
    );
    final double actualStep = resolved.movedDistance;

    if (resolved.blockedX) {
      worker.manualVelocityX = 0.0;
    }
    if (resolved.blockedY) {
      worker.manualVelocityY = 0.0;
    }

    if (actualStep > _kCollisionEpsilon) {
      worker.x = resolved.nextX;
      worker.y = resolved.nextY;
      worker.direction = nextDir;
      worker.status = 'walking';
      worker.action = 'walk';
      worker.advanceAnimPhase(actualStep);
    } else {
      worker.direction = nextDir;
      worker.status = 'idle';
      worker.action = 'idle';
      if (hasIntent) {
        _logCollisionDebug(
          'Blocked worker ${worker.workerId} at (${worker.x.toStringAsFixed(2)}, ${worker.y.toStringAsFixed(2)}).',
        );
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

  WorkerCollisionResolver _buildWorkerCollisionResolver(int gridW, int gridH) {
    return (worker, desiredDx, desiredDy) {
      return _resolveCollisionSweep(
        fromX: worker.x,
        fromY: worker.y,
        desiredDx: desiredDx,
        desiredDy: desiredDy,
        movingWorkerId: worker.workerId,
        gridW: gridW,
        gridH: gridH,
      );
    };
  }

  _CollisionMoveResult _resolveCollisionSweep({
    required double fromX,
    required double fromY,
    required double desiredDx,
    required double desiredDy,
    required String movingWorkerId,
    required int gridW,
    required int gridH,
  }) {
    if (gridW <= 0 || gridH <= 0) {
      return _CollisionMoveResult(
        nextX: fromX,
        nextY: fromY,
        movedDistance: 0.0,
        blockedX: desiredDx.abs() > _kCollisionEpsilon,
        blockedY: desiredDy.abs() > _kCollisionEpsilon,
      );
    }

    final double totalDistance = math.sqrt(
      desiredDx * desiredDx + desiredDy * desiredDy,
    );
    if (totalDistance <= _kCollisionEpsilon) {
      return _CollisionMoveResult(
        nextX: fromX,
        nextY: fromY,
        movedDistance: 0.0,
      );
    }

    final int sweepSteps = math.max(
      1,
      (totalDistance / _kCollisionSweepStep).ceil(),
    );
    final double stepDx = desiredDx / sweepSteps;
    final double stepDy = desiredDy / sweepSteps;

    double x = fromX;
    double y = fromY;
    bool blockedX = false;
    bool blockedY = false;

    for (int i = 0; i < sweepSteps; i++) {
      final _CollisionMoveResult step = _resolveSingleCollisionStep(
        fromX: x,
        fromY: y,
        stepDx: stepDx,
        stepDy: stepDy,
        movingWorkerId: movingWorkerId,
        gridW: gridW,
        gridH: gridH,
      );
      x = step.nextX;
      y = step.nextY;
      blockedX = blockedX || step.blockedX;
      blockedY = blockedY || step.blockedY;
    }

    final double movedDistance = math.sqrt(
      (x - fromX) * (x - fromX) + (y - fromY) * (y - fromY),
    );
    return _CollisionMoveResult(
      nextX: x,
      nextY: y,
      movedDistance: movedDistance,
      blockedX: blockedX,
      blockedY: blockedY,
    );
  }

  _CollisionMoveResult _resolveSingleCollisionStep({
    required double fromX,
    required double fromY,
    required double stepDx,
    required double stepDy,
    required String movingWorkerId,
    required int gridW,
    required int gridH,
  }) {
    final double bothX = fromX + stepDx;
    final double bothY = fromY + stepDy;
    if (!_isWorkerPositionBlocked(
      movingWorkerId: movingWorkerId,
      x: bothX,
      y: bothY,
      gridW: gridW,
      gridH: gridH,
    )) {
      return _applyHardBoundaryClamping(
        bothX,
        bothY,
        math.sqrt(stepDx * stepDx + stepDy * stepDy),
        false,
        false,
        gridW,
        gridH,
      );
    }

    final bool canMoveX =
        stepDx.abs() > _kCollisionEpsilon &&
        !_isWorkerPositionBlocked(
          movingWorkerId: movingWorkerId,
          x: fromX + stepDx,
          y: fromY,
          gridW: gridW,
          gridH: gridH,
        );
    final bool canMoveY =
        stepDy.abs() > _kCollisionEpsilon &&
        !_isWorkerPositionBlocked(
          movingWorkerId: movingWorkerId,
          x: fromX,
          y: fromY + stepDy,
          gridW: gridW,
          gridH: gridH,
        );

    if (canMoveX && !canMoveY) {
      return _applyHardBoundaryClamping(
        fromX + stepDx,
        fromY,
        stepDx.abs(),
        false,
        stepDy.abs() > _kCollisionEpsilon,
        gridW,
        gridH,
      );
    }
    if (!canMoveX && canMoveY) {
      return _applyHardBoundaryClamping(
        fromX,
        fromY + stepDy,
        stepDy.abs(),
        stepDx.abs() > _kCollisionEpsilon,
        false,
        gridW,
        gridH,
      );
    }
    if (canMoveX && canMoveY) {
      if (stepDx.abs() >= stepDy.abs()) {
        return _applyHardBoundaryClamping(
          fromX + stepDx,
          fromY,
          stepDx.abs(),
          false,
          true,
          gridW,
          gridH,
        );
      }
      return _applyHardBoundaryClamping(
        fromX,
        fromY + stepDy,
        stepDy.abs(),
        true,
        false,
        gridW,
        gridH,
      );
    }

    return _applyHardBoundaryClamping(
      fromX,
      fromY,
      0.0,
      stepDx.abs() > _kCollisionEpsilon,
      stepDy.abs() > _kCollisionEpsilon,
      gridW,
      gridH,
    );
  }

  _CollisionMoveResult _applyHardBoundaryClamping(
    double nextX,
    double nextY,
    double movedDistance,
    bool blockedX,
    bool blockedY,
    int gridW,
    int gridH,
  ) {
    // Adaptive offset for small lands (25% of smaller dimension, min 0.3)
    final double adaptiveOffset = math.max(
      0.3,
      math.min(_kBoundaryMinOffset, math.min(gridW, gridH) * 0.25),
    );
    final double minBound = adaptiveOffset;
    final double maxXBound = gridW - adaptiveOffset;
    final double maxYBound = gridH - adaptiveOffset;

    double clampedX = nextX.clamp(minBound, maxXBound);
    double clampedY = nextY.clamp(minBound, maxYBound);

    final bool clampedXAxis = (nextX - clampedX).abs() > _kCollisionEpsilon;
    final bool clampedYAxis = (nextY - clampedY).abs() > _kCollisionEpsilon;

    if (clampedXAxis || clampedYAxis) {
      _logCollisionDebug(
        'Hard clamp applied: (${nextX.toStringAsFixed(3)}, ${nextY.toStringAsFixed(3)}) -> (${clampedX.toStringAsFixed(3)}, ${clampedY.toStringAsFixed(3)})',
      );
    }

    return _CollisionMoveResult(
      nextX: clampedX,
      nextY: clampedY,
      movedDistance: clampedXAxis || clampedYAxis
          ? math.sqrt((clampedX - nextX) * (clampedX - nextX) + (clampedY - nextY) * (clampedY - nextY))
          : movedDistance,
      blockedX: blockedX || clampedXAxis,
      blockedY: blockedY || clampedYAxis,
    );
  }

  bool _isWorkerPositionBlocked({
    required String movingWorkerId,
    required double x,
    required double y,
    required int gridW,
    required int gridH,
  }) {
    if (!x.isFinite || !y.isFinite) return true;

    // HARD BOUNDARY CHECK: Prevent worker's collision circle from ever
    // crossing grid bounds. This is a fail-safe before the cell-probe loop.
    // Adaptive offset for small lands (25% of smaller dimension, min 0.3)
    final double adaptiveOffset = math.max(
      0.3,
      math.min(_kBoundaryMinOffset, math.min(gridW, gridH) * 0.25),
    );
    final double minBound = adaptiveOffset;
    final double maxXBound = gridW - adaptiveOffset;
    final double maxYBound = gridH - adaptiveOffset;
    if (x < minBound ||
        y < minBound ||
        x > maxXBound ||
        y > maxYBound) {
      _logCollisionDebug(
        'Hard boundary blocked: worker at (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}) outside bounds [${minBound.toStringAsFixed(2)}, ${maxXBound.toStringAsFixed(2)}] x [${minBound.toStringAsFixed(2)}, ${maxYBound.toStringAsFixed(2)}]',
      );
      return true;
    }

    final double maxProbeRadius =
        _kWorkerCollisionRadius + _kOffLandCollisionPadding;
    final int minX = (x - maxProbeRadius).floor();
    final int maxX = (x + maxProbeRadius).ceil();
    final int minY = (y - maxProbeRadius).floor();
    final int maxY = (y + maxProbeRadius).ceil();

    for (int yy = minY; yy <= maxY; yy++) {
      for (int xx = minX; xx <= maxX; xx++) {
        final bool isPlayable = _isPlayableCell(xx, yy, gridW, gridH);
        final bool isBlocked =
            !isPlayable || !_isCellNavigable(xx, yy, gridW, gridH);
        if (!isBlocked) continue;

        final double collisionRadius = isPlayable
            ? _kWorkerCollisionRadius
            : maxProbeRadius;
        if (_circleIntersectsCell(x, y, collisionRadius, xx, yy)) {
          return true;
        }
      }
    }

    final double minDist = _kWorkerCollisionRadius * 2;
    final double minDistSq = minDist * minDist;
    for (final other in _workers) {
      if (other.workerId == movingWorkerId) continue;
      final double dx = other.x - x;
      final double dy = other.y - y;
      if (dx * dx + dy * dy < minDistSq) {
        return true;
      }
    }
    return false;
  }

  bool _circleIntersectsCell(
    double cx,
    double cy,
    double radius,
    int cellX,
    int cellY,
  ) {
    final double left = cellX.toDouble();
    final double top = cellY.toDouble();
    final double right = left + 1.0;
    final double bottom = top + 1.0;
    final double nearestX = cx.clamp(left, right).toDouble();
    final double nearestY = cy.clamp(top, bottom).toDouble();
    final double dx = cx - nearestX;
    final double dy = cy - nearestY;
    return dx * dx + dy * dy < radius * radius;
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

  void _logCollisionDebug(String message) {
    if (!_collisionDebugEnabled) return;
    debugPrint('[Collision] $message');
  }

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
    if (rawMask == null || rawMask.isEmpty) {
      _logCollisionDebug('Playable mask missing; using rectangular bounds.');
      return null;
    }

    final normalized = <List<bool>>[];
    for (final row in rawMask) {
      if (row is! List) {
        debugPrint('Invalid playable mask row; expected List.');
        return null;
      }
      normalized.add(row.map((cell) => cell == true).toList());
    }

    final hasExpectedShape =
        normalized.length == gridHeight &&
        normalized.every((row) => row.length == gridWidth);
    if (!hasExpectedShape) {
      debugPrint(
        'Playable mask dimensions do not match grid '
        '(${normalized.isNotEmpty ? normalized.first.length : 0}x${normalized.length} vs ${gridWidth}x$gridHeight).',
      );
      return null;
    }

    return normalized;
  }

  List<List<bool>> _normalizeObstacleMask(
    List<dynamic>? matrix,
    int gridWidth,
    int gridHeight,
  ) {
    final List<List<bool>> normalized = List<List<bool>>.generate(
      gridHeight,
      (_) => List<bool>.filled(gridWidth, false),
    );
    if (matrix == null) return normalized;

    if (matrix.length != gridHeight) {
      debugPrint(
        'Grid matrix height mismatch (${matrix.length} vs $gridHeight). '
        'Obstacle collisions may be incomplete.',
      );
    }

    final int maxY = math.min(gridHeight, matrix.length);
    for (int y = 0; y < maxY; y++) {
      final row = matrix[y];
      if (row is! List) {
        debugPrint('Invalid matrix row at y=$y; expected List.');
        continue;
      }
      final int maxX = math.min(gridWidth, row.length);
      for (int x = 0; x < maxX; x++) {
        normalized[y][x] = _isBlockingMatrixCell(row[x]);
      }
    }
    return normalized;
  }

  bool _isBlockingMatrixCell(dynamic cell) {
    if (cell == null) return false;
    if (cell is! Map) return true;

    final dynamic categoryField = cell['category'] ?? cell['asset_category'];
    final String? category = categoryField is String
        ? categoryField.toLowerCase()
        : null;
    if (category != null && category.isNotEmpty) {
      return true;
    }

    final bool hasFootprint =
        (cell['footprint_width'] is num && cell['footprint_width'] > 0) ||
        (cell['footprint_height'] is num && cell['footprint_height'] > 0);
    if (hasFootprint) return true;

    if (cell['sprites'] is Map || cell['variant_id'] != null) return true;
    return false;
  }

  bool _isPlayableCell(int x, int y, int gridWidth, int gridHeight) {
    if (x < 0 || x >= gridWidth || y < 0 || y >= gridHeight) return false;
    if (_playableMask == null) return true;
    if (y >= _playableMask!.length) return false;
    final row = _playableMask![y];
    if (x >= row.length) return false;
    return row[x];
  }

  bool _isCellNavigable(int x, int y, int gridWidth, int gridHeight) {
    if (!_isPlayableCell(x, y, gridWidth, gridHeight)) return false;
    if (_obstacleMask == null) return true;
    if (y < 0 || y >= _obstacleMask!.length) return false;
    final row = _obstacleMask![y];
    if (x < 0 || x >= row.length) return false;
    return !row[x];
  }

  (double, double)? _findNearestNavigableCell(
    double x,
    double y,
    int gridWidth,
    int gridHeight,
  ) {
    if (gridWidth <= 0 || gridHeight <= 0) return null;

    final int targetX = x.floor().clamp(0, gridWidth - 1);
    final int targetY = y.floor().clamp(0, gridHeight - 1);
    if (_isCellNavigable(targetX, targetY, gridWidth, gridHeight)) {
      // Use smaller margin for cell-internal positioning (just collision radius)
      // The full _kBoundaryMinOffset is for grid edges, not cell-internal clamping
      final double cellMargin = _kWorkerCollisionRadius; // 0.25, not 0.70
      final double minX = targetX + cellMargin;
      final double maxX = targetX + 1.0 - cellMargin;
      final double minY = targetY + cellMargin;
      final double maxY = targetY + 1.0 - cellMargin;
      // Only clamp if we have valid range; otherwise return center
      if (minX < maxX && minY < maxY) {
        return (x.clamp(minX, maxX).toDouble(), y.clamp(minY, maxY).toDouble());
      }
      return (targetX + 0.5, targetY + 0.5);
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
          if (!_isCellNavigable(xx, yy, gridWidth, gridHeight)) continue;

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

  /// Returns diagnostics about worker loading for debugging.
  Map<String, dynamic> getWorkerDiagnostics() {
    return {
      'workerCount': _workers.length,
      'gridSize': '$_gridWidth x $_gridHeight',
      'playableMask': _playableMask != null ? 'custom (${_playableMask!.length}x${_playableMask!.firstOrNull?.length ?? 0})' : 'null (full rectangular)',
      'collisionRadius': _kWorkerCollisionRadius,
      'boundaryOffset': _kBoundaryMinOffset,
      'manualControlActive': manualControlActive,
      'workers': _workers.map((w) => {
        'id': w.workerId,
        'pos': '(${w.x.toStringAsFixed(2)}, ${w.y.toStringAsFixed(2)})',
        'available': w.availability,
      }).toList(),
    };
  }

  /// Emergency reload workers - useful if workers failed to load initially.
  Future<void> reloadWorkersForCurrentLand() async {
    if (currentLandId.isEmpty) {
      debugPrint('Cannot reload workers: no current land ID');
      return;
    }
    debugPrint('Emergency worker reload for land $currentLandId...');
    await loadWorkersForLand(
      currentLandId,
      gridWidth: _gridWidth,
      gridHeight: _gridHeight,
      playableMask: _playableMask,
    );
  }

  /// Finds a valid worker spawn position with multiple fallback strategies.
  /// Returns null only if absolutely no valid position exists.
  (double, double)? _findValidWorkerSpawnPosition(
    double preferredX,
    double preferredY,
    int gridWidth,
    int gridHeight, {
    required String workerId,
  }) {
    if (gridWidth <= 0 || gridHeight <= 0) return null;

    // Strategy 1: Try the preferred position with standard navigation check
    final preferred = _findNearestNavigableCell(
      preferredX,
      preferredY,
      gridWidth,
      gridHeight,
    );
    if (preferred != null) {
      // Validate it's within safe bounds
      if (_isPositionWithinSafeBounds(preferred.$1, preferred.$2, gridWidth, gridHeight)) {
        return preferred;
      }
    }

    // Strategy 2: Try center of land
    final centerX = gridWidth / 2.0;
    final centerY = gridHeight / 2.0;
    final center = _findNearestNavigableCell(centerX, centerY, gridWidth, gridHeight);
    if (center != null &&
        _isPositionWithinSafeBounds(center.$1, center.$2, gridWidth, gridHeight)) {
      return center;
    }

    // Strategy 3: Scan all cells for any valid position
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        if (_isCellNavigable(x, y, gridWidth, gridHeight)) {
          final posX = x + 0.5;
          final posY = y + 0.5;
          if (_isPositionWithinSafeBounds(posX, posY, gridWidth, gridHeight)) {
            return (posX, posY);
          }
        }
      }
    }

    // Strategy 4: Return center with relaxed bounds (will be clamped later)
    if (center != null) return center;
    if (preferred != null) return preferred;

    return null;
  }

  /// Checks if a position is within the safe boundary bounds.
  /// Adapts for small lands by using a smaller offset.
  bool _isPositionWithinSafeBounds(double x, double y, int gridW, int gridH) {
    // For small lands, use adaptive offset (25% of smaller dimension, min 0.3)
    final double adaptiveOffset = math.max(
      0.3,
      math.min(_kBoundaryMinOffset, math.min(gridW, gridH) * 0.25),
    );
    final double minBound = adaptiveOffset;
    final double maxXBound = gridW - adaptiveOffset;
    final double maxYBound = gridH - adaptiveOffset;
    return x >= minBound && x <= maxXBound && y >= minBound && y <= maxYBound;
  }

  /// Emergency spawn position when normal navigation fails.
  /// Uses minimum safe distance or center of land.
  (double, double)? _calculateEmergencySpawnPosition(int gridWidth, int gridHeight) {
    if (gridWidth <= 0 || gridHeight <= 0) return null;

    // Calculate safe bounds - use minimum of 0.3 if 0.70 is too large for small lands
    final double minOffset = math.min(_kBoundaryMinOffset, math.min(gridWidth, gridHeight) * 0.25);
    final double safeMin = math.max(0.3, minOffset);
    final double safeMaxX = gridWidth - safeMin;
    final double safeMaxY = gridHeight - safeMin;

    // If land is too small, just place at center
    if (safeMin >= safeMaxX || safeMin >= safeMaxY) {
      return (gridWidth / 2.0, gridHeight / 2.0);
    }

    return (
      (gridWidth / 2.0).clamp(safeMin, safeMaxX),
      (gridHeight / 2.0).clamp(safeMin, safeMaxY),
    );
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
