import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../models/worker_profile_model.dart';
import '../shared/worker_detail_screen.dart';

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
      context.read<WorkerProvider>().loadMarketplace();
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
    );
  }

  Widget _buildWorkerCard(WorkerProfile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerDetailScreen(
              workerProfile: profile,
              landId: widget.landId,
              landName: widget.landName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2333) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Hero(
              tag: 'worker-${profile.id}',
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.green.shade100,
                backgroundImage: profile.userProfilePicture != null
                    ? NetworkImage(profile.userProfilePicture!)
                    : null,
                child: profile.userProfilePicture == null
                    ? Icon(Icons.person, color: Colors.green.shade700, size: 28)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            // Info
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
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (profile.isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified,
                          color: Colors.blue.shade400,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (profile.skills.take(3)).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          skill,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade600, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        profile.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.task_alt,
                        color: Colors.grey.shade500,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.completedTasks} tasks',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rate
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${profile.hourlyRate.toStringAsFixed(0)} TND',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  '/hour',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Worker Marketplace'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search workers...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF1C2333) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (_) => _applyFilters(),
            ),
          ),

          // Skill Filters
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _skillFilters.length,
              itemBuilder: (ctx, i) {
                final skill = _skillFilters[i];
                final selected = (_selectedSkillFilter ?? 'All') == skill;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(skill),
                    selected: selected,
                    onSelected: (val) {
                      setState(
                        () => _selectedSkillFilter = val ? skill : 'All',
                      );
                      _applyFilters();
                    },
                    selectedColor: Colors.green.shade100,
                    backgroundColor: isDark
                        ? const Color(0xFF1C2333)
                        : Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? Colors.green.shade800
                          : Colors.grey.shade600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Worker List
          Expanded(
            child: workerProvider.marketplaceLoading
                ? const Center(child: CircularProgressIndicator())
                : workerProvider.marketplace.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No verified workers found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => workerProvider.loadMarketplace(),
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
}
