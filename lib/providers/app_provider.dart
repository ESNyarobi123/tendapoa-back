import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final JobService _jobService = JobService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    // First load from cache
    _categories = await _storageService.getCategories();
    notifyListeners();
    
    // Then fetch fresh from API
    await loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final categories = await _jobService.getCategories();
      _categories = categories;
      // Save to cache
      await _storageService.saveCategories(categories);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error loading categories: $e');
    }
  }
}
