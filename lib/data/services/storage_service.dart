import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/app_models.dart';

class StorageService {
  static StorageService? _instance;
  late final SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();
  bool _initialized = false;

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Auth Token (Secure)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }

  // User Data
  Future<void> saveUser(User user) async {
    await init();
    await _prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    await init();
    final userStr = _prefs.getString(AppConstants.userKey);
    if (userStr == null) return null;
    try {
      return User.fromJson(jsonDecode(userStr));
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    await init();
    await _prefs.remove(AppConstants.userKey);
  }

  // Categories Cache
  Future<void> saveCategories(List<Category> categories) async {
    await init();
    final categoriesJson = categories.map((c) => c.toJson()).toList();
    await _prefs.setString(
        AppConstants.categoriesKey, jsonEncode(categoriesJson));
  }

  Future<List<Category>> getCategories() async {
    await init();
    final categoriesStr = _prefs.getString(AppConstants.categoriesKey);
    if (categoriesStr == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(categoriesStr);
      return jsonList.map((j) => Category.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  // App Settings Cache
  Future<void> saveSettings(AppSettings settings) async {
    // Implementation for saving settings
  }

  // Clear All
  Future<void> clearAll() async {
    await init();
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}
