class WorkerProfile {
  final String id;
  final String userId;
  final List<String> skills;
  final String? bio;
  final double hourlyRate;
  final String verificationStatus; // pending, verified, rejected
  final double rating;
  final int completedTasks;
  final double onTimeRate;
  final int disputeCount;
  final String availability; // available, busy, unavailable
  final String? userName;
  final String? userEmail;
  final String? userProfilePicture;
  final DateTime? createdAt;

  // New extended fields
  final List<String> certifications;
  final int? yearsOfExperience;
  final List<String> preferredTasks;
  final String? availabilityCalendar;
  final List<String> languagesSpoken;
  final Map<String, dynamic>? expectedRateRange;

  WorkerProfile({
    required this.id,
    required this.userId,
    this.skills = const [],
    this.bio,
    this.hourlyRate = 0.0,
    this.verificationStatus = 'pending',
    this.rating = 0.0,
    this.completedTasks = 0,
    this.onTimeRate = 0.0,
    this.disputeCount = 0,
    this.availability = 'available',
    this.userName,
    this.userEmail,
    this.userProfilePicture,
    this.createdAt,
    this.certifications = const [],
    this.yearsOfExperience,
    this.preferredTasks = const [],
    this.availabilityCalendar,
    this.languagesSpoken = const [],
    this.expectedRateRange,
  });

  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return WorkerProfile(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      bio: json['bio'],
      hourlyRate:
          double.tryParse(json['hourly_rate']?.toString() ?? '0') ?? 0.0,
      verificationStatus: json['verification_status'] ?? 'pending',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      completedTasks: json['completed_tasks'] ?? 0,
      onTimeRate:
          double.tryParse(json['on_time_rate']?.toString() ?? '0') ?? 0.0,
      disputeCount: json['dispute_count'] ?? 0,
      availability: json['availability'] ?? 'available',
      userName: user?['profile']?['name'] ?? user?['email'],
      userEmail: user?['email'],
      userProfilePicture: user?['profile']?['picture'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : [],
      yearsOfExperience: json['years_of_experience'],
      preferredTasks: json['preferred_tasks'] != null
          ? List<String>.from(json['preferred_tasks'])
          : [],
      availabilityCalendar: json['availability_calendar'],
      languagesSpoken: json['languages_spoken'] != null
          ? List<String>.from(json['languages_spoken'])
          : [],
      expectedRateRange: json['expected_rate_range'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skills': skills,
      'bio': bio,
      'hourly_rate': hourlyRate,
      'availability': availability,
      'certifications': certifications,
      'years_of_experience': yearsOfExperience,
      'preferred_tasks': preferredTasks,
      'availability_calendar': availabilityCalendar,
      'languages_spoken': languagesSpoken,
      if (expectedRateRange != null) 'expected_rate_range': expectedRateRange,
    };
  }

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';

  WorkerProfile copyWith({
    String? id,
    String? userId,
    List<String>? skills,
    String? bio,
    double? hourlyRate,
    String? verificationStatus,
    double? rating,
    int? completedTasks,
    double? onTimeRate,
    int? disputeCount,
    String? availability,
    String? userName,
    String? userEmail,
    String? userProfilePicture,
    DateTime? createdAt,
  }) {
    return WorkerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rating: rating ?? this.rating,
      completedTasks: completedTasks ?? this.completedTasks,
      onTimeRate: onTimeRate ?? this.onTimeRate,
      disputeCount: disputeCount ?? this.disputeCount,
      availability: availability ?? this.availability,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userProfilePicture: userProfilePicture ?? this.userProfilePicture,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
