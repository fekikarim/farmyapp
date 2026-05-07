import 'job_request_model.dart';
import 'land_model.dart';

enum JobApplicationStatus { pending, approved, rejected, cancelled }

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final JobApplicationStatus status;
  final String? notes;
  final DateTime createdAt;
  final JobRequest? job;
  final Map<String, dynamic>? worker; // For farmer view

  JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.status,
    this.notes,
    required this.createdAt,
    this.job,
    this.worker,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      jobId: json['job_id'],
      workerId: json['worker_id'],
      status: _parseStatus(json['status']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      job: json['job'] != null ? JobRequest.fromJson(json['job']) : null,
      worker: json['worker'],
    );
  }

  static JobApplicationStatus _parseStatus(String status) {
    switch (status) {
      case 'approved':
        return JobApplicationStatus.approved;
      case 'rejected':
        return JobApplicationStatus.rejected;
      case 'cancelled':
        return JobApplicationStatus.cancelled;
      default:
        return JobApplicationStatus.pending;
    }
  }

  String get statusDisplay {
    switch (status) {
      case JobApplicationStatus.approved:
        return 'Approved';
      case JobApplicationStatus.rejected:
        return 'Rejected';
      case JobApplicationStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }
}
