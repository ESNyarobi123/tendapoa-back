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
      final List data = response['data'] ?? [];
      _availableJobs = data.map((j) => Job.fromJson(j)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
}
