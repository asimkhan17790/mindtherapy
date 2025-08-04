import 'package:flutter/foundation.dart';
import '../models/mood.dart';
import '../services/api_service.dart';

class MoodProvider with ChangeNotifier {
  Mood? _currentMood;
  List<Mood> _moodHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Mood? get currentMood => _currentMood;
  List<Mood> get moodHistory => _moodHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Submit mood
  Future<void> submitMood(String moodType, String? notes, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final mood = Mood(
        userId: userId,
        moodType: moodType,
        notes: notes ?? '',
        timestamp: DateTime.now(),
      );

      final savedMood = await ApiService.saveMood(mood);
      _currentMood = savedMood;
      
      // Add to history
      _moodHistory.insert(0, savedMood);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load mood history
  Future<void> loadMoodHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _moodHistory = await ApiService.getUserMoods(userId);
      if (_moodHistory.isNotEmpty) {
        _currentMood = _moodHistory.first;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get today's mood
  bool get hasTodaysMood {
    if (_currentMood == null) return false;
    
    final now = DateTime.now();
    final moodDate = _currentMood!.timestamp;
    
    return now.year == moodDate.year &&
           now.month == moodDate.month &&
           now.day == moodDate.day;
  }
}