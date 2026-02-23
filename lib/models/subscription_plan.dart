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
          features: [
            'All Monthly features',
            '33% Savings',
            'Priority Support',
          ],
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
