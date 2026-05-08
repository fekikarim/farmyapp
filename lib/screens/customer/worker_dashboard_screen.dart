import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../models/task_model.dart';
import '../../models/land_worker_model.dart';
import '../../models/worker_invitation_model.dart';
import '../../models/worker_contract_model.dart';
import '../../models/proof_request_model.dart';
import '../../services/proof_service.dart';
import '../../services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import '../shared/contract_negotiation_screen.dart';
import 'worker_land_details_screen.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final Set<String> _invitationActionLoading = <String>{};

  Future<void> _refreshDashboard() async {
    final workerProvider = context.read<WorkerProvider>();
    final lifecycle = context.read<WorkerLifecycleProvider>();
    await Future.wait([
      workerProvider.refreshWorkerDashboard(),
      lifecycle.refreshWorkerDashboardLifecycle(),
    ]);
  }

  Future<void> _handleInvitationResponse({
    required WorkerInvitation invitation,
    required String response,
  }) async {
    setState(() => _invitationActionLoading.add(invitation.id));
    final lifecycle = context.read<WorkerLifecycleProvider>();
    final workerProvider = context.read<WorkerProvider>();

    final ok = await lifecycle.respondToInvitation(
      invitationId: invitation.id,
      response: response,
    );

    if (ok) {
      await Future.wait([
        lifecycle.refreshWorkerDashboardLifecycle(),
        workerProvider.loadAssignedLands(),
      ]);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? (response == 'approve'
                      ? AppLocalizations.of(context)!.invitationAcceptedSuccess
                      : AppLocalizations.of(context)!.invitationDeclinedSuccess)
                : (lifecycle.lastError ??
                      AppLocalizations.of(context)!.unableToProcessInvitation),
          ),
          backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
        ),
      );
      setState(() => _invitationActionLoading.remove(invitation.id));
    }
  }

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
      _refreshDashboard();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = workerProvider.myProfile;
    final lands = workerProvider.assignedLands;
    final tasks = workerProvider.myTasks;

    final lifecycle = context.watch<WorkerLifecycleProvider>();

    final isLoading =
        workerProvider.profileLoading ||
        workerProvider.assignedLandsLoading ||
        workerProvider.myTasksLoading ||
        lifecycle.myInvitationsLoading ||
        lifecycle.myContractsLoading;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workerDashboard),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? _buildShimmerDashboard(isDark)
          : FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: _refreshDashboard,
                edgeOffset: 20,
                color: const Color(0xFF10B981),
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (workerProvider.profileError != null)
                      _buildErrorBanner(
                        title: AppLocalizations.of(context)!.profileSyncIssue,
                        message: workerProvider.profileError!,
                        isDark: isDark,
                        onRetry: _refreshDashboard,
                      ),
                    if (workerProvider.assignedLandsError != null)
                      _buildErrorBanner(
                        title: AppLocalizations.of(context)!.assignedLandsUnavailable,
                        message: workerProvider.assignedLandsError!,
                        isDark: isDark,
                        onRetry: () => workerProvider.loadAssignedLands(),
                      ),
                    if (workerProvider.myTasksError != null)
                      _buildErrorBanner(
                        title: AppLocalizations.of(context)!.tasksUnavailable,
                        message: workerProvider.myTasksError!,
                        isDark: isDark,
                        onRetry: () => workerProvider.loadMyTasks(),
                      ),
                    if (lifecycle.myInvitationsError != null)
                      _buildErrorBanner(
                        title: AppLocalizations.of(context)!.invitationsUnavailable,
                        message: lifecycle.myInvitationsError!,
                        isDark: isDark,
                        onRetry: () => lifecycle.loadMyInvitations(),
                      ),
                    if (lifecycle.myContractsError != null)
                      _buildErrorBanner(
                        title: AppLocalizations.of(context)!.contractsUnavailable,
                        message: lifecycle.myContractsError!,
                        isDark: isDark,
                        onRetry: () => lifecycle.loadMyContracts(),
                      ),
                    if (lifecycle.myProofsError != null)
                      _buildErrorBanner(
                        title: AppLocalizations.of(context)!.proofsUnavailable,
                        message: lifecycle.myProofsError!,
                        isDark: isDark,
                        onRetry: () => lifecycle.loadMyProofs(),
                      ),


                    // Quick Stats
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.85,
                      children: [
                        _statWidget(
                          AppLocalizations.of(context)!.assignedLands,
                          '${lands.length}',
                          Icons.landscape,
                          Colors.green,
                          isDark,
                        ),
                        _statWidget(
                          AppLocalizations.of(context)!.activeTasks,
                          '${tasks.where((t) => t.isAssigned || t.isInProgress).length}',
                          Icons.task,
                          Colors.blue,
                          isDark,
                        ),
                        _statWidget(
                          AppLocalizations.of(context)!.escrowBalance,
                          AppLocalizations.of(context)!.amountPrefix(_getPendingBalance(lifecycle)),
                          Icons.account_balance_wallet,
                          Colors.purple,
                          isDark,
                        ),
                        _statWidget(
                          AppLocalizations.of(context)!.performance,
                          '${profile?.rating.toStringAsFixed(1) ?? '0.0'}',
                          Icons.star,
                          Colors.amber,
                          isDark,
                        ),
                        _statWidget(
                          AppLocalizations.of(context)!.completed,
                          '${profile?.completedTasks ?? 0}',
                          Icons.check_circle,
                          Colors.teal,
                          isDark,
                        ),
                        _statWidget(
                          AppLocalizations.of(context)!.onTime,
                          '${profile?.onTimeRate.toStringAsFixed(0) ?? '0'}%',
                          Icons.timer,
                          Colors.orange,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Escrow Balance Info
                    if (!lifecycle.balanceLoading &&
                        (double.tryParse(
                                  lifecycle.myBalance['pending_balance']
                                          ?.toString() ??
                                      '0',
                                ) ??
                                0) >
                            0)
                      _buildEscrowBalanceCard(lifecycle, isDark),
                    if ((double.tryParse(
                              lifecycle.myBalance['pending_balance']
                                      ?.toString() ??
                                  '0',
                            ) ??
                            0) >
                        0)
                      const SizedBox(height: 24),

                    // Assigned Lands
                    _sectionHeader(AppLocalizations.of(context)!.assignedLands, Icons.landscape, isDark),
                    const SizedBox(height: 12),
                    if (lands.isEmpty)
                      _emptyState(
                        AppLocalizations.of(context)!.noLandAssignments,
                        AppLocalizations.of(context)!.noLandAssignmentsHint,
                        Icons.landscape_outlined,
                      )
                    else
                      ...lands.map(
                        (land) => _buildLandCard(land, lifecycle, isDark),
                      ),
                    const SizedBox(height: 24),

                    // ── Lifecycle Loading / Error ──
                    if (lifecycle.myContractsLoading ||
                        lifecycle.myInvitationsLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.green.shade500,
                            ),
                          ),
                        ),
                      ),

                    if (lifecycle.myContractsError != null &&
                        !lifecycle.myContractsLoading)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.red.withOpacity(0.1)
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              color: Colors.red.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.failedToLoadContracts,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.red.shade300
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lifecycle.myContractsError!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.red.shade200
                                          : Colors.red.shade600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                lifecycle.loadMyContracts();
                                lifecycle.loadMyInvitations();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.refresh_rounded,
                                  size: 20,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ── Farmer Invitations Section ──
                    Builder(
                      builder: (context) {
                        final pendingInvitations = lifecycle.myInvitations
                            .where((i) => i.isPending)
                            .toList();
                        if (pendingInvitations.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              AppLocalizations.of(context)!.farmerInvitations,
                              Icons.mail_outline,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            ...pendingInvitations.map(
                              (inv) => _buildInvitationActionCard(inv, isDark),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    Builder(
                      builder: (context) {
                        final updates =
                            lifecycle.myInvitations
                                .where((i) => !i.isPending)
                                .toList()
                              ..sort(
                                (a, b) => (b.createdAt ?? DateTime(1970))
                                    .compareTo(a.createdAt ?? DateTime(1970)),
                              );
                        if (updates.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              AppLocalizations.of(context)!.invitationUpdates,
                              Icons.mark_email_read_outlined,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            ...updates
                                .take(5)
                                .map(
                                  (inv) =>
                                      _buildInvitationStatusCard(inv, isDark),
                                ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // ── Hiring Proposals Section ──
                    Builder(
                      builder: (context) {
                        final proposals = lifecycle.myContracts
                            .where(
                              (c) =>
                                  c.status == 'hiring_pending' ||
                                  c.status == 'negotiation_pending' ||
                                  c.status == 'negotiation_countered' ||
                                  c.status == 'payment_pending',
                            )
                            .toList();
                        if (proposals.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              AppLocalizations.of(context)!.hiringProposals,
                              Icons.handshake_outlined,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            ...proposals.map(
                              (contract) =>
                                  _buildContractActionCard(contract, isDark),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Proof Requests Section ──
                    Builder(
                      builder: (context) {
                        final pendingProofs = lifecycle.pendingMyProofs;
                        if (pendingProofs.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              AppLocalizations.of(context)!.proofRequests,
                              Icons.camera_alt_outlined,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            ...pendingProofs.map(
                              (proof) => _buildProofActionCard(proof, isDark),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // ── Proof History Section ──
                    Builder(
                      builder: (context) {
                        final historyProofs = lifecycle.historyMyProofs;
                        if (historyProofs.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              AppLocalizations.of(context)!.proofHistory,
                              Icons.history_rounded,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            ...historyProofs
                                .take(10)
                                .map(
                                  (proof) =>
                                      _buildProofActionCard(proof, isDark),
                                ),
                            if (historyProofs.length > 10)
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    // Could navigate to a full history screen later
                                  },
                                  child: Text(AppLocalizations.of(context)!.viewAllHistory),
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // ── Active Contracts Section ──
                    Builder(
                      builder: (context) {
                        final activeContracts = lifecycle.myContracts
                            .where((c) => c.status == 'active')
                            .toList();
                        if (activeContracts.isEmpty) return const SizedBox();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              AppLocalizations.of(context)!.activeContracts,
                              Icons.verified_outlined,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            ...activeContracts.map(
                              (contract) =>
                                  _buildActiveContractCard(contract, isDark),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),

                    // Active Tasks
                    _sectionHeader(AppLocalizations.of(context)!.activeTasks, Icons.task, isDark),
                    const SizedBox(height: 12),
                    if (tasks.isEmpty)
                      _emptyState(
                        AppLocalizations.of(context)!.noTasksAssigned,
                        AppLocalizations.of(context)!.noTasksAssignedHint,
                        Icons.task_outlined,
                      )
                    else
                      ...tasks
                          .take(5)
                          .map((task) => _buildTaskCard(task, isDark)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }


  Widget _buildEscrowBalanceCard(
    WorkerLifecycleProvider lifecycle,
    bool isDark,
  ) {
    final pending =
        double.tryParse(
          lifecycle.myBalance['pending_balance']?.toString() ?? '0',
        ) ??
        0.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: isDark ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.deepPurpleAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.escrowBalance.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.deepPurple.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.amountPrefix(pending.toStringAsFixed(2)),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.deepPurple.shade900,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.fundsReleasedAfterVerification,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPendingBalance(WorkerLifecycleProvider lifecycle) {
    final balance = lifecycle.myBalance;
    final pending = balance['pending_balance'];
    if (pending == null) return '0';
    final val = double.tryParse(pending.toString()) ?? 0.0;
    return val.toStringAsFixed(0);
  }

  Widget _statWidget(
    String label,
    String value,
    IconData icon,
    MaterialColor color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.15 : 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : color.shade900,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white.withValues(alpha: 0.4) : color.shade700,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDashboard(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Column(
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
              children: List.generate(
                6,
                (i) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(height: 30, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Container(height: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandCard(
    LandWorker land,
    WorkerLifecycleProvider lifecycle,
    bool isDark,
  ) {
    final relatedContract = lifecycle.myContracts.where(
      (c) => c.landId == land.landId,
    );
    WorkerContract? contract;
    if (relatedContract.isNotEmpty) {
      contract = relatedContract.first;
    }

    final relatedInvitation = lifecycle.myInvitations.where(
      (i) => i.landId == land.landId,
    );
    WorkerInvitation? invitation;
    if (relatedInvitation.isNotEmpty) {
      invitation = relatedInvitation.first;
    }

    final farmerName =
        contract?.investorName ??
        invitation?.farmerName ??
        land.assignerName ??
        AppLocalizations.of(context)!.farmer;
    final relationStatus =
        contract?.statusLabel ??
        (invitation != null
            ? (invitation.isApproved
                  ? AppLocalizations.of(context)!.invitationApproved
                  : invitation.isPending
                  ? AppLocalizations.of(context)!.invitationPending
                  : invitation.isDeclined
                  ? AppLocalizations.of(context)!.invitationDeclined
                  : AppLocalizations.of(context)!.invitationExpired)
            : null);

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkerLandDetailsScreen(assignment: land),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.landscape_rounded, color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                land.landName ?? AppLocalizations.of(context)!.land,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: land.isActive ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  if (land.isActive)
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              land.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.amountPerMonth(land.salary.toStringAsFixed(0)),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.person_pin_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                farmerName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (relationStatus != null)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _translateContractStatus(context, relationStatus).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(FarmTask task, bool isDark) {
    final theme = Theme.of(context);
    final statusColor = task.isCompleted
        ? Colors.green
        : task.isAssigned
        ? Colors.blue
        : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    task.typeIcon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '⏱ ${task.timeRequiredMinutes}${AppLocalizations.of(context)!.min}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.orange.shade300 : Colors.orange.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '💰 ${AppLocalizations.of(context)!.amountPrefix(task.reward.toStringAsFixed(0))}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.green.shade300 : Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _translateTaskStatus(context, task.statusLabel).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationActionCard(WorkerInvitation invitation, bool isDark) {
    final remaining = invitation.expiresAt?.difference(DateTime.now());
    final timeLeft = remaining == null
        ? null
        : remaining.isNegative
        ? AppLocalizations.of(context)!.expiredLabel
        : remaining.inDays > 0
        ? AppLocalizations.of(context)!.daysLeft(remaining.inDays)
        : remaining.inHours > 0
        ? AppLocalizations.of(context)!.hoursLeft(remaining.inHours)
        : AppLocalizations.of(context)!.minutesLeft(remaining.inMinutes);
    final isSubmitting = _invitationActionLoading.contains(invitation.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.withOpacity(0.15),
                child: Icon(
                  Icons.mail_outline,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.invitationFrom(invitation.farmerName ?? AppLocalizations.of(context)!.farmer),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (invitation.landName != null)
                      Text(
                        AppLocalizations.of(context)!.landWithColon(invitation.landName ?? ""),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    if (invitation.farmerEmail != null)
                      Text(
                        invitation.farmerEmail!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (timeLeft != null)
                      Text(
                        timeLeft,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.orange.shade300
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (invitation.message != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"${invitation.message}"',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => _handleInvitationResponse(
                          invitation: invitation,
                          response: 'decline',
                        ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(AppLocalizations.of(context)!.decline),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () => _handleInvitationResponse(
                          invitation: invitation,
                          response: 'approve',
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.accept),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationStatusCard(WorkerInvitation invitation, bool isDark) {
    final isApproved = invitation.isApproved;
    final isDeclined = invitation.isDeclined;
    final theme = Theme.of(context);
    
    final statusColor = isApproved
        ? Colors.green
        : isDeclined
        ? Colors.red
        : Colors.grey;
        
    final statusLabel = isApproved
        ? AppLocalizations.of(context)!.approvedUpper
        : isDeclined
        ? AppLocalizations.of(context)!.declinedUpper
        : AppLocalizations.of(context)!.expiredUpper;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isApproved
                        ? Icons.check_circle_rounded
                        : isDeclined
                        ? Icons.cancel_rounded
                        : Icons.timer_off_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.farmerName ?? AppLocalizations.of(context)!.farmer,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        invitation.landName ?? AppLocalizations.of(context)!.land,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.red.shade200 : Colors.red.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry)),
        ],
      ),
    );
  }

  Widget _buildContractActionCard(WorkerContract contract, bool isDark) {
    Color statusColor;
    String statusText;
    switch (contract.status) {
      case 'hiring_pending':
        statusColor = Colors.blue;
        statusText = AppLocalizations.of(context)!.newProposal;
        break;
      case 'negotiation_pending':
      case 'negotiation_countered':
        statusColor = Colors.orange;
        statusText = AppLocalizations.of(context)!.negotiating;
        break;
      case 'payment_pending':
        statusColor = Colors.purple;
        statusText = AppLocalizations.of(context)!.awaitingPayment;
        break;
      default:
        statusColor = Colors.grey;
        statusText = _translateContractStatus(context, contract.statusLabel);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ContractNegotiationScreen(contract: contract),
          ),
        ).then((_) {
          final lc = context.read<WorkerLifecycleProvider>();
          lc.loadMyContracts();
          lc.loadMyInvitations();
          lc.loadMyBalance();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: statusColor.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: statusColor.withOpacity(0.15),
              child: Icon(Icons.handshake, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.investorName ?? AppLocalizations.of(context)!.investor,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.amountPerType(contract.salaryAmount.toStringAsFixed(0), _translateSalaryTypeLabel(context, contract.salaryTypeLabel)),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContractCard(WorkerContract contract, bool isDark) {
    final theme = Theme.of(context);
    final statusColor = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.work_rounded, color: statusColor, size: 24),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.investorName ?? AppLocalizations.of(context)!.investor,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.amountPerType(
                              contract.salaryAmount.toStringAsFixed(0),
                              _translateSalaryTypeLabel(context, contract.salaryTypeLabel),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.activeLabelUpper,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.untilDate(DateFormat('MMM d').format(contract.contractEndDate)),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
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

  Widget _buildProofActionCard(ProofRequest proof, bool isDark) {
    final bool isVerified = proof.isVerified;
    final bool isRejected = proof.isRejected;
    final bool isExpired = proof.isExpired;
    final bool isPending = proof.isPending && !isExpired;

    Color cardColor;
    Color iconColor;
    if (isVerified) {
      cardColor = Colors.green;
      iconColor = Colors.green;
    } else if (isRejected) {
      cardColor = Colors.red;
      iconColor = Colors.red;
    } else if (isExpired) {
      cardColor = Colors.grey;
      iconColor = Colors.grey;
    } else {
      cardColor = Colors.blue;
      iconColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? cardColor.withOpacity(0.05)
            : cardColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isVerified
                      ? Icons.check_circle_outline
                      : isRejected
                      ? Icons.error_outline
                      : isExpired
                      ? Icons.timer_off_outlined
                      : Icons.camera_alt,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proof.targetName ?? proof.landName ?? AppLocalizations.of(context)!.farmingActivity,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isVerified
                          ? AppLocalizations.of(context)!.verificationSuccessful
                          : isRejected
                          ? AppLocalizations.of(context)!.verificationFailed
                          : isExpired
                          ? AppLocalizations.of(context)!.requestExpired
                          : (proof.targetType == 'item'
                                ? AppLocalizations.of(context)!.itemVerification
                                : AppLocalizations.of(context)!.generalLandProof),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? cardColor.withOpacity(0.7)
                            : cardColor.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 10,
                          color: isDark
                              ? Colors.blue.shade300
                              : Colors.blue.shade600,
                        ),
                        const SizedBox(width: 4),
                        _ProofCountdown(
                          proof: proof,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isVerified
                      ? AppLocalizations.of(context)!.verifiedUpper
                      : isRejected
                      ? AppLocalizations.of(context)!.rejectedUpper
                      : isExpired
                      ? AppLocalizations.of(context)!.expiredUpper
                      : AppLocalizations.of(context)!.aiVerifyUpper,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? iconColor.withOpacity(0.8) : iconColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (proof.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                '${AuthService.baseUrl}${proof.imageUrl}',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey.withOpacity(0.1),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                      );
                      if (image != null) {
                        final lifecycle = context
                            .read<WorkerLifecycleProvider>();
                        final statusNotifier = ValueNotifier<String>(
                          AppLocalizations.of(context)!.uploadingImage,
                        );

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: isDark
                                ? const Color(0xFF2A2D30)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            content: ValueListenableBuilder<String>(
                              valueListenable: statusNotifier,
                              builder: (context, status, _) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 10),
                                    CircularProgressIndicator(
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      status,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!.pleaseWaitAFewMoments,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                          ),
                        );

                        final error = await ProofService.submitProof(
                          proof.id,
                          image,
                          onStatusUpdate: (status) =>
                              statusNotifier.value = status,
                        );

                        if (context.mounted) Navigator.pop(context);
                        statusNotifier.dispose();

                        if (error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.proofSubmittedVerified),
                            ),
                          );
                          lifecycle.loadMyProofs();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.upload_rounded, size: 18),
                    label: Text(AppLocalizations.of(context)!.captureSubmit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (isRejected && proof.aiReasoning != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      proof.aiReasoning!,
                      style: const TextStyle(fontSize: 11, color: Colors.red),
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

  Widget _emptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _translateContractStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.activeLabel;
      case 'pending':
      case 'hiring_pending':
      case 'payment_pending':
        return l10n.pendingLabel;
      case 'suspended':
        return l10n.suspendedLabel;
      case 'inactive':
        return l10n.inactiveLabel;
      default:
        return status;
    }
  }

  String _translateTaskStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'open':
      case 'assigned':
        return l10n.open;
      case 'in_progress':
      case 'in progress':
        return l10n.inProgress;
      case 'completed':
      case 'done':
        return l10n.completed;
      default:
        return status;
    }
  }

  String _translateSalaryTypeLabel(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context)!;
    switch (label.toLowerCase()) {
      case 'monthly':
        return l10n.monthly;
      case 'hourly':
        return l10n.hourly;
      case 'per task':
      case 'per_task':
        return l10n.perTask;
      default:
        return label;
    }
  }
}

class _ProofCountdown extends StatefulWidget {
  final ProofRequest proof;
  final TextStyle? style;
  const _ProofCountdown({required this.proof, this.style});

  @override
  State<_ProofCountdown> createState() => _ProofCountdownState();
}

class _ProofCountdownState extends State<_ProofCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
        if (widget.proof.isExpired) {
          _timer?.cancel();
        }
      }
    });
  }

  @override
  void didUpdateWidget(_ProofCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.proof.id != widget.proof.id ||
        oldWidget.proof.expiresAt != widget.proof.expiresAt) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.proof.timeRemaining, style: widget.style);
  }
}
