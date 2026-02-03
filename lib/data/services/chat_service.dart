import 'api_service.dart';
import '../models/models.dart';

class ChatService {
  final ApiService _api = ApiService();

  /// Get total unread count
  Future<int> getUnreadCount() async {
    try {
      final conversations = await getConversations();
      return conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
    } catch (_) {
      return 0;
    }
  }

  /// Get all conversations
  Future<List<ChatConversation>> getConversations() async {
    final response = await _api.get('/chat');

    final dynamic rawData = response.data!['data'];
    List listData = [];

    if (rawData is Map) {
      listData = rawData.values.toList();
    } else if (rawData is List) {
      listData = rawData;
    }

    return listData.map((c) => ChatConversation.fromJson(c)).toList();
  }

  /// Get messages for a specific job
  Future<List<ChatMessage>> getMessages(int jobId, {int? workerId}) async {
    final Map<String, dynamic> query = {};
    if (workerId != null) query['worker_id'] = workerId;

    final response = await _api.get(
      '/chat/$jobId',
      queryParams: query.isNotEmpty ? query : null,
    );

    // According to user docs: { success: true, data: { messages: [...] } }
    dynamic rawData = response.data!['data'];

    if (rawData is Map && rawData.containsKey('messages')) {
      rawData = rawData['messages'];
    }

    List listData = [];

    if (rawData is Map) {
      listData = rawData.values.toList();
    } else if (rawData is List) {
      listData = rawData;
    }

    return listData.map((m) => ChatMessage.fromJson(m)).toList();
  }

  /// Send a message
  Future<ChatMessage> sendMessage(
    int jobId,
    String message, {
    int? receiverId,
  }) async {
    final body = {
      'message': message,
      if (receiverId != null) 'receiver_id': receiverId,
    };

    final response = await _api.post('/chat/$jobId/send', body: body);

    dynamic messageData = response.data!['data'];

    if (messageData == null && response.data!['message'] is Map) {
      messageData = response.data!['message'];
    }

    if (messageData != null && messageData is Map<String, dynamic>) {
      return ChatMessage.fromJson(messageData);
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      conversationId: 0,
      senderId: 0,
      message: message,
      isRead: false,
      createdAt: DateTime.now(),
    );
  }
}
