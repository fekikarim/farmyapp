class User {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String? profilePicture;
  final bool isVerified;
  final bool isBanned;
  final bool isTwoFactorEnabled;
  final String authProvider;
  final double credits;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.profilePicture,
    this.isVerified = false,
    this.isBanned = false,
    this.isTwoFactorEnabled = false,
    this.authProvider = 'email',
    this.credits = 0.0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      name: json['profile']?['name'],
      profilePicture: json['profile']?['picture'],
      isVerified: json['is_verified'] ?? false,
      isBanned: json['is_banned'] ?? false,
      isTwoFactorEnabled: json['is_two_factor_enabled'] ?? false,
      authProvider: json['auth_provider'] ?? 'email',
      credits: double.tryParse(json['credits']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'profile': {
        'name': name,
        'picture': profilePicture,
      },
      'is_verified': isVerified,
      'is_banned': isBanned,
      'is_two_factor_enabled': isTwoFactorEnabled,
      'auth_provider': authProvider,
      'credits': credits,
    };
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

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

  AuthResponse({
    this.user,
    this.tokens,
    this.require2fa = false,
    this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data['require2fa'] == true) {
      return AuthResponse(
        require2fa: true,
        userId: data['userId'],
      );
    }
    return AuthResponse(
      user: User.fromJson(data['user']),
      tokens: AuthTokens.fromJson(data),
    );
  }
}
