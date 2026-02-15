class FarmTask {
  final String id;
  final String landId;
  final String? assignedTo;
  final String createdBy;
  final String title;
  final String? description;
  final String type; // water, harvest, feed, install, verify, maintenance
  final String status; // open, assigned, in_progress, completed, verified
  final double reward;
  final int timeRequiredMinutes;
  final String? proofImageUrl;
  final String? proofVideoUrl;
  final Map<String, dynamic>? proofGps;
  final DateTime? completedAt;
  final DateTime? createdAt;

  // Populated from relations
  final String? assigneeName;
  final String? assigneeEmail;
  final String? creatorName;
  final String? landName;

  FarmTask({
    required this.id,
    required this.landId,
    this.assignedTo,
    required this.createdBy,
    required this.title,
    this.description,
    this.type = 'maintenance',
    this.status = 'open',
    this.reward = 0.0,
    this.timeRequiredMinutes = 30,
    this.proofImageUrl,
    this.proofVideoUrl,
    this.proofGps,
    this.completedAt,
    this.createdAt,
    this.assigneeName,
    this.assigneeEmail,
    this.creatorName,
    this.landName,
  });

  factory FarmTask.fromJson(Map<String, dynamic> json) {
    final assignee = json['assignee'];
    final creator = json['creator'];
    final land = json['land'];
    return FarmTask(
      id: json['id'] ?? '',
      landId: json['land_id'] ?? '',
      assignedTo: json['assigned_to'],
      createdBy: json['created_by'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'maintenance',
      status: json['status'] ?? 'open',
      reward: double.tryParse(json['reward']?.toString() ?? '0') ?? 0.0,
      timeRequiredMinutes: json['time_required_minutes'] ?? 30,
      proofImageUrl: json['proof_image_url'],
      proofVideoUrl: json['proof_video_url'],
      proofGps: json['proof_gps'],
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      assigneeName: assignee?['profile']?['name'] ?? assignee?['email'],
      assigneeEmail: assignee?['email'],
      creatorName: creator?['profile']?['name'] ?? creator?['email'],
      landName: land?['name'],
    );
  }

  bool get isOpen => status == 'open';
  bool get isAssigned => status == 'assigned';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isVerified => status == 'verified';

  String get typeIcon {
    switch (type) {
      case 'water':
        return '💧';
      case 'harvest':
        return '🌾';
      case 'feed':
        return '🐄';
      case 'install':
        return '🏗️';
      case 'verify':
        return '✅';
      case 'maintenance':
        return '🔧';
      default:
        return '📋';
    }
  }

  String get typeLabel {
    switch (type) {
      case 'water':
        return 'Water Vegetation';
      case 'harvest':
        return 'Harvest Products';
      case 'feed':
        return 'Feed Animals';
      case 'install':
        return 'Install Structure';
      case 'verify':
        return 'Verify Placement';
      case 'maintenance':
        return 'Maintenance';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'open':
        return 'Open';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'verified':
        return 'Verified';
      default:
        return status;
    }
  }
}
