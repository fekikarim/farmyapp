import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../widgets/farmy_avatar.dart';
import '../../models/worker_performance_model.dart';
import '../../providers/worker_performance_provider.dart';

class WorkerPerformanceDashboard extends StatefulWidget {
  const WorkerPerformanceDashboard({super.key});

  @override
  State<WorkerPerformanceDashboard> createState() =>
      _WorkerPerformanceDashboardState();
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
            IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
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

              if (provider.error != null && provider.workers.isNotEmpty)
                _buildSyncErrorBanner(provider, theme, l10n),

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
                    key: ValueKey(
                      'workers_${provider.sortCriteria}_${provider.currentDatePreset}_${provider.selectedLandIds.join(",")}_${provider.workers.length}',
                    ),
                    children: provider.workers
                        .map(
                          (worker) => _buildWorkerCard(
                            worker,
                            l10n,
                            theme,
                            isSmallScreen,
                          ),
                        )
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final cardColor = isDark ? Colors.grey.shade900 : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              3,
              (_) => Container(
                height: 180,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.errorLoadingPerformance,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                provider.error!,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadAll(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncErrorBanner(
    WorkerPerformanceProvider provider,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.sync_problem_rounded,
            color: Colors.red.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sync issue: ${provider.error}',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: () => provider.clearError(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.red.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noWorkersFound,
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add workers to your land to see their performance metrics',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.farmerLands.isNotEmpty)
            _buildLandFilter(provider, l10n, isSmallScreen, isDark),
          SizedBox(height: isSmallScreen ? 12 : 16),
          isSmallScreen
              ? Column(
                  children: [
                    _buildDateFilter(provider, l10n, isSmallScreen, isDark),
                    const SizedBox(height: 12),
                    _buildSortDropdown(provider, l10n, isSmallScreen, isDark),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildDateFilter(
                        provider,
                        l10n,
                        isSmallScreen,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSortDropdown(
                        provider,
                        l10n,
                        isSmallScreen,
                        isDark,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  InputDecoration _buildDropdownDecoration(
    String hint,
    IconData? prefixIcon,
    bool isSmallScreen,
    bool isDark,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null && !isSmallScreen
          ? Icon(
              prefixIcon,
              size: 18,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            )
          : null,
      filled: true,
      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 10 : 14,
      ),
      isDense: true,
    );
  }

  Widget _buildLandFilter(
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    bool isSmallScreen,
    bool isDark,
  ) {
    final bool hasFilter = provider.selectedLandIds.isNotEmpty;
    final String? selectedLandName = hasFilter
        ? provider.farmerLands
              .firstWhere(
                (l) => l.id == provider.selectedLandIds.first,
                orElse: () => provider.farmerLands.first,
              )
              .name
        : null;

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: hasFilter ? provider.selectedLandIds.first : null,
            isExpanded: true,
            dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            decoration:
                _buildDropdownDecoration(
                  l10n.filterByLand,
                  Icons.landscape,
                  isSmallScreen,
                  isDark,
                ).copyWith(
                  suffixIcon: hasFilter
                      ? Tooltip(
                          message: 'Filtered by: $selectedLandName',
                          child: Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.all(14),
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
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...provider.farmerLands.map(
                (land) => DropdownMenuItem<String?>(
                  value: land.id,
                  child: Text(
                    land.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
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
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.clear,
                  size: 20,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateFilter(
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    bool isSmallScreen,
    bool isDark,
  ) {
    final Map<String, String> labels = {
      'all': isSmallScreen ? 'All Time' : l10n.allTime,
      'today': isSmallScreen ? 'Today' : l10n.today,
      'week': isSmallScreen ? 'This Week' : l10n.thisWeek,
      'month': isSmallScreen ? 'This Month' : l10n.thisMonth,
    };

    return DropdownButtonFormField<String>(
      value: provider.currentDatePreset,
      isExpanded: true,
      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
      decoration: _buildDropdownDecoration(
        l10n.filterByDate,
        Icons.calendar_today,
        isSmallScreen,
        isDark,
      ),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text(
            labels['all']!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 'today',
          child: Text(
            labels['today']!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 'week',
          child: Text(
            labels['week']!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 'month',
          child: Text(
            labels['month']!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildSortDropdown(
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    bool isSmallScreen,
    bool isDark,
  ) {
    final Map<String, String> labels = {
      'scoreHighToLow': isSmallScreen ? 'Score ↓' : 'Score: High → Low',
      'scoreLowToHigh': isSmallScreen ? 'Score ↑' : 'Score: Low → High',
      'tasksHighToLow': isSmallScreen ? 'Tasks ↓' : 'Tasks: Most → Least',
      'nameAZ': isSmallScreen ? 'Name A-Z' : 'Name: A → Z',
    };

    return DropdownButtonFormField<WorkerSortCriteria>(
      value: provider.sortCriteria,
      isExpanded: true,
      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
      borderRadius: BorderRadius.circular(16),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
      decoration: _buildDropdownDecoration(
        l10n.sortBy,
        Icons.sort,
        isSmallScreen,
        isDark,
      ),
      items: [
        DropdownMenuItem(
          value: WorkerSortCriteria.scoreHighToLow,
          child: Text(
            labels['scoreHighToLow']!,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: WorkerSortCriteria.scoreLowToHigh,
          child: Text(
            labels['scoreLowToHigh']!,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: WorkerSortCriteria.tasksHighToLow,
          child: Text(
            labels['tasksHighToLow']!,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem(
          value: WorkerSortCriteria.nameAZ,
          child: Text(
            labels['nameAZ']!,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildSummaryCards(
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    ThemeData theme,
    bool isSmallScreen,
  ) {
    final summary = provider.summary;
    final isDark = theme.brightness == Brightness.dark;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: isSmallScreen ? 12 : 16,
      crossAxisSpacing: isSmallScreen ? 12 : 16,
      childAspectRatio: isSmallScreen ? 1.6 : 1.4,
      children: [
        _buildSummaryCard(
          title: l10n.totalWorkers,
          value: summary.totalWorkers.toString(),
          icon: Icons.people_alt_rounded,
          color: theme.colorScheme.primary,
          isSmallScreen: isSmallScreen,
          isDark: isDark,
        ),
        _buildSummaryCard(
          title: l10n.avgPerformanceScore,
          value: '${summary.averagePerformanceScore}',
          icon: Icons.auto_graph_rounded,
          color: _getScoreColor(summary.averagePerformanceScore),
          isSmallScreen: isSmallScreen,
          isDark: isDark,
        ),
        _buildSummaryCard(
          title: l10n.totalTasksCompleted,
          value: summary.totalTasksCompleted.toString(),
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green.shade500,
          isSmallScreen: isSmallScreen,
          isDark: isDark,
        ),
        _buildSummaryCard(
          title: l10n.overallVerificationRate,
          value: '${summary.overallVerificationRate.toStringAsFixed(0)}%',
          icon: Icons.verified_rounded,
          color: Colors.blue.shade500,
          isSmallScreen: isSmallScreen,
          isDark: isDark,
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
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.05)
            : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isSmallScreen ? 14 : 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(
    WorkerPerformanceProvider provider,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (provider.workers.length <= 1) return const SizedBox.shrink();

    final topIds = provider.underperformers.map((w) => w.workerId).toSet();
    final uniqueTopPerformers = provider.topPerformers
        .where((w) => !topIds.contains(w.workerId))
        .toList();

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
          const SizedBox(height: 12),
          ...uniqueTopPerformers.map(
            (w) => _buildInsightCard(w, l10n, theme, isTop: true),
          ),
          const SizedBox(height: 24),
        ],
        if (realUnderperformers.isNotEmpty) ...[
          _buildSectionHeader(l10n.needsAttention, Colors.orange),
          const SizedBox(height: 12),
          ...realUnderperformers.map(
            (w) => _buildInsightCard(w, l10n, theme, isTop: false),
          ),
          const SizedBox(height: 24),
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
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
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
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isTop ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? baseColor.withValues(alpha: 0.05)
            : baseColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isTop ? Icons.emoji_events_rounded : Icons.warning_rounded,
            color: baseColor,
            size: 20,
          ),
        ),
        title: Text(
          worker.workerName,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          worker.landNames.join(', '),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${worker.performanceScore}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerCard(
    WorkerPerformance worker,
    AppLocalizations l10n,
    ThemeData theme,
    bool isSmallScreen,
  ) {
    final scoreColor = _getScoreColor(worker.performanceScore);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Hero(
                  tag: 'worker_avatar_${worker.workerId}',
                  child: FarmyAvatar(
                    imageUrl: worker.workerProfilePicture,
                    radius: isSmallScreen ? 24 : 28,
                    displayName: worker.workerName,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.workerName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        worker.landNames.join(', '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: isSmallScreen ? 12 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.transparent : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: scoreColor, width: 1.5),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: scoreColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    '${worker.performanceScore}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              height: 1,
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final useCompactLayout = constraints.maxWidth < 300;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn(
                      label: useCompactLayout ? 'Tasks' : l10n.tasksCompleted,
                      value: worker.totalTasksCompleted.toString(),
                      icon: Icons.check_circle_outline_rounded,
                      isSmallScreen: isSmallScreen,
                      isDark: isDark,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                    _buildStatColumn(
                      label: useCompactLayout
                          ? 'Verified'
                          : l10n.verifiedProofs,
                      value: worker.verifiedProofs.toString(),
                      icon: Icons.verified_rounded,
                      valueColor: Colors.green.shade500,
                      isSmallScreen: isSmallScreen,
                      isDark: isDark,
                    ),
                    Container(
                      height: 30,
                      width: 1,
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                    _buildStatColumn(
                      label: useCompactLayout
                          ? 'Rejected'
                          : l10n.rejectedProofs,
                      value: worker.rejectedProofs.toString(),
                      icon: Icons.cancel_rounded,
                      valueColor: worker.rejectedProofs > 0
                          ? Colors.red.shade500
                          : Colors.grey.shade500,
                      isSmallScreen: isSmallScreen,
                      isDark: isDark,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.verificationRate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${worker.verificationSuccessRate.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 13 : 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: worker.verificationSuccessRate / 100,
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  worker.verificationSuccessRate >= 80
                      ? Colors.green.shade500
                      : worker.verificationSuccessRate >= 50
                      ? Colors.orange.shade500
                      : Colors.red.shade500,
                ),
                minHeight: 6,
              ),
            ),
          ],
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
    required bool isDark,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 16 : 18,
                color:
                    valueColor ??
                    (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 12,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green.shade500;
    if (score >= 50) return Colors.orange.shade500;
    return Colors.red.shade500;
  }
}
