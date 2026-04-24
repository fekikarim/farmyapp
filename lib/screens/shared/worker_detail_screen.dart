import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../models/worker_profile_model.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class WorkerDetailScreen extends StatelessWidget {
  final WorkerProfile workerProfile;
  final String? landId;
  final String? landName;
  final bool inviteMode; // true = farmer invite, false = legacy assign

  const WorkerDetailScreen({
    super.key,
    required this.workerProfile,
    this.landId,
    this.landName,
    this.inviteMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.green.shade700,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade800,
                      Colors.green.shade500,
                      Colors.teal.shade400,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Hero(
                        tag: 'worker-${workerProfile.id}',
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage:
                              workerProfile.userProfilePicture != null
                              ? NetworkImage(workerProfile.userProfilePicture!)
                              : null,
                          child: workerProfile.userProfilePicture == null
                              ? const Icon(
                                  Icons.person,
                                  size: 44,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            workerProfile.userName ?? AppLocalizations.of(context)!.worker,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (workerProfile.isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.amountPerHour(workerProfile.hourlyRate.toStringAsFixed(0)),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _statCard(
                        AppLocalizations.of(context)!.ratingLabel,
                        '⭐ ${workerProfile.rating.toStringAsFixed(1)}',
                        Colors.amber,
                        isDark,
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        AppLocalizations.of(context)!.tasksLabelShort,
                        '${workerProfile.completedTasks}',
                        Colors.blue,
                        isDark,
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        AppLocalizations.of(context)!.onTimeLabel,
                        '${workerProfile.onTimeRate.toStringAsFixed(0)}%',
                        Colors.green,
                        isDark,
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        AppLocalizations.of(context)!.disputesLabel,
                        '${workerProfile.disputeCount}',
                        Colors.red,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Skills
                  _sectionTitle(AppLocalizations.of(context)!.skills, isDark),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: workerProfile.skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade50,
                              Colors.green.shade100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          _translateSkill(context, skill),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Bio
                  if (workerProfile.bio != null &&
                      workerProfile.bio!.isNotEmpty) ...[
                    _sectionTitle(AppLocalizations.of(context)!.about, isDark),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        workerProfile.bio!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Performance Graph Placeholder
                  _sectionTitle(AppLocalizations.of(context)!.performance, isDark),
                  const SizedBox(height: 10),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.performanceGraphComingSoon,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Coming Soon Placeholders
                  _comingSoonCard(
                    context,
                    '💬 ${AppLocalizations.of(context)!.messageWorker}',
                    AppLocalizations.of(context)!.directMessagingDescription,
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _comingSoonCard(
                    context,
                    '📝 ${AppLocalizations.of(context)!.viewReviews}',
                    AppLocalizations.of(context)!.readReviewsDescription,
                    isDark,
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  if (landId != null && inviteMode) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _inviteToLand(context),
                        icon: const Icon(
                          Icons.mail_outline,
                          color: Colors.white,
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.inviteToLand,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                  if (landId != null && !inviteMode) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => _assignToLand(context),
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: Text(
                          AppLocalizations.of(context)!.assignToLand,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _inviteToLand(BuildContext context) async {
    final message = await _showInviteDialog(context);
    if (message == null) return;

    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.inviteWorker(
      landId: landId!,
      workerId: workerProfile.userId,
      message: message.isNotEmpty ? message : null,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.invitationSentTo(workerProfile.userName ?? AppLocalizations.of(context)!.worker),
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        final errorMsg = provider.lastError ?? AppLocalizations.of(context)!.failedToSendInvitation;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<String?> _showInviteDialog(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.inviteWorker,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.inviteWorkerMessage(workerProfile.userName ?? AppLocalizations.of(context)!.thisWorker, landName ?? ""),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.optionalMessageHint,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.green.shade500,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.sendInvite,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _assignToLand(BuildContext context) async {
    final provider = context.read<WorkerProvider>();
    final salary = await _showSalaryDialog(context);
    if (salary == null) return;

    final success = await provider.assignWorker(
      landId: landId!,
      workerId: workerProfile.userId,
      salary: salary,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.workerAssignedToLand(workerProfile.userName ?? AppLocalizations.of(context)!.worker, landName ?? ""),
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.of(context)
          ..pop()
          ..pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToAssignWorker),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<double?> _showSalaryDialog(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.setMonthlySalary,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'e.g. 500',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
            suffixText: AppLocalizations.of(context)!.tndMo,
            suffixStyle: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade500, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              Navigator.pop(ctx, val);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.assign, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
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
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _comingSoonCard(BuildContext context, String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppLocalizations.of(context)!.soon,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _translateSkill(BuildContext context, String skill) {
    final l10n = AppLocalizations.of(context)!;
    switch (skill.toLowerCase()) {
      case 'watering': return l10n.watering;
      case 'harvesting': return l10n.harvesting;
      case 'planting': return l10n.planting;
      case 'animal care':
      case 'animal_care': return l10n.animalCare;
      case 'machine operation':
      case 'machine_operation': return l10n.machineOperation;
      case 'soil management':
      case 'soil_management': return l10n.soilManagement;
      default: return skill;
    }
  }
}
