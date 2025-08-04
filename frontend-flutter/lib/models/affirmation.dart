class Affirmation {
  final String? id;
  final String message;
  final String category;

  Affirmation({
    this.id,
    required this.message,
    required this.category,
  });

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      id: json['id'] ?? json['_id'],
      message: json['message'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'category': category,
    };
  }

  // Helper methods
  String get categoryIcon {
    switch (category) {
      case 'motivation':
        return '💪';
      case 'self-love':
        return '💖';
      case 'strength':
        return '🌟';
      case 'gratitude':
        return '🙏';
      case 'mindfulness':
        return '🧘';
      default:
        return '✨';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'motivation':
        return 'Motivation';
      case 'self-love':
        return 'Self Love';
      case 'strength':
        return 'Strength';
      case 'gratitude':
        return 'Gratitude';
      case 'mindfulness':
        return 'Mindfulness';
      default:
        return 'General';
    }
  }
}