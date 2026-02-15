import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import '../models/task_model.dart';

class TaskService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.1.21:3001',
  );

  static Future<FarmTask?> createTask({
    required String landId,
    required String title,
    String? description,
    String? type,
    double? reward,
    int? timeRequiredMinutes,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/tasks/lands/$landId/tasks'),
      body: jsonEncode({
        'title': title,
        'description': description,
        'type': type,
        'reward': reward,
        'time_required_minutes': timeRequiredMinutes,
      }),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return FarmTask.fromJson(body['data']);
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to create task');
  }

  static Future<List<FarmTask>> getLandTasks(
    String landId, {
    String? status,
  }) async {
    var url = '$_baseUrl/api/v1/tasks/lands/$landId/tasks';
    if (status != null) url += '?status=$status';

    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((item) => FarmTask.fromJson(item)).toList();
    }
    return [];
  }

  static Future<FarmTask?> assignTask({
    required String taskId,
    required String workerId,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'PATCH',
      Uri.parse('$_baseUrl/api/v1/tasks/$taskId/assign'),
      body: jsonEncode({'worker_id': workerId}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return FarmTask.fromJson(body['data']);
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to assign task');
  }

  static Future<FarmTask?> completeTask({
    required String taskId,
    String? proofImageUrl,
    String? proofVideoUrl,
    Map<String, dynamic>? proofGps,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/tasks/$taskId/complete'),
      body: jsonEncode({
        'proof_image_url': proofImageUrl,
        'proof_video_url': proofVideoUrl,
        'proof_gps': proofGps,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return FarmTask.fromJson(body['data']);
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to complete task');
  }

  static Future<List<FarmTask>> getMyTasks() async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/tasks/me'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((item) => FarmTask.fromJson(item)).toList();
    }
    return [];
  }
}
