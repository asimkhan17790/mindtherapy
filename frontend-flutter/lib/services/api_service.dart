import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mood.dart';
import '../models/affirmation.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3001/api'; // Connected to our demo backend

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Affirmations
  static Future<Affirmation> getRandomAffirmation() async {
    final response = await http.get(
      Uri.parse('$baseUrl/affirmations/random'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Affirmation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load affirmation');
    }
  }

  static Future<List<Affirmation>> getAllAffirmations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/affirmations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Affirmation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load affirmations');
    }
  }

  // Authentication
  static Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google-signin'),
      headers: headers,
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign in with Google');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user profile');
    }
  }

  static Future<Map<String, dynamic>> updateUserPreferences(
      String token, Map<String, dynamic> preferences) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/preferences'),
      headers: headersWithAuth(token),
      body: jsonEncode({'preferences': preferences}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update preferences');
    }
  }

  static Future<Map<String, dynamic>> verifyToken(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/verify'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify token');
    }
  }

  // Moods
  static Future<Mood> saveMood(Mood mood, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mood'),
      headers: headersWithAuth(token),
      body: jsonEncode(mood.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Mood.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save mood');
    }
  }

  static Future<List<Mood>> getUserMoods(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood/history'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Mood.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load mood history');
    }
  }

  static Future<Mood?> getLatestMood(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood/latest'),
      headers: headersWithAuth(token),
    );

    if (response.statusCode == 200) {
      return Mood.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load latest mood');
    }
  }

  // Tasks
  static Future<List<Task>> getTaskSuggestions([String? mood]) async {
    String url = '$baseUrl/tasks/suggestions';
    if (mood != null) {
      url += '?mood=$mood';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load task suggestions');
    }
  }

  static Future<List<Task>> getAllTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}