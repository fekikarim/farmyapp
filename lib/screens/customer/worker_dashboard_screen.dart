import 'package:flutter/material.dart';
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
                      ? 'Invitation accepted successfully.'
                      : 'Invitation declined successfully.')
                : (lifecycle.lastError ??
                      'Unable to process invitation response.'),
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
        title: const Text('Worker Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnim,
              child: RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (workerProvider.profileError != null)
                      _buildErrorBanner(
                        title: 'Profile sync issue',
                        message: workerProvider.profileError!,
                        isDark: isDark,
                        onRetry: _refreshDashboard,
                      ),
                    if (workerProvider.assignedLandsError != null)
                      _buildErrorBanner(
                        title: 'Assigned lands unavailable',
                        message: workerProvider.assignedLandsError!,
                        isDark: isDark,
                        onRetry: () => workerProvider.loadAssignedLands(),
                      ),
                    if (workerProvider.myTasksError != null)
                      _buildErrorBanner(
                        title: 'Tasks unavailable',
                        message: workerProvider.myTasksError!,
                        isDark: isDark,
                        onRetry: () => workerProvider.loadMyTasks(),
                      ),
                    if (lifecycle.myInvitationsError != null)
                      _buildErrorBanner(
                        title: 'Invitations unavailable',
                        message: lifecycle.myInvitationsError!,
                        isDark: isDark,
                        onRetry: () => lifecycle.loadMyInvitations(),
                      ),
                    if (lifecycle.myContractsError != null)
                      _buildErrorBanner(
                        title: 'Contracts unavailable',
                        message: lifecycle.myContractsError!,
                        isDark: isDark,
                        onRetry: () => lifecycle.loadMyContracts(),
                      ),
                    if (lifecycle.myProofsError != null)
                      _buildErrorBanner(
                        title: 'Proofs unavailable',
                        message: lifecycle.myProofsError!,
                        isDark: isDark,
                        onRetry: () => lifecycle.loadMyProofs(),
                      ),

                    // Profile Status Card
                    if (profile != null) _buildProfileCard(profile, isDark),
                    const SizedBox(height: 20),

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
                          'Assigned Lands',
                          '${lands.length}',
                          Icons.landscape,
                          Colors.green,
                          isDark,
                        ),
                        _statWidget(
                          'Active Tasks',
                          '${tasks.where((t) => t.isAssigned || t.isInProgress).length}',
                          Icons.task,
                          Colors.blue,
                          isDark,
                        ),
                        _statWidget(
                          'Escrow Balance',
                          '\$${_getPendingBalance(lifecycle)}',
                          Icons.account_balance_wallet,
                          Colors.purple,
                          isDark,
                        ),
                        _statWidget(
                          'Performance',
                          '${profile?.rating.toStringAsFixed(1) ?? '0.0'}',
                          Icons.star,
                          Colors.amber,
                          isDark,
                        ),
                        _statWidget(
                          'Completed',
                          '${profile?.completedTasks ?? 0}',
                          Icons.check_circle,
                          Colors.teal,
                          isDark,
                        ),
                        _statWidget(
                          'On-time',
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
                    _sectionHeader('Assigned Lands', Icons.landscape, isDark),
                    const SizedBox(height: 12),
                    if (lands.isEmpty)
                      _emptyState(
                        'No land assignments yet',
                        'You\'ll see your assigned lands here',
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
                                    'Failed to load contracts',
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
                              'Farmer Invitations',
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
                              'Invitation Updates',
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
                              'Hiring Proposals',
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
                              'Proof Requests',
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
                              'Proof History',
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
                                  child: const Text('View All History'),
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
                              'Active Contracts',
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
                    _sectionHeader('Active Tasks', Icons.task, isDark),
                    const SizedBox(height: 12),
                    if (tasks.isEmpty)
                      _emptyState(
                        'No tasks assigned',
                        'Tasks will appear here when assigned',
                        Icons.task_outlined,
                      )
                    else
                      ...tasks
                          .take(5)
                          .map((task) => _buildTaskCard(task, isDark)),
                    const SizedBox(height: 24),

                    // Notifications Placeholder
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.blue.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: isDark
                                ? Colors.blue.shade400
                                : Colors.blue.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.blue.shade200
                                        : Colors.blue.shade800,
                                  ),
                                ),
                                Text(
                                  'Real-time task notifications coming soon',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.blue.shade100
                                        : Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.amber.withOpacity(0.15)
                                  : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Soon',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.amber.shade300
                                    : Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(dynamic profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981), // Emerald 500
            const Color(0xFF059669), // Emerald 600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: profile.userProfilePicture != null
                  ? NetworkImage(profile.userProfilePicture!)
                  : null,
              child: profile.userProfilePicture == null
                  ? const Icon(Icons.person, color: Colors.white, size: 32)
                  : null,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.userName ?? 'Worker',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (profile.isVerified)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFF059669),
                          size: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: profile.isVerified
                        ? Colors.white.withOpacity(0.2)
                        : Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        profile.isVerified
                            ? Icons.verified_user_outlined
                            : Icons.pending_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        profile.isVerified
                            ? 'Verified Worker'
                            : 'Pending Verification',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.purple.shade900.withOpacity(0.4),
                  Colors.deepPurple.shade900.withOpacity(0.3),
                ]
              : [Colors.purple.shade50, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.purple.shade700.withOpacity(0.3)
              : Colors.purple.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.purple.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Escrow Balance',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.purple.shade800,
                ),
              ),
              const Spacer(),
              Text(
                '\$${pending.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: isDark ? Colors.white : Colors.purple.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Funds will be released after task verification (Coming Soon)',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.purple.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
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

  Widget _sectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
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
        'Farmer';
    final relationStatus =
        contract?.statusLabel ??
        (invitation != null
            ? (invitation.isApproved
                  ? 'Invitation Approved'
                  : invitation.isPending
                  ? 'Invitation Pending'
                  : invitation.isDeclined
                  ? 'Invitation Declined'
                  : 'Invitation Expired')
            : null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerLandDetailsScreen(assignment: land),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(14),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.landscape, color: Colors.green.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      land.landName ?? 'Land',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          land.role,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '\$${land.salary.toStringAsFixed(0)}/mo',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Farmer: $farmerName',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (relationStatus != null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              relationStatus,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.blue.shade300
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: land.isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(FarmTask task, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Text(task.typeIcon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      task.typeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '⏱ ${task.timeRequiredMinutes}min',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '💰 \$${task.reward.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.green.shade400
                            : Colors.green.shade600,
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
              color: task.isCompleted
                  ? (isDark
                        ? Colors.green.withOpacity(0.15)
                        : Colors.green.shade50)
                  : (task.isAssigned
                        ? (isDark
                              ? Colors.blue.withOpacity(0.15)
                              : Colors.blue.shade50)
                        : (isDark
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.grey.shade100)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: task.isCompleted
                    ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
                    : (task.isAssigned
                          ? (isDark
                                ? Colors.blue.shade300
                                : Colors.blue.shade700)
                          : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationActionCard(WorkerInvitation invitation, bool isDark) {
    final remaining = invitation.expiresAt?.difference(DateTime.now());
    final timeLeft = remaining == null
        ? null
        : remaining.isNegative
        ? 'Expired'
        : remaining.inDays > 0
        ? '${remaining.inDays}d left'
        : remaining.inHours > 0
        ? '${remaining.inHours}h left'
        : '${remaining.inMinutes}m left';
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
                      'Invitation from ${invitation.farmerName ?? "Farmer"}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (invitation.landName != null)
                      Text(
                        'Land: ${invitation.landName}',
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
                  child: const Text('Decline'),
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
                      : const Text('Accept'),
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
    final statusColor = isApproved
        ? Colors.green
        : isDeclined
        ? Colors.red
        : Colors.grey;
    final statusLabel = isApproved
        ? 'APPROVED'
        : isDeclined
        ? 'DECLINED'
        : 'EXPIRED';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: statusColor.withOpacity(0.12),
            child: Icon(
              isApproved
                  ? Icons.check_circle_outline
                  : isDeclined
                  ? Icons.cancel_outlined
                  : Icons.timer_off_outlined,
              color: statusColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.farmerName ?? 'Farmer',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  invitation.landName ?? 'Land',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
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
          TextButton(onPressed: onRetry, child: const Text('Retry')),
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
        statusText = 'New Proposal';
        break;
      case 'negotiation_pending':
      case 'negotiation_countered':
        statusColor = Colors.orange;
        statusText = 'Negotiating';
        break;
      case 'payment_pending':
        statusColor = Colors.purple;
        statusText = 'Awaiting Payment';
        break;
      default:
        statusColor = Colors.grey;
        statusText = contract.statusLabel;
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
                    contract.investorName ?? 'Investor',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${contract.salaryAmount.toStringAsFixed(0)}/${contract.salaryTypeLabel}',
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
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
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green.withOpacity(0.15),
                child: Icon(Icons.work, color: Colors.green.shade600, size: 20),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.investorName ?? 'Investor',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${contract.salaryAmount.toStringAsFixed(0)}/${contract.salaryTypeLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...[
                const SizedBox(height: 4),
                Text(
                  'Until ${DateFormat('MMM d').format(contract.contractEndDate)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ],
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
                      proof.targetName ?? proof.landName ?? 'Farming activity',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isVerified
                          ? 'Verification Successful'
                          : isRejected
                          ? 'Verification Failed'
                          : isExpired
                          ? 'Request Expired'
                          : (proof.targetType == 'item'
                                ? 'Item Verification'
                                : 'General Land Proof'),
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
                      ? 'VERIFIED'
                      : isRejected
                      ? 'REJECTED'
                      : isExpired
                      ? 'EXPIRED'
                      : 'AI VERIFY',
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
                          'Uploading Image...',
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
                                      'Please wait a few moments',
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
                            const SnackBar(
                              content: Text('Proof submitted and verified!'),
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
                    label: const Text('Capture & Submit'),
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
