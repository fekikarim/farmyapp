import 'subscription_plan.dart';

enum SubscriptionStatus { active, expired, cancelled, pastDue, unknown }

class UserSubscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final bool autoRenew;
  final String paymentMethod;
  final String? stripePaymentIntentId;
  final String billingCycle;
  final Map<String, dynamic>? entitlementsSnapshot;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.autoRenew,
    required this.paymentMethod,
    this.stripePaymentIntentId,
    required this.billingCycle,
    this.entitlementsSnapshot,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['user_id'],
      plan: json['plan'] is Map<String, dynamic>
          ? SubscriptionPlan.fromJson(json['plan'])
          : SubscriptionPlan.fromJson({'id': json['plan_id'] ?? ''}),
      status: _parseStatus(json['status']),
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      autoRenew: json['auto_renew'] ?? false,
      paymentMethod: json['payment_method'] ?? 'free',
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      billingCycle: json['billing_cycle'] ?? 'monthly',
      entitlementsSnapshot:
          json['entitlements_snapshot'] is Map<String, dynamic>
          ? json['entitlements_snapshot']
          : null,
    );
  }

  static SubscriptionStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
      case 'canceled':
        return SubscriptionStatus.cancelled;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      default:
        return SubscriptionStatus.unknown;
    }
  }

  bool get isActive => status == SubscriptionStatus.active;
}
