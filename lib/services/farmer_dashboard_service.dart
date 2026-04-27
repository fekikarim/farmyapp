import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/farmer_dashboard_model.dart';
import 'auth_service.dart';

class DashboardServiceException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const DashboardServiceException(
    this.code,
    this.message, {
    this.statusCode,
  });

  @override
  String toString() => message;
}

class FarmerDashboardService {
  static const Duration _requestTimeout = Duration(seconds: 15);
  static String get _baseUrl {
    // For development, use localhost
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001';
    } else if (Platform.isIOS) {
      return 'http://localhost:3001';
    }
    return 'http://localhost:3001';
  }

  static String get _apiUrl => '$_baseUrl/api/v1';

  static Future<Map<String, String>> _getHeaders({String? localeCode}) async {
    final token = await AuthService.getAccessToken();
    final language = (localeCode == null || localeCode.isEmpty) ? 'en' : localeCode;

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept-Language': language,
    };
  }

  /// Get full dashboard data
  static Future<FarmerDashboardData> getDashboardData({String? localeCode}) async {
    try {
      final headers = await _getHeaders(localeCode: localeCode);
      final response = await http
          .get(
            Uri.parse('$_apiUrl/farmer/dashboard'),
            headers: headers,
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return FarmerDashboardData.fromJson(jsonData);
      }

      throw _buildHttpError(response);
    } on DashboardServiceException {
      rethrow;
    } on TimeoutException {
      throw const DashboardServiceException(
        'timeout',
        'Connection timed out. Please try again.',
      );
    } on SocketException {
      throw const DashboardServiceException(
        'network',
        'No internet connection. Please check your network.',
      );
    } on FormatException {
      throw const DashboardServiceException(
        'invalid_response',
        'Invalid response format from server.',
      );
    } catch (e) {
      throw DashboardServiceException(
        'unknown',
        'Failed to load dashboard: $e',
      );
    }
  }

  static String _extractErrorMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Best effort parsing only.
    }
    return fallback;
  }

  static DashboardServiceException _buildHttpError(http.Response response) {
    final status = response.statusCode;
    if (status == 401) {
      return DashboardServiceException(
        'unauthorized',
        _extractErrorMessage(response, 'Unauthorized. Please log in again.'),
        statusCode: status,
      );
    }
    if (status == 403) {
      return DashboardServiceException(
        'forbidden',
        _extractErrorMessage(response, 'Access denied for this operation.'),
        statusCode: status,
      );
    }
    if (status == 404) {
      return DashboardServiceException(
        'not_found',
        _extractErrorMessage(response, 'Requested resource was not found.'),
        statusCode: status,
      );
    }
    if (status >= 500) {
      return DashboardServiceException(
        'server',
        _extractErrorMessage(response, 'Server error. Please try again.'),
        statusCode: status,
      );
    }

    return DashboardServiceException(
      'http',
      _extractErrorMessage(response, 'Request failed with status $status.'),
      statusCode: status,
    );
  }

  /// Force refresh dashboard data
  static Future<FarmerDashboardData> refreshDashboard({String? localeCode}) async {
    try {
      final headers = await _getHeaders(localeCode: localeCode);
      final response = await http
          .post(
            Uri.parse('$_apiUrl/farmer/dashboard/refresh'),
            headers: headers,
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return FarmerDashboardData.fromJson(jsonData);
      }

      // Backward compatibility with deployments where refresh endpoint is not present.
      if (response.statusCode == 404 || response.statusCode == 405) {
        return getDashboardData(localeCode: localeCode);
      }

      throw _buildHttpError(response);
    } on DashboardServiceException {
      rethrow;
    } on TimeoutException {
      throw const DashboardServiceException(
        'timeout',
        'Connection timed out. Please try again.',
      );
    } on SocketException {
      throw const DashboardServiceException(
        'network',
        'No internet connection. Please check your network.',
      );
    } catch (e) {
      throw DashboardServiceException(
        'unknown',
        'Failed to refresh dashboard: $e',
      );
    }
  }

  /// Repair a placed item (restore durability to 100%)
  static Future<Map<String, dynamic>> repairPlacedItem(
    String itemId, {
    String? localeCode,
  }) async {
    try {
      final headers = await _getHeaders(localeCode: localeCode);
      final response = await http
          .post(
            Uri.parse('$_apiUrl/farmer/placed-items/$itemId/repair'),
            headers: headers,
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw _buildHttpError(response);
    } on DashboardServiceException {
      rethrow;
    } on TimeoutException {
      throw const DashboardServiceException(
        'timeout',
        'Connection timed out. Please try again.',
      );
    } on SocketException {
      throw const DashboardServiceException(
        'network',
        'No internet connection. Please check your network.',
      );
    } catch (e) {
      throw DashboardServiceException(
        'unknown',
        'Failed to repair item: $e',
      );
    }
  }

  /// Quick action: Get pending item requests count
  static Future<int> getPendingItemRequestsCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_apiUrl/item-requests/pending/count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Quick action: Get harvest-ready items count
  static Future<int> getHarvestReadyCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_apiUrl/placed-items/harvest-ready/count'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
