import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/product_model.dart';
import '../models/product_type_model.dart';
import '../services/auth_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _myProducts = [];
  List<ProductType> _productTypes = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  List<Product> get myProducts => _myProducts;
  List<ProductType> get productTypes => _productTypes;
  bool get isLoading => _isLoading;

  Future<void> fetchProductTypes() async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('${AuthService.baseUrl}/api/v1/product-types'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        _productTypes = data.map((e) => ProductType.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching product types: $e');
    }
  }

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

  Future<bool> addProduct(
    Map<String, dynamic> productData, {
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final uri = Uri.parse('${AuthService.baseUrl}/api/v1/products');

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      productData.forEach((key, value) {
        if (key != 'images') {
          // Skip images array as we handle file separately
          request.fields[key] = value.toString();
        }
      });

      // Add file
      if (imageFile != null) {
        final mimeTypeData = lookupMimeType(
          imageFile.path,
          headerBytes: [0xFF, 0xD8],
        )?.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // Field name matches backend upload.array('images')
            imageFile.path,
            contentType: mimeTypeData != null
                ? MediaType(mimeTypeData[0], mimeTypeData[1])
                : MediaType('image', 'jpeg'),
          ),
        );
      } else if (productData['images'] != null &&
          (productData['images'] as List).isNotEmpty) {
        // Fallback for URL string if entered manually
        request.fields['image'] = (productData['images'] as List).first;
      }

      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        final newProduct = Product.fromJson(data);
        _myProducts.add(newProduct);
        notifyListeners();
        return true;
      } else {
        print('Failed to add product: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Add Product Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(
    String id,
    Map<String, dynamic> productData, {
    File? imageFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final uri = Uri.parse('${AuthService.baseUrl}/api/v1/products/$id');

      var request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      productData.forEach((key, value) {
        if (key != 'images') {
          request.fields[key] = value.toString();
        }
      });

      // Add file
      if (imageFile != null) {
        final mimeTypeData = lookupMimeType(
          imageFile.path,
          headerBytes: [0xFF, 0xD8],
        )?.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            imageFile.path,
            contentType: mimeTypeData != null
                ? MediaType(mimeTypeData[0], mimeTypeData[1])
                : MediaType('image', 'jpeg'),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody)['data'];
        final updatedProduct = Product.fromJson(data);
        final index = _myProducts.indexWhere((p) => p.id == id);
        if (index != -1) {
          _myProducts[index] = updatedProduct;
        }
        notifyListeners();
        return true;
      } else {
        print('Failed to update product: $responseBody');
        return false;
      }
    } catch (e) {
      print('Update Product Error: $e');
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
