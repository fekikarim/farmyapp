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

  num getLimit(String key, num defaultValue) {
    if (_entitlements[key] == null) return defaultValue;
    return _entitlements[key] as num;
  }

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

  Future<void> subscribe(String planKey, String billingCycle) async {
    // This will be handled by the UI using SubscriptionService.subscribe
    // and then calling confirmSubscription after Stripe success.
  }

  Future<void> cancelSubscription() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentSubscription = await SubscriptionService.cancelSubscription();
      await refresh();
    } catch (e) {
      print('Cancel Subscription Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
