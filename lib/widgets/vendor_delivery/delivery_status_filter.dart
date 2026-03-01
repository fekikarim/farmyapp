import 'package:flutter/material.dart';
import '../../models/delivery_model.dart';

/// Horizontal filter chip bar for delivery status filtering.
class DeliveryStatusFilter extends StatelessWidget {
  final DeliveryStatus? selected;
  final ValueChanged<DeliveryStatus?> onChanged;

  const DeliveryStatusFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _filters = [
    (null, 'All', Icons.list_alt_rounded),
    (DeliveryStatus.orderCreated, 'New', Icons.fiber_new_rounded),
    (DeliveryStatus.confirmed, 'Confirmed', Icons.check_circle_outline_rounded),
    (DeliveryStatus.preparing, 'Preparing', Icons.inventory_2_rounded),
    (DeliveryStatus.outForDelivery, 'In Transit', Icons.local_shipping_rounded),
    (DeliveryStatus.delivered, 'Delivered', Icons.verified_rounded),
    (DeliveryStatus.cancelled, 'Cancelled', Icons.cancel_rounded),
  ];

  Color _chipColor(DeliveryStatus? status, ThemeData theme) {
    if (status == null) return theme.colorScheme.primary;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (status, label, icon) = _filters[index];
          final isSelected = selected == status;
          final color = _chipColor(status, theme);

          return GestureDetector(
            onTap: () => onChanged(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? color : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? color
                      : theme.colorScheme.onSurface.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
