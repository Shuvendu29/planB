import 'package:flutter/material.dart';
import '../data/local_storage.dart';

/// Local authentication provider for testing without Firebase
/// Replace with Firebase Auth integration later
class LocalAuthProvider with ChangeNotifier {
  final LocalStorage _storage = localStorage;
  
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  LocalAuthProvider() {
    // Initialize sample data
    _storage.initSampleData();
    // Check for persisted session
    _checkSession();
  }

  void _checkSession() {
    final userId = _storage.currentUserId;
    if (userId != null) {
      _currentUser = _storage.getUser(userId);
      notifyListeners();
    }
  }

  /// Login with email and password (local testing)
  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Check credentials (demo: any password works)
      final user = _storage.getUserByEmail(email);
      
      if (user != null) {
        _storage.setCurrentUser(user['uid']);
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'User not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user (local testing)
  Future<bool> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Check if email exists
      if (_storage.getUserByEmail(email) != null) {
        _error = 'Email already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      final uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final user = {
        'uid': uid,
        'email': email,
        'name': name,
        'points': 5, // First login bonus
        'firstLogin': true,
        'firstTopup': false,
        'role': 'user',
      };
      
      _storage.createUser(user);
      _storage.setCurrentUser(uid);
      _currentUser = user;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _storage.setCurrentUser(null);
    _currentUser = null;
    notifyListeners();
  }

  /// Get current user role
  String get role => _currentUser?['role'] ?? 'user';

  /// Check if user is SME
  bool get isSME => role == 'sme';

  /// Check if user is Admin
  bool get isAdmin => role == 'admin';

  /// Demo login helpers
  Future<void> loginAsUser() async {
    await signInWithEmail('user@test.com', 'password');
  }

  Future<void> loginAsSME() async {
    await signInWithEmail('sme@test.com', 'password');
  }

  Future<void> loginAsAdmin() async {
    await signInWithEmail('admin@test.com', 'password');
  }
}