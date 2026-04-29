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
    // Step 1: Register kwanza
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

    if (!response.success || response.data == null) {
      throw ApiException(response.message ?? 'Registration failed');
    }

    // Step 2: Auto-login kupata token (kwa sababu register haipi token)
    return await login(email, password);
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

  // ─── FORGOT PASSWORD (OTP) ──────────────────────────────────────────

  /// Step 1: Send OTP to email
  Future<String> sendPasswordOtp(String email) async {
    final response = await _api.post(
      '/password/send-otp',
      body: {'email': email},
      requiresAuth: false,
    );
    if (response.success) {
      return response.data?['message'] ?? 'OTP sent';
    }
    throw ApiException(response.message ?? 'Failed to send OTP');
  }

  /// Step 2: Verify OTP → returns reset_token
  Future<String> verifyPasswordOtp(String email, String otp) async {
    final response = await _api.post(
      '/password/verify-otp',
      body: {'email': email, 'otp': otp},
      requiresAuth: false,
    );
    if (response.success && response.data?['reset_token'] != null) {
      return response.data!['reset_token'];
    }
    throw ApiException(response.message ?? 'Invalid OTP');
  }

  /// Step 3: Reset password with token
  Future<String> resetPassword({
    required String email,
    required String resetToken,
    required String password,
  }) async {
    final response = await _api.post(
      '/password/reset',
      body: {
        'email': email,
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': password,
      },
      requiresAuth: false,
    );
    if (response.success) {
      return response.data?['message'] ?? 'Password reset successful';
    }
    throw ApiException(response.message ?? 'Password reset failed');
  }
}
