import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/crop_cycle_model.dart';
import '../../models/crop_plan_model.dart';
import '../../providers/crop_calendar_provider.dart';
import '../../theme/app_theme.dart';
import 'crop_cycle_indicator.dart';

/// Monthly calendar view showing crop cycles as colored bars on days
class CalendarMonthView extends StatelessWidget {
  final DateTime focusedDate;
  final Function(DateTime)? onDaySelected;

  const CalendarMonthView({
    super.key,
    required this.focusedDate,
    this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropCalendarProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate days for this month
    final daysInMonth = DateTime(
      focusedDate.year,
      focusedDate.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Day names
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        // Day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayNames.map((day) {
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const Divider(height: 1),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemCount: daysInMonth + firstWeekday,
            itemBuilder: (context, index) {
              // Empty cells before start of month
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }

              final day = index - firstWeekday + 1;
              final date = DateTime(focusedDate.year, focusedDate.month, day);

              return _DayCell(
                date: date,
                isToday: _isSameDay(date, DateTime.now()),
                isSelected: _isSameDay(date, provider.currentDate),
                items: provider.getItemsForDate(date),
                onTap: () {
                  provider.setCurrentDate(date);
                  onDaySelected?.call(date);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final List<dynamic> items;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get colors for items
    final itemColors = items.map((item) {
      if (item is CropCycle) {
        return item.getStatusColor(context);
      } else if (item is CropPlan) {
        return item.getStatusColor(context);
      }
      return Colors.grey;
    }).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.15)
              : isToday
              ? AppTheme.primaryColor.withOpacity(0.1)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : isToday
                ? AppTheme.primaryColor.withOpacity(0.5)
                : isDark
                ? Colors.white12
                : Colors.black12,
            width: isSelected || isToday ? 2 : 0.5,
          ),
        ),
        child: Column(
          children: [
            // Day number
            Container(
              padding: const EdgeInsets.only(top: 4, right: 4),
              alignment: Alignment.topRight,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday
                      ? AppTheme.primaryColor
                      : isDark
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),

            // Crop indicators (dots)
            if (items.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: itemColors.take(6).map((color) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.black12,
                            width: 0.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // More indicator
            if (items.length > 6)
              Text(
                '+${items.length - 6}',
                style: TextStyle(
                  fontSize: 8,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mini month header with navigation
class CalendarMonthHeader extends StatelessWidget {
  final DateTime focusedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const CalendarMonthHeader({
    super.key,
    required this.focusedDate,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthYear = _formatMonthYear(focusedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Month/Year display
          Expanded(
            child: Text(
              monthYear,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Today button
          TextButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.today, size: 18),
            label: const Text('Today'),
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
                      ? Colors.white12
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white12
                      : Colors.black.withOpacity(0.05),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }
}
