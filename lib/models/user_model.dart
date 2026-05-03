import 'dart:convert';

class UserProfile {
  final String? username;
  final String? name;
  final String? picture;
  final String? coverImage;
  final String? dob;
  final String? country;
  final String? city;
  final String? timezone;
  final String? preferredLanguage;
  final String? headline;
  final String? bio;

  // Portfolio
  final String? linkedin;
  final String? website;
  final String? farmPage;

  // Farmer Details
  final String? businessName;
  final List<String>? farmLocations;
  final List<String>? productionTypes;
  final String? workforceSize;
  final List<String>? preferredHiringTypes;

  // Investor Details
  final List<String>? investmentFocus;
  final String? budgetRange;
  final String? riskProfile;
  final List<String>? preferredRegions;
  final String? involvementLevel;

  // Privacy & score
  final bool? discoverable;
  final bool? showContactInfo;
  final int? completenessScore;

  UserProfile({
    this.username,
    this.name,
    this.picture,
    this.coverImage,
    this.dob,
    this.country,
    this.city,
    this.timezone,
    this.preferredLanguage,
    this.headline,
    this.bio,
    this.linkedin,
    this.website,
    this.farmPage,
    this.businessName,
    this.farmLocations,
    this.productionTypes,
    this.workforceSize,
    this.preferredHiringTypes,
    this.investmentFocus,
    this.budgetRange,
    this.riskProfile,
    this.preferredRegions,
    this.involvementLevel,
    this.discoverable,
    this.showContactInfo,
    this.completenessScore,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic value) => value == null ? null : value.toString();

    Map<String, dynamic>? asMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map)
        return value.map((key, value) => MapEntry(key.toString(), value));
      return null;
    }

    List<String>? asStringList(dynamic value) {
      if (value is! List) return null;
      return value
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    }

    bool? asBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return null;
    }

    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.round();
      return int.tryParse(value?.toString() ?? '');
    }

    final portfolioLinks = asMap(json['portfolio_links']);
    final farmerDetails = asMap(json['farmer_details']);
    final investorDetails = asMap(json['investor_details']);
    final privacySettings = asMap(json['privacy_settings']);

    return UserProfile(
      username: asString(json['username']),
      name: asString(json['name']),
      picture: asString(json['picture']),
      coverImage: asString(json['cover_image']),
      dob: asString(json['dob']),
      country: asString(json['country']),
      city: asString(json['city']),
      timezone: asString(json['timezone']),
      preferredLanguage: asString(json['preferred_language']),
      headline: asString(json['headline']),
      bio: asString(json['bio']),
      linkedin: asString(portfolioLinks?['linkedin']),
      website: asString(portfolioLinks?['website']),
      farmPage: asString(portfolioLinks?['farm_page']),
      businessName: asString(farmerDetails?['business_name']),
      farmLocations: asStringList(farmerDetails?['farm_locations']),
      productionTypes: asStringList(farmerDetails?['production_types']),
      workforceSize: asString(farmerDetails?['workforce_size']),
      preferredHiringTypes: asStringList(
        farmerDetails?['preferred_hiring_types'],
      ),
      investmentFocus: asStringList(investorDetails?['investment_focus']),
      budgetRange: asString(investorDetails?['budget_range']),
      riskProfile: asString(investorDetails?['risk_profile']),
      preferredRegions: asStringList(investorDetails?['preferred_regions']),
      involvementLevel: asString(investorDetails?['involvement_level']),
      discoverable: asBool(privacySettings?['discoverable']),
      showContactInfo: asBool(privacySettings?['show_contact_info']),
      completenessScore: asInt(json['completeness_score']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'picture': picture,
      'cover_image': coverImage,
      'dob': dob,
      'country': country,
      'city': city,
      'timezone': timezone,
      'preferred_language': preferredLanguage,
      'headline': headline,
      'bio': bio,
      'portfolio_links': {
        if (linkedin != null) 'linkedin': linkedin,
        if (website != null) 'website': website,
        if (farmPage != null) 'farm_page': farmPage,
      },
      'farmer_details': {
        if (businessName != null) 'business_name': businessName,
        if (farmLocations != null) 'farm_locations': farmLocations,
        if (productionTypes != null) 'production_types': productionTypes,
        if (workforceSize != null) 'workforce_size': workforceSize,
        if (preferredHiringTypes != null)
          'preferred_hiring_types': preferredHiringTypes,
      },
      'investor_details': {
        if (investmentFocus != null) 'investment_focus': investmentFocus,
        if (budgetRange != null) 'budget_range': budgetRange,
        if (riskProfile != null) 'risk_profile': riskProfile,
        if (preferredRegions != null) 'preferred_regions': preferredRegions,
        if (involvementLevel != null) 'involvement_level': involvementLevel,
      },
      'privacy_settings': {
        if (discoverable != null) 'discoverable': discoverable,
        if (showContactInfo != null) 'show_contact_info': showContactInfo,
      },
      'completeness_score': completenessScore,
    };
  }
}

