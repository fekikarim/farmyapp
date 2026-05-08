import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/farmy_avatar.dart';
import '../../providers/worker_provider.dart';
import '../../models/worker_profile_model.dart';
import '../shared/worker_detail_screen.dart';
import '../../widgets/profile_preview_sheet.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class WorkerMarketplaceScreen extends StatefulWidget {
  final String landId;
  final String landName;

  const WorkerMarketplaceScreen({
    super.key,
    required this.landId,
    required this.landName,
  });

  @override
  State<WorkerMarketplaceScreen> createState() =>
      _WorkerMarketplaceScreenState();
}

class _WorkerMarketplaceScreenState extends State<WorkerMarketplaceScreen> {
  final _searchController = TextEditingController();
  String? _selectedSkillFilter;
  double? _minRating;

  static const List<String> _skillFilters = [
    'All',
    'Watering',
    'Harvesting',
    'Planting',
    'Animal Care',
    'Machine Operation',
    'Soil Management',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadMarketplace(
        excludeLandId: widget.landId,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<WorkerProvider>().loadMarketplace(
      skill: _selectedSkillFilter == 'All' ? null : _selectedSkillFilter,
      minRating: _minRating,
      excludeLandId: widget.landId,
    );
  }

  Widget _buildWorkerCard(WorkerProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        final invited = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerDetailScreen(
              workerProfile: profile,
              landId: widget.landId,
              landName: widget.landName,
              inviteMode: true,
            ),
          ),
        );
        if (invited == true && mounted) {
          Navigator.of(context).pop(true);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
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
            // Avatar with Gradient Border
            Hero(
              tag: 'worker_avatar_${profile.userId}',
              child: FarmyAvatar(
                imageUrl: profile.userProfilePicture,
                radius: 26,
                displayName: profile.userName,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: () =>
                              ProfilePreviewSheet.show(context, profile.userId),
                          child: Text(
                            profile.userName ??
                                AppLocalizations.of(context)!.worker,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (profile.isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified,
                          color: Colors.blue.shade500,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (profile.skills.take(3)).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.15,
                                )
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Text(
                          _translateSkill(context, skill),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade500,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.grey.shade500,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.tasksCount(profile.completedTasks),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
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
            // Rate Pill
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.amountTND(profile.hourlyRate.toStringAsFixed(0)),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.perHour,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.workerMarketplace,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchWorkers,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (_) => _applyFilters(),
              ),
            ),
          ),

          // Skill Filters
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _skillFilters.length,
              itemBuilder: (ctx, i) {
                final skill = _skillFilters[i];
                final selected = (_selectedSkillFilter ?? 'All') == skill;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () {
                      setState(
                        () => _selectedSkillFilter = skill == 'All'
                            ? null
                            : skill,
                      );
                      _applyFilters();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primary
                            : (isDark ? Colors.grey.shade800 : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? theme.colorScheme.primary
                              : (isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade200),
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          skill == 'All'
                              ? AppLocalizations.of(context)!.all
                              : _translateSkill(context, skill),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : (isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Worker List
          Expanded(
            child: workerProvider.marketplaceLoading
                ? _buildShimmerLoading(isDark, theme)
                : workerProvider.marketplace.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_search_rounded,
                            size: 64,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noVerifiedWorkersFound,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => workerProvider.loadMarketplace(
                      skill: _selectedSkillFilter == 'All'
                          ? null
                          : _selectedSkillFilter,
                      minRating: _minRating,
                      excludeLandId: widget.landId,
                    ),
                    color: theme.colorScheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: workerProvider.marketplace.length,
                      itemBuilder: (ctx, i) =>
                          _buildWorkerCard(workerProvider.marketplace[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDark, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }

  String _translateSkill(BuildContext context, String skill) {
    final l10n = AppLocalizations.of(context)!;
    switch (skill.toLowerCase()) {
      case 'watering':
        return l10n.watering;
      case 'harvesting':
        return l10n.harvesting;
      case 'planting':
        return l10n.planting;
      case 'animal care':
      case 'animal_care':
        return l10n.animalCare;
      case 'machine operation':
      case 'machine_operation':
        return l10n.machineOperation;
      case 'soil management':
      case 'soil_management':
        return l10n.soilManagement;
      default:
        return skill;
    }
  }
}
