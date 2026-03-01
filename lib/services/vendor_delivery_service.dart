import 'dart:convert';
import '../models/vendor_delivery_model.dart';
import '../models/delivery_model.dart';
import 'auth_service.dart';

class VendorDeliveryService {
  static final String _base = '${AuthService.baseUrl}/api/v1/vendor/deliveries';

  /// Fetch paginated vendor deliveries with filters
  static Future<({List<VendorDeliveryItem> data, PaginationMeta pagination})>
  getDeliveries({
    DeliveryStatus? status,
    int page = 1,
    int limit = 20,
    String sortBy = 'date',
    String sortOrder = 'DESC',
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    if (status != null) queryParams['status'] = status.apiValue;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final uri = Uri.parse(_base).replace(queryParameters: queryParams);
    final response = await AuthService.authenticatedRequest('GET', uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final items = (body['data'] as List)
          .map((e) => VendorDeliveryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = PaginationMeta.fromJson(
        body['pagination'] as Map<String, dynamic>,
      );
      return (data: items, pagination: pagination);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to fetch vendor deliveries');
    }
  }

  /// Fetch vendor delivery stats
  static Future<VendorDeliveryStats> getStats() async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_base/stats'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return VendorDeliveryStats.fromJson(data as Map<String, dynamic>);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to fetch delivery stats');
    }
  }

  /// Fetch single vendor delivery detail
  static Future<VendorDeliveryDetail> getDetail(String deliveryId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_base/$deliveryId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return VendorDeliveryDetail.fromJson(data as Map<String, dynamic>);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to fetch delivery detail');
    }
  }

  /// Update delivery status
  static Future<VendorDeliveryDetail> updateStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? note,
    double? latitude,
    double? longitude,
    String? cancellationReason,
  }) async {
    final bodyMap = <String, dynamic>{'status': status.apiValue};
    if (note != null) bodyMap['note'] = note;
    if (latitude != null) bodyMap['latitude'] = latitude;
    if (longitude != null) bodyMap['longitude'] = longitude;
    if (cancellationReason != null) {
      bodyMap['cancellation_reason'] = cancellationReason;
    }

    final response = await AuthService.authenticatedRequest(
      'PATCH',
      Uri.parse('$_base/$deliveryId/status'),
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return VendorDeliveryDetail.fromJson(data as Map<String, dynamic>);
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to update delivery status');
    }
  }
}
