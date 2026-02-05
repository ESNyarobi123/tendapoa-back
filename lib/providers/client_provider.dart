import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

class ClientProvider extends ChangeNotifier {
  final _jobService = JobService();
  final _chatService = ChatService();
  final _notificationService = NotificationService();
  final _walletService = WalletService();

  bool _isLoading = false;
  bool _isDashboardLoading = false;
  bool _isWalletLoading = false;
  bool _isWithdrawing = false;
  String? _error;

  List<Job> _myJobs = [];
  List<NearbyWorker> _nearbyWorkers = [];
  int _unreadChatCount = 0;
  int _unreadNotificationCount = 0;
  ClientDashboard? _dashboard;
  double _walletBalance = 0;

  // Getters
  bool get isLoading => _isLoading;
  bool get isDashboardLoading => _isDashboardLoading;
  bool get isWalletLoading => _isWalletLoading;
  bool get isWithdrawing => _isWithdrawing;
  String? get error => _error;
  List<Job> get myJobs => _myJobs;
  List<NearbyWorker> get nearbyWorkers => _nearbyWorkers;
  int get unreadChatCount => _unreadChatCount;
  int get unreadChats => _unreadChatCount; // Alias
  int get unreadNotificationCount => _unreadNotificationCount;
  ClientDashboard? get dashboard => _dashboard;
  double get walletBalance => _walletBalance;

  // Load Unread Counts
  Future<void> loadUnreadCounts() async {
    try {
      final chatCount = await _chatService.getUnreadCount();
      final notificationData =
          await _notificationService.getNotifications(page: 1);

      _unreadChatCount = chatCount;
      _unreadNotificationCount = notificationData['unread_count'] ?? 0;
      notifyListeners();
    } catch (e) {
      print('Client Counts Error: $e');
    }
  }

  // Load My Jobs
  Future<void> loadMyJobs({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final jobs = await _jobService.getMyJobs();
      _myJobs = jobs;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Nearby Workers
  Future<void> loadNearbyWorkers(
      {required double lat, required double lng}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _jobService.getNearbyWorkers(lat: lat, lng: lng);
      _nearbyWorkers = response.workers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Post a Job
  Future<void> postJob({
    required String title,
    required int categoryId,
    required int price,
    required String description,
    required double lat,
    required double lng,
    required String phone,
    String? addressText,
    dynamic image, // File?
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _jobService.postJob(
        title: title,
        categoryId: categoryId,
        price: price,
        description: description,
        lat: lat,
        lng: lng,
        phone: phone,
        addressText: addressText,
        image: image,
      );

      // Reload jobs after posting
      await loadMyJobs();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a worker for a job
  Future<void> selectWorker(int jobId, int commentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _jobService.selectWorker(jobId, commentId);
      await loadMyJobs(); // Refresh state
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Retry payment for a job
  Future<void> retryPayment(int jobId) async {
    await _jobService.retryPayment(jobId);
    await loadMyJobs();
  }

  // Cancel a job
  Future<void> cancelJob(int jobId) async {
    await _jobService.cancelJob(jobId);
    await loadMyJobs();
  }

  // Load Dashboard Data
  Future<void> loadDashboard() async {
    _isDashboardLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _jobService.getClientDashboard();
      // Also load wallet balance
      await loadWalletBalance();
      _isDashboardLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isDashboardLoading = false;
      notifyListeners();
      debugPrint('Dashboard Error: $e');
    }
  }

  // Load Wallet Balance
  Future<void> loadWalletBalance() async {
    _isWalletLoading = true;
    notifyListeners();

    try {
      final data = await _walletService.getWalletBalance();
      _walletBalance = data['balance'] ?? 0.0;
      _isWalletLoading = false;
      notifyListeners();
    } catch (e) {
      _isWalletLoading = false;
      notifyListeners();
      debugPrint('Wallet Error: $e');
    }
  }

  // Submit Withdrawal Request
  Future<Map<String, dynamic>> submitWithdrawal({
    required int amount,
    required String phoneNumber,
    required String registeredName,
    required String networkType,
    String method = 'mobile_money',
  }) async {
    _isWithdrawing = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _walletService.submitWithdrawal(
        amount: amount,
        phoneNumber: phoneNumber,
        registeredName: registeredName,
        networkType: networkType,
        method: method,
      );

      // Reload wallet balance after withdrawal
      await loadWalletBalance();

      _isWithdrawing = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isWithdrawing = false;
      notifyListeners();
      rethrow;
    }
  }
}
