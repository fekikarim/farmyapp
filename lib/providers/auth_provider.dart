import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitializing = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
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

    _isInitializing = false;
    _isLoading = false;
    notifyListeners();
  }

  /// Public method to refresh user data from server (e.g., after KYC)
  Future<void> refreshUser() async {
    try {
      final userProfile = await AuthService.fetchProfile();
      if (userProfile != null) {
        _user = userProfile;
        notifyListeners();
      }
    } catch (e) {
      print('RefreshUser Error: $e');
    }
  }

  String? _tempUserId; // For 2FA verification
  String? get tempUserId => _tempUserId;

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);
      if (response != null) {
        if (response.require2fa) {
          _tempUserId = response.userId;
          _isLoading = false;
          notifyListeners();
          return 'requires_2fa';
        }

        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return null; // Success
      }
      _isLoading = false;
      notifyListeners();
      return 'Login failed';
    } catch (e) {
      print('AuthProvider caught error: $e');
      _isLoading = false;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return errorMessage;
    }
  }

  Future<String?> verify2faLogin(String code) async {
    if (_tempUserId == null) return 'Session expired';
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.verify2faLogin(_tempUserId!, code);
      if (response != null) {
        _user = response.user;
        _tempUserId = null;
        _isLoading = false;
        notifyListeners();
        return null; // Success
      }
      return 'Verification failed';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<Map<String, dynamic>?> setup2fa() async {
    _isLoading = true;
    notifyListeners();
    final result = await AuthService.setup2FA();
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<String?> confirm2fa(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await AuthService.verifyAndEnable2FA(code);
      if (success) {
        // Refresh profile to get updated isTwoFactorEnabled
        _user = await AuthService.fetchProfile();
        _isLoading = false;
        notifyListeners();
        return null;
      }
      _isLoading = false;
      notifyListeners();
      return 'Invalid code';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> disable2fa(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await AuthService.disable2FA(code);
      if (success) {
        _user = await AuthService.fetchProfile();
        _isLoading = false;
        notifyListeners();
        return null;
      }
      _isLoading = false;
      notifyListeners();
      return 'Invalid code';
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

  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.signInWithGoogle();
      if (response != null) {
        if (response.require2fa) {
          _tempUserId = response.userId;
          _isLoading = false;
          notifyListeners();
          return 'requires_2fa';
        }

        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return null; // Success
      }
      _isLoading = false;
      notifyListeners();
      return 'Google sign-in failed';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> signInWithGithub() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.signInWithGithub();
      if (response != null) {
        if (response.require2fa) {
          _tempUserId = response.userId;
          _isLoading = false;
          notifyListeners();
          return 'requires_2fa';
        }

        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return null; // Success
      }
      _isLoading = false;
      notifyListeners();
      return 'GitHub sign-in failed';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> resendVerificationCode() async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();
    
    final success = await AuthService.resendVerificationCode(_user!.email);
    
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<String?> verifyEmail(String code) async {
    if (_user == null) return 'No user found';
    
    _isLoading = true;
    notifyListeners();

    try {
      final success = await AuthService.verifyEmail(_user!.email, code);
      if (success) {
        // Sync profile to get is_verified: true
        final updatedUser = await AuthService.fetchProfile();
        if (updatedUser != null) {
          _user = updatedUser;
        }
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Invalid or expired verification code';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await AuthService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return success ? null : 'Failed to send reset code. Please check your email.';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<String?> resetPassword(String email, String code, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await AuthService.resetPassword(email, code, newPassword);
      _isLoading = false;
      notifyListeners();
      return success ? null : 'Invalid code or failed to reset password.';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }


  Future<String?> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await AuthService.changePassword(oldPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return success ? null : 'Failed to change password. Please verify your old password.';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}
