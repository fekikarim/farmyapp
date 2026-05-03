import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/delivery_model.dart';
import '../../providers/delivery_provider.dart';
import '../../widgets/delivery/delivery_timeline.dart';
import '../../widgets/delivery/delivery_info_card.dart';
import '../../widgets/delivery/delivery_map_section.dart';
import '../../widgets/delivery/delivery_tracking_skeleton.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

/// Track Order Screen — shows real-time delivery tracking information.
///
/// Usage:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => TrackOrderScreen(orderId: purchaseId),
/// ));
/// ```
class TrackOrderScreen extends StatefulWidget {
  /// The purchase (order) ID to track
  final String orderId;

  const TrackOrderScreen({super.key, required this.orderId});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen>
    with TickerProviderStateMixin {
  late DeliveryProvider _deliveryProvider;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _deliveryProvider = context.read<DeliveryProvider>();

    // Defer fetch to post-frame to prevent setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deliveryProvider.fetchByOrderId(widget.orderId).then((_) {
        if (!mounted) return;
        _fadeController.forward();
        // Start polling only if not terminal
        final tracking = _deliveryProvider.tracking;
        if (tracking != null && !tracking.isTerminal) {
          _deliveryProvider.startPolling(widget.orderId);
        }
      });
    });
  }

  @override
  void dispose() {
    _deliveryProvider.stopPolling();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _deliveryProvider.silentRefresh(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.trackOrder),
        centerTitle: false,
        titleTextStyle: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
        actions: [
          // Polling indicator
          Consumer<DeliveryProvider>(
            builder: (_, provider, __) {
              if (!provider.isPolling) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.live,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, provider, _) {
          // ── Loading state ──
          if (provider.isLoading && provider.tracking == null) {
            return const DeliveryTrackingSkeleton();
          }

          // ── Error state ──
          if (provider.error != null && provider.tracking == null) {
            return _buildErrorState(theme, provider.error!);
          }

          // ── No tracking data ──
          if (provider.tracking == null) {
            return _buildEmptyState(theme);
          }

          final tracking = provider.tracking!;

          // ── Main content ──
          return FadeTransition(
            opacity: _fadeAnim,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: theme.colorScheme.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
                children: [
                  // ── Delivery Info Card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DeliveryInfoCard(tracking: tracking),
                  ),

                  const SizedBox(height: 20),

                  // ── Map Section (conditional) ──
                  DeliveryMapSection(tracking: tracking),
                  if (tracking.showMap) const SizedBox(height: 20),

                  // ── Progress Header ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Delivery Progress',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        if (!tracking.isTerminal) _LiveBadge(theme: theme),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Status Timeline ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DeliveryTimeline(
                      steps: tracking.timeline,
                      currentStatus: tracking.deliveryStatus,
                    ),
                  ),

                  // ── Delivered celebration ──
                  if (tracking.deliveryStatus == DeliveryStatus.delivered)
                    _buildDeliveredBanner(theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.unableToLoadTracking,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _deliveryProvider.fetchByOrderId(widget.orderId),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.retry),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.25),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noTrackingInformation,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.deliveryTrackingEmptyHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveredBanner(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade50,
              Colors.green.shade100.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade200.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration_rounded,
                color: Colors.green.shade700,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.orderDelivered,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.orderDeliveredSuccess,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small animated "Live" badge in the timeline header
class _LiveBadge extends StatefulWidget {
  final ThemeData theme;

  const _LiveBadge({required this.theme});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade500.withOpacity(
                    0.4 + 0.6 * _controller.value,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context)!.updating,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
