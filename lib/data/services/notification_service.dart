import 'api_service.dart';
import '../models/models.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final response = await _api.get('/notifications?page=$page');
    final body = response.data;
    if (body == null) {
      throw StateError('Invalid notifications response');
    }
    final result = Map<String, dynamic>.from(body);
    final envelope = result['data'];
    Map<String, dynamic>? envMap;
    if (envelope is Map) {
      envMap = Map<String, dynamic>.from(envelope);
    }

    // API: { success, data: { notifications: paginator, unread_count }, notifications, unread_count }
    final dynamic notificationData =
        result['notifications'] ?? envMap?['notifications'] ?? result;

    final dynamic rawData = notificationData is Map
        ? notificationData['data']
        : null;
    List list = [];
    if (rawData is Map) {
      list = rawData.values.toList();
    } else if (rawData is List) {
      list = rawData;
    }

    final notifications = list.map((e) => AppNotification.fromJson(e)).toList();

    final unreadRaw = result['unread_count'] ?? envMap?['unread_count'] ?? 0;
    final unread = unreadRaw is num ? unreadRaw.toInt() : int.tryParse('$unreadRaw') ?? 0;

    Map<String, dynamic>? pageMap;
    if (notificationData is Map) {
      pageMap = Map<String, dynamic>.from(notificationData);
    }

    return {
      'notifications': notifications,
      'unread_count': unread,
      'current_page': pageMap?['current_page'],
      'last_page': pageMap?['last_page'],
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
