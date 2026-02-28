import 'package:flutter/material.dart';

enum SubscriptionRole { farmer, investor, customer, worker }

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final double priceYearly;
  final String interval;
  final List<String> features;
  final List<String> extendedFeatures;
  final Color accentColor;
  final IconData icon;
  final SubscriptionRole role;
  final String? badge;
  final String planKey;

  bool get isFree => price <= 0 && priceYearly <= 0;

  SubscriptionPlan({
    required this.id,
    required this.planKey,
    required this.name,
    required this.description,
    required this.price,
    this.priceYearly = 0.0,
    required this.interval,
    required this.features,
    required this.extendedFeatures,
    required this.accentColor,
    required this.icon,
    required this.role,
    this.badge,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final String planKey = json['plan_key'] ?? '';
    final String name = json['name'] ?? 'Premium Plan';
    final String description = json['description'] ?? '';
    final double price =
        double.tryParse(json['price_monthly']?.toString() ?? '0') ?? 0.0;
    final double priceYearly =
        double.tryParse(json['price_yearly']?.toString() ?? '0') ?? 0.0;
    final role = _parseRole(json['role'] ?? '');

    final dynamic entitlements = json['entitlements'];
    List<String> dynamicFeatures = [];
    if (entitlements != null && entitlements is Map<String, dynamic>) {
      entitlements.forEach((key, value) {
        String featureName = _formatFeatureName(key);
        if (value == true) {
          dynamicFeatures.add(featureName);
        } else if (value is num) {
          if (value == -1) {
            dynamicFeatures.add('Unlimited $featureName');
          } else if (value > 0) {
            dynamicFeatures.add('$value $featureName');
          }
        } else if (value is String && value.isNotEmpty && value != 'false') {
          dynamicFeatures.add('$featureName: ${_capitalize(value)}');
        }
      });
    }

    if (dynamicFeatures.isEmpty) {
      dynamicFeatures.add('Standard Access');
    }

    Color dynamicColor = Colors.grey;
    IconData dynamicIcon = Icons.star;
    String? dynamicBadge;

    if (planKey.startsWith('farmy_free_')) {
      dynamicColor = Colors.teal;
      if (planKey.contains('farmer')) {
        dynamicIcon = Icons.grass;
      } else if (planKey.contains('investor')) {
        dynamicIcon = Icons.pie_chart;
      } else {
        dynamicIcon = Icons.shopping_bag_outlined;
      }
    } else if (planKey.contains('farmer') || role == SubscriptionRole.farmer) {
      dynamicColor = Colors.green;
      dynamicIcon = Icons.agriculture;
    } else if (planKey.contains('investor') ||
        role == SubscriptionRole.investor) {
      dynamicColor = Colors.blue;
      dynamicIcon = Icons.pie_chart;
    } else if (planKey.contains('worker') || role == SubscriptionRole.worker) {
      dynamicColor = Colors.purple;
      dynamicIcon = Icons.work;
    } else {
      dynamicColor = Colors.orange;
      dynamicIcon = Icons.shopping_basket;
    }

    if (planKey.contains('pro') || planKey.contains('medium')) {
      dynamicBadge = 'Popular';
    } else if (planKey.contains('plus') ||
        planKey.contains('large') ||
        planKey.contains('premium')) {
      dynamicBadge = 'Premium';
    }

    if (price == 0 && priceYearly == 0) {
      dynamicBadge = null;
    }

    return SubscriptionPlan(
      id: json['id'] ?? '',
      planKey: planKey,
      name: name,
      description: description,
      price: price,
      priceYearly: priceYearly,
      interval: 'month',
      features: dynamicFeatures,
      extendedFeatures: [], // Dynamic plans just use standard features for now
      accentColor: dynamicColor,
      icon: dynamicIcon,
      role: role,
      badge: dynamicBadge,
    );
  }

  static String _formatFeatureName(String key) {
    return key
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  static SubscriptionRole _parseRole(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'farmer':
        return SubscriptionRole.farmer;
      case 'investor':
        return SubscriptionRole.investor;
      case 'worker':
        return SubscriptionRole.worker;
      case 'customer':
      default:
        return SubscriptionRole.customer;
    }
  }
}
