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

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] ?? json['photo'],
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
      unreadCount: json['unread_count'] ?? 0,
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
      id: json['id'] ?? 0,
      workOrderId: json['job_id'] ?? json['work_order_id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'],
      message: json['message'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      sender: json['sender'] != null ? ChatUser.fromJson(json['sender']) : null,
    );
  }
}
