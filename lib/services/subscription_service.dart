import 'dart:convert';
import 'auth_service.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';

class SubscriptionService {
  static Future<List<SubscriptionPlan>> getPlans({String? role}) async {
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse(
      '$baseUrl/api/v1/subscriptions/plans${role != null ? '?role=$role' : ''}',
    );

    final response = await AuthService.authenticatedRequest('GET', url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch subscription plans');
    }
  }

  static Future<Map<String, dynamic>> getCurrentSubscription() async {
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse('$baseUrl/api/v1/subscriptions/current');

    final response = await AuthService.authenticatedRequest('GET', url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return {
        'subscription': data['subscription'] != null
            ? UserSubscription.fromJson(data['subscription'])
            : null,
        'entitlements': data['entitlements'] ?? {},
      };
    } else {
      throw Exception('Failed to fetch current subscription');
    }
  }

  static Future<Map<String, dynamic>> createStripePaymentIntent(
    String planKey,
    String billingCycle,
  ) async {
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse('$baseUrl/api/v1/subscriptions/subscribe/stripe');

    final response = await AuthService.authenticatedRequest(
      'POST',
      url,
      body: {'planKey': planKey, 'billingCycle': billingCycle},
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        response.body,
      ); // This will be the Stripe Payment Intent (clientSecret and paymentIntentId)
    } else {
      final body = jsonDecode(response.body);
      throw Exception(
        body['message'] ?? 'Failed to initiate Stripe subscription',
      );
    }
  }

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
    );

    if (response.statusCode == 200) {
      return UserSubscription.fromJson(jsonDecode(response.body));
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to upgrade with credits');
    }
  }

  // Admin/Dev tool
  static Future<void> seedPlans() async {
    final baseUrl = AuthService.baseUrl;
    final url = Uri.parse('$baseUrl/api/v1/subscriptions/seed');
    await AuthService.authenticatedRequest('POST', url);
  }
}
