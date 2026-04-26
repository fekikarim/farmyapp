import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../models/worker_performance_model.dart';
import '../../providers/worker_performance_provider.dart';

class WorkerPerformanceDashboard extends StatefulWidget {
  const WorkerPerformanceDashboard({super.key});

  @override
  State<WorkerPerformanceDashboard> createState() => _WorkerPerformanceDashboardState();
}

class _WorkerPerformanceDashboardState extends State<WorkerPerformanceDashboard>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  Timer? _refreshTimer;
  bool _isVisible = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      final provider = context.read<WorkerPerformanceProvider>();
      provider.loadFarmerLands();
      provider.loadAll();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isVisible = true;
      _startAutoRefresh();
    } else {
      _isVisible = false;
      _stopAutoRefresh();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _stopAutoRefresh();
    if (_isVisible) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted && _isVisible) {
          context.read<WorkerPerformanceProvider>().refresh();
        }
      });
    }
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<WorkerPerformanceProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<WorkerPerformanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.workerPerformanceTitle),
        centerTitle: true,
        actions: [
          // Show sync indicator when loading
          if (provider.isLoading && provider.workers.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        displacement: 20,
        child: _buildBody(context, provider, l10n, theme),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    // Show skeleton loading for initial load
    if (provider.isLoading && provider.workers.isEmpty) {
      return _buildSkeletonLoading();
    }

    // Show error state only when we have no data
    if (provider.error != null && provider.workers.isEmpty) {
      return _buildErrorState(context, provider, l10n);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Bar
              _buildFilterBar(context, provider, l10n, isSmallScreen),
              SizedBox(height: isSmallScreen ? 12 : 16),

              // Summary KPI Cards
              _buildSummaryCards(provider, l10n, theme, isSmallScreen),
              SizedBox(height: isSmallScreen ? 20 : 24),

              // Insights Section (Top/Underperformers)
              _buildInsightsSection(provider, l10n, theme),

              // Worker List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.workerListTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${provider.workers.length} ${l10n.workersCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Worker List with animation
              if (provider.workers.isEmpty)
                _buildEmptyState(l10n)
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    key: ValueKey('workers_${provider.sortCriteria}_${provider.workers.length}'),
                    children: provider.workers
                        .map((worker) => _buildWorkerCard(worker, l10n, theme, isSmallScreen))
                        .toList(),
                  ),
                ),

              // Bottom padding for safe area
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoading() {
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter bar skeleton
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),

            // Summary cards skeleton
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: List.generate(4, (_) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              )),
            ),
            const SizedBox(height: 24),

            // Worker cards skeleton
            ...List.generate(3, (_) => Container(
              height: 180,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorLoadingPerformance,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.error!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadAll(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noWorkersFound,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add workers to your land to see their performance metrics',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Land Filter - Full width
            if (provider.farmerLands.isNotEmpty)
              _buildLandFilter(provider, l10n, isSmallScreen),

            SizedBox(height: isSmallScreen ? 10 : 12),

            // Date Range and Sort - Stacked on small screens, side by side on larger
            isSmallScreen
                ? Column(
                    children: [
                      _buildDateFilter(provider, l10n, isSmallScreen),
                      const SizedBox(height: 8),
                      _buildSortDropdown(provider, l10n, isSmallScreen),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildDateFilter(provider, l10n, isSmallScreen),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSortDropdown(provider, l10n, isSmallScreen),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandFilter(WorkerPerformanceProvider provider, AppLocalizations l10n, bool isSmallScreen) {
    final bool hasFilter = provider.selectedLandIds.isNotEmpty;
    final String? selectedLandName = hasFilter
        ? provider.farmerLands.firstWhere(
            (l) => l.id == provider.selectedLandIds.first,
            orElse: () => provider.farmerLands.first,
          ).name
        : null;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: hasFilter ? provider.selectedLandIds.first : null,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, size: 18),
            decoration: InputDecoration(
              hintText: l10n.filterByLand,
              prefixIcon: isSmallScreen ? null : const Icon(Icons.landscape, size: 18),
              border: const OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12, vertical: isSmallScreen ? 8 : 12),
              isDense: true,
              suffixIcon: hasFilter
                  ? Tooltip(
                      message: 'Filtered by: $selectedLandName',
                      child: Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  l10n.allLands,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
              ),
              ...provider.farmerLands.map((land) => DropdownMenuItem<String?>(
                value: land.id,
                child: Text(
                  land.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
              )),
            ],
            onChanged: (landId) {
              if (landId == null) {
                provider.setLandFilter([]);
              } else {
                provider.setLandFilter([landId]);
              }
            },
          ),
        ),
        if (hasFilter) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'Clear land filter',
            child: InkWell(
              onTap: () => provider.setLandFilter([]),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.clear, size: 18, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateFilter(WorkerPerformanceProvider provider, AppLocalizations l10n, bool isSmallScreen) {
    final Map<String, String> labels = {
      'all': isSmallScreen ? 'All Time' : l10n.allTime,
      'today': isSmallScreen ? 'Today' : l10n.today,
      'week': isSmallScreen ? 'This Week' : l10n.thisWeek,
      'month': isSmallScreen ? 'This Month' : l10n.thisMonth,
    };

    return DropdownButtonFormField<String>(
      value: _getCurrentPreset(provider),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, size: 18),
      decoration: InputDecoration(
        hintText: l10n.filterByDate,
        prefixIcon: isSmallScreen ? null : const Icon(Icons.calendar_today, size: 18),
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12, vertical: isSmallScreen ? 8 : 12),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text(
            labels['all']!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          ),
        ),
        DropdownMenuItem(
          value: 'today',
          child: Text(
            labels['today']!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          ),
        ),
        DropdownMenuItem(
          value: 'week',
          child: Text(
            labels['week']!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          ),
        ),
        DropdownMenuItem(
          value: 'month',
          child: Text(
            labels['month']!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
          ),
        ),
      ],
      onChanged: (preset) {
        if (preset != null) {
          provider.setPresetDateRange(preset);
        }
      },
    );
  }

  Widget _buildSortDropdown(WorkerPerformanceProvider provider, AppLocalizations l10n, bool isSmallScreen) {
    final Map<String, String> labels = {
      'scoreHighToLow': isSmallScreen ? 'Score ↓' : 'Score: High → Low',
      'scoreLowToHigh': isSmallScreen ? 'Score ↑' : 'Score: Low → High',
      'tasksHighToLow': isSmallScreen ? 'Tasks ↓' : 'Tasks: Most → Least',
      'nameAZ': isSmallScreen ? 'Name A-Z' : 'Name: A → Z',
    };

    return DropdownButtonFormField<WorkerSortCriteria>(
      value: provider.sortCriteria,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, size: 18),
      decoration: InputDecoration(
        hintText: l10n.sortBy,
        prefixIcon: isSmallScreen ? null : const Icon(Icons.sort, size: 18),
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12, vertical: isSmallScreen ? 8 : 12),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(
          value: WorkerSortCriteria.scoreHighToLow,
          child: Text(
            labels['scoreHighToLow']!,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: WorkerSortCriteria.scoreLowToHigh,
          child: Text(
            labels['scoreLowToHigh']!,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: WorkerSortCriteria.tasksHighToLow,
          child: Text(
            labels['tasksHighToLow']!,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: WorkerSortCriteria.nameAZ,
          child: Text(
            labels['nameAZ']!,
            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      onChanged: (criteria) {
        if (criteria != null) {
          provider.setSortCriteria(criteria);
        }
      },
    );
  }

  String _getCurrentPreset(WorkerPerformanceProvider provider) {
    if (provider.startDate == null && provider.endDate == null) return 'all';
    return 'all';
  }

  Widget _buildSummaryCards(
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    ThemeData theme,
    bool isSmallScreen,
  ) {
    final summary = provider.summary;

    // Responsive grid - 2 columns for all sizes but different aspect ratio
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: isSmallScreen ? 8 : 12,
      crossAxisSpacing: isSmallScreen ? 8 : 12,
      childAspectRatio: isSmallScreen ? 1.8 : 1.5,
      children: [
        _buildSummaryCard(
          title: l10n.totalWorkers,
          value: summary.totalWorkers.toString(),
          icon: Icons.people,
          color: theme.primaryColor,
          isSmallScreen: isSmallScreen,
        ),
        _buildSummaryCard(
          title: l10n.avgPerformanceScore,
          value: '${summary.averagePerformanceScore}',
          icon: Icons.score,
          color: _getScoreColor(summary.averagePerformanceScore),
          isSmallScreen: isSmallScreen,
        ),
        _buildSummaryCard(
          title: l10n.totalTasksCompleted,
          value: summary.totalTasksCompleted.toString(),
          icon: Icons.task_alt,
          color: Colors.green,
          isSmallScreen: isSmallScreen,
        ),
        _buildSummaryCard(
          title: l10n.overallVerificationRate,
          value: '${summary.overallVerificationRate.toStringAsFixed(0)}%',
          icon: Icons.verified,
          color: Colors.blue,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isSmallScreen ? 16 : 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    // Don't show insights if there's only 1 worker (it would appear in both lists)
    if (provider.workers.length <= 1) return const SizedBox.shrink();

    // Get unique top performers (not in underperformers)
    final topIds = provider.underperformers.map((w) => w.workerId).toSet();
    final uniqueTopPerformers = provider.topPerformers
        .where((w) => !topIds.contains(w.workerId))
        .toList();

    // Only show underperformers with scores < 50
    final realUnderperformers = provider.underperformers
        .where((w) => w.performanceScore < 50 || w.needsAttention)
        .toList();

    if (uniqueTopPerformers.isEmpty && realUnderperformers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (uniqueTopPerformers.isNotEmpty) ...[
          _buildSectionHeader(l10n.topPerformers, Colors.green),
          const SizedBox(height: 8),
          ...uniqueTopPerformers
              .map((w) => _buildInsightCard(w, l10n, theme, isTop: true)),
          const SizedBox(height: 16),
        ],
        if (realUnderperformers.isNotEmpty) ...[
          _buildSectionHeader(l10n.needsAttention, Colors.orange),
          const SizedBox(height: 8),
          ...realUnderperformers
              .map((w) => _buildInsightCard(w, l10n, theme, isTop: false)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    WorkerPerformance worker,
    AppLocalizations l10n,
    ThemeData theme, {
    required bool isTop,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: isTop ? Colors.green.shade50 : Colors.orange.shade50,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isTop ? Colors.green : Colors.orange,
          child: Icon(
            isTop ? Icons.emoji_events : Icons.warning,
            color: Colors.white,
            size: 18,
          ),
        ),
        title: Text(
          worker.workerName,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          worker.landNames.join(', '),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isTop ? Colors.green : Colors.orange).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTop ? Colors.green : Colors.orange,
              width: 1,
            ),
          ),
          child: Text(
            '${worker.performanceScore}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isTop ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerCard(WorkerPerformance worker, AppLocalizations l10n, ThemeData theme, bool isSmallScreen) {
    final scoreColor = _getScoreColor(worker.performanceScore);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Name, Score
              Row(
                children: [
                  Hero(
                    tag: 'worker_avatar_${worker.workerId}',
                    child: CircleAvatar(
                      radius: isSmallScreen ? 20 : 24,
                      backgroundColor: scoreColor.withOpacity(0.2),
                      backgroundImage: worker.workerProfilePicture != null
                          ? NetworkImage(worker.workerProfilePicture!)
                          : null,
                      child: worker.workerProfilePicture == null
                          ? Icon(Icons.person, color: scoreColor, size: isSmallScreen ? 20 : 24)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.workerName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          worker.landNames.join(', '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: scoreColor, width: 2),
                    ),
                    child: Text(
                      '${worker.performanceScore}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Stats Row - More compact
              LayoutBuilder(
                builder: (context, constraints) {
                  final useCompactLayout = constraints.maxWidth < 300;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(
                        label: useCompactLayout ? 'Tasks' : l10n.tasksCompleted,
                        value: worker.totalTasksCompleted.toString(),
                        icon: Icons.task_alt,
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildStatColumn(
                        label: useCompactLayout ? 'Verified' : l10n.verifiedProofs,
                        value: worker.verifiedProofs.toString(),
                        icon: Icons.verified,
                        valueColor: Colors.green,
                        isSmallScreen: isSmallScreen,
                      ),
                      _buildStatColumn(
                        label: useCompactLayout ? 'Rejected' : l10n.rejectedProofs,
                        value: worker.rejectedProofs.toString(),
                        icon: Icons.cancel,
                        valueColor: worker.rejectedProofs > 0 ? Colors.red : Colors.grey,
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),

              // Verification Rate Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: worker.verificationSuccessRate / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    worker.verificationSuccessRate >= 80
                        ? Colors.green
                        : worker.verificationSuccessRate >= 50
                            ? Colors.orange
                            : Colors.red,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.verificationRate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${worker.verificationSuccessRate.toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 11 : 12,
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

  Widget _buildStatColumn({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    required bool isSmallScreen,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isSmallScreen ? 14 : 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green.shade600;
    if (score >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}
