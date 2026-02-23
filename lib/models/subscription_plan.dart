import 'package:flutter/material.dart';

enum SubscriptionRole { farmer, investor, customer, worker }

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String interval;
  final List<String> features;
  final Color accentColor;
  final IconData icon;
  final SubscriptionRole role;
  final String? badge;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.interval,
    required this.features,
    required this.accentColor,
    required this.icon,
    required this.role,
    this.badge,
  });

  static List<SubscriptionPlan> get mockPlans => [
        // Farmer Pro
        SubscriptionPlan(
          id: 'farmer_pro_monthly',
          name: 'Farmer Pro',
          description: 'Unlock AI-powered crop planning and unlimited land listings.',
          price: 14.99,
          interval: 'month',
          features: [
            'Unlimited land listings',
            'Premium asset types',
            'AI-powered crop planner',
            'Advanced analytics (90-day)',
            'Priority KYC (4h)',
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
          features: [
            'All Monthly features',
            '33% Savings',
            'Priority Support',
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
          accentColor: Colors.blue,
          icon: Icons.trending_up,
          role: SubscriptionRole.investor,
        ),

        // FarmBox (Customer)
        SubscriptionPlan(
          id: 'farmbox_medium',
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
          accentColor: Colors.orange,
          icon: Icons.shopping_basket,
          role: SubscriptionRole.customer,
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
          accentColor: Colors.purple,
          icon: Icons.work,
          role: SubscriptionRole.worker,
        ),
      ];
}
