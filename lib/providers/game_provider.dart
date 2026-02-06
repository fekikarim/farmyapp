import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider with ChangeNotifier {
  bool _shouldShowBubble = true;
  bool _isLoading = true;

  bool get shouldShowBubble => _shouldShowBubble;
  bool get isLoading => _isLoading;

  GameProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _shouldShowBubble = prefs.getBool('show_game_bubble') ?? true;
    } catch (e) {
      print('Error loading game settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setBubbleVisibility(bool visible) async {
    _shouldShowBubble = visible;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_game_bubble', visible);
    } catch (e) {
      print('Error saving game settings: $e');
    }
  }
}
