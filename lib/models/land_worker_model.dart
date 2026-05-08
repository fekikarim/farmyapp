enum HiringSource { invitation, jobApplication, manual }

class LandWorker {
  final String id;
  final String landId;
  final String workerId;
  final String assignedBy;
  final String role;
  final double salary;
  final String status; // active, inactive, suspended
  final HiringSource hiringSource;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? createdAt;

  // Populated from relations
  final String? workerName;
  final String? workerEmail;
  final String? workerProfilePicture;
  final String? workerAvailability;
  final String? assignerName;

  // Land info (when fetching worker's assigned lands)
  final String? landName;
  final String? landOwnerId;

  LandWorker({
    required this.id,
    required this.landId,
    required this.workerId,
    required this.assignedBy,
    this.role = 'general',
    this.salary = 0.0,
    this.status = 'active',
    this.hiringSource = HiringSource.manual,
    this.startedAt,
    this.endedAt,
    this.createdAt,
    this.workerName,
    this.workerEmail,
    this.workerProfilePicture,
    this.workerAvailability,
    this.assignerName,
    this.landName,
    this.landOwnerId,
  });

  factory LandWorker.fromJson(Map<String, dynamic> json) {
    final worker = json['worker'];
    final assigner = json['assigner'];
    final land = json['land'];

    HiringSource source = HiringSource.manual;
    final sourceStr = json['hiring_source'] ?? 'manual';
    if (sourceStr == 'invitation') {
      source = HiringSource.invitation;
    } else if (sourceStr == 'job_application') {
      source = HiringSource.jobApplication;
    }

    return LandWorker(
      id: json['id'] ?? '',
      landId: json['land_id'] ?? '',
      workerId: json['worker_id'] ?? '',
      assignedBy: json['assigned_by'] ?? '',
      role: json['role'] ?? 'general',
      salary: double.tryParse(json['salary']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'active',
      hiringSource: source,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'])
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      workerName: worker?['profile']?['name'] ?? worker?['email'],
      workerEmail: worker?['email'],
      workerProfilePicture: worker?['profile']?['picture'],
      workerAvailability: json['worker_availability'] ?? 'available',
      assignerName: assigner?['profile']?['name'] ?? assigner?['email'],
      landName: land?['name'],
      landOwnerId: land?['owner_id'],
    );
  }

  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
  bool get isInactive => status == 'inactive';
}
