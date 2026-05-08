import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/crop_cycle_model.dart';
import '../../models/crop_plan_model.dart';
import '../../providers/crop_calendar_provider.dart';
import '../../theme/app_theme.dart';

/// Yearly timeline view showing all crop cycles across the year
class CalendarYearView extends StatelessWidget {
  final int year;
  final Function(DateTime)? onMonthSelected;

  const CalendarYearView({super.key, required this.year, this.onMonthSelected});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropCalendarProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group items by month
    final monthlyItems = _groupItemsByMonth(provider.allItems, year);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final items = monthlyItems[month] ?? [];

        return _MonthTimelineCard(
          month: month,
          year: year,
          items: items,
          isDark: isDark,
          onTap: () {
            onMonthSelected?.call(DateTime(year, month, 1));
          },
        );
      },
    );
  }

  Map<int, List<dynamic>> _groupItemsByMonth(List<dynamic> items, int year) {
    final Map<int, List<dynamic>> result = {};

    for (final item in items) {
      // Get relevant months for this item
      final months = _getActiveMonths(item, year);

      for (final month in months) {
        result.putIfAbsent(month, () => []);
        result[month]!.add(item);
      }
    }

    return result;
  }

  List<int> _getActiveMonths(dynamic item, int year) {
    final List<int> months = [];
    DateTime? startDate;
    DateTime? endDate;

    if (item is CropCycle) {
      startDate = item.placedAt;
      if (item.upcomingHarvests?.isNotEmpty == true) {
        endDate = item.upcomingHarvests!.last;
      }
    } else if (item is CropPlan) {
      startDate = item.plannedPlantingDate;
      endDate = item.expectedHarvestDate;
    }

    if (startDate == null) return months;

    // Add months from start to end
    var current = DateTime(startDate.year, startDate.month, 1);
    final end = endDate != null
        ? DateTime(endDate.year, endDate.month, 1)
        : DateTime(year, 12, 1);

    while (current.isBefore(end) ||
        (current.year == end.year && current.month == end.month)) {
      if (current.year == year) {
        months.add(current.month);
      }
      current = DateTime(current.year, current.month + 1, 1);
    }

    return months.toSet().toList(); // Remove duplicates
  }
}

class _MonthTimelineCard extends StatelessWidget {
  final int month;
  final int year;
  final List<dynamic> items;
  final bool isDark;
  final VoidCallback onTap;

  const _MonthTimelineCard({
    required this.month,
    required this.year,
    required this.items,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthName(month);
    final isCurrentMonth =
        DateTime.now().year == year && DateTime.now().month == month;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentMonth
              ? AppTheme.primaryColor
              : isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.12),
          width: isCurrentMonth ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentMonth
                          ? AppTheme.primaryColor
                          : isDark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      monthName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentMonth ? Colors.white : null,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (items.isNotEmpty)
                    Text(
                      AppLocalizations.of(context)!.cropCount(items.length),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.black.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),

              if (items.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                // Crop list for this month
                ...items.take(3).map((item) => _buildItemRow(item, context)),

                if (items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '+ ${items.length - 3} more',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.black.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ] else ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 16,
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.noCropsThisMonth,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.4)
                            : Colors.black.withOpacity(0.4),
                        fontSize: 14,
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

  Widget _buildItemRow(dynamic item, BuildContext context) {
    String name;
    String subtitle;
    Color color;
    IconData icon;

    if (item is CropCycle) {
      name = item.variantName;
      final daysUntil = item.daysUntilHarvest;
      subtitle = daysUntil != null
          ? daysUntil <= 0
                ? AppLocalizations.of(context)!.readyToHarvestStatus
                : AppLocalizations.of(context)!.daysUntilHarvest(daysUntil)
          : AppLocalizations.of(context)!.growingStatusShort;
      color = item.getStatusColor(context);
      icon = Icons.local_florist;
    } else if (item is CropPlan) {
      name = item.variantName;
      if (item.status == CropPlanStatus.planned) {
        final days = item.daysUntilPlanting;
        subtitle = days < 0
            ? AppLocalizations.of(context)!.overdueByDays(-days)
            : days == 0
            ? AppLocalizations.of(context)!.plantToday
            : AppLocalizations.of(context)!.plantInDays(days);
      } else {
        subtitle = item.status.getLabel();
      }
      color = item.getStatusColor(context);
      icon = Icons.event_note;
    } else {
      name = 'Unknown';
      subtitle = '';
      color = Colors.grey;
      icon = Icons.help;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

/// Year navigation header
class CalendarYearHeader extends StatelessWidget {
  final int year;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const CalendarYearHeader({
    super.key,
    required this.year,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Year display
          Expanded(
            child: Text(
              '$year',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black.withOpacity(0.87),
              ),
            ),
          ),

          // Today button
          TextButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.today, size: 18),
            label: Text(AppLocalizations.of(context)!.today),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          ),

          const SizedBox(width: 8),

          // Navigation arrows
          Row(
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.12)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
