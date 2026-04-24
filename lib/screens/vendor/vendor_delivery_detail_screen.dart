import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/delivery_model.dart';
import '../../models/vendor_delivery_model.dart';
import '../../providers/vendor_delivery_provider.dart';
import '../../widgets/delivery/delivery_timeline.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

/// Full vendor delivery detail + management screen.
class VendorDeliveryDetailScreen extends StatefulWidget {
  final String deliveryId;

  const VendorDeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  State<VendorDeliveryDetailScreen> createState() =>
      _VendorDeliveryDetailScreenState();
}

class _VendorDeliveryDetailScreenState
    extends State<VendorDeliveryDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<VendorDeliveryProvider>().fetchDetail(widget.deliveryId);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<VendorDeliveryProvider>().fetchDetail(widget.deliveryId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageDeliveryTitle),
        centerTitle: false,
        titleTextStyle: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      body: Consumer<VendorDeliveryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail && provider.selectedDetail == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detailError != null && provider.selectedDetail == null) {
            return _buildError(theme, provider.detailError!);
          }

          final detail = provider.selectedDetail;
          if (detail == null) {
            return _buildError(theme, AppLocalizations.of(context)!.deliveryNotFound);
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: theme.colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status Header ──
                  _StatusHeader(detail: detail, theme: theme),
                  const SizedBox(height: 20),

                  // ── Order Info Card ──
                  _OrderInfoCard(detail: detail, theme: theme),
                  const SizedBox(height: 16),

                  // ── Customer Info Card ──
                  _CustomerInfoCard(detail: detail, theme: theme),
                  const SizedBox(height: 16),

                  // ── Delivery Details Card ──
                  _DeliveryDetailsCard(detail: detail, theme: theme),
                  const SizedBox(height: 20),

                  // ── Timeline ──
                  Text(
                    AppLocalizations.of(context)!.deliveryTimeline,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DeliveryTimeline(
                    steps: detail.timeline,
                    currentStatus: detail.deliveryStatus,
                  ),
                  const SizedBox(height: 24),

                  // ── Status Update Controls ──
                  if (!detail.isTerminal) ...[
                    Text(
                      AppLocalizations.of(context)!.updateStatus,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusUpdateControls(detail: detail, theme: theme),
                  ],

                  // ── Delivered / Cancelled Banner ──
                  if (detail.isTerminal) ...[
                    const SizedBox(height: 8),
                    _TerminalBanner(detail: detail, theme: theme),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STATUS HEADER
// ═══════════════════════════════════════════════════════════════

class _StatusHeader extends StatelessWidget {
  final VendorDeliveryDetail detail;
  final ThemeData theme;

  const _StatusHeader({required this.detail, required this.theme});

  Color get _color {
    switch (detail.deliveryStatus) {
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color, _color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              detail.isTerminal
                  ? (detail.deliveryStatus == DeliveryStatus.delivered
                        ? Icons.verified_rounded
                        : Icons.cancel_rounded)
                  : Icons.local_shipping_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.deliveryStatusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (detail.estimatedDeliveryTime != null &&
                    !detail.isTerminal) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.etaLabel(_formatTime(context, detail.estimatedDeliveryTime!)),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final mon = dt.month.toString().padLeft(2, '0');
    return AppLocalizations.of(context)!.dateTimeAt('$day/$mon/${dt.year}', '$h:$m');
  }
}

// ═══════════════════════════════════════════════════════════════
// ORDER INFO CARD
// ═══════════════════════════════════════════════════════════════

class _OrderInfoCard extends StatelessWidget {
  final VendorDeliveryDetail detail;
  final ThemeData theme;

  const _OrderInfoCard({required this.detail, required this.theme});

  @override
  Widget build(BuildContext context) {
    final order = detail.order;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.orderDetails,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: AppLocalizations.of(context)!.productLabel,
            value: order?.productName ?? 'N/A',
            theme: theme,
          ),
          _InfoRow(
            label: AppLocalizations.of(context)!.quantityLabel,
            value: order?.quantity.toStringAsFixed(0) ?? 'N/A',
            theme: theme,
          ),
          _InfoRow(
            label: AppLocalizations.of(context)!.totalLabel,
            value: order != null
                ? AppLocalizations.of(context)!.priceTnd(order.totalPrice.toStringAsFixed(2))
                : 'N/A',
            theme: theme,
            valueColor: theme.colorScheme.primary,
            valueBold: true,
          ),
          _InfoRow(
            label: AppLocalizations.of(context)!.orderIdLabel,
            value: detail.orderId.length > 8
                ? '${detail.orderId.substring(0, 8)}...'
                : detail.orderId,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOMER INFO CARD
// ═══════════════════════════════════════════════════════════════

class _CustomerInfoCard extends StatelessWidget {
  final VendorDeliveryDetail detail;
  final ThemeData theme;

  const _CustomerInfoCard({required this.detail, required this.theme});

  @override
  Widget build(BuildContext context) {
    final customer = detail.customer;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.customerLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: customer?.picture != null
                    ? NetworkImage(customer!.picture!)
                    : null,
                child: customer?.picture == null
                    ? Text(
                        (customer?.name ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.name ?? AppLocalizations.of(context)!.unknown,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      customer?.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DELIVERY DETAILS CARD
// ═══════════════════════════════════════════════════════════════

class _DeliveryDetailsCard extends StatelessWidget {
  final VendorDeliveryDetail detail;
  final ThemeData theme;

  const _DeliveryDetailsCard({required this.detail, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.deliveryInfo,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (detail.deliveryAddress != null)
            _InfoRow(
              label: AppLocalizations.of(context)!.addressLabel,
              value: detail.deliveryAddress!,
              theme: theme,
            ),
          _InfoRow(
            label: AppLocalizations.of(context)!.createdLabel,
            value: _formatDateTime(context, detail.createdAt),
            theme: theme,
          ),
          if (detail.startedAt != null)
            _InfoRow(
              label: AppLocalizations.of(context)!.startedLabel,
              value: _formatDateTime(context, detail.startedAt!),
              theme: theme,
            ),
          if (detail.deliveredAt != null)
            _InfoRow(
              label: AppLocalizations.of(context)!.deliveredLabel,
              value: _formatDateTime(context, detail.deliveredAt!),
              theme: theme,
            ),
          if (detail.cancellationReason != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail.cancellationReason!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return AppLocalizations.of(context)!.dateTimeAt('$d/$m/${dt.year}', '$h:$min');
  }
}

// ═══════════════════════════════════════════════════════════════
// STATUS UPDATE CONTROLS
// ═══════════════════════════════════════════════════════════════

class _StatusUpdateControls extends StatefulWidget {
  final VendorDeliveryDetail detail;
  final ThemeData theme;

  const _StatusUpdateControls({required this.detail, required this.theme});

  @override
  State<_StatusUpdateControls> createState() => _StatusUpdateControlsState();
}

class _StatusUpdateControlsState extends State<_StatusUpdateControls> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _cancelReasonController = TextEditingController();

  Color _transitionColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.confirmed:
        return Colors.teal.shade600;
      case DeliveryStatus.preparing:
        return Colors.orange.shade600;
      case DeliveryStatus.outForDelivery:
        return Colors.indigo.shade600;
      case DeliveryStatus.nearby:
        return Colors.blue.shade600;
      case DeliveryStatus.delivered:
        return Colors.green.shade600;
      case DeliveryStatus.cancelled:
        return Colors.red.shade500;
      default:
        return widget.theme.colorScheme.primary;
    }
  }

  IconData _transitionIcon(DeliveryStatus status) {
    switch (status) {
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
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  Future<void> _confirmAndUpdate(DeliveryStatus newStatus) async {
    final isCancellation = newStatus == DeliveryStatus.cancelled;
    final color = _transitionColor(newStatus);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(_transitionIcon(newStatus), color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isCancellation
                      ? AppLocalizations.of(context)!.cancelDeliveryQuestion
                      : AppLocalizations.of(context)!.updateToStatusQuestion(newStatus.label),
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCancellation
                    ? AppLocalizations.of(context)!.cancelNotifyCustomer
                    : AppLocalizations.of(context)!.advanceNotifyCustomer(newStatus.label),
                style: TextStyle(
                  color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              if (isCancellation)
                TextField(
                  controller: _cancelReasonController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.cancellationReasonHint,
                    hintStyle: TextStyle(
                      color: widget.theme.colorScheme.onSurface.withOpacity(
                        0.35,
                      ),
                      fontSize: 13,
                    ),
                  ),
                  maxLines: 2,
                )
              else
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.addNoteHint,
                    hintStyle: TextStyle(
                      color: widget.theme.colorScheme.onSurface.withOpacity(
                        0.35,
                      ),
                      fontSize: 13,
                    ),
                  ),
                  maxLines: 2,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isCancellation ? AppLocalizations.of(context)!.cancelDeliveryAction : AppLocalizations.of(context)!.confirmUpdate),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<VendorDeliveryProvider>();
    final success = await provider.updateDeliveryStatus(
      deliveryId: widget.detail.id,
      newStatus: newStatus,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      cancellationReason:
          isCancellation && _cancelReasonController.text.isNotEmpty
          ? _cancelReasonController.text
          : null,
    );

    _noteController.clear();
    _cancelReasonController.clear();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.statusUpdatedTo(newStatus.label)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(provider.updateError ?? AppLocalizations.of(context)!.failedUpdateStatus),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _cancelReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorDeliveryProvider>();
    final transitions = widget.detail.allowedTransitions;

    if (transitions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Separate forward transitions from cancel
    final forwardTransitions = transitions
        .where((t) => t != DeliveryStatus.cancelled)
        .toList();
    final canCancel = transitions.contains(DeliveryStatus.cancelled);

    return Column(
      children: [
        // Forward status transitions
        for (final status in forwardTransitions) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isUpdatingStatus
                  ? null
                  : () => _confirmAndUpdate(status),
              icon: provider.isUpdatingStatus
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(_transitionIcon(status), size: 18),
              label: Text(AppLocalizations.of(context)!.moveToStatus(status.label)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _transitionColor(status),
                foregroundColor: Colors.white,
                disabledBackgroundColor: _transitionColor(
                  status,
                ).withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Cancel button (destructive)
        if (canCancel) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.isUpdatingStatus
                  ? null
                  : () => _confirmAndUpdate(DeliveryStatus.cancelled),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: Text(AppLocalizations.of(context)!.cancelDeliveryAction),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade500,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TERMINAL BANNER (Delivered / Cancelled)
// ═══════════════════════════════════════════════════════════════

class _TerminalBanner extends StatelessWidget {
  final VendorDeliveryDetail detail;
  final ThemeData theme;

  const _TerminalBanner({required this.detail, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isDelivered = detail.deliveryStatus == DeliveryStatus.delivered;
    final color = isDelivered ? Colors.green.shade600 : Colors.red.shade500;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isDelivered ? Icons.celebration_rounded : Icons.cancel_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDelivered ? AppLocalizations.of(context)!.successfullyDelivered : AppLocalizations.of(context)!.deliveryCancelled,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (detail.deliveredAt != null && isDelivered)
                  Text(
                    AppLocalizations.of(context)!.completedOn(_fmt(detail.deliveredAt!)),
                    style: TextStyle(
                      color: color.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED INFO ROW
// ═══════════════════════════════════════════════════════════════

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;
  final bool valueBold;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.45),
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: valueColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
