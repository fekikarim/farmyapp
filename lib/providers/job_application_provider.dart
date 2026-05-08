import 'package:flutter/material.dart';
import '../models/job_application_model.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JobApplicationProvider with ChangeNotifier {
  List<JobApplication> _myApplications = [];
  Map<String, List<JobApplication>> _jobApplications =
      {}; // jobId -> applications
  bool _isLoading = false;
  String? _error;

  List<JobApplication> get myApplications => _myApplications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  List<JobApplication> getApplicationsForJob(String jobId) {
    return _jobApplications[jobId] ?? [];
  }

  Future<void> fetchMyApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/job-applications/my'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _myApplications = data.map((j) => JobApplication.fromJson(j)).toList();
      } else {
        _error = 'Failed to load applications';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobApplications(String jobId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final url = '$_baseUrl/api/v1/job-applications/$jobId/applications';
      print('📡 Fetching applications for job $jobId: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _jobApplications[jobId] = data
            .map((j) => JobApplication.fromJson(j))
            .toList();
      } else {
        _error = 'Failed to load applications: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ Error fetching applications: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> applyToJob(String jobId, {String? notes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/job-applications/$jobId/apply'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'notes': notes}),
      );

      if (response.statusCode == 201) {
        await fetchMyApplications();
        return true;
      } else {
        final body = json.decode(response.body);
        _error = body['message'] ?? 'Failed to apply';
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

  Future<bool> updateApplicationStatus(
    String applicationId,
    String jobId,
    JobApplicationStatus status,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/v1/job-applications/$applicationId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status.name}),
      );

      if (response.statusCode == 200) {
        await fetchJobApplications(jobId);
        return true;
      } else {
        _error = 'Failed to update status';
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
