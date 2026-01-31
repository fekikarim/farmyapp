import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';

class AuthService {
  static final String _baseUrl = dotenv.get('API_BASE_URL', fallback: 'http://localhost:3001');
  static const _storage = FlutterSecureStorage();
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '207350526659-uc61dhrc5htldf5q7dq5293ac9v75cbt.apps.googleusercontent.com',
  );

  // Persistence keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // --- Auth Actions ---

  static Future<AuthResponse?> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveAuthData(authResponse);
        return authResponse;
      }
      return null;
    } catch (e) {
      print('Register Error: $e');
      return null;
    }
  }

  static Future<AuthResponse?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveAuthData(authResponse);
        return authResponse;
      }
      return null;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await _saveAuthData(authResponse);
        return authResponse;
      }
      return null;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/api/v1/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      } catch (e) {
        print('Logout API Error: $e');
      }
    }
    await _storage.deleteAll();
    await _googleSignIn.signOut();
  }

  // --- Token Management ---

  static Future<void> _saveAuthData(AuthResponse response) async {
    await _storage.write(key: _accessTokenKey, value: response.tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: response.tokens.refreshToken);
    await _storage.write(key: _userKey, value: jsonEncode(response.user.toMap()));
  }

  static Future<User?> getUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData == null) return null;
    try {
      return User.fromJson(jsonDecode(userData));
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);

  static Future<bool> refreshTokens() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final tokens = AuthTokens.fromJson(data);
        await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
        await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
        return true;
      }
    } catch (e) {
      print('Token Refresh Error: $e');
    }
    return false;
  }
}
