import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../core/router/app_router.dart';
import '../../data/models/models.dart';
import '../../data/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _loadNotifications(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _lastPage) {
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _notifications.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final result = await _notificationService.getNotifications(
          page: refresh ? 1 : _currentPage + 1);
      final List<AppNotification> newNotifications =
          List<AppNotification>.from(result['notifications'] ?? []);

      if (mounted) {
        setState(() {
          if (refresh)
            _notifications = newNotifications;
          else
            _notifications.addAll(newNotifications);
          if (!refresh && newNotifications.isNotEmpty) _currentPage++;
          _lastPage = result['last_page'] ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
    }
  }

  Future<void> _markAllRead() async {
    _notificationService.markAllAsRead();
    // Optimistic update
    setState(() {
      for (var n in _notifications) {
        n.readAt = DateTime.now();
      }
    });
  }

  void _handleTap(AppNotification n) {
    if (n.readAt == null) {
      _notificationService.markAsRead(n.id);
      setState(() => n.readAt = DateTime.now());
    }

    if (n.jobId != null) {
      Navigator.pushNamed(context, AppRouter.jobDetails,
          arguments: {'jobId': n.jobId});
    }
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Leo (Today)';
    if (diff == 1) return 'Jana (Yesterday)';
    return DateFormat('d MMMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Taarifa (Alerts)',
            style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5)),
        actions: [
          if (_notifications.any((n) => n.readAt == null))
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Read All',
                  style: TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => _loadNotifications(refresh: true),
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _notifications.length)
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator()));

                      final n = _notifications[index];
                      return _buildNotificationItem(n);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), shape: BoxShape.circle),
            child: Icon(Icons.notifications_off_rounded,
                size: 80, color: Colors.blue[50]),
          ),
          const SizedBox(height: 30),
          const Text('Hakuna Taarifa',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          const Text('Taarifa zako mpya zitaonekana hapa.',
              style: TextStyle(color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification n) {
    final isRead = n.readAt != null;
    return InkWell(
      onTap: () => _handleTap(n),
      child: Container(
        padding: const EdgeInsets.all(20),
        color: isRead
            ? Colors.transparent
            : const Color(0xFFEFF6FF).withValues(alpha: 0.5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRead ? const Color(0xFFF1F5F9) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: isRead
                    ? []
                    : [
                        BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
              ),
              child: Icon(_getIcon(n.type),
                  color: isRead ? const Color(0xFF94A3B8) : AppColors.primary,
                  size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(n.title,
                            style: TextStyle(
                                fontWeight:
                                    isRead ? FontWeight.bold : FontWeight.w900,
                                fontSize: 16,
                                color: const Color(0xFF1E293B))),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFFF97316), shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.message,
                      style: TextStyle(
                          color: isRead
                              ? const Color(0xFF64748B)
                              : const Color(0xFF334155),
                          fontSize: 14,
                          height: 1.5,
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.w500)),
                  const SizedBox(height: 10),
                  Text(
                      DateFormat('h:mm a • ').format(n.createdAt) +
                          _getRelativeDate(n.createdAt),
                      style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  IconData _getIcon(String type) {
    if (type.contains('JobApplication')) return Icons.person_search_rounded;
    if (type.contains('JobStatus')) return Icons.assignment_turned_in_rounded;
    if (type.contains('Payment')) return Icons.payments_rounded;
    return Icons.notifications_active_rounded;
  }
}
