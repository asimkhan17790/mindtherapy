import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/affirmation_provider.dart';
import '../providers/mood_provider.dart';
import '../providers/auth_provider.dart';
import '../app_theme.dart';
import 'mood_trends_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  void switchTab(int i) => setState(() => _tab = i);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final token = context.read<AuthProvider>().accessToken ?? '';
    final mood = context.read<MoodProvider>();
    if (!mood.isLoading) await mood.loadMoodHistory(token);
    if (!mounted) return;
    final aff = context.read<AffirmationProvider>();
    if (aff.affirmations.isEmpty) await aff.loadAllAffirmations();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _TodayTab(),
      const MoodTrendsScreen(),
      const _LibraryTab(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: MT.bg,
      body: IndexedStack(
        index: _tab,
        children: tabs,
      ),
      bottomNavigationBar: MTNavBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ─── Today Tab ────────────────────────────────────────────────────────────────

class _TodayTab extends StatelessWidget {
  const _TodayTab();

  String _dateLabel() {
    final now = DateTime.now();
    return DateFormat('EEEE · MMM d').format(now);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final firstName = auth.user?.name.split(' ').first ?? '';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_dateLabel(), style: MT.meta()),
                            const SizedBox(height: 3),
                            Text(
                              firstName.isNotEmpty
                                  ? '${_greeting()}, $firstName'
                                  : _greeting(),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: MT.ink,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            // Switch to Me tab via HomeScreen state
                            context
                                .findAncestorStateOfType<_HomeScreenState>()
                                ?.switchTab(3);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MT.box,
                              border: Border.all(color: MT.ink4),
                            ),
                            child: auth.user?.picture != null
                                ? ClipOval(
                                    child: Image.network(
                                      auth.user!.picture!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.person, size: 18, color: MT.ink3),
                                    ),
                                  )
                                : const Icon(Icons.person, size: 18, color: MT.ink3),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Affirmation hero card (dark)
                Consumer<AffirmationProvider>(
                  builder: (context, prov, _) {
                    final aff = prov.todaysAffirmation;
                    return MTDarkCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AFFIRMATION · TODAY',
                            style: MT.eyebrow(color: Colors.white54),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            aff?.cleanMessage ?? 'You are allowed to rest without earning it.',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: MT.paper,
                              height: 1.2,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                aff?.category != null
                                    ? '— ${aff!.category}'
                                    : '— self-compassion',
                                style: MT.meta(color: Colors.white38),
                              ),
                              GestureDetector(
                                onTap: () => prov.getNewAffirmation(),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: const Icon(Icons.refresh_rounded,
                                      size: 15, color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // Mood check-in row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: MT.ink,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/mood'),
                      child: Text('See all 10 ›', style: MT.meta()),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Mood chips (quick log)
                Consumer<MoodProvider>(
                  builder: (context, moodProv, _) {
                    final quickMoods = _quickMoods;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: quickMoods.map((m) {
                          final isCurrent =
                              moodProv.hasTodaysMood &&
                              moodProv.currentMood?.moodType == m['type'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/mood'),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 68,
                                height: 82,
                                decoration: BoxDecoration(
                                  color: isCurrent ? MT.ink : m['tint'] as Color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isCurrent
                                      ? null
                                      : Border.all(color: MT.ink4),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      m['emoji'] as String,
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      m['label'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w500,
                                        color: isCurrent ? MT.paper : MT.ink3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // Streak row
                Consumer<MoodProvider>(
                  builder: (context, moodProv, _) {
                    final streak = moodProv.moodStreak;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('STREAK', style: MT.eyebrow()),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$streak',
                                    style: GoogleFonts.inter(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: MT.ink,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' days',
                                    style: MT.body(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _StreakDots(streak: streak),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // CTA if mood logged today
                Consumer<MoodProvider>(
                  builder: (context, moodProv, _) {
                    if (!moodProv.hasTodaysMood) return const SizedBox.shrink();
                    return Column(
                      children: [
                        MTCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Text(
                                moodProv.currentMood!.moodEmoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "You're feeling ${moodProv.currentMood!.moodLabel.toLowerCase()}",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: MT.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'See personalized suggestions →',
                                      style: MT.meta(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: MTGhostButton(
                                label: 'View Suggestions',
                                onTap: () =>
                                    Navigator.pushNamed(context, '/suggestions'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: MTFilledButton(
                                label: 'Update Mood',
                                onTap: () =>
                                    Navigator.pushNamed(context, '/mood'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _quickMoods = [
    {'type': 'amazing', 'emoji': '🤩', 'label': 'AMAZING', 'tint': MT.sand},
    {'type': 'happy', 'emoji': '😊', 'label': 'HAPPY', 'tint': MT.sage},
    {'type': 'good', 'emoji': '🙂', 'label': 'GOOD', 'tint': MT.mist},
    {'type': 'neutral', 'emoji': '😐', 'label': 'OKAY', 'tint': MT.box},
    {'type': 'low', 'emoji': '😕', 'label': 'LOW', 'tint': MT.plum},
    {'type': 'sad', 'emoji': '😔', 'label': 'SAD', 'tint': MT.clay},
  ];
}

class _StreakDots extends StatelessWidget {
  final int streak;
  const _StreakDots({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final filled = i < streak.clamp(0, 6);
        final isToday = i == streak.clamp(0, 6);
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? MT.ink : Colors.transparent,
              border: Border.all(
                color: isToday ? MT.ink : MT.ink4,
                width: isToday ? 2 : 1.2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Library Tab ──────────────────────────────────────────────────────────────

class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Consumer<AffirmationProvider>(
            builder: (context, prov, _) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LIBRARY', style: MT.eyebrow()),
                          const SizedBox(height: 8),
                          Text('Affirmations', style: MT.headlineLg()),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  if (prov.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final aff = prov.affirmations[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: MTCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      aff.category.toUpperCase(),
                                      style: MT.eyebrow(),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      aff.cleanMessage,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: MT.ink,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: prov.affirmations.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
