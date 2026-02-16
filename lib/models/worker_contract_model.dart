class WorkerContract {
  final String id;
  final String landId;
  final String invitationId;
  final String investorId;
  final String workerId;
  final String salaryType; // monthly, hourly, per_task
  final double salaryAmount;
  final DateTime contractStartDate;
  final DateTime contractEndDate;
  final String status;
  final String currentProposer; // investor, worker
  final String? message;
  final String? firstPaymentTransactionId;
  final DateTime? createdAt;

  // Populated relations
  final String? landName;
  final String? investorName;
  final String? investorEmail;
  final String? workerName;
  final String? workerEmail;
  final String? workerProfilePicture;

  WorkerContract({
    required this.id,
    required this.landId,
    required this.invitationId,
    required this.investorId,
    required this.workerId,
    this.salaryType = 'monthly',
    this.salaryAmount = 0.0,
    required this.contractStartDate,
    required this.contractEndDate,
    this.status = 'hiring_pending',
    this.currentProposer = 'investor',
    this.message,
    this.firstPaymentTransactionId,
    this.createdAt,
    this.landName,
    this.investorName,
    this.investorEmail,
    this.workerName,
    this.workerEmail,
    this.workerProfilePicture,
  });

  factory WorkerContract.fromJson(Map<String, dynamic> json) {
    final land = json['land'];
    final investor = json['investor'];
    final worker = json['worker'];

    return WorkerContract(
      id: json['id'] ?? '',
      landId: json['land_id'] ?? '',
      invitationId: json['invitation_id'] ?? '',
      investorId: json['investor_id'] ?? '',
      workerId: json['worker_id'] ?? '',
      salaryType: json['salary_type'] ?? 'monthly',
      salaryAmount:
          double.tryParse(json['salary_amount']?.toString() ?? '0') ?? 0.0,
      contractStartDate:
          DateTime.tryParse(json['contract_start_date']?.toString() ?? '') ??
          DateTime.now(),
      contractEndDate:
          DateTime.tryParse(json['contract_end_date']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status'] ?? 'hiring_pending',
      currentProposer: json['current_proposer'] ?? 'investor',
      message: json['message'],
      firstPaymentTransactionId: json['first_payment_transaction_id'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      landName: land?['name'],
      investorName: investor?['profile']?['name'] ?? investor?['email'],
      investorEmail: investor?['email'],
      workerName: worker?['profile']?['name'] ?? worker?['email'],
      workerEmail: worker?['email'],
      workerProfilePicture: worker?['profile']?['picture'],
    );
  }

  // Status helpers
  bool get isHiringPending => status == 'hiring_pending';
  bool get isNegotiationPending => status == 'negotiation_pending';
  bool get isNegotiationCountered => status == 'negotiation_countered';
  bool get isHiringDeclined => status == 'hiring_declined';
  bool get isPaymentPending => status == 'payment_pending';
  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
  bool get isTerminated => status == 'terminated';
  bool get isExpired => status == 'expired';

  bool get isInNegotiation =>
      isHiringPending || isNegotiationPending || isNegotiationCountered;

  bool get needsWorkerAction =>
      (isHiringPending && currentProposer == 'investor') ||
      (isNegotiationCountered && currentProposer == 'investor');

  bool get needsInvestorAction =>
      isNegotiationPending ||
      isPaymentPending ||
      (isNegotiationCountered && currentProposer == 'worker');

  String get salaryTypeLabel {
    switch (salaryType) {
      case 'monthly':
        return '/month';
      case 'hourly':
        return '/hour';
      case 'per_task':
        return '/task';
      default:
        return '';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'hiring_pending':
        return 'Pending';
      case 'negotiation_pending':
        return 'Negotiating';
      case 'negotiation_countered':
        return 'Counter-offer';
      case 'hiring_declined':
        return 'Declined';
      case 'payment_pending':
        return 'Awaiting Payment';
      case 'active':
        return 'Active';
      case 'suspended':
        return 'Suspended';
      case 'terminated':
        return 'Terminated';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }
}
