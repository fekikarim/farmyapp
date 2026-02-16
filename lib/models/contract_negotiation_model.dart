class ContractNegotiation {
  final String id;
  final String contractId;
  final String senderId;
  final double? proposedSalaryAmount;
  final String comment;
  final DateTime? createdAt;

  // Populated
  final String? senderName;
  final String? senderEmail;
  final String? senderProfilePicture;

  ContractNegotiation({
    required this.id,
    required this.contractId,
    required this.senderId,
    this.proposedSalaryAmount,
    required this.comment,
    this.createdAt,
    this.senderName,
    this.senderEmail,
    this.senderProfilePicture,
  });

  factory ContractNegotiation.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    return ContractNegotiation(
      id: json['id'] ?? '',
      contractId: json['contract_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      proposedSalaryAmount: json['proposed_salary_amount'] != null
          ? double.tryParse(json['proposed_salary_amount'].toString())
          : null,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      senderName: sender?['profile']?['name'] ?? sender?['email'],
      senderEmail: sender?['email'],
      senderProfilePicture: sender?['profile']?['picture'],
    );
  }
}
