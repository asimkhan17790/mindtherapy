import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> with TickerProviderStateMixin {
  String? _selectedMood;
  int? _selectedIntensity;
  final TextEditingController _notesController = TextEditingController();
  final String _userId = 'user123'; // TODO: Replace with actual user ID
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<String> _selectedTags = [];

  final List<Map<String, String>> _moodOptions = [
    {'type': 'amazing', 'emoji': '🤩', 'label': 'Amazing', 'color': 'FFD700'},
    {'type': 'happy', 'emoji': '😊', 'label': 'Happy', 'color': '4CAF50'},
    {'type': 'good', 'emoji': '🙂', 'label': 'Good', 'color': '8BC34A'},
    {'type': 'neutral', 'emoji': '😐', 'label': 'Neutral', 'color': '9E9E9E'},
    {'type': 'low', 'emoji': '😕', 'label': 'Low', 'color': 'FF9800'},
    {'type': 'sad', 'emoji': '😔', 'label': 'Sad', 'color': '2196F3'},
    {'type': 'anxious', 'emoji': '😰', 'label': 'Anxious', 'color': '9C27B0'},
    {'type': 'angry', 'emoji': '😠', 'label': 'Angry', 'color': 'F44336'},
    {'type': 'tired', 'emoji': '😴', 'label': 'Tired', 'color': '607D8B'},
    {'type': 'stressed', 'emoji': '😤', 'label': 'Stressed', 'color': 'FF5722'},
  ];

  final List<String> _availableTags = [
    'work', 'family', 'friends', 'health', 'exercise', 'sleep', 'food',
    'weather', 'social', 'alone', 'creative', 'learning', 'traveling'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitMood() async {
    if (_selectedMood == null) return;

    await context.read<MoodProvider>().submitMood(
      _selectedMood!,
      _notesController.text.trim(),
      _userId,
      intensity: _selectedIntensity,
      tags: _selectedTags,
    );

    if (mounted) {
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mood saved! 💖'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Navigate to suggestions with the selected mood
      Navigator.pushReplacementNamed(
        context,
        '/suggestions',
        arguments: _selectedMood,
      );
    }
  }

  Color _getColorFromHex(String hexColor) {
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('How are you feeling?'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with encouragement
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.1),
                        Theme.of(context).primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '✨ Check in with yourself',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your emotions are valid and important. Take a moment to acknowledge how you\'re feeling right now.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Mood Selection
                const Text(
                  'How are you feeling?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                // Mood Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _moodOptions.length,
                  itemBuilder: (context, index) {
                    final mood = _moodOptions[index];
                    final isSelected = _selectedMood == mood['type'];

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedMood = mood['type']);
                        if (isSelected) {
                          _animationController.forward().then((_) {
                            _animationController.reverse();
                          });
                        }
                        // Haptic feedback
                        // HapticFeedback.lightImpact();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getColorFromHex(mood['color']!).withOpacity(0.2)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? _getColorFromHex(mood['color']!)
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _getColorFromHex(mood['color']!)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mood['emoji']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                mood['label']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? _getColorFromHex(mood['color']!)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: _getColorFromHex(mood['color']!),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                if (_selectedMood != null) ...[
                  const SizedBox(height: 30),

                  // Intensity Slider
                  const Text(
                    'How intense is this feeling?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Barely', style: TextStyle(color: Colors.grey[600])),
                            Text('Extremely', style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        Slider(
                          value: (_selectedIntensity ?? 3).toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _selectedIntensity != null
                              ? ['Barely', 'Slightly', 'Moderately', 'Quite', 'Extremely'][_selectedIntensity! - 1]
                              : 'Moderately',
                          onChanged: (value) {
                            setState(() => _selectedIntensity = value.round());
                          },
                          activeColor: _getColorFromHex(_moodOptions
                              .firstWhere((m) => m['type'] == _selectedMood)['color']!),
                        ),
                        if (_selectedIntensity != null)
                          Text(
                            ['Barely', 'Slightly', 'Moderately', 'Quite', 'Extremely'][_selectedIntensity! - 1],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Tags
                  const Text(
                    'What influenced this feeling?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTags.remove(tag);
                            } else {
                              _selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 30),

                // Notes Section
                const Text(
                  'Want to share more?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind? How was your day? What made you feel this way?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedMood != null && !provider.isLoading
                        ? _submitMood
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedMood != null
                          ? _getColorFromHex(_moodOptions
                              .firstWhere((m) => m['type'] == _selectedMood)['color']!)
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedMood != null ? 'Save My Mood' : 'Select a Mood',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Error: ${provider.error}',
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}