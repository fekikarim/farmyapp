import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/farmy_avatar.dart';
import '../../providers/worker_provider.dart';
import '../../providers/worker_lifecycle_provider.dart';
import '../../models/worker_profile_model.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class WorkerDetailScreen extends StatefulWidget {
  final WorkerProfile workerProfile;
  final String? landId;
  final String? landName;
  final bool inviteMode;

  const WorkerDetailScreen({
    super.key,
    required this.workerProfile,
    this.landId,
    this.landName,
    this.inviteMode = false,
  });

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadWorkerPerformance(widget.workerProfile.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workerProvider = context.watch<WorkerProvider>();
    final stats = workerProvider.performanceStats;
    final isLoading = workerProvider.performanceLoading;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Performance Analytics Section
                  _buildSectionTitle(AppLocalizations.of(context)!.performance, isDark),
                  const SizedBox(height: 16),
                  if (isLoading && stats.isEmpty)
                    _buildPerformanceShimmer(isDark)
                  else
                    _buildPerformanceGrid(context, stats, isDark),

                  const SizedBox(height: 32),

                  // Skills Section
                  _buildSectionTitle(AppLocalizations.of(context)!.skills, isDark),
                  const SizedBox(height: 12),
                  _buildSkillsList(context, widget.workerProfile.skills, isDark),

                  const SizedBox(height: 32),

                  // About Section
                  if (widget.workerProfile.bio != null && widget.workerProfile.bio!.isNotEmpty) ...[
                    _buildSectionTitle(AppLocalizations.of(context)!.about, isDark),
                    const SizedBox(height: 12),
                    _buildAboutCard(widget.workerProfile.bio!, isDark),
                    const SizedBox(height: 32),
                  ],

                  // Activity Summary
                  if (stats.isNotEmpty && (stats['landNames'] as List?)?.isNotEmpty == true) ...[
                    _buildSectionTitle(AppLocalizations.of(context)!.activeLands, isDark),
                    const SizedBox(height: 12),
                    _buildLandsSummary(stats['landNames'], isDark),
                    const SizedBox(height: 32),
                  ],

                  // Invite Action
                  if (widget.landId != null && widget.inviteMode)
                    _buildInviteButton(context),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.green.shade800,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Gradient & Pattern
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade900,
                    Colors.green.shade600,
                    Colors.teal.shade700,
                  ],
                ),
              ),
            ),
            // Profile Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Hero(
                      tag: 'worker_avatar_${widget.workerProfile.userId}',
                      child: FarmyAvatar(
                        imageUrl: widget.workerProfile.userProfilePicture,
                        radius: 50,
                        displayName: widget.workerProfile.userName,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.workerProfile.userName ?? AppLocalizations.of(context)!.worker,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (widget.workerProfile.isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: Colors.white, size: 22),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.amountPerHour(widget.workerProfile.hourlyRate.toStringAsFixed(0)),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
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

  Widget _buildPerformanceGrid(BuildContext context, Map<String, dynamic> stats, bool isDark) {
    final successRate = (stats['verificationSuccessRate'] ?? 0.0) as double;
    final completed = (stats['totalTasksCompleted'] ?? 0) as int;
    final score = (stats['performanceScore'] ?? 0) as int;

    return Column(
      children: [
        Row(
          children: [
            _buildMetricCard(
              context,
              AppLocalizations.of(context)!.successRate,
              '${successRate.toStringAsFixed(1)}%',
              Icons.bolt,
              Colors.amber,
              isDark,
            ),
            const SizedBox(width: 12),
            _buildMetricCard(
              context,
              AppLocalizations.of(context)!.tasksCompleted,
              '$completed',
              Icons.task_alt,
              Colors.blue,
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.overallPerformance,
                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  Text(
                    '$score/100',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Colors.green.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 8,
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsList(BuildContext context, List<String> skills, bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills.map((skill) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.green.withValues(alpha: 0.1) : Colors.green.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        ),
        child: Text(
          _translateSkill(context, skill),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700, fontSize: 13),
        ),
      )).toList(),
    );
  }

  Widget _buildAboutCard(String bio, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Text(
        bio,
        style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? Colors.white70 : Colors.black87),
      ),
    );
  }

  Widget _buildLandsSummary(List landNames, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.blue.withValues(alpha: 0.05) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.terrain, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              landNames.join(', '),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue.shade800),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _inviteToLand(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 8,
          shadowColor: Colors.green.withValues(alpha: 0.3),
        ),
        child: Text(
          AppLocalizations.of(context)!.invite,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
    );
  }

  Widget _buildPerformanceShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
        ],
      ),
    );
  }

  void _inviteToLand(BuildContext context) async {
    final message = await _showInviteDialog(context);
    if (message == null) return;

    final provider = context.read<WorkerLifecycleProvider>();
    final success = await provider.inviteWorker(
      landId: widget.landId!,
      workerId: widget.workerProfile.userId,
      message: message.isNotEmpty ? message : null,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invitationSentTo(widget.workerProfile.userName ?? "")),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.lastError ?? "Failed"), backgroundColor: Colors.redAccent),
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
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(AppLocalizations.of(context)!.inviteToLand),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.inviteWorkerMessage(widget.workerProfile.userName ?? "", widget.landName ?? ""),
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.optionalMessageHint,
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(AppLocalizations.of(context)!.sendInvite, style: const TextStyle(color: Colors.white)),
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
      case 'animal care': case 'animal_care': return l10n.animalCare;
      case 'machine operation': case 'machine_operation': return l10n.machineOperation;
      case 'soil management': case 'soil_management': return l10n.soilManagement;
      default: return skill;
    }
  }
}
