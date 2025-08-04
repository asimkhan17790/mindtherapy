import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _suggestions = [];
  List<Task> _allTasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get suggestions => _suggestions;
  List<Task> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load task suggestions based on mood
  Future<void> loadSuggestions([String? mood]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _suggestions = await ApiService.getTaskSuggestions(mood);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all tasks
  Future<void> loadAllTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTasks = await ApiService.getAllTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter suggestions by category
  List<Task> getSuggestionsByCategory(String category) {
    return _suggestions.where((task) => task.category == category).toList();
  }

  // Get suggestions for specific mood
  Future<void> getSuggestionsForMood(String mood) async {
    await loadSuggestions(mood);
  }
}