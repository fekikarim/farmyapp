import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/delivery_model.dart';
import '../../providers/delivery_provider.dart';
import 'track_order_screen.dart';

/// My Orders screen — lists all deliveries for the current user.
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<DeliveryProvider>().fetchMyDeliveries(role: 'buyer'),
    );
  }

  Future<void> _onRefresh() async {
    await context.read<DeliveryProvider>().fetchMyDeliveries(role: 'buyer');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        centerTitle: false,
        titleTextStyle: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.myDeliveries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myDeliveries.isEmpty) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: theme.colorScheme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: provider.myDeliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final delivery = provider.myDeliveries[index];
                return _OrderCard(
                  delivery: delivery,
                  theme: theme,
                  onTap: () => _navigateToTracking(delivery),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToTracking(DeliveryTracking delivery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackOrderScreen(orderId: delivery.orderId),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here\nafter your first purchase.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final DeliveryTracking delivery;
  final ThemeData theme;
  final VoidCallback onTap;

  const _OrderCard({
    required this.delivery,
    required this.theme,
    required this.onTap,
  });

  Color get _statusColor {
    switch (delivery.deliveryStatus) {
      case DeliveryStatus.delivered:
        return Colors.green.shade600;
      case DeliveryStatus.cancelled:
        return Colors.red.shade500;
      case DeliveryStatus.outForDelivery:
      case DeliveryStatus.nearby:
        return Colors.blue.shade600;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData get _statusIcon {
    switch (delivery.deliveryStatus) {
      case DeliveryStatus.orderCreated:
        return Icons.receipt_long_rounded;
      case DeliveryStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case DeliveryStatus.preparing:
        return Icons.inventory_2_rounded;
      case DeliveryStatus.outForDelivery:
        return Icons.local_shipping_rounded;
      case DeliveryStatus.nearby:
        return Icons.share_location_rounded;
      case DeliveryStatus.delivered:
        return Icons.verified_rounded;
      case DeliveryStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_statusIcon, color: _statusColor, size: 22),
            ),
            const SizedBox(width: 14),

            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.order?.productName ?? 'Order',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            delivery.deliveryStatusLabel,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(delivery.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (delivery.order != null)
                  Text(
                    '${delivery.order!.totalPrice.toStringAsFixed(2)} TND',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  }
}
