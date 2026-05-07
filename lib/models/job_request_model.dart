import 'land_model.dart';

enum JobRequestStatus { open, closed }

class JobRequest {
  final String id;
  final String farmerId;
  final String landId;
  final String title;
  final String description;
  final List<String>? requiredSkills;
  final String? duration;
  final String? taskType;
  final JobRequestStatus status;
  final double? salary;
  final Land? land;
  final int? matchScore; // For AI recommendation

  JobRequest({
    required this.id,
    required this.farmerId,
    required this.landId,
    required this.title,
    required this.description,
    this.requiredSkills,
    this.duration,
    this.taskType,
    required this.status,
    this.salary,
    this.land,
    this.matchScore,
  });

  factory JobRequest.fromJson(Map<String, dynamic> json) {
    return JobRequest(
      id: json['id'],
      farmerId: json['farmer_id'],
      landId: json['land_id'],
      title: json['title'],
      description: json['description'],
      requiredSkills: json['required_skills'] != null
          ? List<String>.from(json['required_skills'])
          : null,
      duration: json['duration'],
      taskType: json['task_type'],
      status: json['status'] == 'open' ? JobRequestStatus.open : JobRequestStatus.closed,
      salary: json['salary'] != null ? double.tryParse(json['salary'].toString()) : null,
      land: json['land'] != null ? Land.fromJson(json['land']) : null,
      matchScore: json['matchScore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'land_id': landId,
      'title': title,
      'description': description,
      'required_skills': requiredSkills,
      'duration': duration,
      'task_type': taskType,
      'salary': salary,
    };
  }
}
