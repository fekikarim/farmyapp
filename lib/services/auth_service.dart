import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:3001'; // Use localhost for iOS simulator

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '207350526659-uc61dhrc5htldf5q7dq5293ac9v75cbt.apps.googleusercontent.com',
  );

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) return null;

      // Send idToken to backend
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Backend Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
