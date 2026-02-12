import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/providers.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatConversation conversation;

  const ChatRoomScreen({super.key, required this.conversation});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSending = false;
  List<ChatMessage> _messages = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(AppConstants.chatPollingInterval, (_) {
      _loadMessages(isPoll: true);
    });
  }

  Future<void> _loadMessages({bool isPoll = false}) async {
    final jobId = widget.conversation.job?.id;
    if (jobId == null) return;

    try {
      final msgs = await _chatService.getMessages(jobId);
      if (mounted) {
        if (!isPoll) {
          setState(() {
            _messages = msgs;
            _isLoading = false;
          });
          _scrollToBottom();
        } else {
          if (msgs.length != _messages.length ||
              (msgs.isNotEmpty &&
                  _messages.isNotEmpty &&
                  msgs.last.id != _messages.last.id)) {
            setState(() {
              _messages = msgs;
            });
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      if (!isPoll && mounted) setState(() => _isLoading = false);
    }
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    final jobId = widget.conversation.job?.id;
    if (jobId == null) return;

    final msgText = _msgController.text.trim();
    _msgController.clear();
    setState(() => _isSending = true);

    try {
      final newMsg = await _chatService.sendMessage(jobId, msgText,
          receiverId: widget.conversation.otherUser?.id);
      if (mounted) {
        setState(() {
          _messages.add(newMsg);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('failed_send_message'))));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.user?.id;
    final otherUser = widget.conversation.otherUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Softer background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: otherUser?.profilePhotoUrl != null
                  ? NetworkImage(otherUser!.profilePhotoUrl!)
                  : null,
              child: otherUser?.profilePhotoUrl == null
                  ? Text(
                      otherUser?.name.isNotEmpty == true
                          ? otherUser!.name[0]
                          : 'U',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(otherUser?.name ?? 'Chat',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                  const Text('Online Now',
                      style: TextStyle(
                          color: Color(0xFF22C55E),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined,
                color: AppColors.textPrimary, size: 22),
            onPressed: () {
              if (otherUser?.phone != null) {
                _makePhoneCall(otherUser!.phone!);
              } else if (widget.conversation.job?.phone != null) {
                _makePhoneCall(widget.conversation.job!.phone!);
              }
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Info banner for the job
          if (widget.conversation.job != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: const Color(0xFFEFF6FF),
              child: Row(
                children: [
                  const Icon(Icons.work_outline_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Kuhusu: ${widget.conversation.job!.title}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) {
                      final msg = _messages[i];
                      final isMe = msg.senderId == currentUserId;
                      return _buildMessageBubble(msg, isMe);
                    },
                  ),
          ),

          // INPUT AREA
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 5),
                bottomRight: Radius.circular(isMe ? 5 : 20),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ],
            ),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Text(
              msg.message,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              DateFormat('HH:mm').format(msg.createdAt ?? DateTime.now()),
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          20, 15, 20, MediaQuery.of(context).padding.bottom + 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _msgController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: context.tr('enter_message_hint'),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
