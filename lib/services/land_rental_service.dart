import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import '../models/land_rental_model.dart';

class LandRentalService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  static Future<LandRental?> createRental(Map<String, dynamic> data) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/land-rentals'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return LandRental.fromJson(body['data']);
    }

    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to create rental');
  }

  static Future<List<LandRental>> getMyRentalsAsOwner() async {
    try {
      final response = await AuthService.authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/land-rentals/owner/my-rentals'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        return data.map((item) => LandRental.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('GetMyRentalsAsOwner Error: $e');
      return [];
    }
  }

  static Future<List<LandRental>> getMyRentalsAsInvestor({
    String? paymentStatus,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/land-rentals/investor/my-rentals')
          .replace(
            queryParameters: paymentStatus != null
                ? {'payment_status': paymentStatus}
                : null,
          );

      final response = await AuthService.authenticatedRequest('GET', uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        return data.map((item) => LandRental.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('GetMyRentalsAsInvestor Error: $e');
      return [];
    }
  }

  static Future<bool> updatePaymentStatus(String id, String status) async {
    final response = await AuthService.authenticatedRequest(
      'PATCH',
      Uri.parse('$_baseUrl/api/v1/land-rentals/$id/payment'),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      return true;
    }

    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to update payment');
  }
}
