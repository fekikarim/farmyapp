import 'package:flutter/material.dart';
import '../models/job_request_model.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JobRequestProvider with ChangeNotifier {
  List<JobRequest> _allJobs = [];
  List<JobRequest> _recommendedJobs = [];
  bool _isLoading = false;
  String? _error;

  List<JobRequest> get allJobs => _allJobs;
  List<JobRequest> get recommendedJobs => _recommendedJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  Future<void> fetchAllJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/job-requests'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allJobs = data.map((j) => JobRequest.fromJson(j)).toList();
      } else {
        _error = 'Failed to load jobs';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendedJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/job-requests/recommended'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _recommendedJobs = data.map((j) => JobRequest.fromJson(j)).toList();
      } else {
        _error = 'Failed to load recommended jobs';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJobRequest(JobRequest job) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/job-requests'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(job.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchAllJobs(); // Refresh
        return true;
      } else {
        _error = 'Failed to create job request';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
