import 'dart:async';
import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';
import '../services/subscription_service.dart';

/// Represents the loading state for subscription data.
enum SubscriptionLoadState { idle, loading, loaded, error }

class SubscriptionProvider with ChangeNotifier {
  UserSubscription? _currentSubscription;
  Map<String, dynamic> _entitlements = {};
  List<SubscriptionPlan> _availablePlans = [];
  bool _isLoading = false;
  String? _error;

  // Granular loading states
  SubscriptionLoadState _plansState = SubscriptionLoadState.idle;
  SubscriptionLoadState _subscriptionState = SubscriptionLoadState.idle;
  String? _plansError;
  String? _subscriptionError;

  // Subscription existence gate
  bool? _hasSubscription;
  bool _isCheckingSubscription = false;
  String? _checkError;

  // Staleness tracking — refresh data if older than threshold
  DateTime? _lastPlansRefresh;
  DateTime? _lastSubscriptionRefresh;
  static const Duration _staleThreshold = Duration(minutes: 5);

  // Debounce protection
  Completer<void>? _initCompleter;
  Completer<void>? _refreshCompleter;

  UserSubscription? get currentSubscription => _currentSubscription;
  Map<String, dynamic> get entitlements => _entitlements;
  List<SubscriptionPlan> get availablePlans => _availablePlans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SubscriptionLoadState get plansState => _plansState;
  SubscriptionLoadState get subscriptionState => _subscriptionState;
  String? get plansError => _plansError;
  String? get subscriptionError => _subscriptionError;

  bool? get hasSubscription => _hasSubscription;
  bool get isCheckingSubscription => _isCheckingSubscription;
  String? get checkError => _checkError;

  /// Whether all critical data has loaded at least once.
  bool get isFullyLoaded =>
      _plansState == SubscriptionLoadState.loaded &&
      _subscriptionState == SubscriptionLoadState.loaded;

  /// Whether any part is actively loading (for composite UI states).
  bool get isAnyLoading =>
      _plansState == SubscriptionLoadState.loading ||
      _subscriptionState == SubscriptionLoadState.loading;

  /// Checks a boolean entitlement. Handles `true`, `"true"`, and `1`.
  bool hasEntitlement(String key) {
    final value = _entitlements[key];
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  /// Alias for [hasEntitlement] — checks boolean feature access.
  bool hasFeature(String key) => hasEntitlement(key);

  /// Returns a numeric limit. Handles int, double, and string-encoded numbers.
  /// Returns [defaultValue] only when the key is completely absent.
  num getLimit(String key, num defaultValue) {
    final value = _entitlements[key];
    if (value == null) return defaultValue;
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }

  bool isWithinLimit(String key, int currentValue) {
    final limit = getLimit(key, 0);
    if (limit == -1) return true;
    return currentValue < limit;
  }

  String get planName => _currentSubscription?.plan.name ?? 'Farmy Free';

  bool get isFreePlan =>
      _currentSubscription?.paymentMethod == 'free' ||
      (_currentSubscription?.plan.price ?? 0) == 0;

  bool _initialized = false;
  String? _lastFetchedRole;

  /// Initializes subscription data. Safe to call multiple times — debounces
  /// and skips if already initialized for the same role.
  Future<void> init({String? role}) async {
    // If already running, return the existing future
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }

    // Skip if already initialized for same role and data is fresh
    if (_initialized && role == _lastFetchedRole && !_isDataStale()) {
      return;
    }

    // If role changed, force a full reset of cached data to avoid stale leakage
    if (_lastFetchedRole != null && role != _lastFetchedRole) {
      debugPrint(
        'SubscriptionProvider: Role changed from $_lastFetchedRole to $role — clearing stale data',
      );
      _currentSubscription = null;
      _entitlements = {};
      _availablePlans = [];
      _plansState = SubscriptionLoadState.idle;
      _subscriptionState = SubscriptionLoadState.idle;
      _plansError = null;
      _subscriptionError = null;
      _lastPlansRefresh = null;
      _lastSubscriptionRefresh = null;
    }
    _lastFetchedRole = role;

    _initCompleter = Completer<void>();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch subscription + plans in parallel for faster init
      await Future.wait([
        _refreshSubscriptionInternal(),
        _fetchPlansInternal(role: role),
      ], eagerError: false);

      // Collect errors — don't fail completely if one part fails
      final errors = <String>[];
      if (_subscriptionError != null) errors.add(_subscriptionError!);
      if (_plansError != null) errors.add(_plansError!);

      if (errors.isNotEmpty &&
          _availablePlans.isEmpty &&
          _currentSubscription == null) {
        _error = errors.join(' | ');
      }

      _initialized = true;
    } catch (e) {
      _error = e.toString();
      debugPrint('SubscriptionProvider Init Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
    }
  }

