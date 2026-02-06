import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/land_model.dart';

class LandService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.1.21:3001',
  );

  static Future<List<Land>> getAllLands() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/v1/lands'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        return data.map((item) => Land.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('GetAllLands Error: $e');
      return [];
    }
  }

  static Future<Land?> getLandById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/v1/lands/$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return Land.fromJson(body['data']);
      }
      return null;
    } catch (e) {
      print('GetLandById Error: $e');
      return null;
    }
  }

  static Future<List<Land>> getMyLands() async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/lands/user/my-lands'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        return data.map((item) => Land.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('GetMyLands Error: $e');
      return [];
    }
  }

  static Future<Land?> createLand(Map<String, dynamic> data) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/lands'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Land.fromJson(body['data']);
    }

    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to create land');
  }

  static Future<Land?> updateLand(String id, Map<String, dynamic> data) async {
    final response = await AuthService.authenticatedRequest(
      'PUT',
      Uri.parse('$_baseUrl/api/v1/lands/$id'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return Land.fromJson(body['data']);
    }

    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to update land');
  }

  static Future<bool> deleteLand(String id) async {
    final response = await AuthService.authenticatedRequest(
      'DELETE',
      Uri.parse('$_baseUrl/api/v1/lands/$id'),
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      return true;
    }

    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to delete land');
  }

  static Future<Map<String, dynamic>?> getLandGrid(String id) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/land-grid/$id/grid'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('GetLandGrid Error: $e');
      return null;
    }
  }
}
