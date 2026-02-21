class ProofRequest {
  final String id;
  final String investorId;
  final String farmerId;
  final String? landId;
  final String status; // pending, verified, rejected, expired
  final String? aiReasoning;
  final DateTime expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Populated relations
  final String? investorName;
  final String? farmerName;
  final String? landName;

  ProofRequest({
    required this.id,
    required this.investorId,
    required this.farmerId,
    this.landId,
    required this.status,
    this.aiReasoning,
    required this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.investorName,
    this.farmerName,
    this.landName,
  });

  factory ProofRequest.fromJson(Map<String, dynamic> json) {
    return ProofRequest(
      id: json['id'] ?? '',
      investorId: json['investor_id'] ?? '',
      farmerId: json['farmer_id'] ?? '',
      landId: json['land_id'],
      status: json['status'] ?? 'pending',
      aiReasoning: json['ai_reasoning'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      investorName: json['investor']?['profile']?['name'] ?? json['investor']?['email'],
      farmerName: json['farmer']?['profile']?['name'] ?? json['farmer']?['email'],
      landName: json['land']?['name'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }
}
