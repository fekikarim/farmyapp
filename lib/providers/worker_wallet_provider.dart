import 'package:flutter/material.dart';
import '../services/worker_wallet_service.dart';

class WorkerWalletProvider with ChangeNotifier {
  final WorkerWalletService _service = WorkerWalletService();

  bool _isLoadingOverview = false;
  bool get isLoadingOverview => _isLoadingOverview;

  bool _isLoadingTransactions = false;
  bool get isLoadingTransactions => _isLoadingTransactions;

  bool _isWithdrawing = false;
  bool get isWithdrawing => _isWithdrawing;

  String? _error;
  String? get error => _error;

  String? _overviewError;
  String? get overviewError => _overviewError;

  String? _transactionsError;
  String? get transactionsError => _transactionsError;

  String? _earningsError;
  String? get earningsError => _earningsError;

  Map<String, dynamic>? _overviewData;
  Map<String, dynamic>? get overviewData => _overviewData;

  List<dynamic> _transactions = [];
  List<dynamic> get transactions => _transactions;

  List<dynamic> _taskEarnings = [];
  List<dynamic> get taskEarnings => _taskEarnings;

  String _friendlyError(Object error) {
    final raw = error
        .toString()
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .trim();
    final lower = raw.toLowerCase();

    if (lower.contains('socketexception') ||
        lower.contains('connection failed')) {
      return 'Unable to reach Farmy right now. Check your connection and try again.';
    }
    if (lower.contains('unknown column') ||
        lower.contains('field list') ||
        lower.contains('sql')) {
      return 'Wallet data is temporarily unavailable. Please try again in a moment.';
    }

    return raw.isEmpty ? 'Something went wrong. Please try again.' : raw;
  }

  Future<void> fetchOverview() async {
    _isLoadingOverview = true;
    _overviewError = null;
    _error = null;
    notifyListeners();

    try {
      _overviewData = await _service.getWalletOverview();
    } catch (e) {
      _overviewError = _friendlyError(e);
      _error = _overviewError;
    } finally {
      _isLoadingOverview = false;
      notifyListeners();
    }
  }

  Future<void> fetchTransactions({String? type}) async {
    _isLoadingTransactions = true;
    _transactionsError = null;
    notifyListeners();

    try {
      final result = await _service.getTransactionHistory(type: type);
      _transactions = result['transactions'] ?? [];
    } catch (e) {
      _transactionsError = _friendlyError(e);
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  Future<void> fetchTaskEarnings() async {
    _isLoadingTransactions = true;
    _earningsError = null;
    notifyListeners();

    try {
      final result = await _service.getTaskEarnings();
      _taskEarnings = result['transactions'] ?? [];
    } catch (e) {
      _earningsError = _friendlyError(e);
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  Future<bool> requestWithdrawal(double amount) async {
    _isWithdrawing = true;
    _error = null;
    notifyListeners();

    try {
      await _service.requestWithdrawal(amount);
      await fetchOverview(); // Refresh balances
      await fetchTransactions(); // Refresh list
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _isWithdrawing = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _overviewError = null;
    _transactionsError = null;
    _earningsError = null;
    notifyListeners();
  }
}
