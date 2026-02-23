import 'package:flutter/material.dart';

enum SubscriptionRole { farmer, investor, customer, worker }

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String interval;
  final List<String> features;
  final List<String> extendedFeatures;
  final Color accentColor;
  final IconData icon;
  final SubscriptionRole role;
  final String? badge;

  String get planKey => id.split('_monthly').first.split('_yearly').first;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.interval,
    required this.features,
    required this.extendedFeatures,
    required this.accentColor,
    required this.icon,
    required this.role,
    this.badge,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    // Basic mapping from backend SubscriptionPlan to frontend UI model
    final planKey = json['plan_key'] ?? '';
    final mockPlan = mockPlans.firstWhere(
      (p) => p.id.startsWith(planKey),
      orElse: () => mockPlans.first,
    );

    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? mockPlan.name,
      description: json['description'] ?? mockPlan.description,
      price: double.tryParse(json['price_monthly']?.toString() ?? '0') ?? 0.0,
      interval: 'month',
      features: mockPlan.features,
      extendedFeatures: mockPlan.extendedFeatures,
      accentColor: mockPlan.accentColor,
      icon: mockPlan.icon,
      role: _parseRole(json['role'] ?? mockPlan.role.name),
      badge: mockPlan.badge,
    );
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

  static SubscriptionPlan fromId(String planId) {
    return mockPlans.firstWhere(
      (p) => p.id == planId,
      orElse: () => mockPlans.first,
    );
  }

  static List<SubscriptionPlan> get mockPlans => [
    // Farmer Pro
    SubscriptionPlan(
      id: 'farmer_pro_monthly',
      name: 'Farmer Pro',
      description:
          'Unlock AI-powered crop planning and unlimited land listings.',
      price: 14.99,
      interval: 'month',
      features: [
        'Unlimited land listings',
        'Premium asset types',
        'AI-powered crop planner',
        'Advanced analytics (90-day)',
        'Priority KYC (4h)',
      ],
      extendedFeatures: [
        'Unlimited land listings for multi-plot scaling',
        'Access to rare animal variants and machine types',
        'Gemini-powered soil and crop analysis',
        '90-day analytics history with CSV export',
        '4-hour priority KYC processing',
        'Advanced worker filters (skill, rating, schedule)',
        'Detailed production chain analytics',
        'Export Hedera audit trails as PDF/CSV',
      ],
      accentColor: Colors.green,
      icon: Icons.agriculture,
      role: SubscriptionRole.farmer,
      badge: 'Popular',
    ),
    SubscriptionPlan(
      id: 'farmer_pro_yearly',
      name: 'Farmer Pro Yearly',
      description: 'Save 33% with our annual plan.',
      price: 119.99,
      interval: 'year',
      features: ['All Monthly features', '33% Savings', 'Priority Support'],
      extendedFeatures: [
        'Save 33% compared to monthly plan',
        'All Farmer Pro features included',
        'Dedicated premium support channel',
        '24h email response SLA',
      ],
      accentColor: Colors.green,
      icon: Icons.agriculture,
      role: SubscriptionRole.farmer,
      badge: 'Best Value',
    ),

    // Investor Plus
    SubscriptionPlan(
      id: 'investor_plus_monthly',
      name: 'Investor Plus',
      description: 'Get early access to lands and advanced ROI analytics.',
      price: 24.99,
      interval: 'month',
      features: [
        'Unlimited simultaneous rentals',
        '48h Early land access',
        'Land ROI analytics',
        'Portfolio dashboard',
        'AI investment advisor',
      ],
      extendedFeatures: [
        'No limit on active land rentals',
        '48h first-look at new land listings',
        'In-depth ROI calculator per land',
        'Unified portfolio and revenue view',
        'Boosted job postings for workers',
        'Pre-built legal contract templates',
        'AI-driven land potential analysis',
      ],
      accentColor: Colors.blue,
      icon: Icons.trending_up,
      role: SubscriptionRole.investor,
    ),

    // FarmBox (Customer)
    SubscriptionPlan(
      id: 'farmbox_small_monthly',
      name: 'FarmBox Small',
      description: '5-7 items bi-weekly, vegetables only.',
      price: 29.99,
      interval: 'month',
      features: [
        '5-7 items per box',
        'Bi-weekly delivery',
        'Vegetables only',
        'Auto-curated selection',
        '5% Marketplace discount',
      ],
      extendedFeatures: [
        '5-7 farm-fresh items per delivery',
        'Bi-weekly home delivery',
        'Curated mix of seasonal vegetables',
        '5% discount on marketplace orders',
      ],
      accentColor: Colors.orange,
      icon: Icons.shopping_basket,
      role: SubscriptionRole.customer,
    ),
    SubscriptionPlan(
      id: 'farmbox_medium_monthly',
      name: 'FarmBox Medium',
      description: 'Weekly delivery of fresh vegetables and fruits.',
      price: 49.99,
      interval: 'month',
      features: [
        '10-14 items per box',
        'Weekly delivery',
        'Vegetables + Fruits',
        'Choose 2 preferred farms',
        '10% Marketplace discount',
      ],
      extendedFeatures: [
        '10-14 farm-fresh items per delivery',
        'Convenient weekly home delivery',
        'Curated mix of vegetables and seasonal fruits',
        'Priority selection of your favorite farms',
        '10% discount on all extra marketplace orders',
        'Traceability info for every product',
      ],
      accentColor: Colors.orange,
      icon: Icons.shopping_basket,
      role: SubscriptionRole.customer,
      badge: 'Popular',
    ),
    SubscriptionPlan(
      id: 'farmbox_large_monthly',
      name: 'FarmBox Large',
      description: 'Full range of 18-22 items with custom picks.',
      price: 79.99,
      interval: 'month',
      features: [
        '18-22 items per box',
        'Weekly delivery',
        'Full range + Premium items',
        'Unlimited farm choice',
        '15% Marketplace discount',
      ],
      extendedFeatures: [
        '18-22 farm-fresh items per delivery',
        'Weekly priority home delivery',
        'Full range of produce including premium items',
        'Custom pick and unlimited farm choice',
        '15% discount on all extra marketplace orders',
        'Direct chat with producing farmers',
        'Blockchain (Hedera) verification',
      ],
      accentColor: Colors.orange,
      icon: Icons.shopping_basket,
      role: SubscriptionRole.customer,
      badge: 'Premium Box',
    ),

    // Worker Plus
    SubscriptionPlan(
      id: 'worker_plus_monthly',
      name: 'Worker Plus',
      description: 'Boost your visibility and get priority job matching.',
      price: 4.99,
      interval: 'month',
      features: [
        'Profile boost (Top 10)',
        'Featured Pro Worker badge',
        'Advanced task filters',
        'Earnings analytics',
        'Instant withdrawal',
      ],
      extendedFeatures: [
        'Appear in top search results',
        'Exclusive profile trust badge',
        'Filter by reward and proximity',
        'Monthly earnings and tax-ready reports',
        'Instant payout to wallet',
        'Insight into market rate salaries',
      ],
      accentColor: Colors.purple,
      icon: Icons.work,
      role: SubscriptionRole.worker,
    ),
  ];
}
