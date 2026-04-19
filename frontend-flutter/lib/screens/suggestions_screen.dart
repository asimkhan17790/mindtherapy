import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../app_theme.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  String? _moodArg;
  String _activeFilter = 'All';

  static const _filters = ['All', 'Self Care', 'Social', 'Activity', 'Creativity', 'Family'];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mood = ModalRoute.of(context)?.settings.arguments as String?;
    if (mood != null && mood != _moodArg) {
      _moodArg = mood;
      _loadSuggestions();
    }
  }

  Future<void> _loadSuggestions() async {
    await context.read<TaskProvider>().loadSuggestions(_moodArg);
  }

  List<Task> _filtered(List<Task> tasks) {
    if (_activeFilter == 'All') return tasks;
    return tasks.where((t) => t.categoryLabel == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MT.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MTBackButton(),
                      Text('SUGGESTIONS', style: MT.eyebrow()),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<TaskProvider>(
                    builder: (context, prov, _) {
                      if (prov.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final tasks = _filtered(prov.suggestions);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_moodArg != null) ...[
                              Text(
                                'Because you feel ${_moodArg!.toLowerCase()}',
                                style: MT.eyebrow(),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              prov.suggestions.isEmpty
                                  ? 'No suggestions right now.'
                                  : 'Things that might help.',
                              style: MT.headlineLg(),
                            ),

                            const SizedBox(height: 18),

                            // Filters
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _filters.map((f) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: MTPill(
                                      label: f,
                                      active: _activeFilter == f,
                                      onTap: () =>
                                          setState(() => _activeFilter = f),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (tasks.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 32),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.lightbulb_outline,
                                          size: 48, color: MT.ink4),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No suggestions in this category',
                                        style: MT.body(color: MT.ink3),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...tasks.map((t) => _TaskCard(task: t)),

                            const SizedBox(height: 24),

                            Row(
                              children: [
                                Expanded(
                                  child: MTFilledButton(
                                    label: 'Back to home',
                                    onTap: () =>
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, '/home', (_) => false),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MTGhostButton(
                                  label: '↻',
                                  onTap: _loadSuggestions,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatefulWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _done = false;

  Color _tint(String category) {
    switch (category.toLowerCase()) {
      case 'family': return MT.clay;
      case 'self-care': return MT.sage;
      case 'activity': return MT.mist;
      case 'creativity': return MT.sand;
      case 'social': return MT.plum;
      default: return MT.box;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _done = !_done),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _done ? MT.box : MT.paper,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _done ? MT.box2 : MT.ink4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: _tint(task.category),
                ),
                child: Center(
                  child: Icon(
                    task.categoryIconData,
                    size: 20,
                    color: MT.ink2,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _done ? MT.ink3 : MT.ink,
                        decoration: _done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: MT.body(color: MT.ink3).copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        MTPill(label: task.durationText),
                        const SizedBox(width: 6),
                        MTPill(label: task.categoryLabel),
                      ],
                    ),
                  ],
                ),
              ),

              // Check
              const SizedBox(width: 10),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _done ? MT.ink : Colors.transparent,
                  border: Border.all(
                    color: _done ? MT.ink : MT.ink4,
                    width: 1.3,
                  ),
                ),
                child: _done
                    ? const Icon(Icons.check, size: 14, color: MT.paper)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
