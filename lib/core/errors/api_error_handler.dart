import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Custom exception for upgrade-required (HTTP 403) responses.
class UpgradeRequiredException implements Exception {
  final String message;
  final String? featureKey;

  UpgradeRequiredException(this.message, {this.featureKey});

  @override
  String toString() => 'UpgradeRequiredException: $message';
}

/// Utility class to handle API responses uniformly across the app.
class ApiErrorHandler {
  /// Checks an HTTP response and throws appropriate exceptions.
  /// Call this after every HTTP call to handle 403s globally.
  static void handleResponse(http.Response response) {
    if (response.statusCode == 403) {
      final body = jsonDecode(response.body);
      throw UpgradeRequiredException(
        body['message'] ?? 'Upgrade required to access this feature.',
      );
    }
  }

  /// Shows a snackbar-based upgrade prompt when a 403 is caught.
  static void showUpgradeSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        action: SnackBarAction(
          label: 'Upgrade',
          onPressed: () {
            Navigator.of(context).pushNamed('/subscriptions');
          },
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Wraps an async API call and catches UpgradeRequiredException,
  /// showing an upgrade prompt automatically.
  static Future<T?> guardedCall<T>(
    BuildContext context,
    Future<T> Function() apiCall,
  ) async {
    try {
      return await apiCall();
    } on UpgradeRequiredException catch (e) {
      showUpgradeSnackbar(context, e.message);
      return null;
    }
  }
}
