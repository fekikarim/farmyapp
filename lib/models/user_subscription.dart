import 'subscription_plan.dart';

enum SubscriptionStatus {
  newly,
  trialing,
  active,
  past_due,
  grace,
  canceled,
  expired,
}

class UserSubscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final String? stripePaymentIntentId;
  final String billingCycle;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    this.currentPeriodEnd,
    required this.cancelAtPeriodEnd,
    this.stripePaymentIntentId,
    required this.billingCycle,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['user_id'],
      plan: json['plan'] is Map<String, dynamic>
          ? SubscriptionPlan.fromJson(json['plan'])
          : SubscriptionPlan.fromId(json['plan_id'] ?? ''),
      status: _parseStatus(json['status']),
      startDate: DateTime.parse(json['start_date']),
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'])
          : null,
      cancelAtPeriodEnd: json['cancel_at_period_end'] ?? false,
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      billingCycle: json['billing_cycle'] ?? 'monthly',
    );
  }

  static SubscriptionStatus _parseStatus(String? status) {
    switch (status) {
      case 'trialing':
        return SubscriptionStatus.trialing;
      case 'active':
        return SubscriptionStatus.active;
      case 'past_due':
        return SubscriptionStatus.past_due;
      case 'grace':
        return SubscriptionStatus.grace;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.newly;
    }
  }

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.trialing ||
      status == SubscriptionStatus.grace;
  bool get isGrace => status == SubscriptionStatus.grace;
}
