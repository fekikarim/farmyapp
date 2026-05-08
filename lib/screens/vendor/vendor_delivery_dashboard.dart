import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/delivery_model.dart';
import '../../providers/vendor_delivery_provider.dart';
import '../../widgets/vendor_delivery/vendor_stat_card.dart';
import '../../widgets/vendor_delivery/delivery_status_filter.dart';
import '../../widgets/vendor_delivery/vendor_delivery_tile.dart';
import '../../widgets/vendor_delivery/vendor_dashboard_skeleton.dart';
import 'vendor_delivery_detail_screen.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

/// Vendor Delivery Management Dashboard — accessible by Farmers & Investors.
class VendorDeliveryDashboard extends StatefulWidget {
  const VendorDeliveryDashboard({super.key});

  @override
  State<VendorDeliveryDashboard> createState() =>
      _VendorDeliveryDashboardState();
}

class _VendorDeliveryDashboardState extends State<VendorDeliveryDashboard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<VendorDeliveryProvider>();
      provider.refreshAll();
      provider.startAutoRefresh(intervalSeconds: 30);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VendorDeliveryProvider>().loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<VendorDeliveryProvider>().refreshAll();
  }

  void _navigateToDetail(String deliveryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VendorDeliveryDetailScreen(deliveryId: deliveryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.deliveriesTitle),
        centerTitle: false,
        titleTextStyle: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 22,
        ),
        actions: [
          Consumer<VendorDeliveryProvider>(
            builder: (context, provider, _) {
              if (provider.isLoadingList || provider.isLoadingStats) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<VendorDeliveryProvider>(
        builder: (context, provider, _) {
          // Initial loading
          if (provider.isLoadingStats &&
              provider.isLoadingList &&
              provider.deliveries.isEmpty) {
            return const VendorDashboardSkeleton();
          }

          // Error state with retry
          if (provider.statsError != null &&
              provider.listError != null &&
              provider.deliveries.isEmpty) {
            return _buildErrorState(
              theme,
              provider.statsError ?? provider.listError ?? 'Unknown error',
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: theme.colorScheme.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Stats Section ──
                SliverToBoxAdapter(child: _buildStatsGrid(theme, provider)),

                // ── Filter Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 16),
                    child: DeliveryStatusFilter(
                      selected: provider.statusFilter,
                      onChanged: provider.setStatusFilter,
                    ),
                  ),
                ),

                // ── Section header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.ordersTitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        if (provider.pagination != null)
                          Text(
                            AppLocalizations.of(context)!.totalCount(
                              provider.pagination!.total.toString(),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Delivery List ──
                if (provider.isLoadingList && provider.deliveries.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (provider.deliveries.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState(theme))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= provider.deliveries.length) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }

                          final delivery = provider.deliveries[index];
                          return VendorDeliveryTile(
                            delivery: delivery,
                            onManage: () => _navigateToDetail(delivery.id),
                          );
                        },
                        childCount:
                            provider.deliveries.length +
                            (provider.isLoadingMore ? 1 : 0),
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, VendorDeliveryProvider provider) {
    final stats = provider.stats;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: VendorStatCard(
                  label: AppLocalizations.of(context)!.totalOrdersLabel,
                  value: stats.totalOrdersCount.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VendorStatCard(
                  label: AppLocalizations.of(context)!.activeLabel,
                  value: stats.activeDeliveriesCount.toString(),
                  icon: Icons.local_shipping_rounded,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: VendorStatCard(
                  label: AppLocalizations.of(context)!.deliveredLabel,
                  value: stats.deliveredCount.toString(),
                  icon: Icons.verified_rounded,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VendorStatCard(
                  label: AppLocalizations.of(context)!.revenueTitle,
                  value: '${stats.totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.payments_rounded,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_outlined,
                size: 38,
                color: theme.colorScheme.primary.withOpacity(0.35),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noDeliveriesYet,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noDeliveriesDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
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
                size: 38,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.somethingWentWrong,
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
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.retry),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
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
}
