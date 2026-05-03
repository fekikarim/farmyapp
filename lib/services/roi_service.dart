import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/roi_model.dart';
import 'auth_service.dart';

class RoiService {
  Future<RoiDashboardData> getRoiDashboard() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/api/v1/investor/roi/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RoiDashboardData.fromJson(data);
      } else {
        throw Exception('Failed to load ROI dashboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ROI data: $e');
    }
  }
}
