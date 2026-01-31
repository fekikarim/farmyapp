import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasRefreshToken = await AuthService.getAccessToken() != null; // Simple check if we were logged in
      if (hasRefreshToken) {
        // Try to refresh tokens first
        final refreshSuccess = await AuthService.refreshTokens();
        if (refreshSuccess) {
          // Sync profile from server to ensure latest data (role, name, etc.)
          final userProfile = await AuthService.fetchProfile();
          if (userProfile != null) {
            _user = userProfile;
          } else {
            // If profile fetch fails but refresh succeeded, try to use local data as fallback
            _user = await AuthService.getUser();
          }
        } else {
          // If refresh fails, session is truly dead
          await AuthService.logout();
        }
      }
    } catch (e) {
      print('Auto Login Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);
      if (response != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return null; // Success
      }
      return 'Login failed';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.register(email, password);
      if (response != null) {
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return null; // Success
      }
      return 'Registration failed';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    final response = await AuthService.signInWithGoogle();
    if (response != null) {
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithGithub() async {
    _isLoading = true;
    notifyListeners();

    final response = await AuthService.signInWithGithub();
    if (response != null) {
      _user = response.user;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
