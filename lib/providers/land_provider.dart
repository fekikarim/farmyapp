import 'package:flutter/material.dart';
import '../models/land_model.dart';
import '../models/land_rental_model.dart';
import '../services/land_service.dart';
import '../services/land_rental_service.dart';

class LandProvider with ChangeNotifier {
  List<Land> _allLands = [];
  List<Land> _myLands = [];
  List<LandRental> _myRentals = [];

  bool _isLoading = false;
  String? _error;

  List<Land> get allLands => _allLands;
  List<Land> get myLands => _myLands;
  List<LandRental> get myRentals => _myRentals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- Land Methods ---

  Future<void> fetchAllLands() async {
    _setLoading(true);
    _error = null;
    try {
      _allLands = await LandService.getAllLands();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> fetchMyLands() async {
    _setLoading(true);
    _error = null;
    try {
      _myLands = await LandService.getMyLands();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<bool> createLand(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      final newLand = await LandService.createLand(data);
      if (newLand != null) {
        _myLands.add(newLand);
        notifyListeners();
        return true;
      }
      _error = "Failed to create land";
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // --- Rental Methods ---

  Future<void> fetchMyRentals(bool asInvestor) async {
    _setLoading(true);
    _error = null;
    try {
      if (asInvestor) {
        _myRentals = await LandRentalService.getMyRentalsAsInvestor();
      } else {
        _myRentals = await LandRentalService.getMyRentalsAsOwner();
      }
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<bool> rentLand(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      final rental = await LandRentalService.createRental(data);
      if (rental != null) {
        _myRentals.add(rental);
        // Refresh all lands to update availability status globally
        await fetchAllLands();
        notifyListeners();
        return true;
      }
      _error = "Failed to create rental";
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // --- Helpers ---

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
