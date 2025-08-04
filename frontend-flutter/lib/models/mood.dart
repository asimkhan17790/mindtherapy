class Mood {
  final String? id;
  final String userId;
  final String moodType;
  final String notes;
  final DateTime timestamp;

  Mood({
    this.id,
    required this.userId,
    required this.moodType,
    required this.notes,
    required this.timestamp,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] ?? json['_id'],
      userId: json['userId'],
      moodType: json['moodType'],
      notes: json['notes'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'moodType': moodType,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Helper methods
  String get moodEmoji {
    switch (moodType) {
      case 'happy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'sad':
        return '😔';
      default:
        return '😐';
    }
  }

  String get moodLabel {
    switch (moodType) {
      case 'happy':
        return 'Happy';
      case 'neutral':
        return 'Neutral';
      case 'sad':
        return 'Sad';
      default:
        return 'Unknown';
    }
  }
}