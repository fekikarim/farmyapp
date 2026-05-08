import 'package:flutter/material.dart';

/// Represents a future crop rotation plan independent of placed items
/// Farmers can plan ahead and schedule future plantings
class CropPlan {
  final String? id;
  final String landId;
  final String variantId;
  final String variantName;
  final String? iconUrl;
  final String assetCategory;

  // Planning dates
  final DateTime plannedPlantingDate;
  final DateTime? expectedHarvestDate;
  final int? cycleDays;
  final int? growthDays;
  final bool isPerennial;

  // Status and notes
  final CropPlanStatus status;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? completedAt;

  CropPlan({
    this.id,
    required this.landId,
    required this.variantId,
    required this.variantName,
    this.iconUrl,
    this.assetCategory = 'vegetation',
    required this.plannedPlantingDate,
    this.expectedHarvestDate,
    this.cycleDays,
    this.growthDays,
    this.isPerennial = false,
    this.status = CropPlanStatus.planned,
    this.notes,
    this.createdAt,
    this.completedAt,
  });

  factory CropPlan.fromJson(Map<String, dynamic> json) {
    final plannedDate = json['planned_planting_date'] != null
        ? DateTime.parse(json['planned_planting_date'])
        : DateTime.now();

    return CropPlan(
      id: json['id']?.toString(),
      landId: json['land_id']?.toString() ?? '',
      variantId: json['variant_id']?.toString() ?? '',
      variantName:
          json['variant_name']?.toString() ??
          json['variant']?['variant_code']?.toString() ??
          'Unknown Crop',
      iconUrl: json['icon_url'] ?? json['variant']?['image_url'],
      assetCategory: json['asset_category']?.toString() ?? 'vegetation',
      plannedPlantingDate: plannedDate,
      expectedHarvestDate: json['expected_harvest_date'] != null
          ? DateTime.tryParse(json['expected_harvest_date'])
          : null,
      cycleDays: json['cycle_days'] != null
          ? int.tryParse(json['cycle_days'].toString())
          : null,
      growthDays: json['growth_days'] != null
          ? int.tryParse(json['growth_days'].toString())
          : null,
      isPerennial:
          json['is_perennial'] == true ||
          json['attributes']?['is_perennial'] == true,
      status: _parseStatus(json['status']?.toString()),
      notes: json['notes']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
    );
  }

