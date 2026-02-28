import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  UserSubscription? _currentSubscription;
  Map<String, dynamic> _entitlements = {};
  List<SubscriptionPlan> _availablePlans = [];
  bool _isLoading = false;
  String? _error;

  UserSubscription? get currentSubscription => _currentSubscription;
  Map<String, dynamic> get entitlements => _entitlements;
  List<SubscriptionPlan> get availablePlans => _availablePlans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool hasEntitlement(String key) => _entitlements[key] == true;

  /// Helper for boolean features (handles both true and 'true' string if necessary,
  /// but usually the backend returns boolean).
  bool hasFeature(String key) => _entitlements[key] == true;

  num getLimit(String key, num defaultValue) {
    if (_entitlements[key] == null) return defaultValue;
    return _entitlements[key] as num;
  }

  /// Returns true if currentValue is still under the plan limit.
  /// -1 means unlimited (always returns true).
  bool isWithinLimit(String key, int currentValue) {
    final limit = getLimit(key, 0);
    if (limit == -1) return true;
    return currentValue < limit;
  }

  /// Readable plan name, or 'Free' as fallback.
  String get planName => _currentSubscription?.plan.name ?? 'Farmy Free';

  /// Whether the current plan is a free plan.
  bool get isFreePlan =>
      _currentSubscription?.paymentMethod == 'free' ||
      (_currentSubscription?.plan.price ?? 0) == 0;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      await refresh();
      await fetchPlans();
    } catch (e) {
      _error = e.toString();
      print('SubscriptionProvider Init Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    try {
      _error = null;
      final data = await SubscriptionService.getCurrentSubscription();
      _currentSubscription = data['subscription'];
      _entitlements = data['entitlements'];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Refresh Subscription Error: $e');
      notifyListeners();
    }
  }

  Future<void> fetchPlans({String? role}) async {
    try {
      _error = null;
      _availablePlans = await SubscriptionService.getPlans(role: role);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      print('Fetch Plans Error: $e');
      notifyListeners();
    }
  }

  Future<void> upgradeWithCredits(String planKey, String billingCycle) async {
    _isLoading = true;
    notifyListeners();
    try {
      await SubscriptionService.upgradeWithCredits(planKey, billingCycle);
      await refresh();
    } catch (e) {
      print('Upgrade with Credits Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
