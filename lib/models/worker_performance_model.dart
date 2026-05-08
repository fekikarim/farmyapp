class WorkerPerformance {
  final String workerId;
  final String workerName;
  final String? workerProfilePicture;
  final int totalTasksCompleted;
  final int verifiedProofs;
  final int rejectedProofs;
  final double verificationSuccessRate;
  final double? averageCompletionTimeMinutes;
  final int performanceScore;
  final List<String> landIds;
  final List<String> landNames;

  WorkerPerformance({
    required this.workerId,
    required this.workerName,
    this.workerProfilePicture,
    required this.totalTasksCompleted,
    required this.verifiedProofs,
    required this.rejectedProofs,
    required this.verificationSuccessRate,
    this.averageCompletionTimeMinutes,
    required this.performanceScore,
    required this.landIds,
    required this.landNames,
  });

  factory WorkerPerformance.fromJson(Map<String, dynamic> json) {
    return WorkerPerformance(
      workerId: json['workerId'] ?? '',
      workerName: json['workerName'] ?? 'Unknown Worker',
      workerProfilePicture: json['workerProfilePicture'],
      totalTasksCompleted: json['totalTasksCompleted'] ?? 0,
      verifiedProofs: json['verifiedProofs'] ?? 0,
      rejectedProofs: json['rejectedProofs'] ?? 0,
      verificationSuccessRate:
          (json['verificationSuccessRate'] as num?)?.toDouble() ?? 0.0,
      averageCompletionTimeMinutes:
          (json['averageCompletionTimeMinutes'] as num?)?.toDouble(),
      performanceScore: json['performanceScore'] ?? 0,
      landIds:
          (json['landIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      landNames:
          (json['landNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'workerName': workerName,
      'workerProfilePicture': workerProfilePicture,
      'totalTasksCompleted': totalTasksCompleted,
      'verifiedProofs': verifiedProofs,
      'rejectedProofs': rejectedProofs,
      'verificationSuccessRate': verificationSuccessRate,
      'averageCompletionTimeMinutes': averageCompletionTimeMinutes,
      'performanceScore': performanceScore,
      'landIds': landIds,
      'landNames': landNames,
    };
  }

  /// Get the performance tier based on score
  PerformanceTier get performanceTier {
    if (performanceScore >= 80) return PerformanceTier.excellent;
    if (performanceScore >= 50) return PerformanceTier.good;
    return PerformanceTier.poor;
  }

  /// Get rejection rate percentage
  double get rejectionRate {
    final total = verifiedProofs + rejectedProofs;
    if (total == 0) return 0.0;
    return (rejectedProofs / total) * 100;
  }

  /// Check if this worker needs attention (low score or high rejection)
  bool get needsAttention {
    return performanceScore < 50 || rejectionRate > 30;
  }

  /// Check if this worker is a top performer
  bool get isTopPerformer {
    return performanceScore >= 80 && verificationSuccessRate >= 90;
  }
}

class PerformanceSummary {
  final int totalWorkers;
  final int averagePerformanceScore;
  final int totalTasksCompleted;
  final double overallVerificationRate;

  PerformanceSummary({
    required this.totalWorkers,
    required this.averagePerformanceScore,
    required this.totalTasksCompleted,
    required this.overallVerificationRate,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      totalWorkers: json['totalWorkers'] ?? 0,
      averagePerformanceScore:
          (json['averagePerformanceScore'] as num?)?.toInt() ?? 0,
      totalTasksCompleted: json['totalTasksCompleted'] ?? 0,
      overallVerificationRate:
          (json['overallVerificationRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkers': totalWorkers,
      'averagePerformanceScore': averagePerformanceScore,
      'totalTasksCompleted': totalTasksCompleted,
      'overallVerificationRate': overallVerificationRate,
    };
  }
}

class WorkerPerformanceResponse {
  final List<WorkerPerformance> workers;
  final PerformanceSummary summary;

  WorkerPerformanceResponse({required this.workers, required this.summary});

  factory WorkerPerformanceResponse.fromJson(Map<String, dynamic> json) {
    return WorkerPerformanceResponse(
      workers:
          (json['workers'] as List<dynamic>?)
              ?.map(
                (e) => WorkerPerformance.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      summary: PerformanceSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Performance tiers for visual indicators
enum PerformanceTier {
  excellent, // 80-100
  good, // 50-79
  poor, // 0-49
}

/// Sort criteria for worker performance list
enum WorkerSortCriteria {
  scoreHighToLow,
  scoreLowToHigh,
  tasksHighToLow,
  tasksLowToHigh,
  nameAZ,
  nameZA,
}
