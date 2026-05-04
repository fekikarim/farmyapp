import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/roi_model.dart';
import '../providers/roi_provider.dart';
import 'auth_service.dart';

/// Enhanced ROI Service with security, timeout, and comprehensive error handling
class RoiService {
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRedirects = 5;
  
  /// Fetch ROI dashboard with enhanced security and error handling
  Future<RoiDashboardData> getRoiDashboard() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        throw RoiException(
          'Authentication token not found',
          type: RoiErrorType.authentication,
        );
      }

      // Validate token format (basic JWT structure check)
      if (!_isValidTokenFormat(token)) {
        throw RoiException(
          'Invalid authentication token',
          type: RoiErrorType.authentication,
        );
      }

      final uri = Uri.parse('${AuthService.baseUrl}/api/v1/investor/roi/dashboard');
      
      // Create request with timeout
      final request = http.Request('GET', uri);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-Client-Version': '1.0.0',
      });

      // Send request with timeout
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      // Handle redirects securely
      if (streamedResponse.isRedirect) {
        int redirectCount = 0;
        var currentResponse = response;
        
        while (currentResponse.statusCode >= 300 && 
               currentResponse.statusCode < 400 && 
               redirectCount < _maxRedirects) {
          final location = currentResponse.headers['location'];
          if (location == null) break;
          
          // Ensure redirect stays within our domain
          if (!_isSameDomain(location, uri)) {
            throw RoiException(
              'Invalid redirect detected',
              type: RoiErrorType.server,
            );
          }
          
          redirectCount++;
          final redirectUri = Uri.parse(location);
          final redirectRequest = http.Request('GET', redirectUri);
          redirectRequest.headers.addAll(request.headers);
          
          final redirectStreamed = await redirectRequest.send().timeout(_timeout);
          currentResponse = await http.Response.fromStream(redirectStreamed);
        }
      }

      // Handle response status codes
      switch (response.statusCode) {
        case 200:
          return _parseResponse(response.body);
        case 401:
          throw RoiException(
            'Session expired. Please sign in again.',
            type: RoiErrorType.authentication,
          );
        case 403:
          throw RoiException(
            'Access denied. You do not have permission to view this data.',
            type: RoiErrorType.authentication,
          );
        case 404:
          throw RoiException(
            'Dashboard data not found.',
            type: RoiErrorType.server,
          );
        case 429:
          throw RoiException(
            'Too many requests. Please wait a moment and try again.',
            type: RoiErrorType.server,
          );
        case 500:
        case 502:
        case 503:
        case 504:
          throw RoiException(
            'Server error. Please try again later.',
            type: RoiErrorType.server,
          );
        default:
          throw RoiException(
            'Unexpected error: ${response.statusCode}',
            type: RoiErrorType.unknown,
          );
      }
    } on TimeoutException {
      throw RoiException(
        'Request timed out. Please check your connection and try again.',
        type: RoiErrorType.timeout,
      );
    } on SocketException catch (e) {
      throw RoiException(
        'Network error: ${e.message}',
        type: RoiErrorType.network,
      );
    } on FormatException catch (e) {
      throw RoiException(
        'Invalid response format: $e',
        type: RoiErrorType.server,
      );
    } on RoiException {
      rethrow;
    } catch (e) {
      throw RoiException(
        'Unexpected error: $e',
        type: RoiErrorType.unknown,
      );
    }
  }
  
  /// Parse and validate response
  RoiDashboardData _parseResponse(String body) {
    try {
      final data = json.decode(body);
      
      // Validate required fields
      if (data is! Map<String, dynamic>) {
        throw RoiException(
          'Invalid response structure',
          type: RoiErrorType.server,
        );
      }
      
      final dashboardData = RoiDashboardData.fromJson(data);
      
      // Validate data integrity
      if (!dashboardData.overview.isValid) {
        throw RoiException(
          'Invalid financial data received',
          type: RoiErrorType.server,
        );
      }
      
      return dashboardData;
    } on RoiException {
      rethrow;
    } catch (e) {
      throw RoiException(
        'Failed to parse dashboard data: $e',
        type: RoiErrorType.server,
      );
    }
  }
  
  /// Validate JWT token format
  bool _isValidTokenFormat(String token) {
    // Basic JWT validation: should have 3 parts separated by dots
    final parts = token.split('.');
    if (parts.length != 3) return false;
    
    // Check that each part is valid base64url
    for (final part in parts) {
      if (part.isEmpty) return false;
      // Base64url only contains alphanumeric, -, and _
      if (!RegExp(r'^[A-Za-z0-9_-]*$').hasMatch(part)) return false;
    }
    
    return true;
  }
  
  /// Check if redirect stays within same domain
  bool _isSameDomain(String redirectUrl, Uri originalUri) {
    try {
      final redirectUri = Uri.parse(redirectUrl);
      return redirectUri.host == originalUri.host ||
             redirectUrl.startsWith('/'); // Relative redirects are OK
    } catch (e) {
      return false;
    }
  }
}
