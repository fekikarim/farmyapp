import 'package:flutter/material.dart';
import '../models/worker_performance_model.dart';
import '../models/land_model.dart';
import '../services/worker_performance_service.dart';
import '../services/land_service.dart';

class WorkerPerformanceProvider extends ChangeNotifier {
  // Performance Data State
  List<WorkerPerformance> _workers = [];
  PerformanceSummary _summary = PerformanceSummary(
    totalWorkers: 0,
    averagePerformanceScore: 0,
    totalTasksCompleted: 0,
    overallVerificationRate: 0.0,
  );
  bool _isLoading = false;
  String? _error;

  // Insights State
  List<WorkerPerformance> _topPerformers = [];
  List<WorkerPerformance> _underperformers = [];
  bool _insightsLoading = false;

  // Filters State
  List<String> _selectedLandIds = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _currentDatePreset = 'all';
  WorkerSortCriteria _sortCriteria = WorkerSortCriteria.scoreHighToLow;

  // Available Lands for Filter
  List<Land> _farmerLands = [];
  bool _landsLoading = false;

  // Getters
  List<WorkerPerformance> get workers {
    // Filter workers whose assigned lands include any selected land IDs
    final filtered = _selectedLandIds.isEmpty
        ? _workers
        : _workers.where((w) {
            return w.landIds.any((landId) => _selectedLandIds.contains(landId));
          }).toList();
    return _sortWorkers(filtered);
  }
  PerformanceSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<WorkerPerformance> get topPerformers => _topPerformers;
  List<WorkerPerformance> get underperformers => _underperformers;
  bool get insightsLoading => _insightsLoading;

  List<String> get selectedLandIds => _selectedLandIds;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get currentDatePreset => _currentDatePreset;
  WorkerSortCriteria get sortCriteria => _sortCriteria;

  List<Land> get farmerLands => _farmerLands;
  bool get landsLoading => _landsLoading;

  /// Get filtered and sorted workers
  List<WorkerPerformance> _sortWorkers(List<WorkerPerformance> list) {
    final sorted = List<WorkerPerformance>.from(list);

    switch (_sortCriteria) {
      case WorkerSortCriteria.scoreHighToLow:
        sorted.sort((a, b) => b.performanceScore.compareTo(a.performanceScore));
        break;
      case WorkerSortCriteria.scoreLowToHigh:
        sorted.sort((a, b) => a.performanceScore.compareTo(b.performanceScore));
        break;
      case WorkerSortCriteria.tasksHighToLow:
        sorted.sort((a, b) => b.totalTasksCompleted.compareTo(a.totalTasksCompleted));
        break;
      case WorkerSortCriteria.tasksLowToHigh:
        sorted.sort((a, b) => a.totalTasksCompleted.compareTo(b.totalTasksCompleted));
        break;
      case WorkerSortCriteria.nameAZ:
        sorted.sort((a, b) => a.workerName.compareTo(b.workerName));
        break;
      case WorkerSortCriteria.nameZA:
        sorted.sort((a, b) => b.workerName.compareTo(a.workerName));
        break;
    }

    return sorted;
  }

  /// Load worker performance data
  Future<void> loadWorkerPerformance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all workers for the farmer's lands, filtering happens client-side
      final response = await WorkerPerformanceService.getWorkerPerformance(
        landIds: null, // Load all, filter client-side by worker assignments
        startDate: _startDate,
        endDate: _endDate,
      );

      _workers = response.workers;
      _summary = response.summary;
    } catch (e) {
      _error = 'Failed to load worker performance: $e';
      debugPrint('WorkerPerformanceProvider: Error loading workers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load insights (top performers and underperformers)
  Future<void> loadInsights() async {
    _insightsLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        WorkerPerformanceService.getTopPerformers(
          landIds: _selectedLandIds.isNotEmpty ? _selectedLandIds : null,
          startDate: _startDate,
          endDate: _endDate,
          limit: 3,
        ),
        WorkerPerformanceService.getUnderperformers(
          landIds: _selectedLandIds.isNotEmpty ? _selectedLandIds : null,
          startDate: _startDate,
          endDate: _endDate,
          limit: 3,
        ),
      ]);

      _topPerformers = results[0];
      _underperformers = results[1];
    } catch (e) {
      // Don't set main error, just log
      debugPrint('Error loading insights: $e');
    } finally {
      _insightsLoading = false;
      notifyListeners();
    }
  }

  /// Load all data including insights
  Future<void> loadAll() async {
    await Future.wait([
      loadWorkerPerformance(),
      loadInsights(),
    ]);
  }

  /// Load farmer lands for filter dropdown
  Future<void> loadFarmerLands() async {
    _landsLoading = true;
    notifyListeners();

    try {
      _farmerLands = await LandService.getMyLands();
    } catch (e) {
      debugPrint('Error loading farmer lands: $e');
    } finally {
      _landsLoading = false;
      notifyListeners();
    }
  }

  /// Update land filter
  Future<void> setLandFilter(List<String> landIds) async {
    _selectedLandIds = landIds;
    notifyListeners();
    await loadAll();
  }

  /// Update date range filter
  Future<void> setDateRange(DateTime? start, DateTime? end) async {
    _startDate = start;
    _endDate = end;
    notifyListeners();
    await loadAll();
  }

  /// Update sort criteria
  void setSortCriteria(WorkerSortCriteria criteria) {
    _sortCriteria = criteria;
    notifyListeners();
  }

  /// Set preset date range
  Future<void> setPresetDateRange(String preset) async {
    final now = DateTime.now();
    _currentDatePreset = preset;

    switch (preset) {
      case 'today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
        break;
      case 'week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'all':
      default:
        _startDate = null;
        _endDate = null;
        _currentDatePreset = 'all';
        break;
    }

    notifyListeners();
    await loadAll();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _selectedLandIds = [];
    _startDate = null;
    _endDate = null;
    _currentDatePreset = 'all';
    _sortCriteria = WorkerSortCriteria.scoreHighToLow;
    notifyListeners();
    await loadAll();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadAll();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get worker by ID
  WorkerPerformance? getWorkerById(String workerId) {
    try {
      return _workers.firstWhere((w) => w.workerId == workerId);
    } catch (e) {
      return null;
    }
  }

  /// Get workers needing attention
  List<WorkerPerformance> get workersNeedingAttention {
    return _workers.where((w) => w.needsAttention).toList();
  }

  /// Get excellent performers
  List<WorkerPerformance> get excellentWorkers {
    return _workers.where((w) => w.performanceTier == PerformanceTier.excellent).toList();
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return _selectedLandIds.isNotEmpty ||
        _startDate != null ||
        _endDate != null;
  }
}
