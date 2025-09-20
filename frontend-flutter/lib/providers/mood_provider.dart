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
  Future<void> submitMood(String moodType, String? notes, String userId, {int? intensity, List<String>? tags}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final mood = Mood(
        userId: userId,
        moodType: moodType,
        notes: notes ?? '',
        timestamp: DateTime.now(),
        intensity: intensity,
        tags: tags ?? [],
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

  // Get mood stats
  Map<String, int> get moodStats {
    final stats = <String, int>{};
    for (final mood in _moodHistory) {
      stats[mood.moodType] = (stats[mood.moodType] ?? 0) + 1;
    }
    return stats;
  }

  // Get mood streak (consecutive days with mood entries)
  int get moodStreak {
    if (_moodHistory.isEmpty) return 0;

    int streak = 1;
    DateTime lastDate = _moodHistory.first.timestamp;

    for (int i = 1; i < _moodHistory.length; i++) {
      final currentDate = _moodHistory[i].timestamp;
      final difference = lastDate.difference(currentDate).inDays;

      if (difference == 1) {
        streak++;
        lastDate = currentDate;
      } else {
        break;
      }
    }

    return streak;
  }

  // Get recent moods (last 7 days)
  List<Mood> get recentMoods {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _moodHistory.where((mood) => mood.timestamp.isAfter(sevenDaysAgo)).toList();
  }

  // Get most common mood
  String? get mostCommonMood {
    if (_moodHistory.isEmpty) return null;

    final stats = moodStats;
    String? mostCommon;
    int maxCount = 0;

    stats.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = mood;
      }
    });

    return mostCommon;
  }
}