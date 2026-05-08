import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/farmy_avatar.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../providers/job_request_provider.dart';
import '../../providers/job_application_provider.dart';
import '../../models/land_worker_model.dart';
import '../../models/worker_invitation_model.dart';
import '../../models/job_request_model.dart';
import 'worker_marketplace_screen.dart';
import 'components/post_job_modal.dart';
import '../../widgets/profile_preview_sheet.dart';
import 'manage_applications_screen.dart';
import '../../theme/app_theme.dart';

class WorkforceScreen extends StatefulWidget {
  final String landId;
  final String landName;
  final bool canHire;

  const WorkforceScreen({
    super.key,
    required this.landId,
    required this.landName,
    this.canHire = true,
  });

  @override
  State<WorkforceScreen> createState() => _WorkforceScreenState();
}

class _WorkforceScreenState extends State<WorkforceScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final jobProv = context.read<JobRequestProvider>();

    await Future.wait([
      workerProv.loadLandWorkers(widget.landId),
      lifecycleProv.loadInvitationsByLand(widget.landId),
      jobProv.fetchAllJobs(filters: {'land_id': widget.landId}),
    ]);
  }

  @override
  void dispose() {
    _animController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.primaryColor;
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
              color: AppTheme.primaryColor,
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
                if (mounted) {
                  _refreshAll();
                }
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.work_outline,
              title: AppLocalizations.of(context)!.openJobRequest,
              subtitle: AppLocalizations.of(context)!.postJobDescription,
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                _showPostJobModal(context);
              },
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: comingSoon
                ? Colors.grey.shade300
                : color.withValues(alpha: 0.3),
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
                      color: comingSoon
                          ? Colors.grey
                          : (isDark ? Colors.white : AppTheme.lightTextPrimary),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: comingSoon
                          ? Colors.grey
                          : (isDark
                                ? Colors.white38
                                : AppTheme.lightTextSecondary),
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

  Widget _buildWorkerCard(LandWorker worker) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: () => ProfilePreviewSheet.show(context, worker.workerId),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
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
            FarmyAvatar(
              imageUrl: worker.workerProfilePicture,
              radius: 24,
              displayName: worker.workerName,
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.workerName ??
                        AppLocalizations.of(context)!.unknownWorker,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppTheme.lightTextPrimary,
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
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
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
                      const SizedBox(width: 8),
                      _buildSourceBadge(worker.hiringSource, isDark),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${worker.salary.toStringAsFixed(0)} ${AppLocalizations.of(context)!.tndMo}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white38
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
    final theme = Theme.of(context);
    final workerProvider = context.watch<WorkerProvider>();
    final lifecycleProvider = context.watch<WorkerLifecycleProvider>();
    final isDark = theme.brightness == Brightness.dark;

    final stats = workerProvider.workforceStats;
    final workers = workerProvider.landWorkers;
    final isLoadingWorkers = workerProvider.landWorkersLoading;
    final isLoadingInvitations = lifecycleProvider.landInvitationsLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.workforceLandName(widget.landName),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: isDark
              ? Colors.white38
              : AppTheme.lightTextSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.activeWorkforce),
            Tab(text: AppLocalizations.of(context)!.jobRequests),
            Tab(text: AppLocalizations.of(context)!.invitations),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkerModal,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.addWorker,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: TabBarView(
          controller: _tabController,
          children: [
            RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (workerProvider.landWorkersError != null)
                    _buildErrorBanner(
                      title: AppLocalizations.of(context)!.workersSyncIssue,
                      message: workerProvider.landWorkersError!,
                      isDark: isDark,
                      onRetry: _refreshAll,
                    ),
                  _buildStatsDashboard(stats, isLoadingWorkers, isDark),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    AppLocalizations.of(context)!.activeWorkforce,
                    workers.length.toString(),
                  ),
                  const SizedBox(height: 14),
                  if (isLoadingWorkers && workers.isEmpty)
                    _buildWorkersListShimmer(isDark)
                  else if (workers.isEmpty)
                    _buildEmptyWorkforce()
                  else
                    ...workers.map(_buildWorkerCard),
                ],
              ),
            ),
            RefreshIndicator(
              onRefresh: _refreshAll,
              child: _buildJobRequestsTab(isDark),
            ),
            RefreshIndicator(
              onRefresh: _refreshAll,
              child: _buildInvitationsTab(
                lifecycleProvider,
                isDark,
                isLoadingInvitations,
              ),
            ),
          ],
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
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

  void _showPostJobModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostJobModal(initialLandId: widget.landId),
    );
  }

  Widget _buildInvitationCard(WorkerInvitation invitation, bool isDark) {
    final theme = Theme.of(context);
    String timeLeft = '';
    if (invitation.expiresAt != null) {
      final remaining = invitation.expiresAt!.difference(DateTime.now());
      if (remaining.isNegative) {
        timeLeft = 'Expired';
      } else if (remaining.inDays > 0) {
        timeLeft = '${remaining.inDays}d left';
      } else {
        timeLeft = '${remaining.inHours}h left';
      }
    }

    final statusColor = Colors.amber;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          FarmyAvatar(
            imageUrl: invitation.workerProfilePicture,
            radius: 22,
            displayName: invitation.workerName,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.workerName ?? 'Worker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invitation.message ?? 'Hiring invitation',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white38
                        : AppTheme.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (timeLeft.isNotEmpty)
                Text(
                  timeLeft,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white24 : Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String count, {
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: const Text(
                'View All',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSourceBadge(HiringSource source, bool isDark) {
    Color color;
    String label;
    IconData icon;

    switch (source) {
      case HiringSource.invitation:
        color = Colors.blue;
        label = 'INVITED';
        icon = Icons.mail_outline_rounded;
        break;
      case HiringSource.jobApplication:
        color = Colors.purple;
        label = 'APPLICANT';
        icon = Icons.assignment_ind_outlined;
        break;
      default:
        color = Colors.orange;
        label = 'MANUAL';
        icon = Icons.person_add_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(
    Map<String, dynamic> stats,
    bool isLoading,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15, // Adjusted to prevent bottom overflow
        children: [
          _buildStatCard(
            'Active',
            '${stats['active'] ?? 0}',
            Icons.people_rounded,
            AppTheme.primaryColor,
            isDark,
          ),
          _buildStatCard(
            'Suspended',
            '${stats['suspended'] ?? 0}',
            Icons.pause_circle_outline,
            Colors.orange,
            isDark,
          ),
          _buildStatCard(
            'Monthly Cost',
            '${stats['monthlyCost'] ?? 0} TND',
            Icons.payments_outlined,
            Colors.blue,
            isDark,
          ),
          _buildStatCard(
            'Avg Productivity',
            '${stats['avgProductivity'] ?? 0}%',
            Icons.trending_up_rounded,
            Colors.purple,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16), // Slightly reduced padding
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.05 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -15,
            top: -15,
            child: Icon(icon, color: color.withValues(alpha: 0.05), size: 70),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark
                        ? Colors.white38
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobRequestsTab(bool isDark) {
    final theme = Theme.of(context);
    final jobProvider = context.watch<JobRequestProvider>();
    final jobs = jobProvider.allJobs
        .where((j) => j.landId == widget.landId)
        .toList();

    if (jobProvider.isLoading && jobs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (jobs.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.work_outline_rounded,
        title: AppLocalizations.of(context)!.noActiveJobRequestsTitle,
        subtitle: AppLocalizations.of(context)!.postJobMarketplaceHint,
        buttonLabel: AppLocalizations.of(context)!.postAJob,
        onPressed: () => _showPostJobModal(context),
        isDark: isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _buildJobRequestCard(job, isDark);
      },
    );
  }

  Widget _buildJobRequestCard(JobRequest job, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        title: Text(
          job.title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              job.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white38 : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMiniBadge(
                  Icons.payments_outlined,
                  '${job.salary ?? 0} TND',
                  AppTheme.primaryColor,
                ),
                const SizedBox(width: 16),
                _buildMiniBadge(
                  Icons.timer_outlined,
                  job.duration ?? 'Not set',
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.people_outline_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ManageApplicationsScreen(
                  jobId: job.id,
                  jobTitle: job.title,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInvitationsTab(
    WorkerLifecycleProvider lifecycle,
    bool isDark,
    bool isLoading,
  ) {
    final pending = lifecycle.pendingInvitations
        .where((i) => i.landId == widget.landId)
        .toList();

    if (isLoading && pending.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (pending.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.mail_outline_rounded,
        title: AppLocalizations.of(context)!.noPendingInvitationsTitle,
        subtitle: AppLocalizations.of(context)!.inviteMarketplaceHint,
        buttonLabel: AppLocalizations.of(context)!.searchMarketplace,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerMarketplaceScreen(
              landId: widget.landId,
              landName: widget.landName,
            ),
          ),
        ),
        isDark: isDark,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final inv = pending[index];
        return _buildInvitationCard(inv, isDark);
      },
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white38 : AppTheme.lightTextSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.withValues(alpha: 0.08) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade400),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: Colors.red),
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
        children: List.generate(
          3,
          (index) => Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationsListShimmer(bool isDark) =>
      _buildWorkersListShimmer(isDark);
}