  static CropPlanStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
      case 'planted':
        return CropPlanStatus.active;
      case 'completed':
      case 'harvested':
        return CropPlanStatus.completed;
      case 'cancelled':
        return CropPlanStatus.cancelled;
      case 'planned':
      default:
        return CropPlanStatus.planned;
    }
  }

  /// Compute expected harvest date from planting date and growth/cycle days
  static DateTime? computeHarvestDate(
    DateTime plantingDate,
    int? growthDays,
    int? cycleDays,
  ) {
    final days = growthDays ?? cycleDays ?? 30;
    return plantingDate.add(Duration(days: days));
  }

  /// Create a copy with computed harvest date
  CropPlan withComputedHarvestDate() {
    if (expectedHarvestDate != null) return this;

    final computed = computeHarvestDate(
      plannedPlantingDate,
      growthDays,
      cycleDays,
    );

    return CropPlan(
      id: id,
      landId: landId,
      variantId: variantId,
      variantName: variantName,
      iconUrl: iconUrl,
      assetCategory: assetCategory,
      plannedPlantingDate: plannedPlantingDate,
      expectedHarvestDate: computed,
      cycleDays: cycleDays,
      growthDays: growthDays,
      isPerennial: isPerennial,
      status: status,
      notes: notes,
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  /// Check if plan is overdue (past planting date but not planted)
  bool get isOverdue {
    if (status != CropPlanStatus.planned) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final plantingDay = DateTime(
      plannedPlantingDate.year,
      plannedPlantingDate.month,
      plannedPlantingDate.day,
    );
    return plantingDay.isBefore(today);
  }

  /// Check if plan is for today
  bool get isToday {
    final now = DateTime.now();
    return plannedPlantingDate.year == now.year &&
        plannedPlantingDate.month == now.month &&
        plannedPlantingDate.day == now.day;
  }

  /// Days until planting (negative if overdue)
  int get daysUntilPlanting {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final plantingDay = DateTime(
      plannedPlantingDate.year,
      plannedPlantingDate.month,
      plannedPlantingDate.day,
    );
    return plantingDay.difference(today).inDays;
  }

  /// Check if this plan spans a specific date
  bool spansDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final plantingDay = DateTime(
      plannedPlantingDate.year,
      plannedPlantingDate.month,
      plannedPlantingDate.day,
    );

    // For planned status, only show on planting date
    if (status == CropPlanStatus.planned) {
      return _isSameDay(startOfDay, plantingDay);
    }

    // For active status, show from planting to harvest
    if (status == CropPlanStatus.active && expectedHarvestDate != null) {
      final harvestDay = DateTime(
        expectedHarvestDate!.year,
        expectedHarvestDate!.month,
        expectedHarvestDate!.day,
      );
      return (startOfDay.isAfter(plantingDay) ||
              _isSameDay(startOfDay, plantingDay)) &&
          (startOfDay.isBefore(harvestDay) ||
              _isSameDay(startOfDay, harvestDay));
    }

    return false;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'land_id': landId,
      'variant_id': variantId,
      'variant_name': variantName,
      if (iconUrl != null) 'icon_url': iconUrl,
      'asset_category': assetCategory,
      'planned_planting_date': plannedPlantingDate.toIso8601String(),
      if (expectedHarvestDate != null)
        'expected_harvest_date': expectedHarvestDate!.toIso8601String(),
      if (cycleDays != null) 'cycle_days': cycleDays,
      if (growthDays != null) 'growth_days': growthDays,
      'is_perennial': isPerennial,
      'status': status.name,
      if (notes != null) 'notes': notes,
    };
  }

  /// Get color based on status
  Color getStatusColor(BuildContext context) {
    switch (status) {
      case CropPlanStatus.planned:
        return isOverdue ? Colors.red : Colors.blue;
      case CropPlanStatus.active:
        return Colors.green;
      case CropPlanStatus.completed:
        return Colors.grey;
      case CropPlanStatus.cancelled:
        return Colors.red.shade300;
    }
  }

  /// Copy with updates
  CropPlan copyWith({
    String? id,
    String? landId,
    String? variantId,
    String? variantName,
    String? iconUrl,
    String? assetCategory,
    DateTime? plannedPlantingDate,
    DateTime? expectedHarvestDate,
    int? cycleDays,
    int? growthDays,
    bool? isPerennial,
    CropPlanStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return CropPlan(
      id: id ?? this.id,
      landId: landId ?? this.landId,
      variantId: variantId ?? this.variantId,
      variantName: variantName ?? this.variantName,
      iconUrl: iconUrl ?? this.iconUrl,
      assetCategory: assetCategory ?? this.assetCategory,
      plannedPlantingDate: plannedPlantingDate ?? this.plannedPlantingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      cycleDays: cycleDays ?? this.cycleDays,
      growthDays: growthDays ?? this.growthDays,
      isPerennial: isPerennial ?? this.isPerennial,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum CropPlanStatus { planned, active, completed, cancelled }

extension CropPlanStatusExtension on CropPlanStatus {
  String getLabel() {
    switch (this) {
      case CropPlanStatus.planned:
        return 'Planned';
      case CropPlanStatus.active:
        return 'Planted';
      case CropPlanStatus.completed:
        return 'Harvested';
      case CropPlanStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case CropPlanStatus.planned:
        return Colors.blue;
      case CropPlanStatus.active:
        return Colors.green;
      case CropPlanStatus.completed:
        return Colors.grey;
      case CropPlanStatus.cancelled:
        return Colors.red.shade300;
    }
  }
}
