import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import 'auth_service.dart';

class InAppNotificationService {
  static final String _baseUrl = AuthService.baseUrl;

  static Future<List<AppNotification>> getMyNotifications() async {
    final token = await AuthService.getAccessToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/notifications'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List notifications = data['data'];
          return notifications.map((n) => AppNotification.fromJson(n)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<bool> markAsRead(String id) async {
    final token = await AuthService.getAccessToken();
    if (token == null) return false;

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/v1/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  static Future<bool> markAllAsRead() async {
    final token = await AuthService.getAccessToken();
    if (token == null) return false;

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/v1/notifications/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  static Future<bool> deleteNotification(String id) async {
    final token = await AuthService.getAccessToken();
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/notifications/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
}
