import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

class WorkerProvider extends ChangeNotifier {
  final _jobService = JobService();

  bool _isLoading = false;
  String? _error;

  // Filter States
  String? _selectedCategory;
  double? _selectedDistance;

  // Dashboard Data
  WorkerDashboard? _dashboard;
  List<Job> _availableJobs = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  WorkerDashboard? get dashboard => _dashboard;
  String? get selectedCategory => _selectedCategory;
  double? get selectedDistance => _selectedDistance;

  Wallet? get wallet => _dashboard != null
      ? Wallet(
          balance: _dashboard!.available,
          totalEarnings: _dashboard!.earnTotal,
          transactions: _dashboard!.earningsHistory,
        )
      : null;
  List<Job> get activeJobs => _dashboard?.currentJobs ?? [];
  List<Job> get availableJobs => _availableJobs;

  Job? get currentActiveJob => activeJobs.isNotEmpty ? activeJobs.first : null;

  // Initialize
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _jobService.getWorkerDashboard();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadJobsFeed({String? category, double? distance}) async {
    _selectedCategory = category;
    _selectedDistance = distance;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _jobService.getFeed(
        category: _selectedCategory,
        distance: _selectedDistance,
      );
      // API returns 'jobs' array directly
      final List data = response['jobs'] ?? response['data'] ?? [];
      _availableJobs = data.map((j) => Job.fromJson(j)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Job>> loadMapJobs() async {
    try {
      final response = await _jobService.getMapFeed();
      final List data = response['jobs'] ?? [];
      return data.map((j) => Job.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadJobsFeed(category: _selectedCategory, distance: _selectedDistance),
    ]);
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedDistance = null;
    loadJobsFeed();
  }

  // Assigned Jobs (jobs where worker was selected by muhitaji - needs accept/decline)
  List<Job> _assignedJobs = [];
  List<Job> get assignedJobs => _assignedJobs;

  // Active Jobs from assigned endpoint (in_progress, ready_for_confirmation)
  List<Job> _activeJobsFromAssigned = [];
  List<Job> get activeJobsFromAssigned => _activeJobsFromAssigned;

  Future<void> loadAssignedJobs() async {
    try {
      // Get pending jobs (status = 'assigned') - need accept/decline
      _assignedJobs = await _jobService.getAssignedJobs();
      // Get active jobs (status = 'in_progress' or 'ready_for_confirmation')
      _activeJobsFromAssigned = await _jobService.getActiveJobs();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> acceptAssignedJob(int jobId) async {
    try {
      await _jobService.acceptAssignedJob(jobId);
      await loadAssignedJobs();
      await loadDashboard();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> declineAssignedJob(int jobId) async {
    try {
      await _jobService.declineAssignedJob(jobId);
      await loadAssignedJobs();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> applyForJob(int jobId, String message, {int? bidAmount}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _jobService.applyForJob(jobId, message, bidAmount: bidAmount);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
