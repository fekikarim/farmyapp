import 'dart:convert';
import '../models/delivery_model.dart';
import 'auth_service.dart';

class DeliveryService {
  static final String _base = '${AuthService.baseUrl}/api/v1/deliveries';

  /// Fetch delivery tracking by order (purchase) ID
  static Future<DeliveryTracking> getByOrderId(String orderId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_base/order/$orderId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return DeliveryTracking.fromJson(data);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to fetch delivery');
    }
  }

  /// Fetch delivery tracking by delivery ID
  static Future<DeliveryTracking> getById(String deliveryId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_base/$deliveryId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return DeliveryTracking.fromJson(data);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to fetch delivery');
    }
  }

  /// List all deliveries for the authenticated user
  static Future<List<DeliveryTracking>> getMyDeliveries({
    String role = 'all',
  }) async {
    final uri = Uri.parse('$_base/me').replace(queryParameters: {'role': role});

    final response = await AuthService.authenticatedRequest('GET', uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data
          .map((e) => DeliveryTracking.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to fetch deliveries');
    }
  }
}
