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
    return UserProfile(
      username: json['username'],
      name: json['name'],
      picture: json['picture'],
      coverImage: json['cover_image'],
      dob: json['dob'],
      country: json['country'],
      city: json['city'],
      timezone: json['timezone'],
      preferredLanguage: json['preferred_language'],
      headline: json['headline'],
      bio: json['bio'],
      linkedin: json['portfolio_links']?['linkedin'],
      website: json['portfolio_links']?['website'],
      farmPage: json['portfolio_links']?['farm_page'],
      businessName: json['farmer_details']?['business_name'],
      farmLocations: (json['farmer_details']?['farm_locations'] as List?)
          ?.map((e) => e as String)
          .toList(),
      productionTypes: (json['farmer_details']?['production_types'] as List?)
          ?.map((e) => e as String)
          .toList(),
      workforceSize: json['farmer_details']?['workforce_size'],
      preferredHiringTypes:
          (json['farmer_details']?['preferred_hiring_types'] as List?)
              ?.map((e) => e as String)
              .toList(),
      investmentFocus: (json['investor_details']?['investment_focus'] as List?)
          ?.map((e) => e as String)
          .toList(),
      budgetRange: json['investor_details']?['budget_range'],
      riskProfile: json['investor_details']?['risk_profile'],
      preferredRegions:
          (json['investor_details']?['preferred_regions'] as List?)
              ?.map((e) => e as String)
              .toList(),
      involvementLevel: json['investor_details']?['involvement_level'],
      discoverable: json['privacy_settings']?['discoverable'],
      showContactInfo: json['privacy_settings']?['show_contact_info'],
      completenessScore: json['completeness_score'],
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
  });

  // Backwards compatibility getters
  String? get name => profile?.name;
  String? get profilePicture => profile?.picture;
  String? get username => profile?.username;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
      isVerified: json['is_verified'] ?? false,
      isBanned: json['is_banned'] ?? false,
      isTwoFactorEnabled: json['is_two_factor_enabled'] ?? false,
      authProvider: json['auth_provider'] ?? 'email',
      credits: (double.tryParse(json['credits']?.toString() ?? '0.0') ?? 0.0),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      rentedLandsCount: json['rentedLandsCount'] != null
          ? int.tryParse(json['rentedLandsCount'].toString())
          : null,
      currentSubscriptionId: json['current_subscription_id'],
      subscriptionStatus: json['subscription_status'],
      creditsBalance:
          (double.tryParse(json['credits_balance']?.toString() ?? '0.0') ??
          0.0),
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
