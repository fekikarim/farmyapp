import 'package:flutter/material.dart';
import '../models/roi_model.dart';
import '../services/roi_service.dart';

class RoiProvider with ChangeNotifier {
  final RoiService _roiService = RoiService();

  RoiDashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  RoiDashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _roiService.getRoiDashboard();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _dashboardData = null;
    _error = null;
    notifyListeners();
  }
}
