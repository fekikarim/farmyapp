import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class WorkerWalletService {
  final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  Uri _walletUri(String endpoint, [Map<String, String>? queryParameters]) {
    final cleanBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse(
      '$cleanBaseUrl/api/v1/worker-wallet/$endpoint',
    ).replace(queryParameters: queryParameters);
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Unexpected server response. Please try again.');
  }

  Never _throwApiError(String body, String fallback) {
    String message = fallback;
    try {
      final jsonResponse = _decodeBody(body);
      message = (jsonResponse['message'] ?? jsonResponse['error'] ?? fallback)
          .toString();
    } catch (_) {
      message = fallback;
    }
    throw Exception(message);
  }

  Future<Map<String, dynamic>> getWalletOverview() async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      _walletUri('overview'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = _decodeBody(response.body);
      return jsonResponse['data'] as Map<String, dynamic>;
    } else {
      _throwApiError(response.body, 'Failed to load wallet overview');
    }
  }

  Future<Map<String, dynamic>> getTransactionHistory({
    String? type,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParameters = <String, String>{
      'limit': limit.clamp(1, 100).toString(),
      'offset': offset < 0 ? '0' : offset.toString(),
      if (type != null && type.isNotEmpty) 'type': type,
    };

    final response = await AuthService.authenticatedRequest(
      'GET',
      _walletUri('transactions', queryParameters),
    );

    if (response.statusCode == 200) {
      final jsonResponse = _decodeBody(response.body);
      return jsonResponse['data'] as Map<String, dynamic>;
    } else {
      _throwApiError(response.body, 'Failed to load transactions');
    }
  }

  Future<Map<String, dynamic>> getTaskEarnings({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      _walletUri('earnings', {
        'limit': limit.clamp(1, 100).toString(),
        'offset': offset < 0 ? '0' : offset.toString(),
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = _decodeBody(response.body);
      return jsonResponse['data'] as Map<String, dynamic>;
    } else {
      _throwApiError(response.body, 'Failed to load earnings');
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal(double amount) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/worker-wallet/withdraw'),
      body: {'amount': amount},
    );

    if (response.statusCode == 200) {
      return _decodeBody(response.body);
    } else {
      _throwApiError(response.body, 'Failed to process withdrawal');
    }
  }
}
