import 'package:flutter/material.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  final List<String> moodTags;
  final String category;
  final int estimatedMinutes;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.moodTags,
    required this.category,
    required this.estimatedMinutes,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? json['_id'],
      title: json['title'],
      description: json['description'],
      moodTags: List<String>.from(json['moodTags'] ?? []),
      category: json['category'],
      estimatedMinutes: json['estimatedMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'moodTags': moodTags,
      'category': category,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  // Helper methods
  IconData get categoryIconData {
    switch (category) {
      case 'family':
        return Icons.people_outline_rounded;
      case 'self-care':
        return Icons.self_improvement_rounded;
      case 'activity':
        return Icons.directions_run_rounded;
      case 'creativity':
        return Icons.palette_outlined;
      case 'social':
        return Icons.group_outlined;
      default:
        return Icons.edit_note_rounded;
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'family':
        return 'Family';
      case 'self-care':
        return 'Self Care';
      case 'activity':
        return 'Activity';
      case 'creativity':
        return 'Creativity';
      case 'social':
        return 'Social';
      default:
        return 'General';
    }
  }

  String get durationText {
    if (estimatedMinutes < 60) {
      return '$estimatedMinutes min';
    } else {
      final hours = estimatedMinutes ~/ 60;
      final minutes = estimatedMinutes % 60;
      return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
    }
  }
}