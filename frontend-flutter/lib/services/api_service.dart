import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mood.dart';
import '../models/affirmation.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Connected to our demo backend
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
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

  // Moods
  static Future<Mood> saveMood(Mood mood) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mood'),
      headers: headers,
      body: jsonEncode(mood.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Mood.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save mood');
    }
  }

  static Future<List<Mood>> getUserMoods(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Mood.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load mood history');
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