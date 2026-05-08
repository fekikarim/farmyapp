import 'package:flutter/material.dart';
import '../../../models/job_request_model.dart';
import '../../../widgets/farmy_avatar.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../providers/job_application_provider.dart';

class JobDetailsModal extends StatelessWidget {
  final JobRequest job;

  const JobDetailsModal({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: FarmyAvatar(
                          imageUrl: job.land?.ownerProfilePicture,
                          radius: 36,
                          displayName: job.land?.name ?? 'Farm',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  job.land?.name ?? 'Unknown Land',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Job Stats Grid
                  _buildStatsGrid(context, isDark),

                  const SizedBox(height: 32),

                  // Job Description Section
                  _buildSectionTitle(
                    context,
                    AppLocalizations.of(context)!.description,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Land Description Section
                  if (job.land?.description != null) ...[
                    _buildSectionTitle(context, 'About the Land'),
                    const SizedBox(height: 12),
                    Text(
                      job.land!.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Required Skills
                  if (job.requiredSkills != null &&
                      job.requiredSkills!.isNotEmpty) ...[
                    _buildSectionTitle(
                      context,
                      AppLocalizations.of(context)!.requiredSkills,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: job.requiredSkills!
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.15),
                                ),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Farmer Profile Preview Card
                  _buildFarmerPreview(context, isDark),

                  const SizedBox(height: 40),

                  // Action Button
                  Consumer<JobApplicationProvider>(
                    builder: (context, applicationProvider, child) {
                      final hasApplied = applicationProvider.myApplications.any(
                        (a) => a.jobId == job.id,
                      );

                      return SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (hasApplied ? Colors.grey : Colors.green)
                                    .withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed:
                                (applicationProvider.isLoading || hasApplied)
                                ? null
                                : () async {
                                    final success = await applicationProvider
                                        .applyToJob(job.id);
                                    if (context.mounted) {
                                      if (success) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Application submitted successfully!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              applicationProvider.error ??
                                                  'Failed to apply',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasApplied
                                  ? Colors.grey.shade300
                                  : Colors.green,
                              disabledBackgroundColor: hasApplied
                                  ? Colors.grey.shade800
                                  : Colors.green.withOpacity(0.6),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: applicationProvider.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    hasApplied
                                        ? 'Applied'
                                        : 'Apply for this Job',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                Icons.payments_outlined,
                AppLocalizations.of(context)!.salaryTND,
                job.salary != null
                    ? '${job.salary!.toStringAsFixed(0)}'
                    : 'N/A',
              ),
            ),
            VerticalDivider(
              color: Colors.grey.withOpacity(0.2),
              indent: 8,
              endIndent: 8,
            ),
            Expanded(
              child: _buildStatItem(
                context,
                Icons.timer_outlined,
                AppLocalizations.of(context)!.duration,
                job.duration ?? 'Long-term',
              ),
            ),
            VerticalDivider(
              color: Colors.grey.withOpacity(0.2),
              indent: 8,
              endIndent: 8,
            ),
            Expanded(
              child: _buildStatItem(
                context,
                Icons.category_outlined,
                AppLocalizations.of(context)!.taskType,
                job.taskType ?? 'General',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFarmerPreview(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FARMER PROFILE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.green.shade600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Builder(
                builder: (context) {
                  final imgUrl = job.land?.ownerProfilePicture;
                  debugPrint('JobDetailsModal: Farmer Avatar URL: $imgUrl');
                  return FarmyAvatar(
                    imageUrl: imgUrl,
                    radius: 28,
                    displayName: job.land?.ownerName ?? 'Farmer',
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.land?.ownerName ?? 'Private Farmer',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      job.land?.ownerEmail ?? 'Contact info protected',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 20,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFarmerBadge(Icons.star, '4.9', Colors.amber),
              const SizedBox(width: 12),
              _buildFarmerBadge(
                Icons.assignment_turned_in,
                '12 Jobs',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
