import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Customer Screens
import 'customer/home_screen.dart';
import 'customer/subscriptions_screen.dart';
import 'customer/marketplace_screen.dart';

// Farmer Screens
import 'farmer/analytics_screen.dart';
// import 'farmer/products_screen.dart'; // Replaced by new implementation
import 'farmer/land_management_screen.dart';
import 'farmer/my_farms_screen.dart';

// Investor Screens
import 'investor/explore_land_screen.dart';
import 'investor/my_investments_screen.dart';
// import 'investor/farming_activities_screen.dart';
import 'investor/revenue_screen.dart';
import 'settings_screen.dart';

// Shared
import 'marketplace/my_products_screen.dart';
import 'vendor/vendor_delivery_dashboard.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      // If user becomes null (logout), navigate back to the AuthWrapper at '/'
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = user.role.toLowerCase();
    List<Widget> screens = [];
    List<BottomNavigationBarItem> items = [];

    // Define tabs based on role
    if (role == 'customer') {
      screens = [
        const CustomerHomeScreen(),
        const CustomerMarketplaceScreen(),
        const SubscriptionsScreen(),
        const SettingsScreen(),
      ];
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.subscriptions_outlined),
          activeIcon: Icon(Icons.subscriptions),
          label: 'Subscriptions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    } else if (role == 'farmer') {
      screens = [
        const FarmerAnalyticsScreen(),
        const FarmerLandManagementScreen(),
        const MyProductsScreen(),
        const VendorDeliveryDashboard(),
        const FarmerMyFarmsScreen(),
        const SettingsScreen(),
      ];
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.landscape_outlined),
          activeIcon: Icon(Icons.landscape),
          label: 'Land',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          activeIcon: Icon(Icons.local_shipping),
          label: 'Deliveries',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.agriculture_outlined),
          activeIcon: Icon(Icons.agriculture),
          label: 'My Farms',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    } else if (role == 'investor') {
      screens = [
        const InvestorExploreLandScreen(),
        const InvestorMyInvestmentsScreen(),
        const MyProductsScreen(), // Updated: Replaced Activities with Products
        const VendorDeliveryDashboard(),
        const InvestorRevenueScreen(),
        const SettingsScreen(),
      ];
      items = const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on_outlined),
          activeIcon: Icon(Icons.monetization_on),
          label: 'Investments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          activeIcon: Icon(Icons.local_shipping),
          label: 'Deliveries',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Revenue',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    } else {
      // Fallback for unknown role
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unknown role: ${user.role}'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure currentIndex is valid if role changed dynamically (unlikely but safe)
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 0,
          items: items,
        ),
      ),
    );
  }
}
