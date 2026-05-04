import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../providers/farmer_dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/farmer_dashboard_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../main_screen.dart';
import 'components/hero_metrics_block.dart';
import 'components/smart_alerts_section.dart';
import 'components/quick_actions_grid.dart';
import 'components/lands_operational_list.dart';
import 'components/active_workers_strip.dart';
import 'components/ai_assistant_strip.dart';
import 'add_land_screen.dart';
import 'workforce_screen.dart';
import 'rental_requests_screen.dart';
import 'crop_calendar_screen.dart';
import '../../features/ai_assistant/ai_screen.dart';

class FarmerOperationalDashboard extends StatefulWidget {
  const FarmerOperationalDashboard({super.key});

  @override
  State<FarmerOperationalDashboard> createState() =>
      _FarmerOperationalDashboardState();
}

class _FarmerOperationalDashboardState extends State<FarmerOperationalDashboard>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  String? _lastLocaleCode;
  bool _isQuickActionNavigating = false;
  String? _quickActionLoadingLabel;
  bool _animateIn = false;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String _currentLocaleCode() {
    return Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animateIn = true;
        });
      }
    });
  }

  void _loadData() {
    Future.microtask(() {
      final provider = context.read<FarmerDashboardProvider>();
      provider.loadDashboard(localeCode: _currentLocaleCode());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<FarmerDashboardProvider>();
    final localeCode = _currentLocaleCode();

    if (state == AppLifecycleState.resumed) {
      provider.setVisibility(true, localeCode: localeCode);
      provider.syncIfStale(
        localeCode: localeCode,
        maxAge: const Duration(seconds: 10),
      );
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      provider.setVisibility(false, localeCode: localeCode);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = _currentLocaleCode();
    final provider = context.read<FarmerDashboardProvider>();

    provider.setVisibility(true, localeCode: localeCode);
    if (_lastLocaleCode != localeCode) {
      _lastLocaleCode = localeCode;
      provider.syncIfStale(
        localeCode: localeCode,
        maxAge: Duration.zero,
      );
    }
  }

  @override
  void dispose() {
    context.read<FarmerDashboardProvider>().setVisibility(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      await context.read<FarmerDashboardProvider>().refresh(
        localeCode: _currentLocaleCode(),
      );
    } catch (_) {
      if (!mounted) return;
      _showNavigationError(_l10n.failedToLoadData);
    }
  }

  Route<T> _buildSoftRoute<T>(Widget screen) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _withQuickActionGuard({
    required String loadingLabel,
    required Future<void> Function() action,
  }) async {
    if (!mounted || _isQuickActionNavigating) return;

    setState(() {
      _isQuickActionNavigating = true;
      _quickActionLoadingLabel = loadingLabel;
    });

    try {
      await action();
    } catch (_) {
      if (mounted) {
        _showNavigationError(_l10n.somethingWentWrong);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isQuickActionNavigating = false;
          _quickActionLoadingLabel = null;
        });
      }
    }
  }

  Future<void> _navigateToTab(int index) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user?.role.toLowerCase() != 'farmer') {
      return;
    }

    final switched = MainScreen.trySwitchToTab(context, index);
    if (switched) {
      // Keep the loading state visible only for the transition frame.
      await Future<void>.delayed(const Duration(milliseconds: 120));
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      _buildSoftRoute(MainScreen(initialIndex: index)),
      (route) => false,
    );
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }

  void _showNavigationError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _pushWithTransition(Widget screen) async {
    if (!mounted) return;
    Navigator.of(context).push(_buildSoftRoute(screen));
    await Future<void>.delayed(const Duration(milliseconds: 280));
  }

  Future<void> _navigateToLandManagement() async {
    await _withQuickActionGuard(
      loadingLabel: _l10n.loading,
      action: () => _navigateToTab(1),
    );
  }

  Future<void> _navigateToItemRequests() async {
    await _withQuickActionGuard(
      loadingLabel: _l10n.loading,
      action: () => _pushWithTransition(const FarmerRentalRequestsScreen()),
    );
  }

  Future<void> _navigateToAddLand() async {
    await _withQuickActionGuard(
      loadingLabel: _l10n.loading,
      action: () => _pushWithTransition(const FarmerAddLandScreen()),
    );
  }

  Future<void> _navigateToReviewRequests() async {
    await _navigateToItemRequests();
  }

  Future<void> _showLandSelectorForInviteWorker() async {
    final provider = context.read<FarmerDashboardProvider>();
    final lands = provider.lands;

    if (lands.isEmpty) {
      _showNoLandsDialog();
      return;
    }

    if (lands.length == 1) {
      _navigateToWorkforce(lands.first, withLoader: true);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LandSelectorSheet(
        lands: lands,
        onLandSelected: (land) {
          Navigator.pop(context);
          _navigateToWorkforce(land, withLoader: true);
        },
      ),
    );
  }

  void _showNoLandsDialog() {
    final l10n = _l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.noLandsYet),
        content: Text(l10n.addFirstLandMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAddLand();
            },
            child: Text(l10n.quickActionAddLand),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToWorkforce(
    LandOperational land, {
    bool withLoader = false,
  }) async {
    Future<void> action() {
      return _pushWithTransition(
        WorkforceScreen(landId: land.id, landName: land.name, canHire: true),
      );
    }

    if (withLoader) {
      await _withQuickActionGuard(
        loadingLabel: _l10n.loading,
        action: action,
      );
      return;
    }

    await action();
  }

  Future<void> _navigateToManageProducts() async {
    await _withQuickActionGuard(
      loadingLabel: _l10n.loading,
      action: () => _navigateToTab(2),
    );
  }

  Future<void> _navigateToAIAssistant() async {
    await _withQuickActionGuard(
      loadingLabel: _l10n.loading,
      action: () => _pushWithTransition(const AiAssistantScreen()),
    );
  }

  Future<void> _navigateToCropCalendar() async {
    await _withQuickActionGuard(
      loadingLabel: _l10n.loading,
      action: () => _pushWithTransition(const CropCalendarScreen()),
    );
  }

  Future<void> _navigateToWorkerPerformance() async {
    await _withQuickActionGuard(
      loadingLabel: _l10n.loading,
      action: () => _navigateToTab(3),
    );
  }

  Future<void> _handleAlertTap(SmartAlert alert) async {
    if (alert.actionRoute == '/land-grid' && alert.landId != null) {
      final provider = context.read<FarmerDashboardProvider>();
      if (provider.lands.isEmpty) {
        _showNavigationError(_l10n.noLandsFound);
        return;
      }

      final land = provider.lands.firstWhere(
        (l) => l.id == alert.landId,
        orElse: () => provider.lands.first,
      );
      await _navigateToWorkforce(land, withLoader: true);
    }
  }

  Future<void> _handleRepairTap(SmartAlert alert) async {
    if (alert.itemId != null) {
      final provider = context.read<FarmerDashboardProvider>();
      final success = await provider.repairItem(alert.itemId!);
      if (!success && mounted) {
        _showNavigationError(
          _localizedErrorText(provider.error),
        );
      }
    }
  }

  Widget _buildEntryAnimation({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 350 + (index * 80)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: _animateIn ? 1 : 0),
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }

  String _localizedErrorText(String? rawError) {
    final text = (rawError ?? '').toLowerCase();

    if (text.contains('internet') ||
        text.contains('network') ||
        text.contains('socket')) {
      return _l10n.noInternetDescription;
    }

    if (text.contains('timeout')) {
      return _l10n.tryAgain;
    }

    if (text.contains('unauthorized') || text.contains('forbidden')) {
      return _l10n.somethingWentWrong;
    }

    if (text.contains('invalid response') || text.contains('format')) {
      return _l10n.failedToLoadData;
    }

    return _l10n.failedToLoadData;
  }

  Widget _buildSoftErrorBanner(FarmerDashboardProvider provider) {
    if (provider.error == null || !provider.hasData) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.24)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: colorScheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _localizedErrorText(provider.error),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              _refresh();
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              _l10n.retry,
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionOverlay() {
    if (!_isQuickActionNavigating) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: AnimatedOpacity(
          opacity: _isQuickActionNavigating ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: ColoredBox(
            color: Colors.black.withOpacity(0.16),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _quickActionLoadingLabel ?? _l10n.loading,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = _l10n.goodMorning;
    } else if (hour < 17) {
      greeting = _l10n.goodAfternoon;
    } else {
      greeting = _l10n.goodEvening;
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            Consumer<FarmerDashboardProvider>(
              builder: (context, provider, child) {
                if (provider.error != null && !provider.hasData) {
                  return _buildErrorState(context, provider);
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  color: colorScheme.primary,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      // Header Section with greeting and profile
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      greeting,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.name ?? user?.email ?? _l10n.user,
                                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              _buildProfileAvatar(context, user, theme),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: provider.isRefreshing ? 2.5 : 0,
                          child: provider.isRefreshing
                              ? LinearProgressIndicator(
                                  color: colorScheme.primary,
                                  backgroundColor: colorScheme.primary
                                      .withOpacity(0.18),
                                )
                              : null,
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildSoftErrorBanner(provider)),
                      SliverToBoxAdapter(
                        child: _buildEntryAnimation(
                          index: 0,
                          child: HeroMetricsBlock(
                            onLandsTap: () {
                              _navigateToLandManagement();
                            },
                            onItemRequestsTap: () {
                              _navigateToItemRequests();
                            },
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: _buildEntryAnimation(
                        index: 1,
                        child: SmartAlertsSection(
                          onAlertTap: (alert) {
                            _handleAlertTap(alert);
                          },
                          onRepairTap: (alert) {
                            _handleRepairTap(alert);
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildEntryAnimation(
                        index: 2,
                        child: QuickActionsGrid(
                          onAddLand: () {
                            _navigateToAddLand();
                          },
                          onReviewRequests: () {
                            _navigateToReviewRequests();
                          },
                          onInviteWorker: () {
                            _showLandSelectorForInviteWorker();
                          },
                          onManageProducts: () {
                            _navigateToManageProducts();
                          },
                          onAIAssistant: () {
                            _navigateToAIAssistant();
                          },
                          onCropCalendar: () {
                            _navigateToCropCalendar();
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildEntryAnimation(
                        index: 3,
                        child: LandsOperationalList(
                          onLandTap: (land) {
                            _navigateToWorkforce(land);
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildEntryAnimation(
                        index: 4,
                        child: ActiveWorkersStrip(
                          onWorkerTap: (worker) {
                            _navigateToWorkerPerformance();
                          },
                          onSeeAllTap: () {
                            _navigateToWorkerPerformance();
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildEntryAnimation(
                        index: 5,
                        child: AIAssistantStrip(
                          onStartConversation: () {
                            _navigateToAIAssistant();
                          },
                          onViewAllSessions: () {
                            _navigateToAIAssistant();
                          },
                          onSessionTap: (session) {
                            _navigateToAIAssistant();
                          },
                        ),
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 112)),
                  ],
                ),
              );
            },
          ),
          _buildQuickActionOverlay(),
        ],
      ),
    ),
  );
  }

  // ==========================================
  // PROFILE AVATAR WITH LOADING & ERROR HANDLING
  // ==========================================

  Widget _buildProfileAvatar(BuildContext context, User? user, ThemeData theme) {
    final String? rawPictureUrl = user?.profilePicture;
    final String? resolvedUrl = _resolveProfileImageUrl(rawPictureUrl);
    final String displayName = user?.name ?? user?.email ?? 'User';

    // If no URL, show fallback immediately
    if (resolvedUrl == null) {
      return _buildAvatarFallback(theme, displayName);
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          resolvedUrl,
          fit: BoxFit.cover,
          width: 56,
          height: 56,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 260),
                child: child,
              );
            }
            // Show shimmer/loading state while frame is loading
            return _buildAvatarLoading(theme);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildAvatarLoading(theme);
          },
          errorBuilder: (context, error, stackTrace) {
            // Log error for debugging but don't crash
            debugPrint('Profile image failed to load: $resolvedUrl - $error');
            return _buildAvatarFallback(theme, displayName);
          },
        ),
      ),
    );
  }

  Widget _buildAvatarLoading(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(ThemeData theme, String name) {
    final initials = _getInitials(name);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                color: Colors.white.withOpacity(0.9),
                size: 28,
              ),
      ),
    );
  }

  String? _resolveProfileImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return null;

    // If it's already a full URL with scheme, return as-is
    final uri = Uri.tryParse(rawPath);
    if (uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return rawPath;
    }

    // Otherwise, prepend the base URL
    final base = AuthService.baseUrl;
    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanPath = rawPath.startsWith('/') ? rawPath : '/$rawPath';
    return '$cleanBase$cleanPath';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Widget _buildErrorState(
    BuildContext context,
    FarmerDashboardProvider provider,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _l10n.failedLoadDashboard,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _localizedErrorText(provider.error),
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                provider.loadDashboard(localeCode: _currentLocaleCode());
              },
              icon: const Icon(Icons.refresh),
              label: Text(_l10n.retry),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandSelectorSheet extends StatelessWidget {
  final List<LandOperational> lands;
  final Function(LandOperational) onLandSelected;

  const _LandSelectorSheet({required this.lands, required this.onLandSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.selectLand,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.inviteToLand,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lands.length,
            itemBuilder: (context, index) {
              final land = lands[index];
              return _LandOptionTile(
                land: land,
                onTap: () => onLandSelected(land),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LandOptionTile extends StatelessWidget {
  final LandOperational land;
  final VoidCallback onTap;

  const _LandOptionTile({required this.land, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    String statusText;

    Color statusColor;
    IconData statusIcon;
    switch (land.status) {
      case LandOperationalStatus.rented:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        statusText = l10n.statusRented;
        break;
      case LandOperationalStatus.harvestReady:
        statusColor = Colors.green;
        statusIcon = Icons.eco;
        statusText = l10n.harvestReady;
        break;
      case LandOperationalStatus.pendingRequests:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
        statusText = l10n.pendingRequests;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.landscape;
        statusText = l10n.statusOwned;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.landscape,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      land.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${land.activeWorkers} ${l10n.workersCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
