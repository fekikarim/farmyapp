import 'package:flutter/foundation.dart';

/// Hero Metrics - Top KPIs displayed in the dashboard
class HeroMetrics {
  final int activeLands;
  final int openTasks;
  final int overdueTasks;
  final int pendingItemRequests; // New: pending item requests from investors
  final double monthlyRevenue;
  final double revenueTrend;
  final double lastMonthRevenue;

  const HeroMetrics({
    required this.activeLands,
    required this.openTasks,
    required this.overdueTasks,
    required this.pendingItemRequests,
    required this.monthlyRevenue,
    required this.revenueTrend,
    required this.lastMonthRevenue,
  });

  factory HeroMetrics.fromJson(Map<String, dynamic> json) {
    return HeroMetrics(
      activeLands: json['activeLands'] ?? 0,
      openTasks: json['openTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      pendingItemRequests: json['pendingItemRequests'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      revenueTrend: (json['revenueTrend'] ?? 0).toDouble(),
      lastMonthRevenue: (json['lastMonthRevenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeLands': activeLands,
      'openTasks': openTasks,
      'overdueTasks': overdueTasks,
      'pendingItemRequests': pendingItemRequests,
      'monthlyRevenue': monthlyRevenue,
      'revenueTrend': revenueTrend,
      'lastMonthRevenue': lastMonthRevenue,
    };
  }

  factory HeroMetrics.empty() {
    return const HeroMetrics(
      activeLands: 0,
      openTasks: 0,
      overdueTasks: 0,
      pendingItemRequests: 0,
      monthlyRevenue: 0.0,
      revenueTrend: 0.0,
      lastMonthRevenue: 0.0,
    );
  }
}

/// Alert Priority Enum
enum AlertPriority {
  critical,
  warning,
  info;

  String get displayName {
    switch (this) {
      case AlertPriority.critical:
        return 'Critical';
      case AlertPriority.warning:
        return 'Warning';
      case AlertPriority.info:
        return 'Info';
    }
  }
}

/// Smart Alert - Dynamic alert generated from backend data
class SmartAlert {
  final String id;
  final AlertPriority priority;
  final String title;
  final String message;
  final String? actionRoute;
  final Map<String, dynamic>? actionData;
  final String? itemId;
  final String? landId;

  const SmartAlert({
    required this.id,
    required this.priority,
    required this.title,
    required this.message,
    this.actionRoute,
    this.actionData,
    this.itemId,
    this.landId,
  });

  factory SmartAlert.fromJson(Map<String, dynamic> json) {
    return SmartAlert(
      id: json['id'] ?? '',
      priority: AlertPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AlertPriority.info,
      ),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      actionRoute: json['actionRoute'],
      actionData: json['actionData'],
      itemId: json['itemId'],
      landId: json['landId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priority': priority.name,
      'title': title,
      'message': message,
      'actionRoute': actionRoute,
      'actionData': actionData,
      'itemId': itemId,
      'landId': landId,
    };
  }
}

/// Land Status Enum
enum LandOperationalStatus {
  owned,
  rented,
  harvestReady,
  pendingRequests;

  String get displayName {
    switch (this) {
      case LandOperationalStatus.owned:
        return 'Owned';
      case LandOperationalStatus.rented:
        return 'Rented';
      case LandOperationalStatus.harvestReady:
        return 'Harvest Ready';
      case LandOperationalStatus.pendingRequests:
        return 'Pending Requests';
    }
  }
}

/// Land Operational - Status of a land with operational metrics
class LandOperational {
  final String id;
  final String name;
  final LandOperationalStatus status;
  final int activeWorkers;
  final int openTasks;
  final int placedItems;
  final bool hasPendingRequests;
  final int pendingRequestsCount;
  final int harvestReadyCount;

  const LandOperational({
    required this.id,
    required this.name,
    required this.status,
    required this.activeWorkers,
    required this.openTasks,
    required this.placedItems,
    required this.hasPendingRequests,
    required this.pendingRequestsCount,
    required this.harvestReadyCount,
  });

  factory LandOperational.fromJson(Map<String, dynamic> json) {
    String statusStr = json['status'] ?? 'owned';
    LandOperationalStatus status;
    switch (statusStr) {
      case 'rented':
        status = LandOperationalStatus.rented;
        break;
      case 'harvest-ready':
        status = LandOperationalStatus.harvestReady;
        break;
      case 'pending-requests':
        status = LandOperationalStatus.pendingRequests;
        break;
      default:
        status = LandOperationalStatus.owned;
    }

    return LandOperational(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: status,
      activeWorkers: json['activeWorkers'] ?? 0,
      openTasks: json['openTasks'] ?? 0,
      placedItems: json['placedItems'] ?? 0,
      hasPendingRequests: json['hasPendingRequests'] ?? false,
      pendingRequestsCount: json['pendingRequestsCount'] ?? 0,
      harvestReadyCount: json['harvestReadyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.name,
      'activeWorkers': activeWorkers,
      'openTasks': openTasks,
      'placedItems': placedItems,
      'hasPendingRequests': hasPendingRequests,
      'pendingRequestsCount': pendingRequestsCount,
      'harvestReadyCount': harvestReadyCount,
    };
  }
}

/// Worker Status Enum
enum WorkerActivityStatus {
  active,
  idle,
  offline;

  String get displayName {
    switch (this) {
      case WorkerActivityStatus.active:
        return 'Active';
      case WorkerActivityStatus.idle:
        return 'Idle';
      case WorkerActivityStatus.offline:
        return 'Offline';
    }
  }
}

/// Active Worker - Worker with current activity status
class ActiveWorker {
  final String id;
  final String name;
  final String? profilePicture;
  final String currentActivity;
  final WorkerActivityStatus status;
  final String? assignedLandId;
  final String? assignedLandName;
  final String? currentTaskId;
  final String? currentTaskTitle;

  const ActiveWorker({
    required this.id,
    required this.name,
    this.profilePicture,
    required this.currentActivity,
    required this.status,
    this.assignedLandId,
    this.assignedLandName,
    this.currentTaskId,
    this.currentTaskTitle,
  });

  factory ActiveWorker.fromJson(Map<String, dynamic> json) {
    return ActiveWorker(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profilePicture: json['profilePicture'],
      currentActivity: json['currentActivity'] ?? 'Idle',
      status: WorkerActivityStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkerActivityStatus.idle,
      ),
      assignedLandId: json['assignedLandId'],
      assignedLandName: json['assignedLandName'],
      currentTaskId: json['currentTaskId'],
      currentTaskTitle: json['currentTaskTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profilePicture': profilePicture,
      'currentActivity': currentActivity,
      'status': status.name,
      'assignedLandId': assignedLandId,
      'assignedLandName': assignedLandName,
      'currentTaskId': currentTaskId,
      'currentTaskTitle': currentTaskTitle,
    };
  }
}

/// AI Session Preview - Preview of farmer's AI sessions
class AISessionPreview {
  final String id;
  final String title;
  final DateTime createdAt;
  final int messageCount;

  const AISessionPreview({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messageCount,
  });

  factory AISessionPreview.fromJson(Map<String, dynamic> json) {
    return AISessionPreview(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Farm Analysis',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      messageCount: json['messageCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'messageCount': messageCount,
    };
  }
}

/// Main Dashboard Data Container
class FarmerDashboardData {
  final HeroMetrics heroMetrics;
  final List<SmartAlert> alerts;
  final List<LandOperational> lands;
  final List<ActiveWorker> workers;
  final List<AISessionPreview> aiSessions;

  const FarmerDashboardData({
    required this.heroMetrics,
    required this.alerts,
    required this.lands,
    required this.workers,
    required this.aiSessions,
  });

  factory FarmerDashboardData.fromJson(Map<String, dynamic> json) {
    return FarmerDashboardData(
      heroMetrics: json['heroMetrics'] != null
          ? HeroMetrics.fromJson(json['heroMetrics'] as Map<String, dynamic>)
          : HeroMetrics.empty(),
      alerts: json['alerts'] != null
          ? (json['alerts'] as List<dynamic>)
                .map((e) => SmartAlert.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      lands: json['lands'] != null
          ? (json['lands'] as List<dynamic>)
                .map((e) => LandOperational.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      workers: json['workers'] != null
          ? (json['workers'] as List<dynamic>)
                .map((e) => ActiveWorker.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      aiSessions: json['aiSessions'] != null
          ? (json['aiSessions'] as List<dynamic>)
                .map(
                  (e) => AISessionPreview.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heroMetrics': heroMetrics.toJson(),
      'alerts': alerts.map((e) => e.toJson()).toList(),
      'lands': lands.map((e) => e.toJson()).toList(),
      'workers': workers.map((e) => e.toJson()).toList(),
      'aiSessions': aiSessions.map((e) => e.toJson()).toList(),
    };
  }
}
