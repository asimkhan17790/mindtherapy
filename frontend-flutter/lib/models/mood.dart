class Mood {
  final String? id;
  final String userId;
  final String moodType;
  final String notes;
  final DateTime timestamp;
  final int? intensity; // 1-5 scale
  final List<String> tags;

  Mood({
    this.id,
    required this.userId,
    required this.moodType,
    required this.notes,
    required this.timestamp,
    this.intensity,
    this.tags = const [],
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] ?? json['_id'],
      userId: json['userId'],
      moodType: json['moodType'],
      notes: json['notes'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      intensity: json['intensity'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'moodType': moodType,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
      'intensity': intensity,
      'tags': tags,
    };
  }

  // Helper methods
  String get moodEmoji {
    switch (moodType) {
      case 'amazing':
        return '🤩';
      case 'happy':
        return '😊';
      case 'good':
        return '🙂';
      case 'neutral':
        return '😐';
      case 'low':
        return '😕';
      case 'sad':
        return '😔';
      case 'anxious':
        return '😰';
      case 'angry':
        return '😠';
      case 'tired':
        return '😴';
      case 'stressed':
        return '😤';
      default:
        return '😐';
    }
  }

  String get moodLabel {
    switch (moodType) {
      case 'amazing':
        return 'Amazing';
      case 'happy':
        return 'Happy';
      case 'good':
        return 'Good';
      case 'neutral':
        return 'Neutral';
      case 'low':
        return 'Low';
      case 'sad':
        return 'Sad';
      case 'anxious':
        return 'Anxious';
      case 'angry':
        return 'Angry';
      case 'tired':
        return 'Tired';
      case 'stressed':
        return 'Stressed';
      default:
        return 'Unknown';
    }
  }

  // Get mood color
  String get moodColor {
    switch (moodType) {
      case 'amazing':
        return '#FFD700';
      case 'happy':
        return '#4CAF50';
      case 'good':
        return '#8BC34A';
      case 'neutral':
        return '#9E9E9E';
      case 'low':
        return '#FF9800';
      case 'sad':
        return '#2196F3';
      case 'anxious':
        return '#9C27B0';
      case 'angry':
        return '#F44336';
      case 'tired':
        return '#607D8B';
      case 'stressed':
        return '#FF5722';
      default:
        return '#9E9E9E';
    }
  }

  // Get intensity description
  String get intensityDescription {
    if (intensity == null) return '';
    switch (intensity!) {
      case 1:
        return 'Barely';
      case 2:
        return 'Slightly';
      case 3:
        return 'Moderately';
      case 4:
        return 'Quite';
      case 5:
        return 'Extremely';
      default:
        return '';
    }
  }
}