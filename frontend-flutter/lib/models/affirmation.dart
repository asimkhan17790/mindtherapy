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
  String get cleanMessage => _stripEmoji(message);

  static String _stripEmoji(String text) {
    return text
        .replaceAll(
          RegExp(
            r'[\u{1F000}-\u{1FFFF}\u{2600}-\u{27BF}\u{FE00}-\u{FE0F}\u{200D}\u{20E3}]+',
            unicode: true,
          ),
          '',
        )
        .trim();
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