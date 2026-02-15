import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../providers/worker_provider.dart';
import '../../../../models/worker_profile_model.dart';
import '../../shared/worker_detail_screen.dart';

class InvestorWorkerMarketplace extends StatefulWidget {
  final String landId;
  final String landName;
  final List<String> excludedWorkerIds;

  const InvestorWorkerMarketplace({
    super.key,
    required this.landId,
    required this.landName,
    this.excludedWorkerIds = const [],
  });

  @override
  State<InvestorWorkerMarketplace> createState() =>
      _InvestorWorkerMarketplaceState();
}

class _InvestorWorkerMarketplaceState extends State<InvestorWorkerMarketplace> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedSkill;

  final List<String> _skills = [
    'All',
    'Watering',
    'Harvesting',
    'Planting',
    'Animal Care',
    'Machine Operation',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadMarketplace();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSkillSelected(String skill) {
    setState(() {
      _selectedSkill = skill == 'All' ? null : skill;
    });
    context.read<WorkerProvider>().loadMarketplace(skill: _selectedSkill);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<WorkerProvider>();

    // Filter out workers already assigned to this land
    final workers = provider.marketplace
        .where((w) => !widget.excludedWorkerIds.contains(w.id))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2125) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hire Workers',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find professionals for ${widget.landName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: (isDark ? Colors.white : Colors.black)
                        .withOpacity(0.05),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search & Filters
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _skills.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final skill = _skills[index];
                final isSelected =
                    (_selectedSkill == null && skill == 'All') ||
                    _selectedSkill == skill;
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (_) => _onSkillSelected(skill),
                  backgroundColor: (isDark ? Colors.white : Colors.black)
                      .withOpacity(0.05),
                  selectedColor: Colors.green.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.green
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.transparent,
                    ),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Divider
          Divider(
            height: 1,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),

          // List
          Expanded(
            child: provider.marketplaceLoading
                ? _buildShimmerList(isDark)
                : workers.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: workers.length,
                    itemBuilder: (context, index) => _MarketplaceWorkerCard(
                      worker: workers[index],
                      isDark: isDark,
                      onHire: () => _openWorkerDetails(workers[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _openWorkerDetails(WorkerProfile worker) {
    // Show Worker Detail screen which has the "Assign" flow
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkerDetailScreen(
          workerProfile: worker,
          landId: widget.landId,
          landName: widget.landName,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // If assigned, close marketplace to show refreshed list
        if (mounted) Navigator.pop(context);
      }
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No Workers Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
        child: Shimmer.fromColors(
          baseColor: isDark ? Colors.white10 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.white24 : Colors.grey.shade100,
          child: Row(
            children: [
              const CircleAvatar(radius: 28, backgroundColor: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 16, width: 150, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 100, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 80, color: Colors.white),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(height: 16, width: 60, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(
                    height: 36,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketplaceWorkerCard extends StatelessWidget {
  final WorkerProfile worker;
  final bool isDark;
  final VoidCallback onHire;

  const _MarketplaceWorkerCard({
    required this.worker,
    required this.isDark,
    required this.onHire,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onHire,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'marketplace_avatar_${worker.id}',
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.shade100,
                    backgroundImage: worker.userProfilePicture != null
                        ? NetworkImage(worker.userProfilePicture!)
                        : null,
                    child: worker.userProfilePicture == null
                        ? Icon(
                            Icons.person,
                            color: isDark ? Colors.white54 : Colors.grey,
                            size: 28,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              worker.userName ?? 'Worker',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (worker.isVerified) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.blue.shade400,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: worker.skills
                            .take(2)
                            .map(
                              (skill) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  skill,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            worker.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${worker.completedTasks} tasks',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${worker.hourlyRate.toStringAsFixed(0)} TND',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade400,
                      ),
                    ),
                    Text(
                      'per hour',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
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
}
