import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';
import '../../models/notification_model.dart';
import '../../services/in_app_notification_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/socket_service.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../customer/home_screen.dart'; 
import 'dart:math';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupSocketListener();
  }

  @override
  void dispose() {
    SocketService().off('notification');
    super.dispose();
  }

  void _setupSocketListener() {
    SocketService().on('notification', (data) {
      if (!mounted) return;
      try {
        final newNotif = AppNotification.fromJson(data);
        setState(() {
          // Add to top and keep only latest if needed, or just append
          _notifications.insert(0, newNotif);
        });
        
        // Haptic feedback for new notification
        // HapticFeedback.lightImpact(); 
      } catch (e) {
        debugPrint('[NotificationsScreen] Error parsing socket notification: $e');
      }
    });
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notifications = await InAppNotificationService.getMyNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load notifications. Please try again.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await InAppNotificationService.markAllAsRead();
    if (success) {
      setState(() {
        for (var i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = AppNotification(
              id: _notifications[i].id,
              userId: _notifications[i].userId,
              title: _notifications[i].title,
              message: _notifications[i].message,
              type: _notifications[i].type,
              isRead: true,
              data: _notifications[i].data,
              createdAt: _notifications[i].createdAt,
            );
          }
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.allNotificationsMarkedRead),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(AppNotification notif, int index) async {
    if (notif.isRead) return;
    final success = await InAppNotificationService.markAsRead(notif.id);
    if (success) {
      setState(() {
        _notifications[index] = AppNotification(
          id: notif.id,
          userId: notif.userId,
          title: notif.title,
          message: notif.message,
          type: notif.type,
          isRead: true,
          data: notif.data,
          createdAt: notif.createdAt,
        );
      });
    }
  }

  Future<void> _deleteNotification(AppNotification notif, int index) async {
    final success = await InAppNotificationService.deleteNotification(notif.id);
    if (success) {
      setState(() {
        _notifications.removeAt(index);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToDeleteNotification),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
      _loadNotifications();
    }
  }

  void _showNotificationDetails(AppNotification notif, int index) {
    if (!notif.isRead) {
      _markAsRead(notif, index);
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C19).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getColorForType(notif.type, Theme.of(context)).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getColorForType(notif.type, Theme.of(context)).withValues(alpha: 0.4),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            _getIconForType(notif.type),
                            color: _getColorForType(notif.type, Theme.of(context)),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          notif.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          timeago.format(notif.createdAt),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          notif.message,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            ),
                            child: const Text(
                              'CLOSE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
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
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'rental': return Icons.real_estate_agent_rounded;
      case 'purchase': return Icons.shopping_cart_rounded;
      case 'item_request': return Icons.inventory_2_rounded;
      case 'proof': return Icons.verified_rounded;
      case 'invitation': return Icons.calendar_month_rounded;
      case 'contract': return Icons.handshake_rounded;
      case 'wallet': return Icons.account_balance_wallet_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type, ThemeData theme) {
    switch (type) {
      case 'rental': return Colors.green.shade400;
      case 'purchase': return Colors.blue.shade400;
      case 'item_request': return Colors.orange.shade400;
      case 'proof': return Colors.teal.shade400;
      case 'invitation': return Colors.purple.shade400;
      case 'contract': return Colors.indigo.shade400;
      case 'wallet': return Colors.amber.shade400;
      default: return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadNotifications,
          color: theme.primaryColor,
          backgroundColor: theme.cardColor,
          edgeOffset: 20,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stay Updated',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Alerts',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderActions(context, theme),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: _isLoading 
                ? SliverToBoxAdapter(child: _buildShimmerLoading())
                : _error != null
                    ? SliverToBoxAdapter(child: _buildErrorState())
                    : _notifications.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState(theme))
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final notif = _notifications[index];
                                return _buildNotificationTile(notif, index, theme);
                              },
                              childCount: _notifications.length,
                            ),
                          ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    ),
  ),
);
}

  Widget _buildNotificationTile(AppNotification notif, int index, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isUnread = !notif.isRead;
    final typeColor = _getColorForType(notif.type, theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dismissible(
            key: Key(notif.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
            ),
            onDismissed: (_) => _deleteNotification(notif, index),
            child: InkWell(
              onTap: () => _showNotificationDetails(notif, index),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isUnread 
                      ? theme.primaryColor.withValues(alpha: isDark ? 0.08 : 0.05)
                      : theme.cardColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isUnread 
                        ? theme.primaryColor.withValues(alpha: 0.2)
                        : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: typeColor.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Icon(_getIconForType(notif.type), color: typeColor, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif.message,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            timeago.format(notif.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(6, (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        width: double.infinity,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.withValues(alpha: 0.1),
          highlightColor: Colors.grey.withValues(alpha: 0.05),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('RETRY'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noNotificationsYet,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHeaderActions(BuildContext context, ThemeData theme) {
    final hasUnread = _notifications.any((n) => !n.isRead);
    
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasUnread 
              ? theme.primaryColor.withValues(alpha: 0.1)
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: hasUnread 
                ? theme.primaryColor.withValues(alpha: 0.2)
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(
          Icons.done_all_rounded, 
          color: hasUnread ? theme.primaryColor : theme.colorScheme.onSurface.withValues(alpha: 0.3), 
          size: 24,
        ),
      ),
      onPressed: hasUnread ? _markAllAsRead : null,
      tooltip: AppLocalizations.of(context)!.markAllAsReadTooltip,
    );
  }

}
