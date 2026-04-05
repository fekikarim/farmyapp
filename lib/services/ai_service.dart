import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class AIService {
  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1';
  final String? _apiKey = dotenv.env['GROQ_API_KEY'];

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
              'content': 'You are a helpful AI assistant for farmers. Provide practical, accurate advice about farming, agriculture, crop management, livestock care, and sustainable farming practices. Keep responses concise and actionable.'
            },
            {
              'role': 'user',
              'content': message
            }
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
  Future<List<Map<String, dynamic>>> getSmartProductRecommendations(String userId) async {
    try {
      print('🔍 Fetching smart product recommendations...');
      
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('${AuthService.baseUrl}/api/v1/matching/recommendations/products?limit=6'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendations = List<Map<String, dynamic>>.from(data['data'] ?? []);
        print('✅ Got ${recommendations.length} product recommendations from AI');
        return recommendations;
      } else {
        print('❌ Product recommendations API error: ${response.statusCode}');
        // Parse error message from response
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Failed to load product recommendations';
          throw Exception(errorMessage);
        } catch (parseError) {
          if (parseError is Exception) rethrow;
          throw Exception('Product recommendations API error: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Product recommendations error: $e');
      rethrow;
    }
  }

  /// Get smart land recommendations for an investor
  Future<List<Map<String, dynamic>>> getSmartLandRecommendations(String userId) async {
    try {
      print('🔍 Fetching smart land recommendations...');
      
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('${AuthService.baseUrl}/api/v1/matching/recommendations/lands?limit=6'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final recommendations = List<Map<String, dynamic>>.from(data['data'] ?? []);
        print('✅ Got ${recommendations.length} land recommendations from AI');
        return recommendations;
      } else {
        print('❌ Land recommendations API error: ${response.statusCode}');
        print('📋 Response body: ${response.body}');
        // Parse error message from response
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Failed to load land recommendations';
          throw Exception(errorMessage);
        } catch (parseError) {
          if (parseError is Exception) rethrow;
          throw Exception('Land recommendations API error: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Land recommendations error: $e');
      rethrow;
    }
  }

  /// Get smart matches (legacy method)
  Future<List<Map<String, dynamic>>> getSmartMatches(String userId, String userRole) async {
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

  Future<bool> sendMatchRequest(String fromUserId, String toUserId, String matchType) async {
    // Send match request to backend
    try {
      print('📤 Sending match request from $fromUserId to $toUserId ($matchType)');
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
      print('${success ? '✅' : '❌'} Match request status: ${response.statusCode}');
      return success;
    } catch (e) {
      print('❌ Match request error: $e');
      return false;
    }
  }
}