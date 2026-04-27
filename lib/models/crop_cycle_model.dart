import 'package:flutter/material.dart';

/// Represents a crop's lifecycle based on placed items
/// Maps placed assets to their growth cycles using asset_productions data
class CropCycle {
  final String id;
  final String landId;
  final String variantId;
  final String assetCategory;
  final String variantName;
  final String? iconUrl;
  
  // Planting info
  final DateTime placedAt;
  final int? growthDays; // From VegetationVariant attributes.growth_days
  final int cycleDays; // From asset_productions.cycle_days
  final bool isPerennial;
  
  // Production info
  final String? productName;
  final double? ratePerCycle;
  final bool onHarvestOnly;
  
  // Current status
  final CropCycleStatus status;
  final DateTime? lastHarvestedAt;
  final int harvestCount;
  
  // Computed
  final List<DateTime>? upcomingHarvests;

  CropCycle({
    required this.id,
    required this.landId,
    required this.variantId,
    required this.assetCategory,
    required this.variantName,
    this.iconUrl,
    required this.placedAt,
    this.growthDays,
    required this.cycleDays,
    this.isPerennial = false,
    this.productName,
    this.ratePerCycle,
    this.onHarvestOnly = true,
    this.status = CropCycleStatus.growing,
    this.lastHarvestedAt,
    this.harvestCount = 0,
    this.upcomingHarvests,
  });

  factory CropCycle.fromJson(Map<String, dynamic> json) {
    final placedAt = json['placed_at'] != null 
        ? DateTime.parse(json['placed_at']) 
        : DateTime.now();
    
    final growthDays = json['growth_days'] ?? json['attributes']?['growth_days'];
    final cycleDays = json['cycle_days'] ?? 30;
    final isPerennial = json['is_perennial'] ?? json['attributes']?['is_perennial'] ?? false;
    
    return CropCycle(
      id: json['id']?.toString() ?? '',
      landId: json['land_id']?.toString() ?? '',
      variantId: json['variant_id']?.toString() ?? '',
      assetCategory: json['asset_category']?.toString() ?? 'vegetation',
      variantName: json['variant_name']?.toString() ?? 
                  json['variant']?['variant_code']?.toString() ?? 
                  'Unknown Crop',
      iconUrl: json['icon_url'] ?? json['variant']?['image_url'],
      placedAt: placedAt,
      growthDays: growthDays != null ? int.tryParse(growthDays.toString()) : null,
      cycleDays: int.tryParse(cycleDays.toString()) ?? 30,
      isPerennial: isPerennial is bool ? isPerennial : (isPerennial.toString() == 'true'),
      productName: json['product_name']?.toString(),
      ratePerCycle: json['rate_per_cycle'] != null 
          ? double.tryParse(json['rate_per_cycle'].toString()) 
          : null,
      onHarvestOnly: json['on_harvest_only'] ?? true,
      status: _parseStatus(json['status']?.toString()),
      lastHarvestedAt: json['last_harvested_at'] != null 
          ? DateTime.tryParse(json['last_harvested_at']) 
          : null,
      harvestCount: json['harvest_count'] ?? 0,
      upcomingHarvests: _calculateUpcomingHarvests(
        placedAt, 
        growthDays != null ? int.tryParse(growthDays.toString()) : null, 
        int.tryParse(cycleDays.toString()) ?? 30,
        isPerennial is bool ? isPerennial : (isPerennial.toString() == 'true'),
      ),
    );
  }

