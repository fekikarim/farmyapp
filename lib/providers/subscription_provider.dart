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

  // Subscription existence gate
  bool? _hasSubscription; // null = not yet checked
  bool _isCheckingSubscription = false;
  String? _checkError;

  UserSubscription? get currentSubscription => _currentSubscription;
  Map<String, dynamic> get entitlements => _entitlements;
  List<SubscriptionPlan> get availablePlans => _availablePlans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Whether user has any subscription history (null = not yet determined)
  bool? get hasSubscription => _hasSubscription;
  bool get isCheckingSubscription => _isCheckingSubscription;
  String? get checkError => _checkError;

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

  bool _initialized = false;
  String? _lastFetchedRole;

  Future<void> init({String? role}) async {
    if (_initialized && role == _lastFetchedRole) return;
    _initialized = true;
    _isLoading = true;
    notifyListeners();
    try {
      await refresh();
      // Always fetch plans if role changes or if plans are empty
      if (_availablePlans.isEmpty || role != _lastFetchedRole) {
        await fetchPlans(role: role);
      }
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availablePlans = await SubscriptionService.getPlans(role: role);
      _lastFetchedRole = role;
    } catch (e) {
      _error = e.toString();
      print('Fetch Plans Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upgradeWithCredits(String planKey, String billingCycle) async {
    _isLoading = true;
    notifyListeners();
    try {
      await SubscriptionService.upgradeWithCredits(planKey, billingCycle);
      await refresh();
      // Mark as subscribed after successful upgrade
      _hasSubscription = true;
    } catch (e) {
      print('Upgrade with Credits Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if the user has any subscription history.
  /// Caches the result so it only hits the network once per session.
  Future<bool> checkSubscriptionExistence() async {
    // Return cached value if already checked
    if (_hasSubscription != null) return _hasSubscription!;

    // Already running — don't double-call
    if (_isCheckingSubscription) return false;

    _isCheckingSubscription = true;
    _checkError = null;
    // Do NOT call notifyListeners() here — it would trigger a rebuild while
    // AuthWrapper is still processing, causing setState-during-build errors.
    // The AuthWrapper reads isCheckingSubscription reactively after the future completes.

    try {
      final result = await SubscriptionService.checkSubscriptionExistence();
      _hasSubscription = result['hasSubscription'] as bool;
      // If active subscription returned, update local state too
      if (result['activeSubscription'] != null &&
          _currentSubscription == null) {
        _currentSubscription = result['activeSubscription'] as UserSubscription;
      }
      return _hasSubscription!;
    } catch (e) {
      _checkError = e.toString();
      print('Check Subscription Existence Error: $e');
      // On error, don't block the user — assume they have a subscription
      _hasSubscription = true;
      return true;
    } finally {
      _isCheckingSubscription = false;
      // Only one notifyListeners call — at the very end after all state is settled
      notifyListeners();
    }
  }

  /// Called after a successful subscription to immediately update the gate state.
  void markSubscribed() {
    _hasSubscription = true;
    notifyListeners();
  }

  /// Resets the subscription existence check (called on logout).
  void resetSubscriptionCheck() {
    _hasSubscription = null;
    _checkError = null;
    _isCheckingSubscription = false;
    _initialized = false;
    _lastFetchedRole = null; // Important: Clear last role on logout
    _availablePlans = [];
    _currentSubscription = null;
    _entitlements = {};
    notifyListeners();
  }
}
