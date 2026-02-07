import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';

class AuthService {
  static final String _baseUrl = dotenv.get(
    'API_BASE_URL',
    fallback: 'http://192.168.1.21:3001',
  );
  static const _storage = FlutterSecureStorage();

  static GoogleSignIn? get _googleSignInInstance {
    if (kIsWeb)
      return GoogleSignIn(
        serverClientId:
            '207350526659-uc61dhrc5htldf5q7dq5293ac9v75cbt.apps.googleusercontent.com',
      );
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return GoogleSignIn(
          serverClientId:
              '207350526659-uc61dhrc5htldf5q7dq5293ac9v75cbt.apps.googleusercontent.com',
        );
      }
    } catch (_) {}
    return null;
  }

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
        if (!authResponse.require2fa) {
          await _saveAuthData(authResponse);
        }
        return authResponse;
      } else {
        final body = jsonDecode(response.body);
        throw Exception(
          body['message'] ?? body['error'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Server connection failed. Please check your internet.');
      }
      print('Register Error: $e');
      rethrow;
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
        if (!authResponse.require2fa) {
          await _saveAuthData(authResponse);
        }
        return authResponse;
      } else {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? body['error'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Server connection failed. Please check your internet.');
      }
      print('Login Error: $e');
      rethrow;
    }
  }

  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      String? idToken;

      if (!kIsWeb && Platform.isWindows) {
        // Windows Desktop Support via Polling Strategy
        final requestId = const Uuid().v4();
        final url = Uri.parse(
          '$_baseUrl/api/v1/auth/google/login?state=$requestId',
        );

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          return null;
        }

        // Poll for result (timeout 2 minutes)
        for (int i = 0; i < 120; i++) {
          await Future.delayed(const Duration(seconds: 1));

          try {
            final checkResponse = await http.get(
              Uri.parse(
                '$_baseUrl/api/v1/auth/google/status?requestId=$requestId',
              ),
            );

            if (checkResponse.statusCode == 200) {
              final data = jsonDecode(checkResponse.body);

              if (data['success'] == true) {
                // Login successful!
                final authResponse = AuthResponse.fromJson(data);
                if (!authResponse.require2fa) {
                  await _saveAuthData(authResponse);
                }
                return authResponse;
              } else if (data['waiting'] == true) {
                // Still waiting...
                continue;
              }
            }
          } catch (_) {
            // Ignore network errors during polling
          }
        }
        return null; // Timeout
      } else {
        // Mobile & Web Support via standard ID Token
        final googleSignIn = _googleSignInInstance;
        if (googleSignIn == null) return null;

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        idToken = googleAuth.idToken;
      }

      if (idToken == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        if (!authResponse.require2fa) {
          await _saveAuthData(authResponse);
        }
        return authResponse;
      }
      return null;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  static Future<AuthResponse?> signInWithGithub() async {
    try {
      final String clientId = dotenv.get('GITHUB_CLIENT_ID');
      const String redirectUri = 'farmyapp://auth';

      // 1. Redirect to GitHub OAuth
      final url = Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'user:email',
      });

      final result = await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: 'farmyapp',
      );

      // 2. Extract code
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) return null;

      // 3. Send CODE to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/github'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        if (!authResponse.require2fa) {
          await _saveAuthData(authResponse);
        }
        return authResponse;
      }
      return null;
    } catch (e) {
      print('GitHub Sign-In Error: $e');
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
    await _googleSignInInstance?.signOut();
  }

  static Future<bool> resendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Resend Verification Error: $e');
      return false;
    }
  }

  static Future<bool> verifyEmail(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code.trim()}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final body = jsonDecode(response.body);
        print('Verify Email Error: ${body['message']}');
        return false;
      }
    } catch (e) {
      print('Verify Email Exception: $e');
      return false;
    }
  }

  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Forgot Password Error: $e');
      return false;
    }
  }

  static Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code.trim(),
          'newPassword': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Reset Password Error: $e');
      return false;
    }
  }

  static Future<bool> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/auth/change-password'),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Change Password Error: $e');
      return false;
    }
  }

  // --- 2FA Methods ---

  static Future<AuthResponse?> verify2faLogin(
    String userId,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/login/verify-2fa'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'token': token}),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        if (authResponse.tokens != null) {
          if (!authResponse.require2fa) {
            await _saveAuthData(authResponse);
          }
        }
        return authResponse;
      } else {
        final body = jsonDecode(response.body);
        throw Exception(
          body['message'] ?? body['error'] ?? '2FA verification failed',
        );
      }
    } catch (e) {
      print('2FA Verify Login Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> setup2FA() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/auth/2fa/setup'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Setup 2FA Error: $e');
      return null;
    }
  }

  static Future<bool> verifyAndEnable2FA(String token) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/auth/2fa/verify'),
        body: jsonEncode({'token': token}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Enable 2FA Error: $e');
      return false;
    }
  }

  static Future<bool> disable2FA(String token) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/auth/2fa/disable'),
        body: jsonEncode({'token': token}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Disable 2FA Error: $e');
      return false;
    }
  }

  // --- Token Management ---

  static Future<void> _saveAuthData(AuthResponse response) async {
    if (response.tokens != null) {
      await _storage.write(
        key: _accessTokenKey,
        value: response.tokens!.accessToken,
      );
      await _storage.write(
        key: _refreshTokenKey,
        value: response.tokens!.refreshToken,
      );
    }
    if (response.user != null) {
      await _storage.write(
        key: _userKey,
        value: jsonEncode(response.user!.toMap()),
      );
    }
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

  static Future<String?> getAccessToken() async =>
      await _storage.read(key: _accessTokenKey);

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

  // --- Authenticated Requests ---

  static Future<User?> fetchProfile() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/auth/me'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        print('Fetched Profile Data: $data');
        final user = User.fromJson(data);
        await _storage.write(key: _userKey, value: jsonEncode(user.toMap()));
        return user;
      }
    } catch (e) {
      print('Fetch Profile Error: $e');
    }
    return null;
  }

  static Future<User?> getUserById(String id) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        Uri.parse('$_baseUrl/api/v1/auth/users/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        return User.fromJson(data);
      }
    } catch (e) {
      print('Fetch UserById Error: $e');
    }
    return null;
  }

  static Future<http.Response> authenticatedRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    headers ??= {};
    print('AuthRequest: Getting token...');
    String? token = await getAccessToken();
    print('AuthRequest: Token retrieved: ${token != null}');
    if (token != null) headers['Authorization'] = 'Bearer $token';
    headers['Content-Type'] = 'application/json';

    try {
      http.Response response;
      if (method == 'POST') {
        response = await http.post(url, headers: headers, body: body);
      } else {
        response = await http.get(url, headers: headers);
      }
      print('AuthRequest: Received ${response.statusCode}');

      if (response.statusCode == 401) {
        final refreshed = await refreshTokens();
        if (refreshed) {
          token = await getAccessToken();
          headers['Authorization'] = 'Bearer $token';
          if (method == 'POST') {
            return await http.post(url, headers: headers, body: body);
          } else {
            return await http.get(url, headers: headers);
          }
        }
      }
      return response;
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        return http.Response(
          jsonEncode({'message': 'Server connection failed'}),
          503,
          headers: {'content-type': 'application/json'},
        );
      }
      rethrow;
    }
  }
}