  static CropCycleStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'ready':
      case 'ready_to_harvest':
        return CropCycleStatus.ready;
      case 'completed':
      case 'harvested':
        return CropCycleStatus.completed;
      case 'growing':
      default:
        return CropCycleStatus.growing;
    }
  }

  static List<DateTime>? _calculateUpcomingHarvests(
    DateTime placedAt, 
    int? growthDays, 
    int cycleDays,
    bool isPerennial,
  ) {
    final now = DateTime.now();
    final List<DateTime> harvests = [];
    
    if (growthDays == null) {
      // Use cycleDays as fallback
      final firstHarvest = placedAt.add(Duration(days: cycleDays));
      if (firstHarvest.isAfter(now)) {
        harvests.add(firstHarvest);
      }
      
      // For perennials, add future cycles
      if (isPerennial && harvests.isNotEmpty) {
        for (int i = 1; i < 4; i++) {
          harvests.add(firstHarvest.add(Duration(days: cycleDays * i)));
        }
      }
    } else {
      // Use growthDays for first harvest
      final firstHarvest = placedAt.add(Duration(days: growthDays));
      harvests.add(firstHarvest);
      
      // For perennials, subsequent harvests use cycleDays
      if (isPerennial) {
        for (int i = 1; i < 4; i++) {
          harvests.add(firstHarvest.add(Duration(days: cycleDays * i)));
        }
      }
    }
    
    return harvests.isEmpty ? null : harvests;
  }

  /// Get the next harvest date
  DateTime? get nextHarvest {
    final now = DateTime.now();
    for (final harvest in upcomingHarvests ?? []) {
      if (harvest.isAfter(now) || _isSameDay(harvest, now)) {
        return harvest;
      }
    }
    return null;
  }

  /// Check if crop is ready for harvest today
  bool get isReadyForHarvest {
    if (upcomingHarvests == null || upcomingHarvests!.isEmpty) return false;
    final next = nextHarvest;
    if (next == null) return false;
    return _isSameDay(next, DateTime.now()) || next.isBefore(DateTime.now());
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (upcomingHarvests == null || upcomingHarvests!.isEmpty) return 0.0;
    final next = nextHarvest ?? upcomingHarvests!.first;
    final lastHarvest = lastHarvestedAt ?? placedAt;
    
    final totalDuration = next.difference(lastHarvest).inDays;
    final elapsed = DateTime.now().difference(lastHarvest).inDays;
    
    if (totalDuration <= 0) return 1.0;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  /// Get days until next harvest
  int? get daysUntilHarvest {
    final next = nextHarvest;
    if (next == null) return null;
    return next.difference(DateTime.now()).inDays;
  }

  /// Check if this crop cycle spans a specific date
  bool spansDate(DateTime date) {
    // Check if date is between placed date and any harvest date
    final startOfDay = DateTime(date.year, date.month, date.day);
    
    // Must be after planting
    final plantingDay = DateTime(placedAt.year, placedAt.month, placedAt.day);
    if (startOfDay.isBefore(plantingDay)) return false;
    
    // Check if it falls on any harvest period
    if (upcomingHarvests != null) {
      for (final harvest in upcomingHarvests!) {
        final harvestDay = DateTime(harvest.year, harvest.month, harvest.day);
        if (_isSameDay(startOfDay, harvestDay)) return true;
        
        // For perennials, check if date falls between harvests
        if (isPerennial && startOfDay.isBefore(harvestDay)) {
          // Check if within a cycle period
          final daysSincePlanting = startOfDay.difference(plantingDay).inDays;
          final cycleNumber = daysSincePlanting ~/ cycleDays;
          final expectedHarvest = plantingDay.add(Duration(days: cycleDays * (cycleNumber + 1)));
          
          if (_isSameDay(startOfDay, expectedHarvest) || 
              (startOfDay.isAfter(plantingDay.add(Duration(days: cycleDays * cycleNumber))) &&
               startOfDay.isBefore(expectedHarvest))) {
            return true;
          }
        }
      }
    }
    
    // For single harvest crops, check if before harvest
    if (!isPerennial && upcomingHarvests?.isNotEmpty == true) {
      final harvest = upcomingHarvests!.first;
      final harvestDay = DateTime(harvest.year, harvest.month, harvest.day);
      return startOfDay.isBefore(harvestDay) || _isSameDay(startOfDay, harvestDay);
    }
    
    return false;
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get color based on status
  Color getStatusColor(BuildContext context) {
    switch (status) {
      case CropCycleStatus.ready:
        return Colors.amber;
      case CropCycleStatus.completed:
        return Colors.grey;
      case CropCycleStatus.growing:
      default:
        return Colors.green;
    }
  }

  /// Copy with updates
  CropCycle copyWith({
    CropCycleStatus? status,
    DateTime? lastHarvestedAt,
    int? harvestCount,
    List<DateTime>? upcomingHarvests,
  }) {
    return CropCycle(
      id: id,
      landId: landId,
      variantId: variantId,
      assetCategory: assetCategory,
      variantName: variantName,
      iconUrl: iconUrl,
      placedAt: placedAt,
      growthDays: growthDays,
      cycleDays: cycleDays,
      isPerennial: isPerennial,
      productName: productName,
      ratePerCycle: ratePerCycle,
      onHarvestOnly: onHarvestOnly,
      status: status ?? this.status,
      lastHarvestedAt: lastHarvestedAt ?? this.lastHarvestedAt,
      harvestCount: harvestCount ?? this.harvestCount,
      upcomingHarvests: upcomingHarvests ?? this.upcomingHarvests,
    );
  }
}

enum CropCycleStatus {
  growing,
  ready,
  completed,
}

extension CropCycleStatusExtension on CropCycleStatus {
  String getLabel() {
    switch (this) {
      case CropCycleStatus.growing:
        return 'Growing';
      case CropCycleStatus.ready:
        return 'Ready to Harvest';
      case CropCycleStatus.completed:
        return 'Completed';
    }
  }

  Color get color {
    switch (this) {
      case CropCycleStatus.growing:
        return Colors.green;
      case CropCycleStatus.ready:
        return Colors.amber;
      case CropCycleStatus.completed:
        return Colors.grey;
    }
  }
}
