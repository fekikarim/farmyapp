import 'package:flutter/material.dart';
import '../models/crop_cycle_model.dart';
import '../models/crop_plan_model.dart';
import '../models/land_model.dart';
import '../services/crop_calendar_service.dart';

enum CalendarViewMode { month, year }

class CropCalendarProvider with ChangeNotifier {
  // Data
  List<CropCycle> _cropCycles = [];
  List<CropPlan> _cropPlans = [];
  List<Land> _lands = [];
  
  // State
  String? _selectedLandId;
  CalendarViewMode _viewMode = CalendarViewMode.month;
  DateTime _currentDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CropCycle> get cropCycles => _cropCycles;
  List<CropPlan> get cropPlans => _cropPlans;
  List<Land> get lands => _lands;
  String? get selectedLandId => _selectedLandId;
  CalendarViewMode get viewMode => _viewMode;
  DateTime get currentDate => _currentDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed: All items for selected land
  List<dynamic> get allItems {
    final List<dynamic> items = [];
    items.addAll(_cropCycles);
    items.addAll(_cropPlans.where((p) => p.status != CropPlanStatus.cancelled));
    return items;
  }

  // Computed: Get items for specific date
  List<dynamic> getItemsForDate(DateTime date) {
    final List<dynamic> items = [];
    
    // Add crop cycles that span this date
    for (final cycle in _cropCycles) {
      if (cycle.spansDate(date)) {
        items.add(cycle);
      }
    }
    
    // Add crop plans that span this date
    for (final plan in _cropPlans) {
      if (plan.spansDate(date) && plan.status != CropPlanStatus.cancelled) {
        items.add(plan);
      }
    }
    
    return items;
  }

