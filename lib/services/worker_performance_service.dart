import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import '../models/worker_performance_model.dart';

class WorkerPerformanceService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  /// Get worker performance data for all workers across farmer's lands
  static Future<WorkerPerformanceResponse> getWorkerPerformance({
    List<String>? landIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};

    if (landIds != null && landIds.isNotEmpty) {
      for (int i = 0; i < landIds.length; i++) {
        queryParams['landIds[$i]'] = landIds[i];
      }
    }

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }

    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final uri = Uri.parse(
      '$_baseUrl/api/v1/workers/performance',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await AuthService.authenticatedRequest('GET', uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return WorkerPerformanceResponse.fromJson(body['data']);
    }

    final errorBody = jsonDecode(response.body);
    throw Exception(
      errorBody['message'] ?? 'Failed to load worker performance data',
    );
  }

  /// Get top performing workers
  static Future<List<WorkerPerformance>> getTopPerformers({
    List<String>? landIds,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 3,
  }) async {
    final queryParams = <String, String>{'limit': limit.toString()};

    if (landIds != null && landIds.isNotEmpty) {
      for (int i = 0; i < landIds.length; i++) {
        queryParams['landIds[$i]'] = landIds[i];
      }
    }

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }

    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final uri = Uri.parse(
      '$_baseUrl/api/v1/workers/performance/top',
    ).replace(queryParameters: queryParams);

    final response = await AuthService.authenticatedRequest('GET', uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data
          .map((e) => WorkerPerformance.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to load top performers');
  }

  /// Get underperforming workers (needs attention)
  static Future<List<WorkerPerformance>> getUnderperformers({
    List<String>? landIds,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 3,
  }) async {
    final queryParams = <String, String>{'limit': limit.toString()};

    if (landIds != null && landIds.isNotEmpty) {
      for (int i = 0; i < landIds.length; i++) {
        queryParams['landIds[$i]'] = landIds[i];
      }
    }

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }

    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final uri = Uri.parse(
      '$_baseUrl/api/v1/workers/performance/underperformers',
    ).replace(queryParameters: queryParams);

    final response = await AuthService.authenticatedRequest('GET', uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data
          .map((e) => WorkerPerformance.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to load underperformers');
  }
}
