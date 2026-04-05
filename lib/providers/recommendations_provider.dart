import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class SmartRecommendationsProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  static const Duration _cacheTtl = Duration(minutes: 3);

  List<Map<String, dynamic>> _productRecommendations = [];
  List<Map<String, dynamic>> _landRecommendations = [];

  bool _isProductsLoading = false;
  bool _isLandsLoading = false;

  String? _productsError;
  String? _landsError;

  DateTime? _productsLastUpdated;
  DateTime? _landsLastUpdated;

  // Getters
  List<Map<String, dynamic>> get productRecommendations =>
      _productRecommendations;
  List<Map<String, dynamic>> get landRecommendations => _landRecommendations;

  bool get isProductsLoading => _isProductsLoading;
  bool get isLandsLoading => _isLandsLoading;

  String? get productsError => _productsError;
  String? get landsError => _landsError;

  bool get hasFreshProductsCache =>
      _productsLastUpdated != null &&
      DateTime.now().difference(_productsLastUpdated!) < _cacheTtl;

  bool get hasFreshLandsCache =>
      _landsLastUpdated != null &&
      DateTime.now().difference(_landsLastUpdated!) < _cacheTtl;

  // Fetch smart product recommendations
  Future<void> fetchProductRecommendations(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (_isProductsLoading) return;
    if (!forceRefresh &&
        _productRecommendations.isNotEmpty &&
        hasFreshProductsCache) {
      return;
    }

    _isProductsLoading = true;
    if (forceRefresh || _productRecommendations.isEmpty) {
      _productsError = null;
    }
    notifyListeners();

    try {
      print('📦 Fetching smart product recommendations...');
      final recommendations = await _aiService.getSmartProductRecommendations(
        userId,
      );
      _productRecommendations = recommendations;
      _productsLastUpdated = DateTime.now();
      _productsError = null;
      print('✅ Got ${recommendations.length} product recommendations');
    } catch (e) {
      _productsError = e.toString().replaceAll('Exception: ', '');
      print('❌ Error: $_productsError');
    }

    _isProductsLoading = false;
    notifyListeners();
  }

  // Fetch smart land recommendations
  Future<void> fetchLandRecommendations(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (_isLandsLoading) return;
    if (!forceRefresh &&
        _landRecommendations.isNotEmpty &&
        hasFreshLandsCache) {
      return;
    }

    _isLandsLoading = true;
    if (forceRefresh || _landRecommendations.isEmpty) {
      _landsError = null;
    }
    notifyListeners();

    try {
      print('🌾 Fetching smart land recommendations...');
      final recommendations = await _aiService.getSmartLandRecommendations(
        userId,
      );
      _landRecommendations = recommendations;
      _landsLastUpdated = DateTime.now();
      _landsError = null;
      print('✅ Got ${recommendations.length} land recommendations');
    } catch (e) {
      _landsError = e.toString().replaceAll('Exception: ', '');
      print('❌ Error: $_landsError');
    }

    _isLandsLoading = false;
    notifyListeners();
  }

  // Clear recommendations
  void clearProductRecommendations() {
    _productRecommendations = [];
    _productsError = null;
    _productsLastUpdated = null;
    notifyListeners();
  }

  void clearLandRecommendations() {
    _landRecommendations = [];
    _landsError = null;
    _landsLastUpdated = null;
    notifyListeners();
  }
}
