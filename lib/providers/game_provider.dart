import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/land_worker_model.dart';
import '../services/worker_service.dart';

/// Holds runtime state for a single worker on the map.
class WorkerState {
  final String workerId;
  final String workerName;
  final String? workerPicture;
  final String availability;
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

    try {
      final List<LandWorker> landWorkers = await WorkerService.getLandWorkers(
        landId,
      );

      // Cancel all running movement timers
      for (var w in _workers) {
        w.stop();
      }

      // Spread workers in a line at top-left of the land
      _workers = [];
      for (int i = 0; i < landWorkers.length; i++) {
        final lw = landWorkers[i];
        if (!lw.isActive) continue; // Only show active workers

        // Spread workers in a horizontal line starting from (1, 1)
        double startX = 1.0 + (i % 4).toDouble(); // Max 4 per row
        double startY = 1.0 + (i ~/ 4).toDouble();

        _workers.add(
          WorkerState(
            workerId: lw.workerId,
            workerName: lw.workerName ?? 'Worker',
            workerPicture: lw.workerProfilePicture,
            availability: lw.workerAvailability ?? 'available',
            x: startX.clamp(0, gridWidth - 1.0),
            y: startY.clamp(0, gridHeight - 1.0),
          ),
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
  void moveClosestWorkerTo(
    double tx,
    double ty, {
    int? gridWidth,
    int? gridHeight,
  }) {
    if (_workers.isEmpty) return;

    // Clamp target to grid bounds
    double clampedX = tx;
    double clampedY = ty;
    if (gridWidth != null) clampedX = clampedX.clamp(0.0, gridWidth - 0.1);
    if (gridHeight != null) clampedY = clampedY.clamp(0.0, gridHeight - 0.1);

    // Find closest worker by Manhattan distance
    WorkerState closest = _workers.first;
    double minDist = double.infinity;
    for (var w in _workers) {
      double dist = (w.x - clampedX).abs() + (w.y - clampedY).abs();
      if (dist < minDist) {
        minDist = dist;
        closest = w;
      }
    }

    closest.moveTo(clampedX, clampedY, notifyListeners, notifyListeners);
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
