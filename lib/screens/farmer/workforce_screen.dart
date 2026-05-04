import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/farmy_avatar.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../models/land_worker_model.dart';
import '../../models/worker_invitation_model.dart';
import 'worker_marketplace_screen.dart';
import '../../widgets/profile_preview_sheet.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class WorkforceScreen extends StatefulWidget {
  final String landId;
  final String landName;
  final bool canHire;

  const WorkforceScreen({
    super.key,
    required this.landId,
    required this.landName,
    this.canHire =
        true, // Default to true for backward compatibility or direct access
  });

  @override
  State<WorkforceScreen> createState() => _WorkforceScreenState();
}

class _WorkforceScreenState extends State<WorkforceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  Future<void> _refreshAll() async {
    final workerProv = context.read<WorkerProvider>();
    final lifecycleProv = context.read<WorkerLifecycleProvider>();
    await Future.wait([
      workerProv.loadLandWorkers(widget.landId),
      lifecycleProv.loadInvitationsByLand(widget.landId),
    ]);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddWorkerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.addWorker,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.person_search,
              title: AppLocalizations.of(context)!.inviteExistingWorker,
              subtitle: AppLocalizations.of(context)!.searchWorkerMarketplace,
              color: Colors.green,
              onTap: () async {
                Navigator.pop(ctx);
                await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkerMarketplaceScreen(
                      landId: widget.landId,
                      landName: widget.landName,
                    ),
                  ),
                );
                // Refresh data when returning — the provider already has
                // the optimistic update, but a server sync ensures consistency
                if (mounted) {
                  _refreshAll();
                }
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.work_outline,
              title: AppLocalizations.of(context)!.openJobRequest,
              subtitle: AppLocalizations.of(context)!.soon,
              color: Colors.grey,
              onTap: null,
              comingSoon: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
    bool comingSoon = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: comingSoon ? Colors.grey.shade300 : color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: comingSoon ? Colors.grey : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: comingSoon
                          ? Colors.grey
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            if (comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.amber.withValues(alpha: 0.15)
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.soon,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.amber.shade300
                        : Colors.amber.shade800,
                  ),
                ),
              )
            else
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? color.withValues(alpha: 0.05) : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.05 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard(LandWorker worker) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => ProfilePreviewSheet.show(context, worker.workerId),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar with subtle border
            FarmyAvatar(
              imageUrl: worker.workerProfilePicture,
              radius: 24,
              displayName: worker.workerName,
              border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.workerName ?? AppLocalizations.of(context)!.unknownWorker,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.blue.withValues(alpha: 0.15)
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          worker.role,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${worker.salary.toStringAsFixed(0)} ${AppLocalizations.of(context)!.tndMo}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status Dot with glow
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _statusColor(worker.status),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _statusColor(worker.status).withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final lifecycleProvider = context.watch<WorkerLifecycleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final stats = workerProvider.workforceStats;
    final workers = workerProvider.landWorkers;
    final isLoadingWorkers = workerProvider.landWorkersLoading;
    final isLoadingInvitations = lifecycleProvider.landInvitationsLoading;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workforceLandName(widget.landName)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkerModal,
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.addWorker,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (workerProvider.landWorkersError != null)
                _buildErrorBanner(
                  title: AppLocalizations.of(context)!.workersSyncIssue,
                  message: workerProvider.landWorkersError!,
                  isDark: isDark,
                  onRetry: _refreshAll,
                ),
              
              // Stats Dashboard
              if (isLoadingWorkers && stats.isEmpty)
                _buildStatsShimmer(isDark)
              else
                Row(
                  children: [
                    _buildStatCard(
                      AppLocalizations.of(context)!.totalLabel,
                      '${stats['total'] ?? 0}',
                      Icons.people,
                      Colors.blue,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      AppLocalizations.of(context)!.activeLabel,
                      '${stats['active'] ?? 0}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      AppLocalizations.of(context)!.suspendedLabel,
                      '${stats['suspended'] ?? 0}',
                      Icons.pause_circle,
                      Colors.orange,
                    ),
                  ],
                ),
              
              if (!isLoadingWorkers || stats.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard(
                      AppLocalizations.of(context)!.monthlyCost,
                      '${stats['monthly_salary_expense'] ?? 0} TND',
                      Icons.payments,
                      Colors.purple,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      AppLocalizations.of(context)!.productivity,
                      '${stats['productivity'] ?? 0}%',
                      Icons.trending_up,
                      Colors.teal,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Workforce Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.workforce,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (!isLoadingWorkers)
                    Text(
                      AppLocalizations.of(context)!.totalSuffix(workers.length),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              if (isLoadingWorkers && workers.isEmpty)
                _buildWorkersListShimmer(isDark)
              else if (workers.isEmpty)
                _buildEmptyWorkforce()
              else
                ...workers.map(_buildWorkerCard),

              // Invitations Section
              const SizedBox(height: 32),
              _buildInvitationsSection(lifecycleProvider, isDark, isLoadingInvitations),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWorkforce() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noWorkersYet,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.addWorkersMarketplaceHint,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsSection(WorkerLifecycleProvider provider, bool isDark, bool isLoading) {
    // FILTER: ONLY PENDING, EXCLUDE APPROVED (Accepted)
    // This ensures no duplication with the Workforce list
    final pending = provider.landInvitations.where((i) => i.isPending).toList();

    if (isLoading && pending.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.pendingInvitations,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 14),
          _buildInvitationsListShimmer(isDark),
        ],
      );
    }

    if (pending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.pendingInvitations,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('${pending.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                ),
              ],
            ),
            if (isLoading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)!.waitingForWorkerResponse,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey.shade500),
        ),
        const SizedBox(height: 14),
        ...pending.map((inv) => _buildInvitationCard(inv, isDark)),
      ],
    );
  }
  Widget _buildInvitationCard(WorkerInvitation invitation, bool isDark) {
    // Calculate remaining time
    String timeLeft = '';
    if (invitation.expiresAt != null) {
      final remaining = invitation.expiresAt!.difference(DateTime.now());
      if (remaining.isNegative) {
        timeLeft = AppLocalizations.of(context)!.expiredLabel;
      } else if (remaining.inDays > 0) {
        timeLeft = AppLocalizations.of(context)!.daysLeft(remaining.inDays);
      } else if (remaining.inHours > 0) {
        timeLeft = AppLocalizations.of(context)!.hoursLeft(remaining.inHours);
      } else {
        timeLeft = AppLocalizations.of(context)!.minutesLeft(remaining.inMinutes);
      }
    }

    final statusColor = invitation.isPending
        ? Colors.amber
        : invitation.isApproved
        ? Colors.green
        : invitation.isDeclined
        ? Colors.red
        : Colors.grey;
    final statusLabel = invitation.isPending
        ? AppLocalizations.of(context)!.pendingUpper
        : invitation.isApproved
        ? AppLocalizations.of(context)!.acceptedUpper
        : invitation.isDeclined
        ? AppLocalizations.of(context)!.declinedUpper
        : AppLocalizations.of(context)!.expiredUpper;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          FarmyAvatar(
            imageUrl: invitation.workerProfilePicture,
            radius: 22,
            displayName: invitation.workerName,
            fallbackIcon: invitation.isPending
                ? Icons.mail_outline
                : invitation.isApproved
                ? Icons.check_circle_outline
                : invitation.isDeclined
                ? Icons.cancel_outlined
                : Icons.timer_off_outlined,
            border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.workerName ?? AppLocalizations.of(context)!.worker,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (invitation.message != null &&
                    invitation.message!.isNotEmpty)
                  Text(
                    invitation.message!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (timeLeft.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeLeft,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (invitation.isPending) ...[
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner({
    required String title,
    required String message,
    required bool isDark,
    required VoidCallback onRetry,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.withValues(alpha: 0.08) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.red.shade200 : Colors.red.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }


  Widget _buildStatsShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 110, decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(20)))),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 110, decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(20)))),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 110, decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(20)))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Container(height: 110, decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(20)))),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 110, decoration: BoxDecoration(color: isDark ? Colors.grey.shade900 : Colors.white, borderRadius: BorderRadius.circular(20)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkersListShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        children: List.generate(3, (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        )),
      ),
    );
  }

  Widget _buildInvitationsListShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        children: List.generate(2, (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 90,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        )),
      ),
    );
  }

}
