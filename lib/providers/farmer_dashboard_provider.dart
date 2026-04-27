import 'dart:async';
import 'package:flutter/material.dart';
import '../models/farmer_dashboard_model.dart';
import '../services/farmer_dashboard_service.dart';

class FarmerDashboardProvider extends ChangeNotifier {
  FarmerDashboardData? _data;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  DateTime? _lastUpdated;
  DateTime? _lastSuccessfulSync;
  DateTime? _lastSyncAttempt;
  int _consecutiveFailures = 0;
  Timer? _refreshTimer;
  Timer? _retryTimer;
  bool _isVisible = true;
  String _localeCode = 'en';

  // Getters
  FarmerDashboardData? get data => _data;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;
  DateTime? get lastSyncAttempt => _lastSyncAttempt;
  int get consecutiveFailures => _consecutiveFailures;
  String get localeCode => _localeCode;
  bool get hasData => _data != null;
  bool get hasSyncIssue => _consecutiveFailures > 0;

  // Hero Metrics getters
  HeroMetrics? get heroMetrics => _data?.heroMetrics;
  int get activeLands => _data?.heroMetrics.activeLands ?? 0;
  int get openTasks => _data?.heroMetrics.openTasks ?? 0;
  int get overdueTasks => _data?.heroMetrics.overdueTasks ?? 0;
  int get pendingItemRequests => _data?.heroMetrics.pendingItemRequests ?? 0;
  double get monthlyRevenue => _data?.heroMetrics.monthlyRevenue ?? 0;
  double get revenueTrend => _data?.heroMetrics.revenueTrend ?? 0;

  // Lists getters
  List<SmartAlert> get alerts => _data?.alerts ?? [];
  List<LandOperational> get lands => _data?.lands ?? [];
  List<ActiveWorker> get workers => _data?.workers ?? [];
  List<AISessionPreview> get aiSessions => _data?.aiSessions ?? [];

  // Filtered alerts by priority
  List<SmartAlert> get criticalAlerts =>
      alerts.where((a) => a.priority == AlertPriority.critical).toList();
  List<SmartAlert> get warningAlerts =>
      alerts.where((a) => a.priority == AlertPriority.warning).toList();
  List<SmartAlert> get infoAlerts =>
      alerts.where((a) => a.priority == AlertPriority.info).toList();

  // Land status counts
  int get ownedLandsCount =>
      lands.where((l) => l.status == LandOperationalStatus.owned).length;
  int get rentedLandsCount =>
      lands.where((l) => l.status == LandOperationalStatus.rented).length;
  int get harvestReadyLandsCount =>
      lands.where((l) => l.status == LandOperationalStatus.harvestReady).length;
  int get pendingRequestsLandsCount => lands
      .where((l) => l.status == LandOperationalStatus.pendingRequests)
      .length;

  /// Load dashboard data (initial load)
  Future<void> loadDashboard({
    String? localeCode,
    bool force = false,
  }) async {
    if (localeCode != null && localeCode.isNotEmpty) {
      _localeCode = localeCode;
    }

    if (_isLoading && !force) return;

    _lastSyncAttempt = DateTime.now();

    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dashboardData = await FarmerDashboardService.getDashboardData(
        localeCode: _localeCode,
      );
      _data = dashboardData;
      _lastUpdated = DateTime.now();
      _lastSuccessfulSync = _lastUpdated;
      _consecutiveFailures = 0;
      _error = null;
      _cancelRetry();
    } catch (e) {
      _error = _normalizeError(e);
      _consecutiveFailures += 1;
      _scheduleRetry();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dashboard data (silent refresh)
  Future<void> refresh({
    String? localeCode,
    bool force = false,
  }) async {
    if (localeCode != null && localeCode.isNotEmpty) {
      _localeCode = localeCode;
    }

    if (_isRefreshing && !force) return;

    _lastSyncAttempt = DateTime.now();

    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      final dashboardData = await FarmerDashboardService.refreshDashboard(
        localeCode: _localeCode,
      );
      _data = dashboardData;
      _lastUpdated = DateTime.now();
      _lastSuccessfulSync = _lastUpdated;
      _consecutiveFailures = 0;
      _error = null;
      _cancelRetry();
    } catch (e) {
      // Don't overwrite existing data on refresh failure
      _error = _normalizeError(e);
      _consecutiveFailures += 1;
      _scheduleRetry();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Sync if data is stale (older than maxAge)
  Future<void> syncIfStale({
    Duration maxAge = const Duration(seconds: 45),
    String? localeCode,
  }) async {
    if (localeCode != null && localeCode.isNotEmpty) {
      _localeCode = localeCode;
    }

    if (_isLoading || _isRefreshing) return;

    if (!hasData) {
      await loadDashboard(localeCode: _localeCode);
      return;
    }

    final referenceTime = _lastSuccessfulSync ?? _lastUpdated;
    if (referenceTime == null || DateTime.now().difference(referenceTime) > maxAge) {
      await refresh(localeCode: _localeCode);
    }
  }

  /// Start auto-refresh timer (30 seconds)
  void startAutoRefresh() {
    stopAutoRefresh();
    if (_isVisible) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (_isVisible) {
          refresh();
        }
      });
    }
  }

  /// Stop auto-refresh timer
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Set visibility state (for app lifecycle management)
  void setVisibility(bool visible, {String? localeCode}) {
    if (localeCode != null && localeCode.isNotEmpty) {
      _localeCode = localeCode;
    }

    _isVisible = visible;
    if (visible) {
      startAutoRefresh();
      unawaited(syncIfStale(localeCode: _localeCode));
    } else {
      stopAutoRefresh();
    }
  }

  /// Repair a placed item and refresh dashboard
  Future<bool> repairItem(String itemId) async {
    try {
      await FarmerDashboardService.repairPlacedItem(
        itemId,
        localeCode: _localeCode,
      );
      // Refresh dashboard to show updated durability
      await refresh(localeCode: _localeCode, force: true);
      return true;
    } catch (e) {
      _error = _normalizeError(e);
      notifyListeners();
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _normalizeError(Object error) {
    if (error is DashboardServiceException) {
      return (error as DashboardServiceException).message;
    }

    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '').trim();
    }
    return message;
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void _scheduleRetry() {
    if (!_isVisible || _isLoading || _isRefreshing) return;

    _cancelRetry();
    const retryDelaysInSec = [5, 10, 20, 30];
    final idx = (_consecutiveFailures - 1).clamp(0, retryDelaysInSec.length - 1);
    final delaySeconds = retryDelaysInSec[idx];

    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isVisible || _isLoading || _isRefreshing) return;
      refresh(localeCode: _localeCode);
    });
  }

  @override
  void dispose() {
    stopAutoRefresh();
    _cancelRetry();
    super.dispose();
  }
}