class User {
  final String id;
  final String email;
  final String role;
  final String? phone;
  final UserProfile? profile;
  final bool isVerified;
  final bool isBanned;
  final bool isTwoFactorEnabled;
  final String authProvider;
  final double credits;
  final DateTime? createdAt;
  final int? rentedLandsCount;
  final String? currentSubscriptionId;
  final String? subscriptionStatus;
  final double creditsBalance;
  final bool hasWorkerProfile;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.phone,
    this.profile,
    this.isVerified = false,
    this.isBanned = false,
    this.isTwoFactorEnabled = false,
    this.authProvider = 'email',
    this.credits = 0.0,
    this.createdAt,
    this.rentedLandsCount,
    this.currentSubscriptionId,
    this.subscriptionStatus,
    this.creditsBalance = 0.0,
    this.hasWorkerProfile = false,
  });

  // Backwards compatibility getters
  String? get name => profile?.name;
  String? get profilePicture => profile?.picture;
  String? get username => profile?.username;

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    Map<String, dynamic>? parseProfile(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is Map)
        return value.map((key, value) => MapEntry(key.toString(), value));
      if (value is String && value.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is Map<String, dynamic>) return decoded;
          if (decoded is Map)
            return decoded.map((key, value) => MapEntry(key.toString(), value));
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    bool parseBool(dynamic value, {bool fallback = false}) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return fallback;
    }

    final profileJson = parseProfile(json['profile']);

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      phone: json['phone']?.toString(),
      profile: profileJson != null ? UserProfile.fromJson(profileJson) : null,
      isVerified: parseBool(json['is_verified']),
      isBanned: parseBool(json['is_banned']),
      isTwoFactorEnabled: parseBool(json['is_two_factor_enabled']),
      authProvider: json['auth_provider'] ?? 'email',
      credits: (double.tryParse(json['credits']?.toString() ?? '0.0') ?? 0.0),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      rentedLandsCount: json['rentedLandsCount'] != null
          ? int.tryParse(json['rentedLandsCount'].toString())
          : null,
      currentSubscriptionId: json['current_subscription_id'],
      subscriptionStatus: json['subscription_status'],
      creditsBalance:
          (double.tryParse(json['credits_balance']?.toString() ?? '0.0') ??
          0.0),
      hasWorkerProfile: parseBool(json['has_worker_profile']),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? role,
    String? phone,
    UserProfile? profile,
    bool? isVerified,
    bool? isBanned,
    bool? isTwoFactorEnabled,
    String? authProvider,
    double? credits,
    String? currentSubscriptionId,
    String? subscriptionStatus,
    double? creditsBalance,
    bool? hasWorkerProfile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profile: profile ?? this.profile,
      isVerified: isVerified ?? this.isVerified,
      isBanned: isBanned ?? this.isBanned,
      isTwoFactorEnabled: isTwoFactorEnabled ?? this.isTwoFactorEnabled,
      authProvider: authProvider ?? this.authProvider,
      credits: credits ?? this.credits,
      currentSubscriptionId:
          currentSubscriptionId ?? this.currentSubscriptionId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      creditsBalance: creditsBalance ?? this.creditsBalance,
      hasWorkerProfile: hasWorkerProfile ?? this.hasWorkerProfile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      if (phone != null) 'phone': phone,
      if (profile != null) 'profile': profile!.toJson(),
      'is_verified': isVerified,
      'is_banned': isBanned,
      'is_two_factor_enabled': isTwoFactorEnabled,
      'auth_provider': authProvider,
      'credits': credits,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (rentedLandsCount != null) 'rentedLandsCount': rentedLandsCount,
      if (currentSubscriptionId != null)
        'current_subscription_id': currentSubscriptionId,
      if (subscriptionStatus != null) 'subscription_status': subscriptionStatus,
      'credits_balance': creditsBalance,
      'has_worker_profile': hasWorkerProfile,
    };
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}

class AuthResponse {
  final User? user;
  final AuthTokens? tokens;
  final bool require2fa;
  final String? userId;

  AuthResponse({this.user, this.tokens, this.require2fa = false, this.userId});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data['require2fa'] == true) {
      return AuthResponse(require2fa: true, userId: data['userId']);
    }
    return AuthResponse(
      user: User.fromJson(data['user']),
      tokens: AuthTokens.fromJson(data),
    );
  }
}
