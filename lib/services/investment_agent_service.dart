import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class InvestmentAgentService {
  /// Gets investment recommendations from the backend AI agent
  Future<String?> getRecommendations(String preferences) async {
    try {
      final response = await AuthService.authenticatedRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/api/v1/investment-agent/recommend'),
        body: jsonEncode({'preferences': preferences}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return data['recommendation'];
      }
      return null;
    } catch (e) {
      print('Error getting investment recommendations: $e');
      throw Exception('Failed to get investment recommendations: $e');
    }
  }
}
