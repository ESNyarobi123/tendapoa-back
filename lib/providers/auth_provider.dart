import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  bool get isAuthenticated => _user != null;
  bool get isMuhitaji => _user?.isMuhitaji ?? false;
  bool get isMfanyakazi => _user?.isMfanyakazi ?? false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Ensure storage is initialized first
      await _storageService.init();
      _user = await _storageService.getUser();
      
      // Also verify token exists (user data without token is invalid)
      final token = await _storageService.getToken();
      if (_user != null && token == null) {
        // User data exists but no token - clear invalid state
        _user = null;
        await _storageService.deleteUser();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider init error: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Wait for initialization to complete
  Future<void> waitForInit() async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _authService.login(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
    double? lat,
    double? lng,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
        lat: lat,
        lng: lng,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(
      {required String name, required String phone}) async {
    _setLoading(true);
    try {
      _user = await _authService.updateProfile(name: name, phone: phone);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    _setLoading(true);
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _isLoading = false;
    notifyListeners();
  }
}
