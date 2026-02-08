import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _myProducts = []; // Products owned by the current user
  bool _isLoading = false;

  List<Product> get products => _products;
  List<Product> get myProducts => _myProducts;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts({
    String? ownerId,
    String? landId,
    String? productTypeId,
    String? status,
    String? search,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (ownerId != null) queryParams['ownerId'] = ownerId;
      if (landId != null) queryParams['landId'] = landId;
      if (productTypeId != null) queryParams['productTypeId'] = productTypeId;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '${AuthService.baseUrl}/api/v1/products',
      ).replace(queryParameters: queryParams);

      final response = await AuthService.authenticatedRequest('GET', uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        _products = data.map((e) => Product.fromJson(e)).toList();
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.getUser();
      if (user == null) return;

      final uri = Uri.parse(
        '${AuthService.baseUrl}/api/v1/products',
      ).replace(queryParameters: {'ownerId': user.id});

      final response = await AuthService.authenticatedRequest('GET', uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        _myProducts = data.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      print('Error fetching my products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/v1/products'),
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        await fetchMyProducts(); // Refresh list
        return true;
      } else {
        print('Failed to add product: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding product: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'DELETE',
        Uri.parse('${AuthService.baseUrl}/api/v1/products/$id'),
      );

      if (response.statusCode == 200) {
        _myProducts.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> buyProduct(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/v1/products/$id/buy'),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Optimistically remove from available list or refresh
        _products.removeWhere((p) => p.id == id);
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Purchase failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
