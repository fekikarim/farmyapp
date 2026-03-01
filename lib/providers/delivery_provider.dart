import 'dart:async';
import 'package:flutter/material.dart';
import '../models/delivery_model.dart';
import '../services/delivery_service.dart';

class DeliveryProvider with ChangeNotifier {
  DeliveryTracking? _tracking;
  List<DeliveryTracking> _myDeliveries = [];
  bool _isLoading = false;
  bool _isPolling = false;
  String? _error;
  Timer? _pollTimer;

  // ─── Getters ───────────────────────────────────────────────

  DeliveryTracking? get tracking => _tracking;
  List<DeliveryTracking> get myDeliveries => _myDeliveries;
  bool get isLoading => _isLoading;
  bool get isPolling => _isPolling;
  String? get error => _error;

  // ─── Fetch single delivery by order ID ─────────────────────

  Future<void> fetchByOrderId(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tracking = await DeliveryService.getByOrderId(orderId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _tracking = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Fetch single delivery by delivery ID ──────────────────

  Future<void> fetchById(String deliveryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tracking = await DeliveryService.getById(deliveryId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _tracking = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Fetch all my deliveries ───────────────────────────────

  Future<void> fetchMyDeliveries({String role = 'all'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myDeliveries = await DeliveryService.getMyDeliveries(role: role);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Polling (near real-time refresh) ──────────────────────

  /// Start polling for delivery updates every [intervalSeconds].
  /// Automatically stops when status is terminal (delivered/cancelled).
  void startPolling(String orderId, {int intervalSeconds = 12}) {
    stopPolling(); // Clear any existing timer
    _isPolling = true;

    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) async {
      try {
        final updated = await DeliveryService.getByOrderId(orderId);
        _tracking = updated;
        _error = null;
        notifyListeners();

        // Stop polling on terminal status
        if (updated.isTerminal) {
          stopPolling();
        }
      } catch (e) {
        // Silently handle poll failures – don't overwrite existing data
        debugPrint('DeliveryProvider poll error: $e');
      }
    });
  }

  /// Stop polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (_isPolling) {
      _isPolling = false;
      notifyListeners();
    }
  }

  // ─── Silent refresh (for pull-to-refresh) ──────────────────

  Future<void> silentRefresh(String orderId) async {
    try {
      _tracking = await DeliveryService.getByOrderId(orderId);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  // ─── Cleanup ───────────────────────────────────────────────

  void clear() {
    stopPolling();
    _tracking = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
