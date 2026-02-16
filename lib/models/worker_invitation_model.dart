class WorkerInvitation {
  final String id;
  final String landId;
  final String farmerId;
  final String workerId;
  final String
  status; // invitation_pending, invitation_approved, invitation_declined, expired
  final String? message;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  // Populated relations
  final String? landName;
  final String? farmerName;
  final String? farmerEmail;
  final String? workerName;
  final String? workerEmail;
  final String? workerProfilePicture;

  WorkerInvitation({
    required this.id,
    required this.landId,
    required this.farmerId,
    required this.workerId,
    this.status = 'invitation_pending',
    this.message,
    this.expiresAt,
    this.createdAt,
    this.landName,
    this.farmerName,
    this.farmerEmail,
    this.workerName,
    this.workerEmail,
    this.workerProfilePicture,
  });

  factory WorkerInvitation.fromJson(Map<String, dynamic> json) {
    final land = json['land'];
    final farmer = json['farmer'];
    final worker = json['worker'];

    return WorkerInvitation(
      id: json['id'] ?? '',
      landId: json['land_id'] ?? '',
      farmerId: json['farmer_id'] ?? '',
      workerId: json['worker_id'] ?? '',
      status: json['status'] ?? 'invitation_pending',
      message: json['message'],
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      landName: land?['name'],
      farmerName: farmer?['profile']?['name'] ?? farmer?['email'],
      farmerEmail: farmer?['email'],
      workerName: worker?['profile']?['name'] ?? worker?['email'],
      workerEmail: worker?['email'],
      workerProfilePicture: worker?['profile']?['picture'],
    );
  }

  bool get isPending => status == 'invitation_pending';
  bool get isApproved => status == 'invitation_approved';
  bool get isDeclined => status == 'invitation_declined';
  bool get isExpired => status == 'expired';
}