  /// Refreshes just the current subscription + entitlements.
  Future<void> refresh() async {
    // Debounce: if already refreshing, wait for that to finish
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<void>();

    try {
      await _refreshSubscriptionInternal();
    } finally {
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete();
      }
    }
  }

  /// Reconciles any pending Stripe payment left from an interrupted app flow.
  /// Returns the resolved status when a pending payment existed.
  Future<String?> reconcilePendingStripePayment() async {
    try {
      final result = await SubscriptionService.reconcilePendingStripePayment();
      if (result == null) return null;

      final status = result['status']?.toString() ?? 'processing';

      if (status == 'succeeded') {
        await _refreshSubscriptionInternal();
        _hasSubscription = true;
      }

      return status;
    } catch (e) {
      debugPrint('Pending Stripe payment reconciliation failed: $e');
      return null;
    }
  }

  /// Full refresh of both subscription and plans (for pull-to-refresh).
  Future<void> fullRefresh({String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _refreshSubscriptionInternal(),
        _fetchPlansInternal(role: role ?? _lastFetchedRole),
      ], eagerError: false);

      final errors = <String>[];
      if (_subscriptionError != null) errors.add(_subscriptionError!);
      if (_plansError != null) errors.add(_plansError!);

      _error = errors.isEmpty ? null : errors.join(' | ');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Internal: fetches current subscription without debounce wrapper.
  Future<void> _refreshSubscriptionInternal() async {
    _subscriptionState = SubscriptionLoadState.loading;
    _subscriptionError = null;
    // Don't notify here — caller controls notifications

    try {
      final data = await SubscriptionService.getCurrentSubscription();
      _currentSubscription = data['subscription'];

      // ── Entitlements with multi-layer fallback ────────────────────────
      final apiEntitlements = data['entitlements'] as Map<String, dynamic>?;

      if (apiEntitlements != null && apiEntitlements.isNotEmpty) {
        _entitlements = apiEntitlements;
      } else if (_currentSubscription?.entitlementsSnapshot != null &&
          _currentSubscription!.entitlementsSnapshot!.isNotEmpty) {
        // Fallback: use the snapshot embedded in the subscription object
        debugPrint(
          'SubscriptionProvider: API entitlements empty — using subscription snapshot',
        );
        _entitlements = _currentSubscription!.entitlementsSnapshot!;
      } else if (_currentSubscription != null &&
          _currentSubscription!.plan.entitlements.isNotEmpty) {
        // Fallback: use the plan's own entitlements
        debugPrint(
          'SubscriptionProvider: Both API & snapshot empty — using plan entitlements',
        );
        _entitlements = Map<String, dynamic>.from(
          _currentSubscription!.plan.entitlements,
        );
      } else {
        // Last resort: keep whatever we had or empty
        debugPrint(
          'SubscriptionProvider: WARNING — no usable entitlements from any source',
        );
        _entitlements = apiEntitlements ?? {};
      }

      _subscriptionState = SubscriptionLoadState.loaded;
      _lastSubscriptionRefresh = DateTime.now();
      _subscriptionError = null;
    } on SubscriptionException catch (e) {
      _subscriptionError = e.message;
      _subscriptionState = _currentSubscription != null
          ? SubscriptionLoadState
                .loaded // Keep stale data visible
          : SubscriptionLoadState.error;
      debugPrint('Refresh Subscription Error: $e');
    } catch (e) {
      _subscriptionError = e.toString();
      _subscriptionState = _currentSubscription != null
          ? SubscriptionLoadState.loaded
          : SubscriptionLoadState.error;
      debugPrint('Refresh Subscription Error: $e');
    }
    notifyListeners();
  }

  /// Fetches plans for a given role.
  Future<void> fetchPlans({String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _fetchPlansInternal(role: role);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Internal: fetches plans without modifying top-level loading state.
  Future<void> _fetchPlansInternal({String? role}) async {
    _plansState = SubscriptionLoadState.loading;
    _plansError = null;

    try {
      _availablePlans = await SubscriptionService.getPlans(role: role);
      _lastFetchedRole = role;
      _plansState = SubscriptionLoadState.loaded;
      _lastPlansRefresh = DateTime.now();
      _plansError = null;
    } on SubscriptionException catch (e) {
      _plansError = e.message;
      _plansState = _availablePlans.isNotEmpty
          ? SubscriptionLoadState.loaded
          : SubscriptionLoadState.error;
      debugPrint('Fetch Plans Error: $e');
    } catch (e) {
      _plansError = e.toString();
      _plansState = _availablePlans.isNotEmpty
          ? SubscriptionLoadState.loaded
          : SubscriptionLoadState.error;
      debugPrint('Fetch Plans Error: $e');
    }
  }

  Future<void> upgradeWithCredits(String planKey, String billingCycle) async {
    _isLoading = true;
    notifyListeners();
    try {
      await SubscriptionService.upgradeWithCredits(planKey, billingCycle);
      await _refreshSubscriptionInternal();
      _hasSubscription = true;
    } catch (e) {
      debugPrint('Upgrade with Credits Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if the user has any subscription history.
  /// Caches the result so it only hits the network once per session.
  Future<bool> checkSubscriptionExistence() async {
    if (_hasSubscription != null) return _hasSubscription!;
    if (_isCheckingSubscription) return false;

    _isCheckingSubscription = true;
    _checkError = null;

    try {
      final result = await SubscriptionService.checkSubscriptionExistence();
      _hasSubscription = result['hasSubscription'] as bool;
      if (result['activeSubscription'] != null &&
          _currentSubscription == null) {
        _currentSubscription = result['activeSubscription'] as UserSubscription;
      }
      return _hasSubscription!;
    } catch (e) {
      _checkError = e.toString();
      debugPrint('Check Subscription Existence Error: $e');
      _hasSubscription = true;
      return true;
    } finally {
      _isCheckingSubscription = false;
      notifyListeners();
    }
  }

  void markSubscribed() {
    _hasSubscription = true;
    notifyListeners();
  }

  /// Resets all state (called on logout).
  void resetSubscriptionCheck() {
    _hasSubscription = null;
    _checkError = null;
    _isCheckingSubscription = false;
    _initialized = false;
    _lastFetchedRole = null;
    _availablePlans = [];
    _currentSubscription = null;
    _entitlements = {};
    _plansState = SubscriptionLoadState.idle;
    _subscriptionState = SubscriptionLoadState.idle;
    _plansError = null;
    _subscriptionError = null;
    _lastPlansRefresh = null;
    _lastSubscriptionRefresh = null;
    _error = null;
    _initCompleter = null;
    _refreshCompleter = null;
    notifyListeners();
  }

  /// Returns true if cached data is considered stale.
  bool _isDataStale() {
    if (_lastPlansRefresh == null || _lastSubscriptionRefresh == null) {
      return true;
    }
    final now = DateTime.now();
    return now.difference(_lastPlansRefresh!) > _staleThreshold ||
        now.difference(_lastSubscriptionRefresh!) > _staleThreshold;
  }
}
