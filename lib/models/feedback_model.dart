enum FeedbackCategory {
  bug,
  featureRequest,
  productReport,
  landReport,
  workerReport,
  paymentIssue,
  walletIssue,
  marketplaceIssue,
  abuse,
  general;

  String get displayName {
    switch (this) {
      case bug:
        return 'Bug Report';
      case featureRequest:
        return 'Feature Request';
      case productReport:
        return 'Product Report';
      case landReport:
        return 'Land Report';
      case workerReport:
        return 'Worker Report';
      case paymentIssue:
        return 'Payment Issue';
      case walletIssue:
        return 'Wallet Issue';
      case marketplaceIssue:
        return 'Marketplace Issue';
      case abuse:
        return 'Abuse/Inappropriate Content';
      case general:
        return 'General Feedback';
    }
  }

  String get backendValue {
    switch (this) {
      case bug:
        return 'bug';
      case featureRequest:
        return 'feature_request';
      case productReport:
        return 'product_report';
      case landReport:
        return 'land_report';
      case workerReport:
        return 'worker_report';
      case paymentIssue:
        return 'payment_issue';
      case walletIssue:
        return 'wallet_issue';
      case marketplaceIssue:
        return 'marketplace_issue';
      case abuse:
        return 'abuse';
      case general:
        return 'general';
    }
  }
}

enum FeedbackStatus {
  pending,
  inReview,
  resolved,
  rejected;

  String get displayName {
    switch (this) {
      case pending:
        return 'Pending';
      case inReview:
        return 'In Review';
      case resolved:
        return 'Resolved';
      case rejected:
        return 'Rejected';
    }
  }
}

enum FeedbackPriority {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case low:
        return 'Low';
      case medium:
        return 'Medium';
      case high:
        return 'High';
      case critical:
        return 'Critical';
    }
  }
}

class FeedbackModel {
  final String id;
  final String title;
  final String description;
  final FeedbackCategory category;
  final FeedbackStatus status;
  final FeedbackPriority priority;
  final String userId;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final String? adminNotes;
  final List<String>? attachments;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    required this.userId,
    this.relatedEntityId,
    this.relatedEntityType,
    this.adminNotes,
    this.attachments,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: FeedbackCategory.values.firstWhere(
        (e) => e.name == json['category'] || e.displayName == json['category'],
        orElse: () => FeedbackCategory.general,
      ),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.name == json['status'] || e.displayName == json['status'],
        orElse: () => FeedbackStatus.pending,
      ),
      priority: FeedbackPriority.values.firstWhere(
        (e) => e.name == json['priority'] || e.displayName == json['priority'],
        orElse: () => FeedbackPriority.medium,
      ),
      userId: json['user_id'],
      relatedEntityId: json['related_entity_id'],
      relatedEntityType: json['related_entity_type'],
      adminNotes: json['admin_notes'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category.backendValue,
      'priority': priority.name,
      'related_entity_id': relatedEntityId,
      'related_entity_type': relatedEntityType,
      'attachments': attachments,
    };
  }
}
