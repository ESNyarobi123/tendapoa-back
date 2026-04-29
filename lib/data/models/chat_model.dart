import 'job_model.dart';

class ChatUser {
  final int id;
  final String name;
  final String? phone;
  final String? profilePhotoUrl;

  ChatUser({
    required this.id,
    required this.name,
    this.phone,
    this.profilePhotoUrl,
  });

  static int _parseInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    if (v is double) return v.toInt();
    return fallback;
  }

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      profilePhotoUrl: (json['profile_photo_url'] ?? json['photo'])?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

/// Chat Conversation Model
class ChatConversation {
  final Job? job;
  final ChatUser? otherUser;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatConversation({
    this.job,
    this.otherUser,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      otherUser: json['other_user'] != null
          ? ChatUser.fromJson(json['other_user'])
          : null,
      lastMessage: json['last_message']?.toString(),
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      unreadCount: ChatUser._parseInt(json['unread_count']),
    );
  }
}

/// Chat Message Model
class ChatMessage {
  final int id;
  final int? workOrderId;
  final int? conversationId;
  final int senderId;
  final int? receiverId;
  final String message;
  final bool isRead;
  final DateTime? createdAt;
  final ChatUser? sender;

  ChatMessage({
    required this.id,
    this.workOrderId,
    this.conversationId,
    required this.senderId,
    this.receiverId,
    required this.message,
    this.isRead = false,
    this.createdAt,
    this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: ChatUser._parseInt(json['id']),
      workOrderId: ChatUser._parseInt(json['job_id'] ?? json['work_order_id']),
      conversationId: ChatUser._parseInt(json['conversation_id']),
      senderId: ChatUser._parseInt(json['sender_id']),
      receiverId: ChatUser._parseInt(json['receiver_id']),
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == 1 ||
          json['is_read'] == true ||
          json['is_read'] == '1',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      sender: json['sender'] != null ? ChatUser.fromJson(json['sender']) : null,
    );
  }
}
