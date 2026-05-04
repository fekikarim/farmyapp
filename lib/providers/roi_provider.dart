import 'dart:async';
import 'package:flutter/material.dart';
import '../models/roi_model.dart';
import '../services/roi_service.dart';

/// Loading state enum for granular UI control
enum RoiLoadingState {
  idle,
  initial,
  refreshing,
  backgroundSync,
}

/// Enhanced ROI Provider with caching, retry logic, and real-time sync
class RoiProvider with ChangeNotifier {
  final RoiService _roiService = RoiService();
  
  // State management
  RoiDashboardData? _dashboardData;
  RoiLoadingState _loadingState = RoiLoadingState.idle;
  String? _error;
  bool _hasInitialData = false;
  
  // Caching
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);
  static const Duration _staleDataThreshold = Duration(minutes: 15);
  
  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 1);
  
  // Background sync
  Timer? _syncTimer;
  static const Duration _syncInterval = Duration(minutes: 2);
  
  // Getters
  RoiDashboardData? get dashboardData => _dashboardData;
  RoiLoadingState get loadingState => _loadingState;
  String? get error => _error;
  bool get isLoading => _loadingState == RoiLoadingState.initial || 
                        _loadingState == RoiLoadingState.refreshing;
  bool get isBackgroundSyncing => _loadingState == RoiLoadingState.backgroundSync;
  bool get hasInitialData => _hasInitialData;
  bool get hasError => _error != null;
  bool get hasData => _dashboardData != null && _dashboardData!.overview.isValid;
  
  /// Check if cached data is still fresh
  bool get isCacheFresh {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }
  
  /// Check if data is stale (needs background refresh)
  bool get isDataStale {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _staleDataThreshold;
  }

  /// Initialize provider with automatic sync
  void initialize() {
    startAutoSync();
  }
  
  /// Dispose and cleanup
  @override
  void dispose() {
    stopAutoSync();
    super.dispose();
  }

  /// Start automatic background synchronization
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) async {
      if (isDataStale && !isLoading) {
        await syncBackground();
      }
    });
  }
  
  /// Stop automatic synchronization
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Fetch dashboard data with caching and retry logic
  Future<void> fetchDashboardData({bool forceRefresh = false}) async {
    // Use cache if available and fresh, unless force refresh
    if (!forceRefresh && isCacheFresh && _dashboardData != null) {
      return;
    }
    
    // Set appropriate loading state
    if (_dashboardData == null) {
      _loadingState = RoiLoadingState.initial;
    } else {
      _loadingState = RoiLoadingState.refreshing;
    }
    _error = null;
    notifyListeners();

    try {
      final data = await _fetchWithRetry();
      _dashboardData = data;
      _hasInitialData = true;
      _lastFetchTime = DateTime.now();
      _error = null;
    } on RoiException catch (e) {
      _error = e.userFriendlyMessage;
      // Keep existing data if we have it
      if (_dashboardData != null) {
        _loadingState = RoiLoadingState.idle;
        notifyListeners();
        return;
      }
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      if (_dashboardData != null) {
        _loadingState = RoiLoadingState.idle;
        notifyListeners();
        return;
      }
    } finally {
      if (_dashboardData == null || _error == null) {
        _loadingState = RoiLoadingState.idle;
      }
      notifyListeners();
    }
  }
  
  /// Background sync (silent refresh)
  Future<void> syncBackground() async {
    if (_loadingState != RoiLoadingState.idle) return;
    
    _loadingState = RoiLoadingState.backgroundSync;
    notifyListeners();
    
    try {
      final data = await _fetchWithRetry();
      _dashboardData = data;
      _lastFetchTime = DateTime.now();
      _error = null;
    } catch (e) {
      // Silent fail - don't show error to user for background sync
      debugPrint('Background sync failed: $e');
    } finally {
      _loadingState = RoiLoadingState.idle;
      notifyListeners();
    }
  }
  
  /// Fetch with exponential backoff retry
  Future<RoiDashboardData> _fetchWithRetry() async {
    int attempts = 0;
    Duration delay = _initialRetryDelay;
    
    while (attempts < _maxRetries) {
      try {
        return await _roiService.getRoiDashboard();
      } on RoiException catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          throw e;
        }
        
        // Don't retry on authentication errors
        if (e.isAuthenticationError) {
          throw e;
        }
        
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
    
    throw RoiException('Max retry attempts reached');
  }

  /// Clear all data and reset state
  void clearData() {
    _dashboardData = null;
    _error = null;
    _loadingState = RoiLoadingState.idle;
    _hasInitialData = false;
    _lastFetchTime = null;
    notifyListeners();
  }
  
  /// Clear error and retry
  Future<void> retry() async {
    _error = null;
    await fetchDashboardData(forceRefresh: true);
  }
  
  /// Get profit summary with product revenue breakdown
  ProfitSummary? get profitSummary {
    if (_dashboardData == null) return null;
    
    final overview = _dashboardData!.overview;
    return ProfitSummary(
      totalNetProfit: overview.netProfit,
      productRevenue: overview.productRevenue,
      rentalRevenue: overview.rentalRevenue,
      totalInvestment: overview.totalInvestment,
      roiPercentage: overview.roiPercentage,
      totalProductsSold: overview.totalProductsSold,
      averageMargin: overview.averageProductMargin,
      isProfitable: overview.netProfit >= 0,
      productContribution: overview.productRevenueContribution,
    );
  }
}

/// Profit summary for UI display
class ProfitSummary {
  final double totalNetProfit;
  final double productRevenue;
  final double rentalRevenue;
  final double totalInvestment;
  final double roiPercentage;
  final int totalProductsSold;
  final double averageMargin;
  final bool isProfitable;
  final double productContribution;

  ProfitSummary({
    required this.totalNetProfit,
    required this.productRevenue,
    required this.rentalRevenue,
    required this.totalInvestment,
    required this.roiPercentage,
    required this.totalProductsSold,
    required this.averageMargin,
    required this.isProfitable,
    required this.productContribution,
  });
}

/// Custom ROI exception with categorization
class RoiException implements Exception {
  final String message;
  final RoiErrorType type;
  
  RoiException(this.message, {this.type = RoiErrorType.unknown});
  
  bool get isNetworkError => type == RoiErrorType.network;
  bool get isAuthenticationError => type == RoiErrorType.authentication;
  bool get isServerError => type == RoiErrorType.server;
  
  String get userFriendlyMessage {
    switch (type) {
      case RoiErrorType.network:
        return 'Unable to connect. Please check your internet connection and try again.';
      case RoiErrorType.authentication:
        return 'Your session has expired. Please sign in again.';
      case RoiErrorType.server:
        return 'Our servers are experiencing issues. Please try again later.';
      case RoiErrorType.timeout:
        return 'The request took too long. Please try again.';
      case RoiErrorType.unknown:
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  
  @override
  String toString() => 'RoiException: $message (type: $type)';
}

enum RoiErrorType {
  network,
  authentication,
  server,
  timeout,
  unknown,
}
