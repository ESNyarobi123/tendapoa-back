import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/chat_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  List<ChatConversation> _conversations = [];
  Timer? _refreshTimer;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadConversations();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadConversations(silent: true);
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _loadConversations(silent: true);
      } else {
        _refreshTimer?.cancel();
      }
    });
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final conversations = await _chatService.getConversations();
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          context.tr('chat'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _conversations.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conversations.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 76,
                      color: Color(0xFFE2E8F0),
                    ),
                    itemBuilder: (context, index) {
                      return _buildConversationItem(_conversations[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    final otherUser = conversation.otherUser;
    final job = conversation.job;
    final hasUnread = conversation.unreadCount > 0;
    
    return InkWell(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          AppRouter.chatRoom,
          arguments: {'conversation': conversation},
        );
        // Refresh after returning from chat room
        _loadConversations(silent: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread ? const Color(0xFFF0F9FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Profile Picture with unread indicator
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                    border: hasUnread 
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                    image: otherUser?.profilePhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(otherUser!.profilePhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: otherUser?.profilePhotoUrl == null
                      ? Center(
                          child: Text(
                            otherUser?.name.isNotEmpty == true
                                ? otherUser!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        )
                      : null,
                ),
                // Unread badge
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Center(
                        child: Text(
                          conversation.unreadCount > 9 ? '9+' : '${conversation.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUser?.name ?? 'Mtumiaji',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'MPYA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage ?? job?.title ?? context.tr('no_messages_found_sub'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                      color: hasUnread
                          ? AppColors.textPrimary
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(context, conversation.lastMessageAt),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                    color: hasUnread ? AppColors.primary : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('no_messages_found'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('no_messages_found_sub'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return context.tr('yesterday');
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
