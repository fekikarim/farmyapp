import 'package:flutter/material.dart';
import '../../models/delivery_model.dart';

/// Card showing delivery info: ETA, address, status, order summary.
class DeliveryInfoCard extends StatefulWidget {
  final DeliveryTracking tracking;

  const DeliveryInfoCard({super.key, required this.tracking});

  @override
  State<DeliveryInfoCard> createState() => _DeliveryInfoCardState();
}

class _DeliveryInfoCardState extends State<DeliveryInfoCard> {
  bool _isExpanded = false;

  DeliveryTracking get t => widget.tracking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Status header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _statusColor(theme).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusColor(theme).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _statusIcon,
                    color: _statusColor(theme),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.deliveryStatusLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _statusColor(theme),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.deliveryStatus.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Info rows ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              children: [
                // ETA
                if (t.estimatedDeliveryTime != null && !t.isTerminal)
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Estimated Delivery',
                    value: _formatETA(t.estimatedDeliveryTime!),
                    theme: theme,
                  ),

                // Address
                if (t.deliveryAddress != null && t.deliveryAddress!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Delivery Address',
                    value: t.deliveryAddress!,
                    theme: theme,
                  ),

                // Seller
                if (t.seller != null)
                  _InfoRow(
                    icon: Icons.storefront_rounded,
                    label: 'Seller',
                    value: t.seller!.name,
                    theme: theme,
                  ),

                // Cancellation reason
                if (t.cancellationReason != null &&
                    t.cancellationReason!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.info_outline_rounded,
                    label: 'Cancellation Reason',
                    value: t.cancellationReason!,
                    theme: theme,
                    valueColor: Colors.red.shade400,
                  ),
              ],
            ),
          ),

          // ── Expandable order summary ──
          if (t.order != null) ...[
            Divider(
              color: theme.colorScheme.onSurface.withOpacity(0.06),
              height: 1,
            ),
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Order Summary',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: t.order!.productName,
                      value: 'x${t.order!.quantity.toStringAsFixed(0)}',
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Total',
                      value: '${t.order!.totalPrice.toStringAsFixed(2)} TND',
                      theme: theme,
                      isBold: true,
                    ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(ThemeData theme) {
    switch (t.deliveryStatus) {
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
    switch (t.deliveryStatus) {
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

  String _formatETA(DateTime eta) {
    final now = DateTime.now();
    final diff = eta.difference(now);

    if (diff.isNegative) return 'Arriving soon';
    if (diff.inMinutes < 60) return '~${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return '~${diff.inHours}h ${diff.inMinutes.remainder(60)}min';
    }

    final day = eta.day.toString().padLeft(2, '0');
    final month = eta.month.toString().padLeft(2, '0');
    final hour = eta.hour.toString().padLeft(2, '0');
    final minute = eta.minute.toString().padLeft(2, '0');
    return '$day/$month at ${hour}:${minute}';
  }
}

// ─── Helper Widgets ──────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(
                isBold ? 0.9 : 0.55,
              ),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
