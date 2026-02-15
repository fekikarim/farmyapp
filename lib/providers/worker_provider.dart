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
  Map<String, dynamic> _workforceStats = {};

  // Worker's Assigned Lands
  List<LandWorker> _assignedLands = [];
  bool _assignedLandsLoading = false;

  // Tasks State
  List<FarmTask> _tasks = [];
  bool _tasksLoading = false;
  List<FarmTask> _myTasks = [];
  bool _myTasksLoading = false;

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
  Map<String, dynamic> get workforceStats => _workforceStats;

  List<LandWorker> get assignedLands => _assignedLands;
  bool get assignedLandsLoading => _assignedLandsLoading;

  List<FarmTask> get tasks => _tasks;
  bool get tasksLoading => _tasksLoading;
  List<FarmTask> get myTasks => _myTasks;
  bool get myTasksLoading => _myTasksLoading;

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
  }) async {
    _marketplaceLoading = true;
    notifyListeners();

    try {
      _marketplace = await WorkerService.getMarketplace(
        skill: skill,
        minRating: minRating,
        availability: availability,
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
    notifyListeners();

    try {
      _landWorkers = await WorkerService.getLandWorkers(landId);
      _workforceStats = await WorkerService.getWorkforceStats(landId);
    } catch (e) {
      _landWorkers = [];
      _workforceStats = {};
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

  // ─── Worker's Assigned Lands ───

  Future<void> loadAssignedLands() async {
    _assignedLandsLoading = true;
    notifyListeners();

    try {
      _assignedLands = await WorkerService.getMyAssignedLands();
    } catch (e) {
      _assignedLands = [];
    } finally {
      _assignedLandsLoading = false;
      notifyListeners();
    }
  }

  // ─── Task Actions ───

  Future<void> loadLandTasks(String landId, {String? status}) async {
    _tasksLoading = true;
    notifyListeners();

    try {
      _tasks = await TaskService.getLandTasks(landId, status: status);
    } catch (e) {
      _tasks = [];
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
    notifyListeners();

    try {
      _myTasks = await TaskService.getMyTasks();
    } catch (e) {
      _myTasks = [];
    } finally {
      _myTasksLoading = false;
      notifyListeners();
    }
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
}
