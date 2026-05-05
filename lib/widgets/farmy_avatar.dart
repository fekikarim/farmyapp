import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

class _FarmyAvatarState extends State<FarmyAvatar> {
  bool _localError = false;

  @override
  void didUpdateWidget(FarmyAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _localError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.isShimmerLoading) {
      return _buildShimmerPlaceholder(isDark);
    }

    final resolvedUrl = _resolveUrl(widget.imageUrl);
    
    // If we know this URL fails, show fallback immediately
    if (resolvedUrl != null && FarmyAvatar._globallyFailedUrls.contains(resolvedUrl)) {
      return _buildFinalContainer(child: _buildFallback(theme, isDark));
    }

    if (_localError || resolvedUrl == null) {
      return _buildFinalContainer(child: _buildFallback(theme, isDark));
    }

    // Optimization: Calculate dimensions for memory cache
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final int cacheSize = (widget.radius * 2 * devicePixelRatio).round();

    return _buildFinalContainer(
      child: CachedNetworkImage(
        imageUrl: resolvedUrl,
        fit: BoxFit.cover,
        // Resizing support for better memory performance
        memCacheWidth: cacheSize,
        memCacheHeight: cacheSize,
        maxWidthDiskCache: 400,
        maxHeightDiskCache: 400,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 200),
        // "Strong Loading": Show fallback UNDER the progress indicator
        placeholder: (context, url) => Stack(
          fit: StackFit.expand,
          children: [
            _buildFallback(theme, isDark),
            Center(
              child: SizedBox(
                width: widget.radius * 0.6,
                height: widget.radius * 0.6,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
        errorWidget: (context, url, error) {
          debugPrint('FarmyAvatar: Failed to load $url - $error');
          // Register failure globally to protect other instances
          _registerFailure(url);
          return _buildFallback(theme, isDark);
        },
      ),
    );
  }

  void _registerFailure(String url) {
    FarmyAvatar._globallyFailedUrls.add(url);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_localError) {
        setState(() => _localError = true);
      }
    });
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
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.rectangle 
            ? BorderRadius.circular(widget.radius * 0.4) 
            : null,
      ),
    );
  }

  Widget _buildFallback(ThemeData theme, bool isDark) {
    final initials = _getInitials(widget.displayName ?? '');
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    // Use a premium gradient if no specific background color is provided
    final decoration = widget.backgroundColor != null
        ? BoxDecoration(color: widget.backgroundColor, shape: widget.shape)
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                secondaryColor.withValues(alpha: 0.8),
              ],
            ),
            shape: widget.shape,
          );

    return Container(
      decoration: decoration,
      child: Center(
        child: widget.fallbackIcon != null 
            ? Icon(
                widget.fallbackIcon,
                color: Colors.white,
                size: widget.radius * 1.1,
              )
            : initials.isNotEmpty
                ? Text(
                    initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.fontSize ?? (widget.radius * 0.85),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: widget.radius * 1.2,
                  ),
      ),
    );
  }

  String? _resolveUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http')) return path;
    
    final base = AuthService.baseUrl.trim();
    if (base.isEmpty) return null;

    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    
    return '$cleanBase$cleanPath';
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
