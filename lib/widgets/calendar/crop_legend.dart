import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../models/crop_cycle_model.dart';
import '../../models/crop_plan_model.dart';
import '../../theme/app_theme.dart';

/// Legend showing color codes for different crop statuses
class CropLegend extends StatelessWidget {
  final bool compact;

  const CropLegend({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    final items = [
      _LegendItem(
        color: CropCycleStatus.growing.color,
        label: l10n.growingStatus,
        icon: Icons.local_florist,
      ),
      _LegendItem(
        color: CropCycleStatus.ready.color,
        label: l10n.readyStatus,
        icon: Icons.eco,
      ),
      _LegendItem(
        color: CropCycleStatus.completed.color,
        label: l10n.completedStatus,
        icon: Icons.check_circle,
      ),
      _LegendItem(
        color: CropPlanStatus.planned.color,
        label: l10n.plannedStatus,
        icon: Icons.event_note,
        isOutlined: true,
      ),
    ];

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: items.map((item) => _buildCompactItem(item)).toList(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.legendTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildFullItem(item)),
        ],
      ),
    );
  }

  Widget _buildCompactItem(_LegendItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: item.isOutlined ? null : item.color,
            shape: BoxShape.circle,
            border: item.isOutlined 
                ? Border.all(color: item.color, width: 2)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFullItem(_LegendItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.isOutlined ? item.color.withOpacity(0.1) : item.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: item.isOutlined 
                  ? Border.all(color: item.color)
                  : null,
            ),
            child: Icon(
              item.icon,
              size: 14,
              color: item.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: item.isOutlined ? null : item.color,
              shape: BoxShape.circle,
              border: item.isOutlined 
                  ? Border.all(color: item.color, width: 2)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem {
  final Color color;
  final String label;
  final IconData icon;
  final bool isOutlined;

  _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
    this.isOutlined = false,
  });
}

/// Floating legend button that expands to show full legend
class ExpandableLegend extends StatefulWidget {
  const ExpandableLegend({super.key});

  @override
  State<ExpandableLegend> createState() => _ExpandableLegendState();
}

class _ExpandableLegendState extends State<ExpandableLegend> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2F2F2F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isExpanded 
          ? _buildExpanded() 
          : _buildCollapsed(),
    );
  }

  Widget _buildCollapsed() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => setState(() => _isExpanded = true),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.palette,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.legendTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        InkWell(
          onTap: () => setState(() => _isExpanded = false),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.legendTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.expand_less,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        // Legend content
        const Padding(
          padding: EdgeInsets.all(12),
          child: CropLegend(compact: true),
        ),
      ],
    );
  }
}
