import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class SmartRecommendationsProvider with ChangeNotifier {
  final AIService _aiService = AIService();

  List<Map<String, dynamic>> _productRecommendations = [];
  List<Map<String, dynamic>> _landRecommendations = [];
  
  bool _isProductsLoading = false;
  bool _isLandsLoading = false;
  
  String? _productsError;
  String? _landsError;

  // Getters
  List<Map<String, dynamic>> get productRecommendations => _productRecommendations;
  List<Map<String, dynamic>> get landRecommendations => _landRecommendations;
  
  bool get isProductsLoading => _isProductsLoading;
  bool get isLandsLoading => _isLandsLoading;
  
  String? get productsError => _productsError;
  String? get landsError => _landsError;

  // Fetch smart product recommendations
  Future<void> fetchProductRecommendations(String userId) async {
    _isProductsLoading = true;
    _productsError = null;
    notifyListeners();

    try {
      print('📦 Fetching smart product recommendations...');
      final recommendations = await _aiService.getSmartProductRecommendations(userId);
      _productRecommendations = recommendations;
      print('✅ Got ${recommendations.length} product recommendations');
    } catch (e) {
      _productsError = e.toString().replaceAll('Exception: ', '');
      print('❌ Error: $_productsError');
    }

    _isProductsLoading = false;
    notifyListeners();
  }

  // Fetch smart land recommendations
  Future<void> fetchLandRecommendations(String userId) async {
    _isLandsLoading = true;
    _landsError = null;
    notifyListeners();

    try {
      print('🌾 Fetching smart land recommendations...');
      final recommendations = await _aiService.getSmartLandRecommendations(userId);
      _landRecommendations = recommendations;
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
    notifyListeners();
  }

  void clearLandRecommendations() {
    _landRecommendations = [];
    _landsError = null;
    notifyListeners();
  }
}
