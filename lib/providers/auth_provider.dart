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

    // Check for existing session
    final persistedUser = await AuthService.getUser();
    if (persistedUser != null) {
      final refreshSuccess = await AuthService.refreshTokens();
      if (refreshSuccess) {
        _user = persistedUser;
      } else {
        await AuthService.logout();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await AuthService.login(email, password);
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

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final response = await AuthService.register(email, password);
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

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
