import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../models/shop_item_model.dart';
import 'auth_service.dart';

enum AssetCategory { animal, vegetation, tree, structure, machine }

class ShopService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  static Future<List<ShopItemType>> getAssetTypes(
    AssetCategory category,
  ) async {
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

  static Future<ShopItemType?> getAssetTypeWithVariants(
    AssetCategory category,
    String id,
  ) async {
    final categoryStr = category.name;
    try {
      // 1. Fetch the type details
      final typeResponse = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/assets/$categoryStr/types/$id'),
      );

      if (typeResponse.statusCode != 200) return null;
      final Map<String, dynamic> typeBody = jsonDecode(typeResponse.body);

      final typeData = typeBody['data'];
      if (typeData == null) return null;
      final shopItemType = ShopItemType.fromJson(typeData);

      // 2. Fetch variants using the working endpoint the user provided
      final variantsResponse = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/assets/$categoryStr/variants?typeId=$id'),
      );

      print('Variants API Status: ${variantsResponse.statusCode}');
      List<ShopItemVariant> variants = [];
      if (variantsResponse.statusCode == 200) {
        final Map<String, dynamic> vBody = jsonDecode(variantsResponse.body);
        final List vData = vBody['data'] ?? [];
        variants = vData.map((v) => ShopItemVariant.fromJson(v)).toList();
        print('Loaded ${variants.length} variants for $id');
      }

      // Return combined result
      return ShopItemType(
        id: shopItemType.id,
        name: shopItemType.name,
        description: shopItemType.description,
        iconUrl: shopItemType.iconUrl,
        isActive: shopItemType.isActive,
        variants: variants,
      );
    } catch (e) {
      print('getAssetTypeWithVariants Error ($categoryStr): $e');
      return null;
    }
  }

  static Future<bool> buyItem({
    required String landId,
    required String variantId,
    required AssetCategory category,
    String? paymentMethodId,
    int positionX = 0,
    int positionY = 0,
  }) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/item-requests'),
        body: jsonEncode({
          'land_id': landId,
          'variant_id': variantId,
          'asset_category': category.name,
          'position_x': positionX,
          'position_y': positionY,
          if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('buyItem Error: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getIncomingItemRequests() async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/item-requests/farmer/incoming'),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('getIncomingItemRequests Error: $e');
      return [];
    }
  }

  static Future<String?> approveItemRequest(
    String requestId, {
    XFile? proofImage,
  }) async {
    try {
      if (proofImage == null) {
        // Fallback for non-placement approvals (e.g. buying or if image is optional on backend)
        final response = await AuthService.authenticatedRequest(
          'POST',
          Uri.parse('$_baseUrl/api/v1/item-requests/$requestId/approve'),
        );
        if (response.statusCode == 200) return null;
        final body = jsonDecode(response.body);
        return body['message'] ??
            'Failed to approve request (Status: ${response.statusCode})';
      }

      // Handle Multipart request for placement with image
      final token = await AuthService.getAccessToken();
      final uri = Uri.parse(
        '$_baseUrl/api/v1/item-requests/$requestId/approve',
      );
      final request = http.MultipartRequest('POST', uri);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final bytes = await proofImage.readAsBytes();
      final mimeType = lookupMimeType(proofImage.name) ?? 'image/jpeg';
      request.files.add(
        http.MultipartFile.fromBytes(
          'proof_image',
          bytes,
          filename: proofImage.name,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return null;
      }
      final body = jsonDecode(response.body);
      print(
        'approveItemRequest Failed: ${response.statusCode} - ${response.body}',
      );
      return body['message'] ??
          'Failed to approve request (Status: ${response.statusCode})';
    } catch (e) {
      print('approveItemRequest Error: $e');
      return 'Network error: $e';
    }
  }

  static Future<bool> rejectItemRequest(String requestId, String reason) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/item-requests/$requestId/reject'),
        body: jsonEncode({'reason': reason}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('rejectItemRequest Error: $e');
      return false;
    }
  }

  static Future<List<dynamic>> getInvestorInventory({String? landId}) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/api/v1/item-requests/investor/inventory',
      ).replace(queryParameters: landId != null ? {'landId': landId} : null);

      final response = await AuthService.authenticatedRequest('GET', uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('getInvestorInventory Error: $e');
      return [];
    }
  }

  static Future<bool> placeItem({
    required String requestId,
    required int x,
    required int y,
    int rotation = 0,
  }) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/item-requests/$requestId/place'),
        body: jsonEncode({
          'position_x': x,
          'position_y': y,
          'rotation': rotation,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      print('placeItem Failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('placeItem Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getAssetFootprint({
    required String category,
    required String variantId,
  }) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse(
          '$_baseUrl/api/v1/land-grid/assets/$category/variants/$variantId/footprint',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      print(
        'getAssetFootprint Failed: ${response.statusCode} - ${response.body}',
      );
      return null;
    } catch (e) {
      print('getAssetFootprint Error: $e');
      return null;
    }
  }
}
