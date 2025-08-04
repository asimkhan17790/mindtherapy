import 'package:flutter/foundation.dart';
import '../models/affirmation.dart';
import '../services/api_service.dart';

class AffirmationProvider with ChangeNotifier {
  Affirmation? _todaysAffirmation;
  List<Affirmation> _affirmations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Affirmation? get todaysAffirmation => _todaysAffirmation;
  List<Affirmation> get affirmations => _affirmations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load today's affirmation
  Future<void> loadTodaysAffirmation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todaysAffirmation = await ApiService.getRandomAffirmation();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all affirmations
  Future<void> loadAllAffirmations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _affirmations = await ApiService.getAllAffirmations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get new random affirmation
  Future<void> getNewAffirmation() async {
    await loadTodaysAffirmation();
  }
}