import 'api_service.dart';
import '../models/models.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final response = await _api.get('/notifications?page=$page');
    final result = response.data!;
    final notificationData = result['notifications'] ?? result;

    final dynamic rawData = notificationData['data'];
    List list = [];
    if (rawData is Map) {
      list = rawData.values.toList();
    } else if (rawData is List) {
      list = rawData;
    }

    final notifications = list.map((e) => AppNotification.fromJson(e)).toList();

    return {
      'notifications': notifications,
      'unread_count': result['unread_count'] ?? 0,
      'current_page': notificationData['current_page'],
      'last_page': notificationData['last_page'],
    };
  }
  
  Future<bool> markAsRead(String id) async {
    try {
      await _api.post('/notifications/$id/read');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _api.post('/notifications/read-all');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _api.post('/update-fcm-token', body: {'token': token});
    } catch (_) {
      // Ignore errors updating token
    }
  }
}

class SettingsService {
  final ApiService _api = ApiService();

  /// Get app settings from the server
  Future<Map<String, dynamic>> getSettings() async {
    final response = await _api.get('/settings');
    return response.data ?? {};
  }

  /// Update user preferences
  Future<bool> updatePreferences(Map<String, dynamic> prefs) async {
    try {
      await _api.post('/settings/preferences', body: prefs);
      return true;
    } catch (_) {
      return false;
    }
  }
}
