import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../models/crop_cycle_model.dart';
import '../../models/crop_plan_model.dart';
import '../../theme/app_theme.dart';

/// Card displaying a single crop cycle or plan
class CropCycleCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const CropCycleCard({
    super.key,
    required this.item,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (item is CropCycle) {
      return _CropCycleCardContent(
        cycle: item as CropCycle,
        isDark: isDark,
        onTap: onTap,
        onAction: onAction,
      );
    } else if (item is CropPlan) {
      return _CropPlanCardContent(
        plan: item as CropPlan,
        isDark: isDark,
        onTap: onTap,
        onAction: onAction,
      );
    }
    
    return const SizedBox.shrink();
  }
}

class _CropCycleCardContent extends StatelessWidget {
  final CropCycle cycle;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const _CropCycleCardContent({
    required this.cycle,
    required this.isDark,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = cycle.getStatusColor(context);
    final daysUntil = cycle.daysUntilHarvest;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
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
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      cycle.assetCategory == 'tree' 
                          ? Icons.forest 
                          : Icons.local_florist,
                      size: 20,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cycle.variantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cycle.status.getLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action button
                  if (cycle.isReadyForHarvest && onAction != null)
                    ElevatedButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(AppLocalizations.of(context)!.harvestButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: cycle.progressPercentage,
                        backgroundColor: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(cycle.progressPercentage * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Dates info
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: AppLocalizations.of(context)!.plantedLabel,
                    value: _formatDate(cycle.placedAt),
                    color: statusColor,
                  ),
                  const SizedBox(width: 16),
                  if (daysUntil != null)
                    _InfoChip(
                      icon: Icons.event_outlined,
                      label: daysUntil <= 0 
                          ? AppLocalizations.of(context)!.readyLabel 
                          : AppLocalizations.of(context)!.harvestLabel,
                      value: daysUntil <= 0 
                          ? AppLocalizations.of(context)!.nowLabel
                          : '$daysUntil ${AppLocalizations.of(context)!.days}',
                      color: statusColor,
                      isHighlighted: daysUntil <= 0,
                    ),
                ],
              ),
              
              // Production info
              if (cycle.productName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${AppLocalizations.of(context)!.producesLabel}: ${cycle.productName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                      ),
                    ),
                    if (cycle.ratePerCycle != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${cycle.ratePerCycle} ${AppLocalizations.of(context)!.perCycle})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CropPlanCardContent extends StatelessWidget {
  final CropPlan plan;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  const _CropPlanCardContent({
    required this.plan,
    required this.isDark,
    this.onTap,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = plan.getStatusColor(context);
    final daysUntil = plan.daysUntilPlanting;
    final isOverdue = plan.isOverdue;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
          style: plan.status == CropPlanStatus.planned 
              ? BorderStyle.solid 
              : BorderStyle.solid,
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
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: plan.status == CropPlanStatus.planned
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: plan.status == CropPlanStatus.planned
                          ? Border.all(color: statusColor.withOpacity(0.3))
                          : null,
                    ),
                    child: Icon(
                      Icons.event_note,
                      size: 20,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.variantName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                plan.status.getLabel(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isOverdue) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: Colors.red,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Action button
                  if (plan.status == CropPlanStatus.planned && onAction != null)
                    ElevatedButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: Text(AppLocalizations.of(context)!.plantButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              
              // Dates info
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: AppLocalizations.of(context)!.plantingLabel,
                    value: _formatDate(plan.plannedPlantingDate),
                    color: statusColor,
                    isHighlighted: plan.isToday,
                  ),
                  const SizedBox(width: 16),
                  if (plan.expectedHarvestDate != null)
                    _InfoChip(
                      icon: Icons.event_outlined,
                      label: AppLocalizations.of(context)!.harvestLabel,
                      value: _formatDate(plan.expectedHarvestDate!),
                      color: statusColor,
                    ),
                ],
              ),
              
              // Days indicator
              if (plan.status == CropPlanStatus.planned) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOverdue 
                        ? Colors.red.withOpacity(0.1) 
                        : isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOverdue ? Icons.warning_amber : Icons.schedule,
                        size: 16,
                        color: isOverdue ? Colors.red : isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOverdue
                            ? AppLocalizations.of(context)!.overdueByDays(-daysUntil)
                            : daysUntil == 0
                                ? AppLocalizations.of(context)!.plantToday
                                : AppLocalizations.of(context)!.plantInDays(daysUntil),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isOverdue ? Colors.red : isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Notes
              if (plan.notes != null && plan.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan.notes!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isHighlighted;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? color.withOpacity(0.15) 
            : isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted 
            ? Border.all(color: color.withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isHighlighted ? color : (isDark ? Colors.white : Colors.black.withOpacity(0.87)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
