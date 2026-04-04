import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'auth_service.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';

/// Structured exception for subscription-related API errors.
class SubscriptionException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final bool isRetryable;

  const SubscriptionException(
    this.message, {
    this.code,
    this.statusCode,
    this.isRetryable = false,
  });

  @override
  String toString() => message;

  bool get isNetworkError =>
      statusCode == 503 || code == 'network_error' || code == 'timeout';

  bool get isAuthError => statusCode == 401 || statusCode == 403;
}

class SubscriptionService {
  static const Duration _defaultTimeout = Duration(seconds: 15);
  static const int _maxRetries = 2;
  static const Duration _retryBaseDelay = Duration(milliseconds: 500);

  // ─── Plans ───────────────────────────────────────────────────────────

  static Future<List<SubscriptionPlan>> getPlans({String? role}) async {
    return _withRetry('getPlans', () async {
      final baseUrl = AuthService.baseUrl;
      final url = Uri.parse(
        '$baseUrl/api/v1/subscriptions/plans${role != null ? '?role=$role' : ''}',
      );

      final response = await AuthService.authenticatedRequest(
        'GET',
        url,
      ).timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
      } else {
        throw _parseError(response, 'Failed to fetch subscription plans');
      }
    });
  }

  // ─── Current Subscription ────────────────────────────────────────────

  static Future<Map<String, dynamic>> getCurrentSubscription() async {
    return _withRetry('getCurrentSubscription', () async {
      final baseUrl = AuthService.baseUrl;
      final url = Uri.parse('$baseUrl/api/v1/subscriptions/current');
      debugPrint('[SubscriptionService] Fetching Current Sub from: $url');

      final response = await AuthService.authenticatedRequest(
        'GET',
        url,
      ).timeout(_defaultTimeout);
      debugPrint('[SubscriptionService] Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'subscription': data['subscription'] != null
              ? UserSubscription.fromJson(data['subscription'])
              : null,
          'entitlements': data['entitlements'] ?? {},
        };
      } else {
        throw _parseError(response, 'Failed to fetch current subscription');
      }
    });
  }

  // ─── Stripe Payment ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createStripePaymentIntent(
    String planKey,
    String billingCycle,
  ) async {
    // No retry for payment initiation — single attempt
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse('$baseUrl/api/v1/subscriptions/subscribe/stripe');

    final response = await AuthService.authenticatedRequest(
      'POST',
      url,
      body: {'planKey': planKey, 'billingCycle': billingCycle},
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _parseError(response, 'Failed to initiate Stripe subscription');
    }
  }

  static Future<Map<String, dynamic>> confirmStripePayment(
    String paymentIntentId,
  ) async {
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse('$baseUrl/api/v1/subscriptions/subscribe/confirm');

    final response = await AuthService.authenticatedRequest(
      'POST',
      url,
      body: {'paymentIntentId': paymentIntentId},
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _parseError(response, 'Failed to confirm payment');
    }
  }

  // ─── Credits Upgrade ─────────────────────────────────────────────────

  static Future<UserSubscription> upgradeWithCredits(
    String planKey,
    String billingCycle,
  ) async {
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse('$baseUrl/api/v1/subscriptions/subscribe/credits');

    final response = await AuthService.authenticatedRequest(
      'POST',
      url,
      body: {'planKey': planKey, 'billingCycle': billingCycle},
    ).timeout(_defaultTimeout);

    if (response.statusCode == 200) {
      return UserSubscription.fromJson(jsonDecode(response.body));
    } else {
      throw _parseError(response, 'Failed to upgrade with credits');
    }
  }

  // ─── Subscription Existence ──────────────────────────────────────────

  static Future<Map<String, dynamic>> checkSubscriptionExistence() async {
    return _withRetry('checkSubscriptionExistence', () async {
      final baseUrl = AuthService.baseUrl;
      final url = Uri.parse('$baseUrl/api/v1/subscriptions/has-subscription');

      final response = await AuthService.authenticatedRequest(
        'GET',
        url,
      ).timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'hasSubscription': data['hasSubscription'] ?? false,
          'activeSubscription': data['activeSubscription'] != null
              ? UserSubscription.fromJson(data['activeSubscription'])
              : null,
        };
      } else {
        throw _parseError(response, 'Failed to check subscription existence');
      }
    });
  }

  // ─── Admin Seed ──────────────────────────────────────────────────────

  static Future<void> seedPlans() async {
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse('$baseUrl/api/v1/subscriptions/seed');
    await AuthService.authenticatedRequest('POST', url);
  }

  // ─── Internal Helpers ────────────────────────────────────────────────

  static SubscriptionException _parseError(
    dynamic response,
    String fallbackMessage,
  ) {
    String message = fallbackMessage;
    String? code;
    int statusCode = 500;

    try {
      statusCode = response.statusCode;
      final body = jsonDecode(response.body);
      message = body['message'] ?? fallbackMessage;
      code = body['code'];
    } catch (_) {}

    final isRetryable =
        statusCode == 503 ||
        statusCode == 502 ||
        statusCode == 504 ||
        statusCode == 429;

    return SubscriptionException(
      message,
      code: code,
      statusCode: statusCode,
      isRetryable: isRetryable,
    );
  }

  static Future<T> _withRetry<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    int attempt = 0;

    while (true) {
      try {
        return await operation();
      } on TimeoutException {
        attempt++;
        if (attempt > _maxRetries) {
          throw const SubscriptionException(
            'Request timed out. Please check your connection and try again.',
            code: 'timeout',
            statusCode: 408,
            isRetryable: true,
          );
        }
        await Future.delayed(_retryBaseDelay * attempt);
      } on SocketException {
        attempt++;
        if (attempt > _maxRetries) {
          throw const SubscriptionException(
            'No internet connection. Please check your network and try again.',
            code: 'network_error',
            statusCode: 503,
            isRetryable: true,
          );
        }
        await Future.delayed(_retryBaseDelay * attempt);
      } on SubscriptionException catch (e) {
        if (e.isRetryable && attempt < _maxRetries) {
          attempt++;
          await Future.delayed(_retryBaseDelay * attempt);
          continue;
        }
        rethrow;
      } catch (e) {
        if (e is SubscriptionException) rethrow;
        throw SubscriptionException(e.toString(), code: 'unknown');
      }
    }
  }
}
