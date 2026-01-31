class User {
  final String id;
  final String email;
  final String role;
  final String? name;
  final String? profilePicture;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      name: json['profile']?['name'],
      profilePicture: json['profile']?['picture'],
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
  final User user;
  final AuthTokens tokens;

  AuthResponse({
    required this.user,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResponse(
      user: User.fromJson(data['user']),
      tokens: AuthTokens.fromJson(data),
    );
  }
}
