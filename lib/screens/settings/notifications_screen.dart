import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/notification_model.dart';
import '../../services/in_app_notification_service.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications = await InAppNotificationService.getMyNotifications();
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
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
          SnackBar(content: Text(AppLocalizations.of(context)!.allNotificationsMarkedRead)),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToDeleteNotification)),
        );
      }
      _loadNotifications(); // Reload to restore if failed
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'rental':
        return Icons.real_estate_agent_rounded;
      case 'purchase':
        return Icons.shopping_cart_rounded;
      case 'item_request':
        return Icons.inventory_2_rounded;
      case 'proof':
        return Icons.verified_rounded;
      case 'invitation':
        return Icons.calendar_month_rounded;
      case 'contract':
        return Icons.handshake_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'system':
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    switch (type) {
      case 'rental':
        return Colors.green.shade400;
      case 'purchase':
        return Colors.blue.shade400;
      case 'item_request':
        return Colors.orange.shade400;
      case 'proof':
        return Colors.teal.shade400;
      case 'invitation':
        return Colors.purple.shade400;
      case 'contract':
        return Colors.indigo.shade400;
      case 'wallet':
        return Colors.amber.shade400;
      case 'system':
      default:
        return isDark ? Colors.white70 : Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Alerts', // Using Alerts as per screenshot, but could be localized
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        actions: [
          if (_notifications.any((element) => !element.isRead))
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              tooltip: AppLocalizations.of(context)!.markAllAsReadTooltip,
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: Colors.green,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.green))
            : _notifications.isEmpty
                ? ListView( // Using ListView so RefreshIndicator works
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.noNotificationsYet,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                    ),
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isUnread = !notif.isRead;
                      final typeColor = _getColorForType(notif.type, theme);
                      
                      return Dismissible(
                        key: Key(notif.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: Colors.red.shade400,
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                        ),
                        onDismissed: (direction) {
                          _deleteNotification(notif, index);
                        },
                        child: InkWell(
                          onTap: () => _markAsRead(notif, index),
                          child: Container(
                            color: isUnread 
                                ? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02))
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: typeColor.withValues(alpha: isDark ? 0.15 : 0.1),
                                  ),
                                  child: Icon(
                                    _getIconForType(notif.type),
                                    color: typeColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif.title,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                                color: isUnread
                                                    ? theme.colorScheme.onSurface
                                                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                                letterSpacing: -0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeago.format(notif.createdAt),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                                            ),
                                          ),
                                          if (isUnread) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green.shade400,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        notif.message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: isUnread 
                                              ? theme.colorScheme.onSurface.withValues(alpha: 0.9)
                                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
