import 'package:flutter/material.dart';
import '../../../services/land_service.dart';
import '../models/farm_grid_model.dart';

class FarmGameProvider with ChangeNotifier {
  FarmGrid? _grid;
  bool _isLoading = false;
  String? _error;

  // View state
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  FarmGrid? get grid => _grid;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get scale => _scale;
  Offset get offset => _offset;

  Future<void> loadLandGrid(String landId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await LandService.getLandGrid(landId);
      if (data != null && data['success'] == true) {
        _grid = FarmGrid.fromJson(data['data']);
      } else {
        _error = 'Failed to load land grid';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateView({double? scale, Offset? offset}) {
    if (scale != null) _scale = scale;
    if (offset != null) _offset = offset;
    notifyListeners();
  }

  void resetView() {
    _scale = 1.0;
    _offset = Offset.zero;
    notifyListeners();
  }
}
