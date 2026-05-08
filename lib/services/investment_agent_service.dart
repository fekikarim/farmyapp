import 'dart:convert';
import 'auth_service.dart';

class InvestmentAgentService {
  /// Gets investment recommendations/chat from the backend AI agent
  Future<Map<String, dynamic>?> getRecommendations(
    String preferences, {
    String? sessionId,
    Map<String, dynamic>? userContext,
  }) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/v1/investment-agent/recommend'),
        body: jsonEncode({
          'preferences': preferences,
          if (sessionId != null) 'sessionId': sessionId,
          if (userContext != null) 'userContext': userContext,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      print('Error getting investment recommendations: $e');
      throw Exception('Failed to get investment recommendations: $e');
    }
  }

  /// Gets all strategic sessions for the investor
  Future<List<dynamic>> getSessionHistory() async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('${AuthService.baseUrl}/api/v1/investment-agent/history'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return [];
    } catch (e) {
      print('Error getting investment history: $e');
      return [];
    }
  }

  /// Gets a specific session details
  Future<Map<String, dynamic>?> getSessionDetails(String sessionId) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse(
          '${AuthService.baseUrl}/api/v1/investment-agent/session/$sessionId',
        ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      print('Error getting session details: $e');
      return null;
    }
  }

  /// Deletes a strategic session
  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'DELETE',
        Uri.parse(
          '${AuthService.baseUrl}/api/v1/investment-agent/session/$sessionId',
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting session: $e');
      return false;
    }
  }
}
