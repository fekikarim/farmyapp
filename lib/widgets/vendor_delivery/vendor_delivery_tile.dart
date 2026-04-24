import 'package:flutter/material.dart';
import '../../models/vendor_delivery_model.dart';
import '../../models/delivery_model.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

/// A single delivery card in the vendor list.
class VendorDeliveryTile extends StatelessWidget {
  final VendorDeliveryItem delivery;
  final VoidCallback onManage;

  const VendorDeliveryTile({
    super.key,
    required this.delivery,
    required this.onManage,
  });

  Color _statusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.orderCreated:
        return Colors.blue.shade600;
      case DeliveryStatus.confirmed:
        return Colors.teal.shade600;
      case DeliveryStatus.preparing:
        return Colors.orange.shade600;
      case DeliveryStatus.outForDelivery:
      case DeliveryStatus.nearby:
        return Colors.indigo.shade600;
      case DeliveryStatus.delivered:
        return Colors.green.shade600;
      case DeliveryStatus.cancelled:
        return Colors.red.shade500;
    }
  }

  IconData _statusIcon(DeliveryStatus status) {
    switch (status) {
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
    final theme = Theme.of(context);
    final color = _statusColor(delivery.deliveryStatus);
    final customerName = delivery.customer?.name ?? AppLocalizations.of(context)!.unknownCustomer;
    final productName = delivery.order?.productName ?? AppLocalizations.of(context)!.orderLabel;
    final amount = delivery.order?.totalPrice ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onManage,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top row: customer + status
                Row(
                  children: [
                    // Status icon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _statusIcon(delivery.deliveryStatus),
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Customer & product
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            productName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.45,
                              ),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Text(
                      AppLocalizations.of(context)!.priceTnd(amount.toStringAsFixed(2)),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom row: status badge + date + manage btn
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        delivery.deliveryStatusLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Date
                    Text(
                      _formatDate(delivery.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),

                    const Spacer(),

                    // Manage button
                    if (!delivery.isTerminal)
                      _ManageButton(onTap: onManage, theme: theme)
                    else
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.25),
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} $hour:$min';
  }
}

class _ManageButton extends StatelessWidget {
  final VoidCallback onTap;
  final ThemeData theme;

  const _ManageButton({required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.settings_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)!.manageButton,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
