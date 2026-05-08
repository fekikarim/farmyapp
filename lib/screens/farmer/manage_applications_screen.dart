import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/job_application_provider.dart';
import '../../providers/worker_provider.dart';
import '../../models/job_application_model.dart';
import '../../widgets/farmy_avatar.dart';
import '../../widgets/profile_preview_sheet.dart';
import '../../models/user_model.dart' as user_model;
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class ManageApplicationsScreen extends StatefulWidget {
  final String jobId;
  final String? jobTitle;

  const ManageApplicationsScreen({
    super.key,
    required this.jobId,
    this.jobTitle,
  });

  @override
  State<ManageApplicationsScreen> createState() =>
      _ManageApplicationsScreenState();
}

class _ManageApplicationsScreenState extends State<ManageApplicationsScreen> {
  JobApplicationStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<JobApplicationProvider>().fetchJobApplications(
        widget.jobId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<JobApplicationProvider>();
    final allApplications = provider.getApplicationsForJob(widget.jobId);

    // Filter logic
    final applications = _statusFilter == null
        ? allApplications
        : allApplications.where((a) => a.status == _statusFilter).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 18,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _showFilterSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _statusFilter != null
                      ? AppTheme.primaryColor.withValues(alpha: 0.2)
                      : AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: _statusFilter != null
                      ? Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.5),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Icon(
                  _statusFilter != null
                      ? Icons.filter_alt_rounded
                      : Icons.filter_list_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: kToolbarHeight + 40),
              _buildHeaderInfo(isDark, theme),
              const SizedBox(height: 20),
              _buildStatsRow(allApplications, isDark, theme),
              const SizedBox(height: 10),
              if (_statusFilter != null) _buildActiveFilterChip(isDark),
              Expanded(
                child: _buildApplicationsList(
                  provider,
                  applications,
                  isDark,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filtering: ${_statusFilter!.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _statusFilter = null),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Applications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a status to filter the candidates',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            _buildFilterOption(
              'All Applications',
              null,
              Icons.all_inclusive_rounded,
              Colors.blue,
              isDark,
            ),
            _buildFilterOption(
              'Pending Only',
              JobApplicationStatus.pending,
              Icons.timer_outlined,
              Colors.amber,
              isDark,
            ),
            _buildFilterOption(
              'Approved Only',
              JobApplicationStatus.approved,
              Icons.verified_rounded,
              AppTheme.primaryColor,
              isDark,
            ),
            _buildFilterOption(
              'Rejected Only',
              JobApplicationStatus.rejected,
              Icons.cancel_rounded,
              Colors.red,
              isDark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    String label,
    JobApplicationStatus? status,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          setState(() => _statusFilter = status);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.applications,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              letterSpacing: -1.0,
            ),
          ),
          if (widget.jobTitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                widget.jobTitle!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    List<JobApplication> apps,
    bool isDark,
    ThemeData theme,
  ) {
    final pending = apps
        .where((a) => a.status == JobApplicationStatus.pending)
        .length;
    final approved = apps
        .where((a) => a.status == JobApplicationStatus.approved)
        .length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _statusFilter = null),
            child: _buildQuickStat(
              'Total',
              apps.length.toString(),
              Colors.blue,
              isDark,
              theme,
              _statusFilter == null,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () =>
                setState(() => _statusFilter = JobApplicationStatus.pending),
            child: _buildQuickStat(
              'Pending',
              pending.toString(),
              Colors.amber,
              isDark,
              theme,
              _statusFilter == JobApplicationStatus.pending,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () =>
                setState(() => _statusFilter = JobApplicationStatus.approved),
            child: _buildQuickStat(
              'Approved',
              approved.toString(),
              AppTheme.primaryColor,
              isDark,
              theme,
              _statusFilter == JobApplicationStatus.approved,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    Color color,
    bool isDark,
    ThemeData theme,
    bool isActive,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.1)
            : (isDark ? Colors.white.withValues(alpha: 0.05) : theme.cardColor),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.1),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.bold,
              color: isActive
                  ? color
                  : (isDark ? Colors.white70 : AppTheme.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(
    JobApplicationProvider provider,
    List<JobApplication> applications,
    bool isDark,
    ThemeData theme,
  ) {
    if (provider.isLoading && applications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryColor),
            SizedBox(height: 16),
          ],
        ),
      );
    }

    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _statusFilter == null
                    ? Icons.people_alt_outlined
                    : Icons.filter_list_off_rounded,
                size: 80,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _statusFilter == null ? 'No Applicants Yet' : 'No matches found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _statusFilter == null
                  ? 'Your job request is live and visible\nto workers in the marketplace.'
                  : 'Try changing your filter to see\nother application statuses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : AppTheme.lightTextSecondary,
                height: 1.5,
              ),
            ),
            if (_statusFilter != null)
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: TextButton(
                  onPressed: () => setState(() => _statusFilter = null),
                  child: const Text(
                    'Clear Filter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      key: ValueKey(_statusFilter), // Re-trigger animations when filter changes
      child: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () => provider.fetchJobApplications(widget.jobId),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
          physics: const BouncingScrollPhysics(),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _ApplicantCard(
                    application: application,
                    jobId: widget.jobId,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatefulWidget {
  final JobApplication application;
  final String jobId;

  const _ApplicantCard({required this.application, required this.jobId});

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final worker = widget.application.worker;
    final profile = worker?['profile'];
    final workerName = profile?['name'] ?? 'Worker';
    final workerEmail = worker?['email'] ?? '';
    final workerPicture = profile?['picture'];
    final appliedAt = widget.application.createdAt != null
        ? '${widget.application.createdAt!.day}/${widget.application.createdAt!.month}/${widget.application.createdAt!.year}'
        : 'Recently';

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showProfile(context, worker),
                        child: Hero(
                          tag: 'avatar_${widget.application.id}',
                          child: FarmyAvatar(
                            imageUrl: workerPicture,
                            radius: 30,
                            displayName: workerName,
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
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
                                    workerName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.lightTextPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  appliedAt,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white38
                                        : AppTheme.lightTextSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              workerEmail,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : AppTheme.lightTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _StatusBadge(status: widget.application.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (widget.application.notes != null &&
                    widget.application.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 12,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'APPLICANT MESSAGE',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.application.notes!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white70
                                  : AppTheme.lightTextPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (widget.application.status == JobApplicationStatus.pending)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.grey.shade50.withValues(alpha: 0.5),
                      border: Border(
                        top: BorderSide(
                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            'Decline',
                            Colors.red.shade400,
                            () => _handleStatusUpdate(
                              context,
                              JobApplicationStatus.rejected,
                            ),
                            isOutlined: true,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            'Hire Candidate',
                            AppTheme.primaryColor,
                            () => _handleStatusUpdate(
                              context,
                              JobApplicationStatus.approved,
                            ),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        if (_isUpdating)
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  void _showProfile(BuildContext context, Map<String, dynamic>? worker) {
    if (worker != null) {
      final workerUser = user_model.User.fromJson(worker);
      ProfilePreviewSheet.show(context, workerUser.id, initialUser: workerUser);
    }
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap, {
    bool isOutlined = false,
    required bool isDark,
  }) {
    return SizedBox(
      height: 50,
      child: isOutlined
          ? OutlinedButton(
              onPressed: _isUpdating ? null : onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(
                  color: color.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: _isUpdating ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ),
    );
  }

  Future<void> _handleStatusUpdate(
    BuildContext context,
    JobApplicationStatus status,
  ) async {
    setState(() => _isUpdating = true);

    try {
      final provider = context.read<JobApplicationProvider>();
      final success = await provider.updateApplicationStatus(
        widget.application.id,
        widget.jobId,
        status,
      );

      if (!mounted) return;

      if (success) {
        if (status == JobApplicationStatus.approved &&
            widget.application.job?.landId != null) {
          context.read<WorkerProvider>().loadLandWorkers(
            widget.application.job!.landId,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  status == JobApplicationStatus.approved
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text('Candidate ${status.name} successfully'),
              ],
            ),
            backgroundColor: status == JobApplicationStatus.approved
                ? AppTheme.primaryColor
                : Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final JobApplicationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case JobApplicationStatus.approved:
        color = AppTheme.primaryColor;
        label = 'Approved';
        icon = Icons.verified_rounded;
        break;
      case JobApplicationStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
      default:
        color = Colors.amber;
        label = 'Pending';
        icon = Icons.timer_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
