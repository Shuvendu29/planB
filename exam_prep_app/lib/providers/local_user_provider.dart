import 'package:flutter/material.dart';
import '../data/local_storage.dart';

/// Local user provider for testing without Firebase
class LocalUserProvider with ChangeNotifier {
  final LocalStorage _storage = localStorage;
  
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  List<Map<String, dynamic>> get transactions => _transactions;
  int get points => _user?['points'] ?? 0;
  bool get isLoading => _isLoading;

  /// Load user by ID
  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    _user = _storage.getUser(uid);
    _transactions = _storage.getUserTransactions(uid);
    
    _isLoading = false;
    notifyListeners();
  }

  /// Load current user from storage
  Future<void> loadCurrentUser() async {
    final userId = _storage.currentUserId;
    if (userId != null) {
      await loadUser(userId);
    }
  }

  /// Top up points (local testing)
  Future<void> topUp(int rupees) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    int pointsToAdd = rupees;
    bool isFirstTopup = !(_user!['firstTopup'] ?? false);

    if (isFirstTopup) {
      pointsToAdd += (rupees * 0.05).toInt(); // 5% extra
    }

    // Update user points
    final newPoints = (_user!['points'] ?? 0) + pointsToAdd;
    _storage.updateUser(_user!['uid'], {
      'points': newPoints,
      'firstTopup': true,
    });
    _user!['points'] = newPoints;
    _user!['firstTopup'] = true;

    // Record transaction
    final tx = {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'userId': _user!['uid'],
      'amount': rupees,
      'pointsAdded': pointsToAdd,
      'type': 'topup',
      'timestamp': DateTime.now().toIso8601String(),
    };
    _storage.addUserTransaction(tx);
    _transactions.insert(0, tx);

    _isLoading = false;
    notifyListeners();
  }

  /// Spend points
  Future<bool> spendPoints(int points) async {
    if (_user == null || (_user!['points'] ?? 0) < points) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final newPoints = (_user!['points'] ?? 0) - points;
    _storage.updateUser(_user!['uid'], {'points': newPoints});
    _user!['points'] = newPoints;

    // Record transaction
    final tx = {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'userId': _user!['uid'],
      'amount': -points,
      'pointsAdded': -points,
      'type': 'spend',
      'timestamp': DateTime.now().toIso8601String(),
    };
    _storage.addUserTransaction(tx);
    _transactions.insert(0, tx);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Refresh user data
  Future<void> refresh() async {
    if (_user != null) {
      await loadUser(_user!['uid']);
    }
  }
}