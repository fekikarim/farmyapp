import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/crop_cycle_model.dart';
import '../../models/crop_plan_model.dart';
import '../../providers/crop_calendar_provider.dart';
import '../../providers/land_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/calendar/calendar_month_view.dart';
import '../../widgets/calendar/calendar_year_view.dart';
import '../../widgets/calendar/crop_cycle_card.dart';
import '../../widgets/calendar/crop_plan_sheet.dart';
import '../../widgets/calendar/land_selector.dart';
import '../../widgets/calendar/crop_legend.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

/// Main crop calendar screen for farmers
class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final cropProvider = context.read<CropCalendarProvider>();
    final landProvider = context.read<LandProvider>();
    
    // Ensure lands are loaded
    if (landProvider.myLands.isEmpty) {
      await landProvider.fetchMyLands();
    }
    
    // Set lands in crop provider
    cropProvider.setLands(landProvider.myLands);
    
    // Load crop data for all lands or selected land
    if (landProvider.myLands.isNotEmpty) {
      await cropProvider.loadCropData(cropProvider.selectedLandId ?? landProvider.myLands.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CropCalendarProvider>();
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              pinned: true,
              expandedHeight: 180,
              title: Text(l10n.cropCalendarTitle),
              actions: [
                // Today button
                IconButton(
                  icon: const Icon(Icons.today),
                  tooltip: 'Go to today',
                  onPressed: () {
                    provider.goToToday();
                  },
                ),
                // Refresh button
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () => provider.refreshData(),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.15),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 56, 0, 60),
                      child: _buildStatsRow(provider),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                onTap: (index) {
                  provider.setViewMode(
                    index == 0 ? CalendarViewMode.month : CalendarViewMode.year,
                  );
                },
                tabs: [
                  Tab(
                    icon: const Icon(Icons.calendar_view_month),
                    text: l10n.monthView,
                  ),
                  Tab(
                    icon: const Icon(Icons.calendar_view_day),
                    text: l10n.yearView,
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Month View
            _MonthViewTab(
              onDaySelected: (date) => _showDayDetails(context, date),
            ),
            // Year View
            _YearViewTab(
              onMonthSelected: (date) {
                _tabController.animateTo(0);
                provider.setCurrentDate(date);
                provider.setViewMode(CalendarViewMode.month);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CropPlanSheet.show(
          context,
          initialLandId: provider.selectedLandId,
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.addCropPlan),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildStatsRow(CropCalendarProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    
    // Show loading indicators while fetching data
    final stats = provider.isLoading && provider.allItems.isEmpty
        ? [
            _StatItem(icon: Icons.local_florist, value: '...', label: l10n.loading, color: Colors.grey),
            _StatItem(icon: Icons.event_available, value: '...', label: l10n.loading, color: Colors.grey),
            _StatItem(icon: Icons.event_note, value: '...', label: l10n.loading, color: Colors.grey),
          ]
        : [
            _StatItem(
              icon: Icons.local_florist,
              value: '${provider.activeCrops.length}',
              label: l10n.activeCrops ?? 'Active',
              color: Colors.green,
            ),
            _StatItem(
              icon: Icons.event_available,
              value: '${provider.upcomingHarvests.length}',
              label: l10n.readySoon ?? 'Ready Soon',
              color: Colors.amber,
            ),
            _StatItem(
              icon: Icons.event_note,
              value: '${provider.plannedCrops.length}',
              label: l10n.plannedCrops ?? 'Planned',
              color: Colors.blue,
            ),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: stats.map((stat) => _buildStatChip(stat, isCompact: isCompact)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(_StatItem stat, {bool isCompact = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12, 
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: stat.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stat.color.withOpacity(0.35), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stat.icon, size: isCompact ? 16 : 18, color: stat.color),
          const SizedBox(width: 4),
          Text(
            stat.value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 14 : 16,
              color: stat.color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            stat.label,
            style: TextStyle(
              fontSize: isCompact ? 11 : 13,
              fontWeight: FontWeight.w500,
              color: stat.color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime date) {
    final provider = context.read<CropCalendarProvider>();
    final items = provider.getItemsForDate(date);
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Date header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          items.isEmpty
                              ? 'No crops'
                              : '${items.length} crop${items.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.6)
                                : Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Items list
            Expanded(
              child: items.isEmpty
                  ? _EmptyDayState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return CropCycleCard(
                          item: item,
                          onTap: () {
                            // Show item details
                          },
                          onAction: () {
                            if (item is CropCycle && item.isReadyForHarvest) {
                              // Mark as harvested
                            } else if (item is CropPlan && 
                                       item.status == CropPlanStatus.planned) {
                              // Activate plan
                              provider.activatePlan(item.id!);
                            }
                          },
                        );
                      },
                    ),
            ),
            
            // Add plan button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  CropPlanSheet.show(
                    context,
                    initialLandId: provider.selectedLandId,
                    initialDate: date,
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.addCropPlan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthViewTab extends StatelessWidget {
  final Function(DateTime)? onDaySelected;

  const _MonthViewTab({this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropCalendarProvider>();
    
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          // Land selector - responsive width
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LandSelector(
              onChanged: () {
                // Data is automatically reloaded by provider.selectLand()
              },
            ),
          ),
          
          // Month header
          CalendarMonthHeader(
            focusedDate: provider.currentDate,
            onPrevious: () => provider.goToPrevious(),
            onNext: () => provider.goToNext(),
            onToday: () => provider.goToToday(),
          ),
          
          // Legend
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CropLegend(compact: true),
          ),
          
          // Calendar with proper scrolling for refresh
          Expanded(
            child: provider.isLoading && provider.allItems.isEmpty
                ? _CalendarSkeleton()
                : provider.error != null
                    ? _ErrorState(
                        message: provider.error!,
                        onRetry: () => provider.refreshData(),
                      )
                    : CalendarMonthView(
                        focusedDate: provider.currentDate,
                        onDaySelected: onDaySelected,
                      ),
          ),
        ],
      ),
    );
  }
}

class _YearViewTab extends StatelessWidget {
  final Function(DateTime)? onMonthSelected;

  const _YearViewTab({this.onMonthSelected});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropCalendarProvider>();
    
    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          // Land selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LandSelector(
              onChanged: () {
                // Data is automatically reloaded by provider.selectLand()
              },
            ),
          ),
          
          // Year header
          CalendarYearHeader(
            year: provider.currentDate.year,
            onPrevious: () => provider.goToPrevious(),
            onNext: () => provider.goToNext(),
            onToday: () => provider.goToToday(),
          ),
          
          // Legend
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CropLegend(compact: true),
          ),
          
          // Year timeline with proper scrolling for refresh
          Expanded(
            child: provider.isLoading && provider.allItems.isEmpty
                ? _YearSkeleton()
                : provider.error != null
                    ? _ErrorState(
                        message: provider.error!,
                        onRetry: () => provider.refreshData(),
                      )
                    : CalendarYearView(
                        year: provider.currentDate.year,
                        onMonthSelected: onMonthSelected,
                      ),
          ),
        ],
      ),
    );
  }
}

class _CalendarSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

class _YearSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_outlined,
            size: 64,
            color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No crops for this day',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Crop Plan" to schedule one',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}
