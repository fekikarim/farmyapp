import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

// Customer Screens
import 'customer/home_screen.dart';
import 'customer/subscriptions_screen.dart';
import 'customer/marketplace_screen.dart';

// Farmer Screens
import 'farmer/analytics_screen.dart';
import 'farmer/worker_performance_dashboard.dart';
// import 'farmer/products_screen.dart'; // Replaced by new implementation
import 'farmer/land_management_screen.dart';
// import 'farmer/my_farms_screen.dart';

// Investor Screens
import 'investor/explore_land_screen.dart';
import 'investor/my_investments_screen.dart';
// import 'investor/farming_activities_screen.dart';
import 'investor/revenue_screen.dart';
import 'settings_screen.dart';

// Shared
import 'marketplace/my_products_screen.dart';

// Worker
import 'worker/tasks_screen.dart';

// Agent
import 'investment_agent_screen.dart';
import '../features/ai_assistant/ai_screen.dart';

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
      items = [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront),
          label: AppLocalizations.of(context)!.marketplace,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.subscriptions_outlined),
          activeIcon: Icon(Icons.subscriptions),
          label: AppLocalizations.of(context)!.subscriptions,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings,
        ),
      ];
    } else if (role == 'farmer') {
      screens = [
        const FarmerAnalyticsScreen(),
        const FarmerLandManagementScreen(),
        const MyProductsScreen(),
        const WorkerPerformanceDashboard(), // Worker Performance Dashboard
        const SettingsScreen(),
      ];
      items = [
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: AppLocalizations.of(context)!.analytics,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.landscape_outlined),
          activeIcon: Icon(Icons.landscape),
          label: AppLocalizations.of(context)!.land,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: AppLocalizations.of(context)!.products,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined),
          activeIcon: Icon(Icons.people),
          label: AppLocalizations.of(context)!.workerPerformanceTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings,
        ),
      ];
    } else if (role == 'investor') {
      screens = [
        const InvestorExploreLandScreen(),
        const InvestorMyInvestmentsScreen(),
        const MyProductsScreen(), // Updated: Replaced Activities with Products
        const InvestorRevenueScreen(),
        const SettingsScreen(),
      ];
      items = [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: AppLocalizations.of(context)!.explore,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on_outlined),
          activeIcon: Icon(Icons.monetization_on),
          label: AppLocalizations.of(context)!.investments,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined), // Changed icon
          activeIcon: Icon(Icons.inventory_2),
          label: AppLocalizations.of(context)!.products, // Changed label
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: AppLocalizations.of(context)!.revenue,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings,
        ),
      ];
    } else if (role == 'worker') {
      screens = [const WorkerTasksScreen(), const SettingsScreen()];
      items = [
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: AppLocalizations.of(context)!.tasks,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: AppLocalizations.of(context)!.settings,
        ),
      ];
    } else {
      // Fallback for unknown role
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.unknownRole(user.role)),
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
                label: Text(AppLocalizations.of(context)!.logout),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Builder(
        builder: (context) {
          if (role == 'investor' || role == 'farmer') {
            return SizedBox(
              width: 58,
              height: 58,
              child: FloatingActionButton(
                heroTag: 'agent_fab',
                tooltip: role == 'investor'
                    ? AppLocalizations.of(context)!.openInvestmentAssistant
                    : AppLocalizations.of(context)!.openAiAssistant,
                onPressed: () {
                  if (role == 'investor') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InvestmentAgentScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiAssistantScreen(),
                      ),
                    );
                  }
                },
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            );
          } else if (role == 'customer' && user.hasWorkerProfile) {
            return FloatingActionButton(
              heroTag: 'worker_tasks_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkerTasksScreen()),
                );
              },
              backgroundColor: Colors.amberAccent,
              child: const Icon(Icons.assignment, color: Colors.black),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
