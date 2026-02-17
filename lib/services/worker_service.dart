import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';
import '../models/worker_profile_model.dart';
import '../models/land_worker_model.dart';

class WorkerService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.0.133:3001',
  );

  // ─── Worker Profile ───

  static Future<WorkerProfile?> createWorkerProfile({
    required List<String> skills,
    String? bio,
    double? hourlyRate,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/worker-profile'),
      body: jsonEncode({
        'skills': skills,
        'bio': bio,
        'hourly_rate': hourlyRate,
      }),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return WorkerProfile.fromJson(body['data']);
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to create worker profile');
  }

  static Future<WorkerProfile?> getMyWorkerProfile() async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/worker-profile/me'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['data'] == null) return null;
      return WorkerProfile.fromJson(body['data']);
    }
    return null;
  }

  static Future<WorkerProfile?> updateMyWorkerProfile({
    List<String>? skills,
    String? bio,
    double? hourlyRate,
    String? availability,
  }) async {
    final data = <String, dynamic>{};
    if (skills != null) data['skills'] = skills;
    if (bio != null) data['bio'] = bio;
    if (hourlyRate != null) data['hourly_rate'] = hourlyRate;
    if (availability != null) data['availability'] = availability;

    final response = await AuthService.authenticatedRequest(
      'PUT',
      Uri.parse('$_baseUrl/api/v1/worker-profile/me'),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return WorkerProfile.fromJson(body['data']);
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to update worker profile');
  }

  static Future<List<WorkerProfile>> getMarketplace({
    String? skill,
    double? minRating,
    String? availability,
    String? excludeLandId,
  }) async {
    final params = <String, String>{};
    if (skill != null) params['skill'] = skill;
    if (minRating != null) params['minRating'] = minRating.toString();
    if (availability != null) params['availability'] = availability;
    if (excludeLandId != null) params['excludeLandId'] = excludeLandId;

    final uri = Uri.parse(
      '$_baseUrl/api/v1/worker-profile/marketplace',
    ).replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await AuthService.authenticatedRequest('GET', uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((item) => WorkerProfile.fromJson(item)).toList();
    }
    return [];
  }

  // ─── Land Workers ───

  static Future<List<LandWorker>> getLandWorkers(String landId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/workers'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((item) => LandWorker.fromJson(item)).toList();
    }
    return [];
  }

  static Future<LandWorker?> assignWorkerToLand({
    required String landId,
    required String workerId,
    String? role,
    double? salary,
  }) async {
    final response = await AuthService.authenticatedRequest(
      'POST',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/workers'),
      body: jsonEncode({'worker_id': workerId, 'role': role, 'salary': salary}),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return LandWorker.fromJson(body['data']);
    }
    final errorBody = jsonDecode(response.body);
    throw Exception(errorBody['message'] ?? 'Failed to assign worker');
  }

  static Future<bool> removeWorkerFromLand(
    String landId,
    String workerId,
  ) async {
    final response = await AuthService.authenticatedRequest(
      'DELETE',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/workers/$workerId'),
    );
    return response.statusCode == 200;
  }

  static Future<bool> updateWorkerStatus(
    String landId,
    String workerId,
    String status,
  ) async {
    final response = await AuthService.authenticatedRequest(
      'PATCH',
      Uri.parse(
        '$_baseUrl/api/v1/workforce/lands/$landId/workers/$workerId/status',
      ),
      body: jsonEncode({'status': status}),
    );
    return response.statusCode == 200;
  }

  static Future<List<LandWorker>> getMyAssignedLands() async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/me/lands'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((item) => LandWorker.fromJson(item)).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> getWorkforceStats(String landId) async {
    final response = await AuthService.authenticatedRequest(
      'GET',
      Uri.parse('$_baseUrl/api/v1/workforce/lands/$landId/workforce-stats'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'] ?? {};
    }
    return {};
  }
}
