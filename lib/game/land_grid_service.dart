import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/auth_service.dart';

class LandGridService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  static Future<Map<String, dynamic>> fetchLandGrid(String landId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/land-grid/$landId/grid'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return body['data'];
    }

    throw Exception('Failed to load land grid');
  }
}
