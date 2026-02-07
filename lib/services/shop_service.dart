import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/shop_item_model.dart';
import 'auth_service.dart';

enum AssetCategory {
  animal,
  vegetation,
  tree,
  structure,
  machine,
}

class ShopService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.1.21:3001',
  );

  static Future<List<ShopItemType>> getAssetTypes(AssetCategory category) async {
    final categoryStr = category.name;
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/assets/$categoryStr/types'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        return data.map((item) => ShopItemType.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('getAssetTypes Error ($categoryStr): $e');
      return [];
    }
  }

  static Future<ShopItemType?> getAssetTypeWithVariants(AssetCategory category, String id) async {
    final categoryStr = category.name;
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/assets/$categoryStr/types/$id/variants'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return ShopItemType.fromJson(body['data']);
      }
      return null;
    } catch (e) {
      print('getAssetTypeWithVariants Error ($categoryStr): $e');
      return null;
    }
  }
}
