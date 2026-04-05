import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class AIService {
  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1';
  final String? _apiKey = dotenv.env['GROQ_API_KEY'];

  bool _isNotFoundResponse(http.Response response) {
    if (response.statusCode != 404) return false;
    try {
      final body = jsonDecode(response.body);
      final message = (body['message'] ?? '').toString().toLowerCase();
      return message.contains('resource not found') ||
          message.contains('not found');
    } catch (_) {
      return true;
    }
  }

  bool _isLocationError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('location not set') || lower.contains('location');
  }

  String _extractErrorMessage(http.Response response, String fallbackMessage) {
    try {
      final body = jsonDecode(response.body);
      return (body['message'] ?? fallbackMessage).toString();
    } catch (_) {
      return fallbackMessage;
    }
  }

  String _toAbsoluteImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    if (imagePath.startsWith('/')) {
      return '${AuthService.baseUrl}$imagePath';
    }
    return '${AuthService.baseUrl}/$imagePath';
  }

  List<Map<String, dynamic>> _extractListData(dynamic rawData) {
    if (rawData is List) {
      return rawData
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const [];
  }

  List<Map<String, dynamic>> _normalizeProductRecommendations(
    List<Map<String, dynamic>> items,
  ) {
    return items.map((item) {
      final rawImages = (item['images'] is List)
          ? (item['images'] as List)
                .where((image) => image != null)
                .map((image) => image.toString())
                .toList()
          : <String>[];
      final normalizedImages = rawImages.map(_toAbsoluteImageUrl).toList();

      return {
        ...item,
        'images': normalizedImages,
        'matchScore':
            (item['matchScore'] as num?)?.toInt() ??
            (item['score'] as num?)?.toInt() ??
            72,
        'aiReasoning':
            item['aiReasoning'] ??
            item['reasoning'] ??
            'Recommended from live marketplace data',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _normalizeLandRecommendations(
    List<Map<String, dynamic>> items,
  ) {
    return items.map((item) {
      final widthM = (item['widthM'] ?? item['width_m'] ?? 10) as num;
      final heightM = (item['heightM'] ?? item['height_m'] ?? 10) as num;

      return {
        ...item,
        'widthM': widthM.toDouble(),
        'heightM': heightM.toDouble(),
        'gridWidth': item['gridWidth'] ?? ((widthM / 1) * 10).round(),
        'gridHeight': item['gridHeight'] ?? ((heightM / 1) * 10).round(),
        'matchScore':
            (item['matchScore'] as num?)?.toInt() ??
            (item['score'] as num?)?.toInt() ??
            70,
        'aiReasoning':
            item['aiReasoning'] ??
            item['reasoning'] ??
            'Suggested based on current land data',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchFallbackProducts({
    int limit = 6,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('${AuthService.baseUrl}/api/v1/products?status=available'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          'Failed to load fallback marketplace products',
        ),
      );
    }

    final data = jsonDecode(response.body);
    final products = _extractListData(data['data']);
    final normalized = _normalizeProductRecommendations(
      products,
    ).take(limit).toList();

    return normalized;
  }

  Future<List<Map<String, dynamic>>> _fetchFallbackLands({
    int limit = 6,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('${AuthService.baseUrl}/api/v1/lands'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to load fallback lands data'),
      );
    }

    final data = jsonDecode(response.body);
    final lands = _extractListData(data['data']);
    final normalized = _normalizeLandRecommendations(
      lands,
    ).take(limit).toList();

    return normalized;
  }

  Future<String> getChatbotResponse(String message, String userRole) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      return 'AI service is not configured. Please check your Groq API key.';
    }

    try {
      final response = await http.post(
        Uri.parse('$_groqBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful AI assistant for farmers. Provide practical, accurate advice about farming, agriculture, crop management, livestock care, and sustainable farming practices. Keep responses concise and actionable.',
            },
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        print('❌ Groq API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return 'API Error (${response.statusCode}): Check your Groq API key and try again.';
      }
    } catch (e) {
      print('❌ Groq Error: $e');
      return 'Error: $e';
    }
  }

  /// Get smart product recommendations for a customer
  Future<List<Map<String, dynamic>>> getSmartProductRecommendations(
    String userId,
  ) async {
    try {
      print('🔍 Fetching smart product recommendations...');

      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse(
          '${AuthService.baseUrl}/api/v1/matching/recommendations/products?limit=6',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendations = _normalizeProductRecommendations(
          _extractListData(data['data']),
        );
        print(
          '✅ Got ${recommendations.length} product recommendations from AI',
        );
        return recommendations;
      } else {
        print('❌ Product recommendations API error: ${response.statusCode}');

        // Production fallback for environments where AI matching routes are not deployed yet.
        if (_isNotFoundResponse(response)) {
          print(
            '↩️ AI recommendation endpoint not found, falling back to marketplace products.',
          );
          return await _fetchFallbackProducts(limit: 6);
        }

        final errorMessage = _extractErrorMessage(
          response,
          'Failed to load product recommendations',
        );

        if (_isLocationError(errorMessage)) {
          throw Exception(errorMessage);
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Product recommendations error: $e');
      rethrow;
    }
  }

  /// Get smart land recommendations for an investor
  Future<List<Map<String, dynamic>>> getSmartLandRecommendations(
    String userId,
  ) async {
    try {
      print('🔍 Fetching smart land recommendations...');

      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse(
          '${AuthService.baseUrl}/api/v1/matching/recommendations/lands?limit=6',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendations = _normalizeLandRecommendations(
          _extractListData(data['data']),
        );
        print('✅ Got ${recommendations.length} land recommendations from AI');
        return recommendations;
      } else {
        print('❌ Land recommendations API error: ${response.statusCode}');
        print('📋 Response body: ${response.body}');

        if (_isNotFoundResponse(response)) {
          print(
            '↩️ Land AI endpoint not found, falling back to lands inventory.',
          );
          return await _fetchFallbackLands(limit: 6);
        }

        final errorMessage = _extractErrorMessage(
          response,
          'Failed to load land recommendations',
        );

        if (_isLocationError(errorMessage)) {
          throw Exception(errorMessage);
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Land recommendations error: $e');
      rethrow;
    }
  }

  /// Get smart matches (legacy method)
  Future<List<Map<String, dynamic>>> getSmartMatches(
    String userId,
    String userRole,
  ) async {
    try {
      print('🔍 AI Service: getSmartMatches called for $userRole');

      if (userRole.toLowerCase() == 'customer') {
        return getSmartProductRecommendations(userId);
      } else if (userRole.toLowerCase() == 'investor') {
        return getSmartLandRecommendations(userId);
      }

      return [];
    } catch (e) {
      print('❌ Smart Matching API Error: $e');
      return [];
    }
  }

  Future<bool> sendMatchRequest(
    String fromUserId,
    String toUserId,
    String matchType,
  ) async {
    // Send match request to backend
    try {
      print(
        '📤 Sending match request from $fromUserId to $toUserId ($matchType)',
      );
      final response = await http.post(
        Uri.parse('${dotenv.env['API_BASE_URL']}/api/v1/matching/request'),
        headers: {
          'Content-Type': 'application/json',
          // Add auth token in production
        },
        body: jsonEncode({
          'fromUserId': fromUserId,
          'toUserId': toUserId,
          'matchType': matchType,
        }),
      );

      final success = response.statusCode == 201 || response.statusCode == 200;
      print(
        '${success ? '✅' : '❌'} Match request status: ${response.statusCode}',
      );
      return success;
    } catch (e) {
      print('❌ Match request error: $e');
      return false;
    }
  }
}
