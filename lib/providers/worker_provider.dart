import 'package:flutter/material.dart';
import '../models/worker_profile_model.dart';
import '../models/land_worker_model.dart';
import '../models/task_model.dart';
import '../services/worker_service.dart';
import '../services/task_service.dart';

class WorkerProvider extends ChangeNotifier {
  // Worker Profile State
  WorkerProfile? _myProfile;
  bool _profileLoading = false;
  String? _profileError;

  // Marketplace State
  List<WorkerProfile> _marketplace = [];
  bool _marketplaceLoading = false;

  // Land Workers State
  List<LandWorker> _landWorkers = [];
  bool _landWorkersLoading = false;
  String? _landWorkersError;
  Map<String, dynamic> _workforceStats = {};

  // Worker's Assigned Lands
  List<LandWorker> _assignedLands = [];
  bool _assignedLandsLoading = false;
  String? _assignedLandsError;

  // Tasks State
  List<FarmTask> _tasks = [];
  bool _tasksLoading = false;
  String? _tasksError;
  List<FarmTask> _myTasks = [];
  bool _myTasksLoading = false;
  String? _myTasksError;

  // Getters
  WorkerProfile? get myProfile => _myProfile;
  bool get profileLoading => _profileLoading;
  String? get profileError => _profileError;
  bool get hasWorkerProfile => _myProfile != null;
  bool get isVerifiedWorker => _myProfile?.isVerified ?? false;

  List<WorkerProfile> get marketplace => _marketplace;
  bool get marketplaceLoading => _marketplaceLoading;

  List<LandWorker> get landWorkers => _landWorkers;
  bool get landWorkersLoading => _landWorkersLoading;
  String? get landWorkersError => _landWorkersError;
  Map<String, dynamic> get workforceStats => _workforceStats;

  List<LandWorker> get assignedLands => _assignedLands;
  bool get assignedLandsLoading => _assignedLandsLoading;
  String? get assignedLandsError => _assignedLandsError;

  List<FarmTask> get tasks => _tasks;
  bool get tasksLoading => _tasksLoading;
  String? get tasksError => _tasksError;
  List<FarmTask> get myTasks => _myTasks;
  bool get myTasksLoading => _myTasksLoading;
  String? get myTasksError => _myTasksError;

  // Global Performance Stats
  Map<String, dynamic> _performanceStats = {};
  bool _performanceLoading = false;
  Map<String, dynamic> get performanceStats => _performanceStats;
  bool get performanceLoading => _performanceLoading;

  // ─── Worker Profile Actions ───

  Future<void> loadMyProfile() async {
    _profileLoading = true;
    _profileError = null;
    notifyListeners();

    try {
      _myProfile = await WorkerService.getMyWorkerProfile();
    } catch (e) {
      _profileError = e.toString();
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProfile({
    required List<String> skills,
    String? bio,
    double? hourlyRate,
  }) async {
    _profileLoading = true;
    _profileError = null;
    notifyListeners();

    try {
      _myProfile = await WorkerService.createWorkerProfile(
        skills: skills,
        bio: bio,
        hourlyRate: hourlyRate,
      );
      _profileLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _profileError = e.toString();
      _profileLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    List<String>? skills,
    String? bio,
    double? hourlyRate,
    String? availability,
  }) async {
    try {
      _myProfile = await WorkerService.updateMyWorkerProfile(
        skills: skills,
        bio: bio,
        hourlyRate: hourlyRate,
        availability: availability,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _profileError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Marketplace Actions ───

  Future<void> loadMarketplace({
    String? skill,
    double? minRating,
    String? availability,
    String? excludeLandId,
  }) async {
    _marketplaceLoading = true;
    notifyListeners();

    try {
      _marketplace = await WorkerService.getMarketplace(
        skill: skill,
        minRating: minRating,
        availability: availability,
        excludeLandId: excludeLandId,
      );
    } catch (e) {
      _marketplace = [];
    } finally {
      _marketplaceLoading = false;
      notifyListeners();
    }
  }

  // ─── Land Workers Actions ───

  Future<void> loadLandWorkers(String landId) async {
    _landWorkersLoading = true;
    _landWorkersError = null;
    notifyListeners();

    try {
      _landWorkers = await WorkerService.getLandWorkers(landId);
      _workforceStats = await WorkerService.getWorkforceStats(landId);
    } catch (e) {
      _landWorkers = [];
      _workforceStats = {};
      _landWorkersError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _landWorkersLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignWorker({
    required String landId,
    required String workerId,
    String? role,
    double? salary,
  }) async {
    try {
      await WorkerService.assignWorkerToLand(
        landId: landId,
        workerId: workerId,
        role: role,
        salary: salary,
      );
      await loadLandWorkers(landId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeWorker(String landId, String workerId) async {
    try {
      await WorkerService.removeWorkerFromLand(landId, workerId);
      await loadLandWorkers(landId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWorkerStatus(
    String landId,
    String workerId,
    String status,
  ) async {
    try {
      final success = await WorkerService.updateWorkerStatus(
        landId,
        workerId,
        status,
      );
      if (success) {
        await loadLandWorkers(landId);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // ─── Worker's Assigned Lands ───

  Future<void> loadAssignedLands() async {
    _assignedLandsLoading = true;
    _assignedLandsError = null;
    notifyListeners();

    try {
      _assignedLands = await WorkerService.getMyAssignedLands();
    } catch (e) {
      _assignedLands = [];
      _assignedLandsError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _assignedLandsLoading = false;
      notifyListeners();
    }
  }

  // ─── Task Actions ───

  Future<void> loadLandTasks(String landId, {String? status}) async {
    _tasksLoading = true;
    _tasksError = null;
    notifyListeners();

    try {
      _tasks = await TaskService.getLandTasks(landId, status: status);
    } catch (e) {
      _tasks = [];
      _tasksError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _tasksLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask({
    required String landId,
    required String title,
    String? description,
    String? type,
    double? reward,
    int? timeRequiredMinutes,
  }) async {
    try {
      await TaskService.createTask(
        landId: landId,
        title: title,
        description: description,
        type: type,
        reward: reward,
        timeRequiredMinutes: timeRequiredMinutes,
      );
      await loadLandTasks(landId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadMyTasks() async {
    _myTasksLoading = true;
    _myTasksError = null;
    notifyListeners();

    try {
      _myTasks = await TaskService.getMyTasks();
    } catch (e) {
      _myTasks = [];
      _myTasksError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _myTasksLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshWorkerDashboard() async {
    await Future.wait([loadMyProfile(), loadAssignedLands(), loadMyTasks()]);
  }

  Future<bool> completeTask({
    required String taskId,
    String? proofImageUrl,
    String? proofVideoUrl,
    Map<String, dynamic>? proofGps,
  }) async {
    try {
      await TaskService.completeTask(
        taskId: taskId,
        proofImageUrl: proofImageUrl,
        proofVideoUrl: proofVideoUrl,
        proofGps: proofGps,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadWorkerPerformance(String workerUserId) async {
    _performanceLoading = true;
    _performanceStats = {};
    notifyListeners();

    try {
      _performanceStats = await WorkerService.getWorkerPerformance(workerUserId);
    } catch (e) {
      _performanceStats = {};
    } finally {
      _performanceLoading = false;
      notifyListeners();
    }
  }
}
