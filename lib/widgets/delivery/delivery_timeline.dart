import 'package:flutter/material.dart';
import '../../models/delivery_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A premium vertical stepper that shows delivery progress.
class DeliveryTimeline extends StatelessWidget {
  final List<DeliveryTimelineStep> steps;
  final DeliveryStatus currentStatus;

  const DeliveryTimeline({
    super.key,
    required this.steps,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return _TimelineStep(step: step, isLast: isLast, theme: theme);
      }),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final DeliveryTimelineStep step;
  final bool isLast;
  final ThemeData theme;

  const _TimelineStep({
    required this.step,
    required this.isLast,
    required this.theme,
  });

  Color get _dotColor {
    if (step.isCompleted) return theme.colorScheme.primary;
    if (step.isCurrent) return theme.colorScheme.primary;
    if (step.isCancelled) return Colors.red.shade400;
    return theme.colorScheme.onSurface.withOpacity(0.15);
  }

  Color get _lineColor {
    if (step.isCompleted) return theme.colorScheme.primary.withOpacity(0.4);
    return theme.colorScheme.onSurface.withOpacity(0.08);
  }

  IconData get _icon {
    final status = step.status;
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dot + Line column ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  width: step.isCurrent ? 36 : 28,
                  height: step.isCurrent ? 36 : 28,
                  decoration: BoxDecoration(
                    color: step.isCurrent || step.isCompleted
                        ? _dotColor
                        : Colors.transparent,
                    border: Border.all(
                      color: _dotColor,
                      width: step.isCurrent ? 3 : 2,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: step.isCurrent
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(
                                0.25,
                              ),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _icon,
                    size: step.isCurrent ? 18 : 14,
                    color: step.isCurrent || step.isCompleted
                        ? Colors.white
                        : _dotColor,
                  ),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: _lineColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Content column ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: theme.textTheme.bodyLarge!.copyWith(
                      fontWeight: step.isCurrent
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: step.isPending
                          ? theme.colorScheme.onSurface.withOpacity(0.35)
                          : step.isCancelled
                          ? Colors.red.shade400
                          : theme.colorScheme.onSurface,
                      fontSize: step.isCurrent ? 15 : 14,
                    ),
                    child: Text(step.label),
                  ),

                  // Timestamp
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(context, step.timestamp!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],

                  // Note
                  if (step.note != null && step.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes.toString());
    if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours.toString());

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month ${hour}:${minute}';
  }
}
