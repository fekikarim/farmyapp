import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/feedback_model.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';

class FeedbackProvider with ChangeNotifier {
  List<FeedbackModel> _myFeedbacks = [];
  bool _isLoading = false;
  String? _error;
  bool _isSocketInitialized = false;

  List<FeedbackModel> get myFeedbacks => _myFeedbacks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  void initSocketListeners() {
    if (_isSocketInitialized) return;

    final socket = SocketService();

    socket.on('feedback_created', (data) {
      debugPrint('[FeedbackProvider] Socket event: feedback_created');
      final newFeedback = FeedbackModel.fromJson(data);
      if (!_myFeedbacks.any((f) => f.id == newFeedback.id)) {
        _myFeedbacks.insert(0, newFeedback);
        notifyListeners();
      }
    });

    socket.on('feedback_updated', (data) {
      debugPrint('[FeedbackProvider] Socket event: feedback_updated');
      final updatedFeedback = FeedbackModel.fromJson(data);
      final index = _myFeedbacks.indexWhere((f) => f.id == updatedFeedback.id);
      if (index != -1) {
        _myFeedbacks[index] = updatedFeedback;
        notifyListeners();
      } else {
        // If not in list, might be a new one we missed
        _myFeedbacks.insert(0, updatedFeedback);
        _myFeedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        notifyListeners();
      }
    });

    socket.on('feedback_deleted', (data) {
      debugPrint('[FeedbackProvider] Socket event: feedback_deleted');
      final id = data['id'];
      _myFeedbacks.removeWhere((f) => f.id == id);
      notifyListeners();
    });

    _isSocketInitialized = true;
  }

  Future<void> fetchMyFeedbacks({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/feedback/my'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _myFeedbacks = data
            .map((json) => FeedbackModel.fromJson(json))
            .toList();
      } else {
        final errorBody = json.decode(response.body);
        _error = errorBody['message'] ?? 'Failed to load feedbacks';
      }
    } catch (e) {
      _error = 'Connection error. Please check your internet.';
    } finally {
      if (!silent) _isLoading = false;
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
          'category': category.backendValue,
          'priority': priority.name,
          'related_entity_id': relatedEntityId,
          'related_entity_type': relatedEntityType,
        }),
      );

      if (response.statusCode == 201) {
        // Socket will handle the update, but we can also fetch just in case
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
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        // Socket will handle the update
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
