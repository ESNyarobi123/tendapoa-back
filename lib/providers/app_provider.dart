import 'package:flutter/material.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<Category> _categories = [];
  final bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    _categories = await _storageService.getCategories();
    notifyListeners();
    // In a real app, you might want to fetch fresh categories from API here
  }
}
