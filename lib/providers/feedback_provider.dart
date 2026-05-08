import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/feedback_model.dart';
import '../services/auth_service.dart';

class FeedbackProvider with ChangeNotifier {
  List<FeedbackModel> _myFeedbacks = [];
  bool _isLoading = false;
  String? _error;

  List<FeedbackModel> get myFeedbacks => _myFeedbacks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  Future<void> fetchMyFeedbacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/feedback/my'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _myFeedbacks = data.map((json) => FeedbackModel.fromJson(json)).toList();
      } else {
        final errorBody = json.decode(response.body);
        _error = errorBody['message'] ?? 'Failed to load feedbacks';
      }
    } catch (e) {
      _error = 'Connection error. Please check your internet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback({
    required String title,
    required String description,
    required FeedbackCategory category,
    FeedbackPriority priority = FeedbackPriority.medium,
    String? relatedEntityId,
    String? relatedEntityType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/feedback'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'category': category.name,
          'priority': priority.name,
          'related_entity_id': relatedEntityId,
          'related_entity_type': relatedEntityType,
        }),
      );

      if (response.statusCode == 201) {
        await fetchMyFeedbacks();
        return true;
      } else {
        _error = 'Failed to submit feedback';
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

  Future<bool> deleteFeedback(String id) async {
    try {
      final token = await AuthService.getAccessToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/feedback/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        _myFeedbacks.removeWhere((f) => f.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