  // Computed: Upcoming harvests (next 30 days)
  List<CropCycle> get upcomingHarvests {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    
    return _cropCycles.where((cycle) {
      final nextHarvest = cycle.nextHarvest;
      if (nextHarvest == null) return false;
      return nextHarvest.isAfter(now) && 
             nextHarvest.isBefore(thirtyDaysFromNow) ||
             cycle.isReadyForHarvest;
    }).toList()
      ..sort((a, b) {
        final aDate = a.nextHarvest ?? DateTime.now();
        final bDate = b.nextHarvest ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
  }

  // Computed: Active crops (currently growing)
  List<CropCycle> get activeCrops {
    return _cropCycles.where((cycle) => 
      cycle.status == CropCycleStatus.growing || 
      cycle.status == CropCycleStatus.ready
    ).toList();
  }

  // Computed: Ready to harvest
  List<CropCycle> get readyToHarvest {
    return _cropCycles.where((cycle) => 
      cycle.isReadyForHarvest || cycle.status == CropCycleStatus.ready
    ).toList();
  }

  // Computed: Overdue plans
  List<CropPlan> get overduePlans {
    return _cropPlans.where((plan) => 
      plan.status == CropPlanStatus.planned && plan.isOverdue
    ).toList();
  }

  // Computed: Today's tasks
  List<dynamic> get todayTasks {
    final today = DateTime.now();
    return getItemsForDate(today);
  }

  // Computed: Planned crops (future planting)
  List<CropPlan> get plannedCrops {
    return _cropPlans.where((plan) => 
      plan.status == CropPlanStatus.planned && !plan.isOverdue
    ).toList()
      ..sort((a, b) => a.plannedPlantingDate.compareTo(b.plannedPlantingDate));
  }

  // Actions
  void setLands(List<Land> lands) {
    _lands = lands;
    if (_selectedLandId == null && lands.isNotEmpty) {
      _selectedLandId = lands.first.id;
    }
    notifyListeners();
  }

  void selectLand(String? landId) {
    _selectedLandId = landId;
    notifyListeners();
    if (landId != null) {
      loadCropData(landId);
    }
  }

  void setViewMode(CalendarViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void goToToday() {
    _currentDate = DateTime.now();
    notifyListeners();
  }

  void goToPrevious() {
    if (_viewMode == CalendarViewMode.month) {
      _currentDate = DateTime(
        _currentDate.year, 
        _currentDate.month - 1, 
        1,
      );
    } else {
      _currentDate = DateTime(_currentDate.year - 1, 1, 1);
    }
    notifyListeners();
  }

  void goToNext() {
    if (_viewMode == CalendarViewMode.month) {
      _currentDate = DateTime(
        _currentDate.year, 
        _currentDate.month + 1, 
        1,
      );
    } else {
      _currentDate = DateTime(_currentDate.year + 1, 1, 1);
    }
    notifyListeners();
  }

  void setCurrentDate(DateTime date) {
    _currentDate = date;
    notifyListeners();
  }

  // Data loading
  Future<void> loadCropData(String landId) async {
    _setLoading(true);
    _error = null;
    
    try {
      // Load crop cycles and plans in parallel
      final results = await Future.wait([
        CropCalendarService.fetchCropCycles(landId),
        CropCalendarService.fetchCropPlans(landId),
      ]);
      
      _cropCycles = results[0] as List<CropCycle>;
      _cropPlans = results[1] as List<CropPlan>;
      
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> loadAllLandsData() async {
    if (_lands.isEmpty) return;
    
    _setLoading(true);
    _error = null;
    
    try {
      final landIds = _lands.map((l) => l.id).toList();
      final allCycles = await CropCalendarService.fetchAllCropCycles(landIds);
      
      // Flatten all cycles
      _cropCycles = allCycles.values.expand((list) => list).toList();
      
      // Load plans for all lands
      final allPlans = <CropPlan>[];
      for (final landId in landIds) {
        final plans = await CropCalendarService.fetchCropPlans(landId);
        allPlans.addAll(plans);
      }
      _cropPlans = allPlans;
      
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> refreshData() async {
    if (_selectedLandId != null) {
      await loadCropData(_selectedLandId!);
    } else {
      await loadAllLandsData();
    }
  }

  // Crop Plan CRUD
  Future<bool> addCropPlan(CropPlan plan) async {
    _setLoading(true);
    
    try {
      final created = await CropCalendarService.createCropPlan(plan);
      
      if (created != null) {
        _cropPlans.add(created);
        _setLoading(false);
        return true;
      }
      
      _error = 'Failed to create crop plan';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCropPlan(CropPlan plan) async {
    if (plan.id == null) return false;
    
    _setLoading(true);
    
    try {
      final updated = await CropCalendarService.updateCropPlan(
        plan.id!, 
        plan.toJson(),
      );
      
      if (updated != null) {
        final index = _cropPlans.indexWhere((p) => p.id == plan.id);
        if (index != -1) {
          _cropPlans[index] = updated;
          notifyListeners();
        }
        _setLoading(false);
        return true;
      }
      
      _error = 'Failed to update crop plan';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCropPlan(String id) async {
    _setLoading(true);
    
    try {
      final success = await CropCalendarService.deleteCropPlan(id);
      
      if (success) {
        _cropPlans.removeWhere((p) => p.id == id);
        _setLoading(false);
        return true;
      }
      
      _error = 'Failed to delete crop plan';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> activatePlan(String id) async {
    try {
      final updated = await CropCalendarService.activateCropPlan(id);
      
      if (updated != null) {
        final index = _cropPlans.indexWhere((p) => p.id == id);
        if (index != -1) {
          _cropPlans[index] = updated;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> completePlan(String id) async {
    try {
      final updated = await CropCalendarService.completeCropPlan(id);
      
      if (updated != null) {
        final index = _cropPlans.indexWhere((p) => p.id == id);
        if (index != -1) {
          _cropPlans[index] = updated;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get land name by ID
  String getLandName(String landId) {
    final land = _lands.firstWhere(
      (l) => l.id == landId,
      orElse: () => Land(
        id: landId, 
        ownerId: '', 
        name: 'Unknown Land',
      ),
    );
    return land.name;
  }

  // Get color for item (cycle or plan)
  Color getItemColor(dynamic item, BuildContext context) {
    if (item is CropCycle) {
      return item.getStatusColor(context);
    } else if (item is CropPlan) {
      return item.getStatusColor(context);
    }
    return Colors.grey;
  }

  // Get status label
  String getItemStatusLabel(dynamic item) {
    if (item is CropCycle) {
      return item.status.getLabel();
    } else if (item is CropPlan) {
      return item.status.getLabel();
    }
    return 'Unknown';
  }
}
