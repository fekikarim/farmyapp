import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/land_worker_model.dart';
import '../services/worker_service.dart';
import '../services/socket_service.dart';

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
  String direction;
  String status; // 'idle' | 'walking'
  Timer? movementTimer;

  WorkerState({
    required this.workerId,
    required this.workerName,
    this.workerPicture,
    this.availability = 'available',
    this.x = 1,
    this.y = 1,
    this.direction = 'front_left',
    this.status = 'idle',
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
        movementTimer?.cancel();
        onStop();
      } else {
        // Update direction
        if (dx.abs() > dy.abs()) {
          direction = dx > 0 ? 'front_right' : 'back_left';
        } else {
          direction = dy > 0 ? 'front_left' : 'back_right';
        }
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
  }
}

class GameProvider with ChangeNotifier {
  bool _showEdgePanel = true;
  bool _isLoading = true;
  bool _workersLoading = false;

  List<WorkerState> _workers = [];

  bool get showEdgePanel => _showEdgePanel;
  bool get isLoading => _isLoading;
  bool get workersLoading => _workersLoading;
  List<WorkerState> get workers => _workers;

  GameProvider() {
    _loadSettings();
  }

  /// Load workers assigned to a specific land from the API.
  Future<void> loadWorkersForLand(
    String landId, {
    int gridWidth = 10,
    int gridHeight = 10,
  }) async {
    _workersLoading = true;
    notifyListeners();

    currentLandId = landId; // Remember which land workers are on

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
      socketService.off('worker_task_completed'); // Clear old listener to prevent duplicates
      socketService.on('worker_task_completed', (data) {
        if (data is Map<String, dynamic>) {
           final completedWorkerId = data['workerId'];
           final landIdEvent = data['landId'];
           if (landIdEvent == currentLandId) { // Verify it's for current land
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
      _saveWorkerPosition(effectiveLandId, closest.workerId, closest.x, closest.y);
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

    worker.moveTo(clampedX, clampedY, notifyListeners, () {
      _saveWorkerPosition(currentLandId, worker.workerId, worker.x, worker.y);
      notifyListeners();
    });
  }


  String currentLandId = '';

  /// Saves a worker's position to SharedPreferences.
  Future<void> _saveWorkerPosition(String landId, String workerId, double x, double y) async {
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
    final availableWorkers = _workers.where((w) => w.availability == 'available').toList();
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
