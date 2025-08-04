import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();
  final String _userId = 'user123'; // TODO: Replace with actual user ID

  final List<Map<String, String>> _moodOptions = [
    {'type': 'happy', 'emoji': '😊', 'label': 'Happy'},
    {'type': 'neutral', 'emoji': '😐', 'label': 'Neutral'},
    {'type': 'sad', 'emoji': '😔', 'label': 'Sad'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitMood() async {
    if (_selectedMood == null) return;

    await context.read<MoodProvider>().submitMood(
      _selectedMood!,
      _notesController.text.trim(),
      _userId,
    );

    if (mounted) {
      // Navigate to suggestions with the selected mood
      Navigator.pushReplacementNamed(
        context, 
        '/suggestions',
        arguments: _selectedMood,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How are you feeling?'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Check in with yourself',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                const Text(
                  'How are you feeling right now? Your emotions are valid.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Mood Selection
                const Text(
                  'Select your mood:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Mood Options
                Column(
                  children: _moodOptions.map((mood) {
                    final isSelected = _selectedMood == mood['type'];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMood = mood['type']),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : Colors.grey[50],
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Text(
                                mood['emoji']!,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  mood['label']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected 
                                        ? Theme.of(context).primaryColor
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                  size: 30,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 30),
                
                // Notes Section
                const Text(
                  'Add a note (optional):',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 15),
                
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind? How was your day?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                
                const Spacer(),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedMood != null && !provider.isLoading
                        ? _submitMood
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Error: ${provider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}