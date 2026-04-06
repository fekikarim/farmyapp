import 'package:flutter/foundation.dart';

import '../data/about_us_repository.dart';
import '../models/about_us_models.dart';

class AboutUsProvider extends ChangeNotifier {
  AboutUsProvider({required this.repository});

  final AboutUsRepository repository;

  AboutUsContent? _content;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AboutUsContent? get content => _content;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized && _content != null) return;
    await _load();
  }

  Future<void> retry() async {
    await _load(force: true);
  }

  Future<void> refresh() async {
    await _load(isRefresh: true, force: true);
  }

  Future<void> _load({bool isRefresh = false, bool force = false}) async {
    if ((_isLoading || _isRefreshing) && !force) return;

    if (isRefresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }

    _errorMessage = null;
    notifyListeners();

    final start = DateTime.now();

    try {
      final fetched = await repository.fetchAboutContent();
      final elapsed = DateTime.now().difference(start);
      const minLoadingDuration = Duration(milliseconds: 650);
      if (elapsed < minLoadingDuration) {
        await Future.delayed(minLoadingDuration - elapsed);
      }

      _content = fetched;
      _isInitialized = true;
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Unable to load About Us right now. Please retry.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
