import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';

class QuickMoodCapture extends StatefulWidget {
  const QuickMoodCapture({super.key});

  @override
  State<QuickMoodCapture> createState() => _QuickMoodCaptureState();
}

class _QuickMoodCaptureState extends State<QuickMoodCapture>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _selectedMood;
  final String _userId = 'user123'; // TODO: Replace with actual user ID

  final List<Map<String, String>> _quickMoods = [
    {'type': 'amazing', 'emoji': '🤩', 'label': 'Amazing'},
    {'type': 'happy', 'emoji': '😊', 'label': 'Happy'},
    {'type': 'good', 'emoji': '🙂', 'label': 'Good'},
    {'type': 'neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'type': 'low', 'emoji': '😕', 'label': 'Low'},
    {'type': 'sad', 'emoji': '😔', 'label': 'Sad'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _quickSaveMood(String moodType) async {
    setState(() => _selectedMood = moodType);
    _animationController.forward().then((_) => _animationController.reverse());

    await context.read<MoodProvider>().submitMood(
      moodType,
      'Quick mood log',
      _userId,
    );

    if (mounted) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(_quickMoods.firstWhere((m) => m['type'] == moodType)['emoji']!),
              const SizedBox(width: 8),
              const Text('Mood saved! 💖'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      setState(() => _selectedMood = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Quick Mood Check',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Tap an emoji to quickly log your current mood',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 16),

          Consumer<MoodProvider>(
            builder: (context, provider, child) {
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _quickMoods.map((mood) {
                  final isSelected = _selectedMood == mood['type'];
                  final isLoading = provider.isLoading && isSelected;

                  return GestureDetector(
                    onTap: isLoading ? null : () => _quickSaveMood(mood['type']!),
                    child: AnimatedScale(
                      scale: isSelected ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  mood['emoji']!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/mood'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_note,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Detailed Mood Log',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}