import 'dart:async';
import 'dart:math' as math;

import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';

enum _ProfilePreviewErrorType {
  notFound,
  server,
  network,
  timeout,
  restricted,
  unknown,
}

class ProfilePreviewSheet extends StatefulWidget {
  final String userId;
  final User? initialUser;

  const ProfilePreviewSheet({
    super.key,
    required this.userId,
    this.initialUser,
  });

  static Future<void> show(
    BuildContext context,
    String userId, {
    User? initialUser,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ProfilePreviewSheet(userId: userId, initialUser: initialUser),
    );
  }

  @override
  State<ProfilePreviewSheet> createState() => _ProfilePreviewSheetState();
}

class _ProfilePreviewSheetState extends State<ProfilePreviewSheet> {
  User? _user;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  String? _syncError;
  _ProfilePreviewErrorType _errorType = _ProfilePreviewErrorType.unknown;
  final Set<String> _failedImageUrls = <String>{};

  bool _isDisposed = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
    // Defer fetch until after first frame to access inherited widgets safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !mounted) return;
      _fetchProfile();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    // Safely get localizations - context is now valid after first frame
    final l10n = AppLocalizations.of(context);
    final fallbackNotFound = 'Profile not found';
    final fallbackLoadError = 'Failed to load profile';

    if (widget.userId.trim().isEmpty) {
      if (_isDisposed || !mounted) return;
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _error = l10n?.profileNotFound ?? fallbackNotFound;
        _errorType = _ProfilePreviewErrorType.notFound;
      });
      return;
    }

    if (_isDisposed || !mounted) return;
    setState(() {
      _isLoading = _user == null;
      _isRefreshing = _user != null;
      _error = null;
      _syncError = null;
      _errorType = _ProfilePreviewErrorType.unknown;
    });

    // Safety timeout to prevent hanging in loading state
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (_isDisposed || !mounted) return;
      if (_isLoading) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _error = l10n?.profileLoadError ?? fallbackLoadError;
          _errorType = _ProfilePreviewErrorType.timeout;
        });
      }
    });

    try {
      final user = await AuthService.fetchPublicProfile(
        widget.userId,
      ).timeout(const Duration(seconds: 14));
      
      _timeoutTimer?.cancel();
      if (_isDisposed || !mounted) return;
      
      setState(() {
        _user = user;
        _isLoading = false;
        _isRefreshing = false;
        _failedImageUrls.clear();
        _error = user == null 
            ? (l10n?.profileNotFound ?? fallbackNotFound) 
            : null;
        _errorType = user == null
            ? _ProfilePreviewErrorType.notFound
            : _ProfilePreviewErrorType.unknown;
      });
    } catch (e) {
      _timeoutTimer?.cancel();
      if (_isDisposed || !mounted) return;
      
      final errorType = _classifyError(e);
      final errorMessage = _friendlyError(e, l10n?.profileLoadError ?? fallbackLoadError);
      
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        if (_user == null) {
          _error = errorMessage;
          _errorType = errorType;
        } else {
          _syncError = errorMessage;
        }
      });
    }
  }

  _ProfilePreviewErrorType _classifyError(Object error) {
    if (error is ProfileFetchException) {
      final lower = error.message.toLowerCase();
      if (error.isNotFound) return _ProfilePreviewErrorType.notFound;
      if (error.isUnauthorized) return _ProfilePreviewErrorType.restricted;
      if (error.isServerError) return _ProfilePreviewErrorType.server;
      if (error.isNetworkError && lower.contains('timed out')) {
        return _ProfilePreviewErrorType.timeout;
      }
      if (error.isNetworkError) return _ProfilePreviewErrorType.network;
    }

    if (error is TimeoutException) return _ProfilePreviewErrorType.timeout;
    final lower = error.toString().toLowerCase();
    if (lower.contains('socketexception') || lower.contains('connection')) {
      return _ProfilePreviewErrorType.network;
    }
    if (lower.contains('timed out')) return _ProfilePreviewErrorType.timeout;
    if (lower.contains('404') || lower.contains('not found')) {
      return _ProfilePreviewErrorType.notFound;
    }
    if (lower.contains('500') || lower.contains('server')) {
      return _ProfilePreviewErrorType.server;
    }
    if (lower.contains('401') || lower.contains('403')) {
      return _ProfilePreviewErrorType.restricted;
    }
    return _ProfilePreviewErrorType.unknown;
  }

  String _friendlyError(Object error, String fallback) {
    if (error is ProfileFetchException) return error.message;
    final raw = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    final lower = raw.toLowerCase();
    if (lower.contains('socketexception') || lower.contains('connection')) {
      return 'Unable to sync this profile. Check your connection and try again.';
    }
    if (error is TimeoutException || lower.contains('timed out')) {
      return 'Profile preview is taking too long to load. Pull down or tap retry to sync again.';
    }
    // Safely access localizations with fallbacks
    final l10n = _isDisposed || !mounted ? null : AppLocalizations.of(context);
    if (lower.contains('404') || lower.contains('not found')) {
      return l10n?.profileNotFound ?? 'Profile not found';
    }
    if (lower.contains('401') || lower.contains('403')) {
      return l10n?.privacyRestricted ?? 'This profile is private';
    }
    return raw.trim().isEmpty ? fallback : raw.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final sheetHeight = math.min(size.height * 0.92, 820.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SizedBox(
          height: sheetHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _isLoading
                    ? _buildShimmer(theme)
                    : _error != null && _user == null
                    ? _buildErrorView(theme)
                    : _buildContent(theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final user = _user;
    if (user == null) return _buildErrorView(theme);

    final profile = user.profile;
    
    // Check if profile is discoverable - if not, show restricted view
    final isDiscoverable = profile?.discoverable ?? true;
    if (!isDiscoverable) {
      return _buildRestrictedView(theme, user);
    }
    final isDark = theme.brightness == Brightness.dark;
    final name = _displayName(user);
    final username = _optional(profile?.username);
    final headline = _optional(profile?.headline);
    final location = _location(profile);

    return RefreshIndicator(
      onRefresh: _fetchProfile,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(
              theme,
              user,
              name,
              username,
              headline,
              location,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isRefreshing || _syncError != null) ...[
                    _buildSyncBanner(theme),
                    const SizedBox(height: 16),
                  ],
                  if (_failedImageUrls.isNotEmpty) ...[
                    _buildImageWarningBanner(theme),
                    const SizedBox(height: 16),
                  ],
                  _buildStatsGrid(theme, user),
                  const SizedBox(height: 18),
                  _buildAboutCard(theme, profile, isDark),
                  const SizedBox(height: 18),
                  _buildProfileDetails(theme, user),
                  if (_hasLinksOrContact(user)) ...[
                    const SizedBox(height: 18),
                    _buildLinksCard(theme, user),
                  ],
                  const SizedBox(height: 28),
                  _buildFooter(theme, user),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    User user,
    String name,
    String? username,
    String? headline,
    String? location,
  ) {
    final profile = user.profile;
    final width = MediaQuery.sizeOf(context).width;
    final avatarSize = width < 380 ? 88.0 : 104.0;
    final roleLabel = _getRoleLabel(context, user.role);

    return SizedBox(
      height: width < 380 ? 286 : 312,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCover(theme, profile),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
          Positioned(top: 18, right: 18, child: _buildCloseButton()),
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAvatar(theme, profile, name, avatarSize),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width < 380 ? 22 : 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF42A5F5),
                            size: 22,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHeaderPill(Icons.badge_outlined, roleLabel),
                        if (username != null)
                          _buildHeaderPill(Icons.alternate_email, username),
                        if (location != null)
                          _buildHeaderPill(Icons.place_outlined, location),
                      ],
                    ),
                    if (headline != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        headline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(ThemeData theme, UserProfile? profile) {
    final coverUrl =
        _resolveAssetUrl(profile?.coverImage) ??
        _resolveAssetUrl(profile?.picture);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildCoverFallback(theme),
        if (coverUrl != null)
          _buildResilientNetworkImage(
            url: coverUrl,
            fit: BoxFit.cover,
            fallback: _buildCoverFallback(theme),
            semanticLabel: 'Profile cover image',
          ),
        // Subtle dark overlay for text readability - NO BLUR
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.55),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.32),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.48),
                    ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverFallback(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.secondary,
            theme.colorScheme.primary,
            const Color(0xFFB8C56A),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -32,
            top: -28,
            child: _decorativeOrb(150, Colors.white.withValues(alpha: 0.12)),
          ),
          Positioned(
            left: -24,
            bottom: 18,
            child: _decorativeOrb(110, Colors.white.withValues(alpha: 0.08)),
          ),
        ],
      ),
    );
  }

  Widget _decorativeOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.black.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.close_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildAvatar(
    ThemeData theme,
    UserProfile? profile,
    String name,
    double size,
  ) {
    final imageUrl = _resolveAssetUrl(profile?.picture);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl == null
            ? _buildAvatarFallback(theme, name)
            : _buildResilientNetworkImage(
                url: imageUrl,
                fit: BoxFit.cover,
                fallback: _buildAvatarFallback(theme, name),
                semanticLabel: 'Profile avatar image',
              ),
      ),
    );
  }

  Widget _buildResilientNetworkImage({
    required String url,
    required BoxFit fit,
    required Widget fallback,
    required String semanticLabel,
  }) {
    if (_failedImageUrls.contains(url)) return fallback;

    return Image.network(
      url,
      fit: fit,
      semanticLabel: semanticLabel,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 220),
            child: child,
          );
        }
        return fallback;
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        final expectedBytes = loadingProgress.expectedTotalBytes;
        final loadedBytes = loadingProgress.cumulativeBytesLoaded;
        final progress = expectedBytes == null || expectedBytes == 0
            ? null
            : (loadedBytes / expectedBytes).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            fallback,
            Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.4,
                  color: Colors.white.withValues(alpha: 0.92),
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) {
        _registerFailedImage(url);
        return fallback;
      },
    );
  }

  void _registerFailedImage(String url) {
    if (_failedImageUrls.contains(url)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _failedImageUrls.contains(url)) return;
      setState(() => _failedImageUrls.add(url));
    });
  }

  Widget _buildAvatarFallback(ThemeData theme, String name) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: Center(
        child: Text(
          _initials(name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncBanner(ThemeData theme) {
    final isError = _syncError != null;
    final color = isError ? theme.colorScheme.error : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          if (_isRefreshing)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            )
          else
            Icon(Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isRefreshing ? 'Syncing latest profile details…' : _syncError!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isError)
            TextButton(
              onPressed: _fetchProfile,
              child: Text(AppLocalizations.of(context)?.retryButton ?? 'Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWarningBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.image_not_supported_outlined, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Some profile images could not be loaded. The profile is still available with secure fallbacks.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: _retryFailedImages,
            child: Text(AppLocalizations.of(context)?.retryButton ?? 'Retry'),
          ),
        ],
      ),
    );
  }

  void _retryFailedImages() {
    for (final url in _failedImageUrls) {
      NetworkImage(url).evict();
    }
    setState(() => _failedImageUrls.clear());
  }

  Widget _buildStatsGrid(ThemeData theme, User user) {
    final profile = user.profile;
    final stats = <_ProfileStat>[
      _ProfileStat(
        Icons.badge_rounded,
        AppLocalizations.of(context)?.roleLabel ?? 'Role',
        _getRoleLabel(context, user.role),
      ),
      _ProfileStat(
        Icons.verified_user_rounded,
        'Status',
        user.isVerified ? 'Verified' : 'Unverified',
      ),
      _ProfileStat(
        Icons.insights_rounded,
        AppLocalizations.of(context)?.completenessLabel ?? 'Complete',
        '${profile?.completenessScore ?? 0}%',
      ),
      if (user.role.toLowerCase() == 'investor')
        _ProfileStat(
          Icons.landscape_rounded,
          AppLocalizations.of(context)?.landsRented ?? 'Lands',
          '${user.rentedLandsCount ?? 0}',
        )
      else
        _ProfileStat(
          Icons.calendar_month_rounded,
          'Member since',
          _memberSince(user.createdAt, short: true),
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth < 360
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats
              .map((stat) => _buildStatCard(theme, stat, cardWidth))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard(ThemeData theme, _ProfileStat stat, double width) {
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface.withValues(alpha: 0.72)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                stat.icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(ThemeData theme, UserProfile? profile, bool isDark) {
    final bio = _optional(profile?.bio);
    return _sectionCard(
      theme,
      title: AppLocalizations.of(context)?.aboutLabel ?? 'About',
      icon: Icons.eco_rounded,
      child: Text(
        bio ??
            'This member has not added a bio yet. Profile details will appear here once shared.',
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.55,
          color: bio == null
              ? theme.colorScheme.onSurface.withValues(alpha: 0.55)
              : theme.colorScheme.onSurface.withValues(
                  alpha: isDark ? 0.78 : 0.72,
                ),
        ),
      ),
    );
  }

  Widget _buildProfileDetails(ThemeData theme, User user) {
    final profile = user.profile;
    final chips = <String>[
      ..._safeList(profile?.productionTypes),
      ..._safeList(profile?.farmLocations),
      ..._safeList(profile?.preferredHiringTypes),
      ..._safeList(profile?.investmentFocus),
      ..._safeList(profile?.preferredRegions),
      if (_optional(profile?.businessName) != null) profile!.businessName!,
      if (_optional(profile?.workforceSize) != null)
        'Workforce: ${profile!.workforceSize}',
      if (_optional(profile?.budgetRange) != null)
        'Budget: ${profile!.budgetRange}',
      if (_optional(profile?.riskProfile) != null)
        'Risk: ${profile!.riskProfile}',
      if (_optional(profile?.involvementLevel) != null)
        profile!.involvementLevel!,
    ];

    if (chips.isEmpty) {
      return _sectionCard(
        theme,
        title: 'Highlights',
        icon: Icons.auto_awesome_rounded,
        child: Text(
          'No public highlights are available for this profile yet.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
          ),
        ),
      );
    }

    return _sectionCard(
      theme,
      title: 'Highlights',
      icon: Icons.auto_awesome_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips
            .take(12)
            .map((chip) => _buildChip(theme, chip))
            .toList(),
      ),
    );
  }

  Widget _buildLinksCard(ThemeData theme, User user) {
    final profile = user.profile;
    return _sectionCard(
      theme,
      title: AppLocalizations.of(context)?.directLinksLabel ?? 'Direct Links',
      icon: Icons.link_rounded,
      child: Column(
        children: [
          if (_shouldShowEmail(user))
            _buildLinkTile(
              theme,
              Icons.mail_outline_rounded,
              'Email',
              user.email,
              null,
            ),
          if (_optional(profile?.linkedin) != null)
            _buildLinkTile(
              theme,
              Icons.work_outline_rounded,
              AppLocalizations.of(context)?.linkedinProfile ?? 'LinkedIn',
              profile!.linkedin!,
              profile.linkedin,
            ),
          if (_optional(profile?.website) != null)
            _buildLinkTile(
              theme,
              Icons.language_rounded,
              AppLocalizations.of(context)?.websiteLabel ?? 'Website',
              profile!.website!,
              profile.website,
            ),
          if (_optional(profile?.farmPage) != null)
            _buildLinkTile(
              theme,
              Icons.agriculture_rounded,
              'Farm page',
              profile!.farmPage!,
              profile.farmPage,
            ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    String? launchTarget,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: launchTarget == null
            ? null
            : () => _launchExternal(launchTarget),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (launchTarget != null)
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.72)
            : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildChip(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, User user) {
    return Center(
      child: Text(
        AppLocalizations.of(context)?.farmyMemberSince(_memberSince(user.createdAt)) 
            ?? 'Farmy member since ${_memberSince(user.createdAt)}',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildShimmer(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.46)
        : Colors.grey.shade300;
    final highlightColor = isDark
        ? theme.colorScheme.primary.withValues(alpha: 0.18)
        : Colors.grey.shade100;
    return Shimmer.fromColors(
      key: const ValueKey('profile-preview-loading'),
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(color: Colors.white),
                Positioned(
                  top: 68,
                  child: _skeletonBox(width: 104, height: 104, radius: 99),
                ),
                Positioned(
                  bottom: 74,
                  child: _skeletonBox(width: 190, height: 26, radius: 14),
                ),
                Positioned(
                  bottom: 40,
                  child: _skeletonBox(width: 250, height: 22, radius: 99),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      4,
                      (_) => _skeletonBox(width: 150, height: 78, radius: 20),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _skeletonBox(width: double.infinity, height: 130, radius: 22),
                  const SizedBox(height: 18),
                  _skeletonBox(width: double.infinity, height: 110, radius: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    final title = _errorTitle(context);
    final icon = _errorIcon();
    final color = _errorType == _ProfilePreviewErrorType.notFound
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return Center(
      key: const ValueKey('profile-preview-error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(alignment: Alignment.centerRight, child: _buildCloseButton()),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 58, color: color),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? AppLocalizations.of(context)?.profileLoadError ?? 'Failed to load profile',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton.icon(
              onPressed: _fetchProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)?.retryButton ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestrictedView(ThemeData theme, User user) {
    final color = theme.colorScheme.primary;
    final name = _displayName(user);
    final profile = user.profile;
    final l10n = AppLocalizations.of(context);
    
    return Center(
      key: const ValueKey('profile-preview-restricted'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(alignment: Alignment.centerRight, child: _buildCloseButton()),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.visibility_off_rounded, size: 58, color: color),
            ),
            const SizedBox(height: 22),
            Text(
              l10n?.privacyRestricted ?? 'Profile Hidden',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$name has chosen to hide their profile from the marketplace. Their profile is not currently discoverable.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                height: 1.45,
              ),
            ),
            if (profile?.completenessScore != null) ...[
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insights_rounded, size: 18, color: color),
                    const SizedBox(width: 8),
                    Text(
                      'Profile ${profile!.completenessScore}% complete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 26),
            ElevatedButton.icon(
              onPressed: _fetchProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n?.retryButton ?? 'Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  String _errorTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (_errorType) {
      case _ProfilePreviewErrorType.notFound:
        return l10n?.profileNotFound ?? 'Profile not found';
      case _ProfilePreviewErrorType.server:
        return 'Farmy server is unavailable';
      case _ProfilePreviewErrorType.network:
        return 'Connection problem';
      case _ProfilePreviewErrorType.timeout:
        return 'Profile took too long to load';
      case _ProfilePreviewErrorType.restricted:
        return l10n?.privacyRestricted ?? 'This profile is private';
      case _ProfilePreviewErrorType.unknown:
        return l10n?.profileLoadError ?? 'Failed to load profile';
    }
  }

  IconData _errorIcon() {
    switch (_errorType) {
      case _ProfilePreviewErrorType.notFound:
        return Icons.person_search_rounded;
      case _ProfilePreviewErrorType.server:
        return Icons.dns_outlined;
      case _ProfilePreviewErrorType.network:
        return Icons.wifi_off_rounded;
      case _ProfilePreviewErrorType.timeout:
        return Icons.hourglass_empty_rounded;
      case _ProfilePreviewErrorType.restricted:
        return Icons.lock_person_outlined;
      case _ProfilePreviewErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  bool _hasLinksOrContact(User user) {
    final profile = user.profile;
    final showContact = profile?.showContactInfo ?? false;
    // Only show email if showContactInfo is enabled
    final hasContact = showContact && _optional(user.email) != null;
    return hasContact ||
        _optional(profile?.linkedin) != null ||
        _optional(profile?.website) != null ||
        _optional(profile?.farmPage) != null;
  }
  
  bool _shouldShowEmail(User user) {
    final profile = user.profile;
    final showContact = profile?.showContactInfo ?? false;
    return showContact && _optional(user.email) != null;
  }

  String _displayName(User user) {
    return _optional(user.profile?.name) ??
        _optional(user.email.split('@').first) ??
        'Farmy Member';
  }

  String? _location(UserProfile? profile) {
    final parts = [
      _optional(profile?.city),
      _optional(profile?.country),
    ].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  String _memberSince(DateTime? value, {bool short = false}) {
    final date = value ?? DateTime.now();
    return DateFormat(short ? 'MMM yyyy' : 'MMMM yyyy').format(date);
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String? _optional(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  List<String> _safeList(List<String>? values) {
    return values
            ?.map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList() ??
        const [];
  }

  String? _resolveAssetUrl(String? rawPath) {
    final path = _optional(rawPath);
    if (path == null) return null;
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) {
      return uri.scheme == 'http' || uri.scheme == 'https' ? path : null;
    }
    final base = AuthService.baseUrl.endsWith('/')
        ? AuthService.baseUrl.substring(0, AuthService.baseUrl.length - 1)
        : AuthService.baseUrl;
    return path.startsWith('/') ? '$base$path' : '$base/$path';
  }

  Future<void> _launchExternal(String rawUrl) async {
    final uri = _normalizeExternalUri(rawUrl);
    if (uri == null) {
      _showSnack('This link is not available.');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) _showSnack('Unable to open this link.');
  }

  Uri? _normalizeExternalUri(String rawUrl) {
    final value = rawUrl.trim();
    if (value.isEmpty) return null;
    final candidate = value.contains('://') ? value : 'https://$value';
    final uri = Uri.tryParse(candidate);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https'))
      return null;
    return uri;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _getRoleLabel(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context);
    switch (role.toLowerCase()) {
      case 'customer':
        return l10n?.customerLabel ?? 'Customer';
      case 'farmer':
        return l10n?.farmer ?? 'Farmer';
      case 'investor':
        return l10n?.investor ?? 'Investor';
      case 'worker':
        return l10n?.worker ?? 'Worker';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}

class _ProfileStat {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStat(this.icon, this.label, this.value);
}
