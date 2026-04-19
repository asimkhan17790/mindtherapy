import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: MT.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign out?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: MT.ink)),
        content: Text('You will need to sign back in to access your data.',
            style: MT.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: MT.body(color: MT.ink3)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: Text('Sign out',
                style: MT.body(color: const Color(0xFFC0392B))),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    final auth = context.read<AuthProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await auth.signOut();
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Consumer2<AuthProvider, MoodProvider>(
            builder: (context, auth, mood, _) {
              final user = auth.user;
              final streak = mood.moodStreak;
              final totalCheckins = mood.moodHistory.length;
              final monthLabel =
                  '${DateFormat('MMMM').format(DateTime.now())}, so far';

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: MT.box,
                                border: Border.all(color: MT.ink4),
                              ),
                              child: user?.picture != null
                                  ? ClipOval(
                                      child: Image.network(
                                        user!.picture!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.person,
                                                size: 18, color: MT.ink3),
                                      ),
                                    )
                                  : const Icon(Icons.person,
                                      size: 18, color: MT.ink3),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'You',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: MT.ink,
                                  ),
                                ),
                                if (user?.email != null)
                                  Text(user!.email, style: MT.meta()),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/settings'),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: MT.ink, width: 1.5),
                            ),
                            child: const Icon(Icons.more_horiz_rounded,
                                size: 16, color: MT.ink),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Narrative header
                    Text('OVERVIEW', style: MT.eyebrow()),
                    const SizedBox(height: 8),
                    Text(monthLabel, style: MT.headlineLg()),

                    const SizedBox(height: 20),

                    // Stats: avg mood chart placeholder
                    MTCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AVG MOOD', style: MT.eyebrow()),
                                  const SizedBox(height: 4),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: mood.moodHistory.isEmpty
                                              ? '—'
                                              : _avgMoodLabel(mood),
                                          style: GoogleFonts.inter(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: MT.ink,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('CHECK-INS', style: MT.eyebrow()),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$totalCheckins',
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: MT.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _MoodBars(moodHistory: mood.moodHistory),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                mood.moodHistory.isNotEmpty
                                    ? DateFormat('MMM d').format(
                                        mood.moodHistory.last.timestamp)
                                    : '',
                                style: MT.meta(),
                              ),
                              Text('Today', style: MT.meta()),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2-up stats
                    Row(
                      children: [
                        Expanded(
                          child: MTDarkCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('STREAK',
                                    style: MT.eyebrow(
                                        color: Colors.white54)),
                                const SizedBox(height: 10),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$streak',
                                        style: GoogleFonts.inter(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          color: MT.paper,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'd',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Keep it up!',
                                  style: MT.meta(color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MTCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('MOST FELT', style: MT.eyebrow()),
                                const SizedBox(height: 10),
                                Text(
                                  _mostFelt(mood),
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: MT.ink,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  mood.moodHistory.isEmpty
                                      ? '0% of days'
                                      : '${_mostFeltPct(mood)}% of days',
                                  style: MT.meta(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Settings condensed
                    MTCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SettingRow(
                            label: 'Settings & reminders',
                            trailing: '›',
                            onTap: () =>
                                Navigator.pushNamed(context, '/settings'),
                            showDivider: true,
                          ),
                          _SettingRow(
                            label: 'Help & feedback',
                            trailing: '›',
                            onTap: () {},
                            showDivider: true,
                          ),
                          _SettingRow(
                            label: 'Sign out',
                            trailing: '›',
                            onTap: _showLogoutConfirmation,
                            labelColor: MT.ink3,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _avgMoodLabel(MoodProvider mood) {
    final moods = mood.moodHistory;
    if (moods.isEmpty) return '—';
    final moodScores = {
      'amazing': 5,
      'happy': 4,
      'good': 4,
      'neutral': 3,
      'low': 2,
      'sad': 2,
      'anxious': 2,
      'angry': 1,
      'tired': 2,
      'stressed': 1,
    };
    final sum = moods
        .map((m) => moodScores[m.moodType] ?? 3)
        .reduce((a, b) => a + b);
    final avg = sum / moods.length;
    return avg.toStringAsFixed(1);
  }

  String _mostFelt(MoodProvider mood) {
    if (mood.moodHistory.isEmpty) return '—';
    final freq = <String, int>{};
    for (final m in mood.moodHistory) {
      freq[m.moodType] = (freq[m.moodType] ?? 0) + 1;
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first.key;
    return top[0].toUpperCase() + top.substring(1);
  }

  int _mostFeltPct(MoodProvider mood) {
    if (mood.moodHistory.isEmpty) return 0;
    final freq = <String, int>{};
    for (final m in mood.moodHistory) {
      freq[m.moodType] = (freq[m.moodType] ?? 0) + 1;
    }
    final max = freq.values.reduce((a, b) => a > b ? a : b);
    return ((max / mood.moodHistory.length) * 100).round();
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String trailing;
  final VoidCallback onTap;
  final Color? labelColor;
  final bool showDivider;

  const _SettingRow({
    required this.label,
    required this.trailing,
    required this.onTap,
    this.labelColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: labelColor ?? MT.ink,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(trailing, style: MT.meta()),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: MT.ink4.withOpacity(0.6)),
      ],
    );
  }
}

class _MoodBars extends StatelessWidget {
  final List<dynamic> moodHistory;

  const _MoodBars({required this.moodHistory});

  @override
  Widget build(BuildContext context) {
    final scores = {
      'amazing': 1.0, 'happy': 0.85, 'good': 0.75, 'neutral': 0.6,
      'low': 0.4, 'sad': 0.35, 'anxious': 0.35, 'tired': 0.4,
      'angry': 0.2, 'stressed': 0.3,
    };

    final recent = moodHistory.length > 14
        ? moodHistory.sublist(moodHistory.length - 14)
        : moodHistory;

    if (recent.isEmpty) {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: MT.box,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: recent.map((m) {
          final h = (scores[m.moodType] ?? 0.5);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: FractionallySizedBox(
                heightFactor: h,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: h > 0.6 ? MT.ink : MT.box2,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
