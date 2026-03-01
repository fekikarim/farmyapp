import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vendor_delivery_model.dart';
import '../models/delivery_model.dart';
import '../services/vendor_delivery_service.dart';

class VendorDeliveryProvider with ChangeNotifier {
  // ─── State ─────────────────────────────────────────────────

  VendorDeliveryStats _stats = VendorDeliveryStats.empty();
  List<VendorDeliveryItem> _deliveries = [];
  PaginationMeta? _pagination;
  VendorDeliveryDetail? _selectedDetail;

  bool _isLoadingList = false;
  bool _isLoadingStats = false;
  bool _isLoadingDetail = false;
  bool _isUpdatingStatus = false;
  bool _isLoadingMore = false;
  String? _listError;
  String? _statsError;
  String? _detailError;
  String? _updateError;

  DeliveryStatus? _statusFilter;
  String _searchQuery = '';
  String _sortBy = 'date';
  String _sortOrder = 'DESC';

  Timer? _refreshTimer;

  // ─── Getters ───────────────────────────────────────────────

  VendorDeliveryStats get stats => _stats;
  List<VendorDeliveryItem> get deliveries => _deliveries;
  PaginationMeta? get pagination => _pagination;
  VendorDeliveryDetail? get selectedDetail => _selectedDetail;

  bool get isLoadingList => _isLoadingList;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isUpdatingStatus => _isUpdatingStatus;
  bool get isLoadingMore => _isLoadingMore;

  String? get listError => _listError;
  String? get statsError => _statsError;
  String? get detailError => _detailError;
  String? get updateError => _updateError;

  DeliveryStatus? get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  bool get hasNextPage => _pagination?.hasNextPage ?? false;

  // ─── FETCH STATS ───────────────────────────────────────────

  Future<void> fetchStats() async {
    _isLoadingStats = true;
    _statsError = null;
    notifyListeners();

    try {
      _stats = await VendorDeliveryService.getStats();
    } catch (e) {
      _statsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // ─── FETCH DELIVERIES (first page) ─────────────────────────

  Future<void> fetchDeliveries() async {
    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    try {
      final result = await VendorDeliveryService.getDeliveries(
        status: _statusFilter,
        page: 1,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _deliveries = result.data;
      _pagination = result.pagination;
    } catch (e) {
      _listError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // ─── LOAD MORE (next page) ─────────────────────────────────

  Future<void> loadMore() async {
    if (_isLoadingMore || _pagination == null || !_pagination!.hasNextPage) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await VendorDeliveryService.getDeliveries(
        status: _statusFilter,
        page: _pagination!.page + 1,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _deliveries.addAll(result.data);
      _pagination = result.pagination;
    } catch (e) {
      debugPrint('VendorDeliveryProvider loadMore error: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ─── FILTERS ───────────────────────────────────────────────

  void setStatusFilter(DeliveryStatus? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    fetchDeliveries();
  }

  void setSearch(String query) {
    _searchQuery = query;
    fetchDeliveries();
  }

  void setSortBy(String sortBy, {String order = 'DESC'}) {
    _sortBy = sortBy;
    _sortOrder = order;
    fetchDeliveries();
  }

  // ─── FETCH DETAIL ──────────────────────────────────────────

  Future<void> fetchDetail(String deliveryId) async {
    _isLoadingDetail = true;
    _detailError = null;
    _selectedDetail = null;
    notifyListeners();

    try {
      _selectedDetail = await VendorDeliveryService.getDetail(deliveryId);
    } catch (e) {
      _detailError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // ─── UPDATE STATUS ─────────────────────────────────────────

  Future<bool> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus newStatus,
    String? note,
    String? cancellationReason,
  }) async {
    _isUpdatingStatus = true;
    _updateError = null;
    notifyListeners();

    try {
      final updated = await VendorDeliveryService.updateStatus(
        deliveryId: deliveryId,
        status: newStatus,
        note: note,
        cancellationReason: cancellationReason,
      );
      _selectedDetail = updated;

      // Update the item in the list too
      final idx = _deliveries.indexWhere((d) => d.id == deliveryId);
      if (idx != -1) {
        // Refresh list data after status change
        fetchDeliveries();
        fetchStats();
      }

      _isUpdatingStatus = false;
      notifyListeners();
      return true;
    } catch (e) {
      _updateError = e.toString().replaceFirst('Exception: ', '');
      _isUpdatingStatus = false;
      notifyListeners();
      return false;
    }
  }

  // ─── REFRESH ALL ───────────────────────────────────────────

  Future<void> refreshAll() async {
    await Future.wait([fetchStats(), fetchDeliveries()]);
  }

  // ─── AUTO-REFRESH (periodic) ───────────────────────────────

  void startAutoRefresh({int intervalSeconds = 30}) {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _silentRefresh(),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _silentRefresh() async {
    try {
      final results = await Future.wait([
        VendorDeliveryService.getStats(),
        VendorDeliveryService.getDeliveries(
          status: _statusFilter,
          page: 1,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
      ]);

      _stats = results[0] as VendorDeliveryStats;
      final listResult =
          results[1]
              as ({List<VendorDeliveryItem> data, PaginationMeta pagination});
      _deliveries = listResult.data;
      _pagination = listResult.pagination;
      _listError = null;
      _statsError = null;
      notifyListeners();
    } catch (e) {
      debugPrint('VendorDeliveryProvider auto-refresh error: $e');
    }
  }

  // ─── CLEAR ─────────────────────────────────────────────────

  void clear() {
    stopAutoRefresh();
    _deliveries = [];
    _stats = VendorDeliveryStats.empty();
    _pagination = null;
    _selectedDetail = null;
    _statusFilter = null;
    _searchQuery = '';
    _listError = null;
    _statsError = null;
    _detailError = null;
    _updateError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
