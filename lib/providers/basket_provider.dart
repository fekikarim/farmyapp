import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/basket_item_model.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';

class BasketProvider with ChangeNotifier {
  static const String _storageKey = 'basket_items';
  static const double taxRate = 0.19; // 19% TVA Tunisia

  List<BasketItem> _items = [];
  bool _isCheckingOut = false;
  String? _checkoutError;

  // ─── Getters ───────────────────────────────────────────────

  List<BasketItem> get items => List.unmodifiable(_items);
  bool get isCheckingOut => _isCheckingOut;
  String? get checkoutError => _checkoutError;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalTND =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get taxTND => subtotalTND * taxRate;
  double get totalTND => subtotalTND + taxTND;

  // ─── Initialization ────────────────────────────────────────

  BasketProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _items = decoded
            .map((e) => BasketItem.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('BasketProvider: Error loading from storage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('BasketProvider: Error saving to storage: $e');
    }
  }

  // ─── Basket Operations ─────────────────────────────────────

  /// Add product to basket. If already present, increments quantity.
  /// Returns true if added, false if stock limit reached.
  bool addToBasket(Product product, {int quantity = 1}) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Product already in basket — increment quantity
      final existing = _items[existingIndex];
      final newQty = existing.quantity + quantity;
      if (newQty > existing.maxQuantity) return false;

      _items[existingIndex] = existing.copyWith(quantity: newQty);
    } else {
      // New product
      final maxQty = product.quantity.toInt();
      if (maxQty <= 0) return false; // Out of stock
      final clampedQty = quantity.clamp(1, maxQty);

      _items.add(BasketItem(product: product, quantity: clampedQty));
    }

    notifyListeners();
    _saveToStorage();
    return true;
  }

  /// Remove a product from the basket entirely.
  void removeFromBasket(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    _saveToStorage();
  }

  /// Update the quantity for a basket item. Removes if qty <= 0.
  bool updateQuantity(String productId, int newQuantity) {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return false;

    if (newQuantity <= 0) {
      _items.removeAt(index);
    } else {
      final item = _items[index];
      if (newQuantity > item.maxQuantity) return false;
      _items[index] = item.copyWith(quantity: newQuantity);
    }

    notifyListeners();
    _saveToStorage();
    return true;
  }

  /// Increment quantity by 1
  bool incrementQuantity(String productId) {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return false;
    return updateQuantity(productId, _items[index].quantity + 1);
  }

  /// Decrement quantity by 1 (removes if hits 0)
  bool decrementQuantity(String productId) {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return false;
    return updateQuantity(productId, _items[index].quantity - 1);
  }

  /// Check if a product is already in the basket
  bool isInBasket(String productId) =>
      _items.any((item) => item.product.id == productId);

  /// Get quantity of a product in basket (0 if not present)
  int getQuantityInBasket(String productId) {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  /// Clear the entire basket
  void clearBasket() {
    _items.clear();
    notifyListeners();
    _saveToStorage();
  }

  // ─── Checkout ──────────────────────────────────────────────

  /// Process checkout: buys each item via the backend API.
  /// Returns a map of results per product.
  Future<Map<String, dynamic>> checkout() async {
    _isCheckingOut = true;
    _checkoutError = null;
    notifyListeners();

    final results = <String, dynamic>{};
    final failedItems = <BasketItem>[];

    for (final item in List.of(_items)) {
      try {
        final response = await AuthService.authenticatedRequest(
          'POST',
          Uri.parse(
              '${AuthService.baseUrl}/api/v1/products/${item.product.id}/buy'),
          body: jsonEncode({'quantity': item.quantity}),
        );

        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          results[item.product.id] = {
            'success': true,
            'message': data['message'] ?? 'Purchase successful',
          };
        } else {
          results[item.product.id] = {
            'success': false,
            'message': data['message'] ?? 'Purchase failed',
          };
          failedItems.add(item);
        }
      } catch (e) {
        results[item.product.id] = {
          'success': false,
          'message': 'Network error: $e',
        };
        failedItems.add(item);
      }
    }

    // Keep only failed items in basket
    _items = failedItems;
    _isCheckingOut = false;

    if (failedItems.isNotEmpty) {
      _checkoutError =
          '${failedItems.length} item(s) could not be purchased';
    }

    notifyListeners();
    _saveToStorage();

    final successCount =
        results.values.where((r) => r['success'] == true).length;
    return {
      'totalItems': results.length,
      'successCount': successCount,
      'failCount': failedItems.length,
      'details': results,
    };
  }
}
