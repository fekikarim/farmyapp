import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../services/auth_service.dart';

class FarmyAvatar extends StatefulWidget {
  // Globally track failed URLs to avoid repeated hangs
  static final Set<String> _globallyFailedUrls = <String>{};

  final String? imageUrl;
  final double radius;
  final String? displayName;
  final bool isShimmerLoading;
  final IconData? fallbackIcon;
  final BoxShape shape;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? fontSize;
  final Color? backgroundColor;

  const FarmyAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.displayName,
    this.isShimmerLoading = false,
    this.fallbackIcon,
    this.shape = BoxShape.circle,
    this.border,
    this.boxShadow,
    this.fontSize,
    this.backgroundColor,
  });

  @override
  State<FarmyAvatar> createState() => _FarmyAvatarState();
}

class _FarmyAvatarState extends State<FarmyAvatar> with SingleTickerProviderStateMixin {
  bool _localError = false;
  bool _hasTimedOut = false;
  bool _isReachable = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initializeLoading();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FarmyAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _hasTimedOut = false;
      _localError = false;
      _isReachable = true;
      _initializeLoading();
    }
  }

  void _initializeLoading() {
    final url = _resolveUrl(widget.imageUrl);
    if (url == null) return;

    // Aggressive Protection: If localhost on physical device, skip immediately
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      if (url.contains('localhost') || url.contains('127.0.0.1')) {
        debugPrint('FarmyAvatar: Localhost detected on mobile. Showing fallback immediately.');
        if (mounted) setState(() => _isReachable = false);
        return;
      }
    }

    // Faster Timeout: 6 seconds is enough for a good connection
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted && !_localError && widget.imageUrl == url) {
        setState(() => _hasTimedOut = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.isShimmerLoading) {
      return _buildShimmerPlaceholder(isDark);
    }

    final resolvedUrl = _resolveUrl(widget.imageUrl);
    
    // Advanced UI: Show pulsing fallback if loading, or static fallback if error/timeout
    if (_localError || _hasTimedOut || !_isReachable || resolvedUrl == null || 
        FarmyAvatar._globallyFailedUrls.contains(resolvedUrl)) {
      return _buildFinalContainer(child: _buildFallback(theme, isDark, isError: true));
    }

    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final int cacheSize = (widget.radius * 2 * devicePixelRatio).round();

    return _buildFinalContainer(
      child: CachedNetworkImage(
        imageUrl: resolvedUrl,
        fit: BoxFit.cover,
        memCacheWidth: cacheSize,
        memCacheHeight: cacheSize,
        maxWidthDiskCache: 500,
        maxHeightDiskCache: 500,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => _buildAdvancedPlaceholder(theme, isDark),
        errorWidget: (context, url, error) {
          debugPrint('FarmyAvatar: Network error for $url');
          _registerFailure(url);
          return _buildFallback(theme, isDark, isError: true);
        },
      ),
    );
  }

  void _registerFailure(String url) {
    if (FarmyAvatar._globallyFailedUrls.contains(url)) return;
    FarmyAvatar._globallyFailedUrls.add(url);
    if (mounted && !_localError) {
      setState(() => _localError = true);
    }
  }

  Widget _buildAdvancedPlaceholder(ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: _pulseController.drive(CurveTween(curve: Curves.easeInOut)),
      child: _buildFallback(theme, isDark, isLoading: true),
    );
  }

  Widget _buildFinalContainer({required Widget child}) {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: widget.shape,
        border: widget.border,
        boxShadow: widget.boxShadow,
        borderRadius: widget.shape == BoxShape.rectangle 
            ? BorderRadius.circular(widget.radius * 0.4) 
            : null,
      ),
      child: ClipRRect(
        borderRadius: widget.shape == BoxShape.circle 
            ? BorderRadius.circular(widget.radius) 
            : BorderRadius.circular(widget.radius * 0.4),
        child: child,
      ),
    );
  }

  Widget _buildShimmerPlaceholder(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: widget.shape,
          borderRadius: widget.shape == BoxShape.rectangle 
              ? BorderRadius.circular(widget.radius * 0.4) 
              : null,
        ),
      ),
    );
  }

  Widget _buildFallback(ThemeData theme, bool isDark, {bool isLoading = false, bool isError = false}) {
    final initials = _getInitials(widget.displayName ?? '');
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    Color startColor = primaryColor;
    Color endColor = secondaryColor.withValues(alpha: 0.8);

    if (isError && initials.isEmpty) {
      // Muted colors for missing data
      startColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
      endColor = isDark ? Colors.grey.shade900 : Colors.grey.shade400;
    }

    final decoration = widget.backgroundColor != null
        ? BoxDecoration(color: widget.backgroundColor, shape: widget.shape)
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [startColor, endColor],
            ),
            shape: widget.shape,
          );

    return Container(
      decoration: decoration,
      child: Center(
        child: (initials.isNotEmpty && widget.fallbackIcon == null)
            ? Text(
                initials,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isLoading ? 0.6 : 1.0),
                  fontSize: widget.fontSize ?? (widget.radius * 0.85),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              )
            : Icon(
                widget.fallbackIcon ?? Icons.person_rounded,
                color: Colors.white.withValues(alpha: isLoading ? 0.4 : 0.8),
                size: widget.radius * 1.1,
              ),
      ),
    );
  }

  String? _resolveUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      debugPrint('FarmyAvatar: Path is null or empty');
      return null;
    }
    
    if (path.startsWith('http')) {
      debugPrint('FarmyAvatar: Using absolute URL: $path');
      return path;
    }
    
    final base = AuthService.baseUrl.trim();
    if (base.isEmpty) {
      debugPrint('FarmyAvatar: Error - AuthService.baseUrl is empty');
      return null;
    }

    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    
    final resolved = '$cleanBase$cleanPath';
    debugPrint('FarmyAvatar: Resolved relative path to: $resolved');
    return resolved;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      final part = parts[0];
      return part.length > 1 
          ? part.substring(0, 1).toUpperCase() 
          : part.toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
