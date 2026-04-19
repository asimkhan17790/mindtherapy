import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _accessToken;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // For web, add your client ID here (optional, can also use meta tag)
    clientId:
        '549305671293-r4lvfheejpdh3er2d92bk3tr7aajp78g.apps.googleusercontent.com',
  );

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userData = prefs.getString('user_data');
      final loginTimestamp = prefs.getInt('login_timestamp');

      // Check if session is still valid (7 days)
      if (token != null && loginTimestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final sessionAge = now - loginTimestamp;
        const sevenDaysInMs = 7 * 24 * 60 * 60 * 1000;

        if (sessionAge < sevenDaysInMs) {
          _accessToken = token;

          // Load user data from cache if available
          if (userData != null) {
            try {
              final userMap = Map<String, dynamic>.from(json.decode(userData));
              _user = User.fromJson(userMap);
              _isAuthenticated = true;
            } catch (e) {
              debugPrint('User data parsing error: $e');
            }
          }

          // Try to load fresh profile data
          await _loadUserProfile();
        } else {
          // Session expired, clear data
          await _clearSession();
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      // For web, idToken might be null due to google_sign_in_web limitations
      // In this case, we'll create a temporary demo user for development
      if (idToken == null) {
        debugPrint(
            'Google Sign-In: idToken is null (common on web), using demo authentication');

        // Create a demo user with Google account info
        _user = User(
          id: 'google-${googleUser.id}',
          email: googleUser.email,
          name: googleUser.displayName ?? 'Google User',
          picture: googleUser.photoUrl,
          preferences: {
            'notifications': true,
            'dailyReminder': true,
            'reminderTime': '09:00'
          },
        );

        // Create a demo access token
        _accessToken = 'google-demo-token-${googleUser.id}';
        _isAuthenticated = true;

        // Save session data to local storage
        await _saveSession();

        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Send ID token to backend (when available)
      final response = await ApiService.signInWithGoogle(idToken);

      if (response['success'] == true) {
        _accessToken = response['accessToken'];
        _user = User.fromJson(response['user']);
        _isAuthenticated = true;

        // Save session data to local storage
        await _saveSession();

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_accessToken == null) return;

      // Guest sessions don't have a real backend token — skip API call
      if (_accessToken!.startsWith('guest-')) return;

      final response = await ApiService.getUserProfile(_accessToken!);

      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        _isAuthenticated = true;
      } else {
        await signOut();
      }
    } catch (e) {
      debugPrint('Load user profile error: $e');
      await signOut();
    }
  }

  Future<void> signInAsGuest() async {
    _user = User(
      id: 'guest',
      email: 'guest@mindtherapy.app',
      name: 'Guest',
      picture: null,
      preferences: {},
    );
    _accessToken = 'guest-token';
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear session data
      await _clearSession();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      if (_accessToken == null) return false;

      final response =
          await ApiService.updateUserPreferences(_accessToken!, preferences);

      if (response['success'] == true) {
        _user = _user?.copyWith(preferences: response['preferences']);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Update preferences error: $e');
      return false;
    }
  }

  Future<bool> verifyToken() async {
    try {
      if (_accessToken == null) return false;

      final response = await ApiService.verifyToken(_accessToken!);
      return response['success'] == true && response['valid'] == true;
    } catch (e) {
      debugPrint('Token verification error: $e');
      return false;
    }
  }

  // Session management helper methods
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();

    if (_accessToken != null) {
      await prefs.setString('access_token', _accessToken!);
      await prefs.setInt(
          'login_timestamp', DateTime.now().millisecondsSinceEpoch);
    }

    if (_user != null) {
      await prefs.setString('user_data', json.encode(_user!.toJson()));
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear stored data
    await prefs.remove('access_token');
    await prefs.remove('user_data');
    await prefs.remove('login_timestamp');

    // Clear state
    _user = null;
    _accessToken = null;
    _isAuthenticated = false;
  }

  // Get session info for debugging
  Future<Map<String, dynamic>> getSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimestamp = prefs.getInt('login_timestamp');

    return {
      'isAuthenticated': _isAuthenticated,
      'hasToken': _accessToken != null,
      'hasUser': _user != null,
      'loginTimestamp': loginTimestamp,
      'sessionAge': loginTimestamp != null
          ? DateTime.now().millisecondsSinceEpoch - loginTimestamp
          : null,
    };
  }
}
