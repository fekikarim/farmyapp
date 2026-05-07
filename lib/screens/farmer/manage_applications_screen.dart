import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/job_application_provider.dart';
import '../../models/job_application_model.dart';
import '../../widgets/farmy_avatar.dart';
import '../../widgets/profile_preview_sheet.dart';
import '../../models/user_model.dart' as user_model;
import 'package:farmyapp/l10n/app_localizations.dart';

class ManageApplicationsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const ManageApplicationsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<ManageApplicationsScreen> createState() => _ManageApplicationsScreenState();
}

class _ManageApplicationsScreenState extends State<ManageApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<JobApplicationProvider>().fetchJobApplications(widget.jobId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<JobApplicationProvider>();
    final applications = provider.getApplicationsForJob(widget.jobId);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAdvancedHeader(context, isDark),
            Expanded(
              child: _buildApplicationsList(provider, applications),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, 
                  color: isDark ? Colors.white : Colors.black, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Applications',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      widget.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
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

  Widget _buildApplicationsList(JobApplicationProvider provider, List<JobApplication> applications) {
    if (provider.isLoading && applications.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    if (applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded,
                  size: 80, color: Colors.blue.withOpacity(0.2)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No applicants yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              'When workers apply, they will appear here.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: RefreshIndicator(
        color: Colors.green,
        onRefresh: () => provider.fetchJobApplications(widget.jobId),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
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

class _ApplicantCard extends StatelessWidget {
  final JobApplication application;
  final String jobId;

  const _ApplicantCard({required this.application, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final worker = application.worker;
    final profile = worker?['profile'];
    final workerName = profile?['name'] ?? 'Worker';
    final workerEmail = worker?['email'] ?? '';
    final workerPicture = profile?['picture'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (worker != null) {
            final workerUser = user_model.User.fromJson(worker);
            ProfilePreviewSheet.show(
              context,
              workerUser.id,
              initialUser: workerUser,
            );
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  FarmyAvatar(
                    imageUrl: workerPicture,
                    radius: 32,
                    displayName: workerName,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          workerEmail,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildMiniBadge(Icons.star_rounded, '4.9', Colors.amber),
                            const SizedBox(width: 12),
                            _buildMiniBadge(Icons.task_alt_rounded, '12 Jobs', Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (application.status != JobApplicationStatus.pending)
                    _StatusBadge(status: application.status),
                ],
              ),
              if (application.notes != null && application.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APPLICATION NOTE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        application.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (application.status == JobApplicationStatus.pending) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Reject',
                        Colors.red,
                        () => _handleStatusUpdate(context, JobApplicationStatus.rejected),
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Approve',
                        Colors.green,
                        () => _handleStatusUpdate(context, JobApplicationStatus.approved),
                      ),
                    ),
                  ],
                ),
              ],
            ],
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
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, Color color, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(
      height: 48,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
    );
  }

  Future<void> _handleStatusUpdate(BuildContext context, JobApplicationStatus status) async {
    final provider = context.read<JobApplicationProvider>();
    final success = await provider.updateApplicationStatus(application.id, jobId, status);
    
    if (!context.mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application ${status.name} successfully'),
          backgroundColor: status == JobApplicationStatus.approved ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update status'), 
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    switch (status) {
      case JobApplicationStatus.approved:
        color = Colors.green;
        label = 'Approved';
        break;
      case JobApplicationStatus.rejected:
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
