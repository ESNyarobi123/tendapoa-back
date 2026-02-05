import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<User> login(String email, String password) async {
    final response = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final user = User.fromJson(response.data!['user']);

      await _storage.saveToken(token);
      await _storage.saveUser(user);
      return user;
    } else {
      throw ApiException(response.message ?? 'Login failed');
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
    double? lat,
    double? lng,
  }) async {
    final response = await _api.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
        'phone': phone,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      },
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final user = User.fromJson(response.data!['user']);

      await _storage.saveToken(token);
      await _storage.saveUser(user);
      return user;
    } else {
      throw ApiException(response.message ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await _storage.clearAll();
    }
  }

  Future<User> getProfile() async {
    final response = await _api.get('/user');
    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!);
      await _storage.saveUser(user);
      return user;
    } else {
      throw ApiException('Failed to get profile');
    }
  }

  Future<User> updateProfile({
    required String name,
    required String phone,
    String? email,
  }) async {
    final response = await _api.post(
      '/user/update',
      body: {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
      },
    );

    if (response.success && response.data != null) {
      final user = User.fromJson(response.data!['data'] ?? response.data!);
      await _storage.saveUser(user);
      return user;
    } else {
      throw ApiException(response.message ?? 'Update failed');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _api.post(
      '/user/change-password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
    );

    if (!response.success) {
      throw ApiException(response.message ?? 'Password change failed');
    }
  }
}
