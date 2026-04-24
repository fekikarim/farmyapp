import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/notification_model.dart';
import '../../services/in_app_notification_service.dart';

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
        return Icons.real_estate_agent;
      case 'purchase':
        return Icons.shopping_cart;
      case 'item_request':
        return Icons.inventory;
      case 'proof':
        return Icons.verified;
      case 'invitation':
        return Icons.insert_invitation;
      case 'contract':
        return Icons.handshake;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'system':
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type, ThemeData theme) {
    switch (type) {
      case 'rental':
        return Colors.green;
      case 'purchase':
        return Colors.blue;
      case 'item_request':
        return Colors.orange;
      case 'proof':
        return Colors.teal;
      case 'invitation':
        return Colors.purple;
      case 'contract':
        return Colors.indigo;
      case 'wallet':
        return Colors.amber.shade700;
      case 'system':
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notificationsTitle),
        actions: [
          if (_notifications.any((element) => !element.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: AppLocalizations.of(context)!.markAllAsReadTooltip,
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
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
                                color: theme.colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.noNotificationsYet,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isUnread = !notif.isRead;
                      
                      return Dismissible(
                        key: Key(notif.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteNotification(notif, index);
                        },
                        child: InkWell(
                          onTap: () => _markAsRead(notif, index),
                          child: Container(
                            color: isUnread 
                                ? theme.colorScheme.primary.withOpacity(0.05)
                                : Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: _getColorForType(notif.type, theme).withOpacity(0.1),
                                  child: Icon(
                                    _getIconForType(notif.type),
                                    color: _getColorForType(notif.type, theme),
                                  ),
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
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            timeago.format(notif.createdAt),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.message,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isUnread 
                                              ? theme.colorScheme.onSurface
                                              : theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isUnread) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
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
