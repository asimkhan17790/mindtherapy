import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/mood_provider.dart';
import '../app_theme.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? _selectedMood;

  static const _moods = [
    {'type': 'amazing', 'label': 'Amazing'},
    {'type': 'happy',   'label': 'Happy'},
    {'type': 'good',    'label': 'Good'},
    {'type': 'neutral', 'label': 'Neutral'},
    {'type': 'low',     'label': 'Low'},
    {'type': 'sad',     'label': 'Sad'},
    {'type': 'anxious', 'label': 'Anxious'},
    {'type': 'angry',   'label': 'Angry'},
    {'type': 'tired',   'label': 'Tired'},
    {'type': 'stressed','label': 'Stressed'},
  ];

  Future<void> _submit() async {
    if (_selectedMood == null) return;
    await context.read<MoodProvider>().submitMood(
          _selectedMood!,
          '',
          'user123',
          intensity: 3,
        );
    if (mounted) {
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
      backgroundColor: MT.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Nav row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MTBackButton(),
                      Text('STEP 1 OF 2', style: MT.eyebrow()),
                      const SizedBox(width: 36),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Headline
                  Column(
                    children: [
                      Text('Tap what fits.',
                          style: MT.headlineLg(), textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(
                        'It can be more than one thing.',
                        style: MT.body(color: MT.ink3),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Circle
                  Expanded(
                    child: Center(
                      child: _MoodCircle(
                        moods: _moods,
                        selected: _selectedMood,
                        onSelect: (t) => setState(() => _selectedMood = t),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Consumer<MoodProvider>(
                    builder: (context, prov, _) => MTFilledButton(
                      label: 'Continue →',
                      loading: prov.isLoading,
                      onTap: _selectedMood != null ? _submit : null,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Circular picker ──────────────────────────────────────────────────────────

class _MoodCircle extends StatelessWidget {
  final List<Map<String, String>> moods;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _MoodCircle({
    required this.moods,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rawSize = min(constraints.maxWidth, constraints.maxHeight);
        final size = rawSize.clamp(240.0, 340.0);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Dashed ring border
              Positioned.fill(
                child: CustomPaint(painter: _RingPainter()),
              ),

              // Nodes
              ...List.generate(moods.length, (i) {
                const nodeSize = 54.0;
                final center = size / 2;
                final radius = size / 2 - nodeSize / 2 - 4;
                final angle = (2 * pi * i / moods.length) - (pi / 2);
                final x = center + radius * cos(angle) - nodeSize / 2;
                final y = center + radius * sin(angle) - nodeSize / 2;
                final isSelected = selected == moods[i]['type'];

                return Positioned(
                  left: x,
                  top: y,
                  child: _MoodNode(
                    mood: moods[i],
                    isSelected: isSelected,
                    onTap: () => onSelect(moods[i]['type']!),
                  ),
                );
              }),

              // Center readout
              Center(
                child: Container(
                  width: size * 0.30,
                  height: size * 0.30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MT.paper,
                    border: Border.all(color: MT.ink4),
                  ),
                  child: Center(
                    child: selected != null
                        ? Text(
                            moods.firstWhere(
                                (m) => m['type'] == selected)['label']!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: MT.ink,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            'tap\na mood',
                            textAlign: TextAlign.center,
                            style: MT.meta(color: MT.ink4)
                                .copyWith(fontSize: 9),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Mood node ────────────────────────────────────────────────────────────────

class _MoodNode extends StatelessWidget {
  final Map<String, String> mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodNode({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  static Color _faceColor(String type) {
    const map = {
      'amazing':  Color(0xFFC8A870), // warm honey
      'happy':    Color(0xFF90AA86), // sage green
      'good':     Color(0xFF8AADA8), // soft teal
      'neutral':  Color(0xFFADABA6), // warm gray
      'low':      Color(0xFFC09A94), // dusty rose
      'sad':      Color(0xFF8EA0BE), // muted slate
      'anxious':  Color(0xFFA698C2), // soft lavender
      'angry':    Color(0xFFBE8E7E), // muted terracotta
      'tired':    Color(0xFFAAA898), // warm khaki
      'stressed': Color(0xFFB29098), // dusty mauve
    };
    return map[type] ?? const Color(0xFFADABA6);
  }

  @override
  Widget build(BuildContext context) {
    final faceColor = _faceColor(mood['type']!);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: faceColor,
          border: Border.all(
            color: isSelected ? MT.ink : Colors.transparent,
            width: isSelected ? 2.5 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MT.ink.withOpacity(0.22),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: CustomPaint(
          painter: _FacePainter(type: mood['type']!),
        ),
      ),
    );
  }
}

// ─── Face painter ─────────────────────────────────────────────────────────────

class _FacePainter extends CustomPainter {
  final String type;

  const _FacePainter({required this.type});

  static final _featurePaint = Paint()
    ..color = const Color(0xFF2A2520)
    ..style = PaintingStyle.fill;

  static Paint get _strokePaint => Paint()
    ..color = const Color(0xFF2A2520)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // ── Eyes ───────────────────────────────────────────────────────────────────

  void _dotEyes(Canvas c, double w, double h) {
    final r = w * 0.068;
    c.drawCircle(Offset(w * 0.36, h * 0.40), r, _featurePaint);
    c.drawCircle(Offset(w * 0.64, h * 0.40), r, _featurePaint);
  }

  void _shineEyes(Canvas c, double w, double h) {
    _dotEyes(c, w, h);
    // small white shine dot
    final shinePaint = Paint()..color = Colors.white.withOpacity(0.7);
    c.drawCircle(Offset(w * 0.375, h * 0.375), w * 0.025, shinePaint);
    c.drawCircle(Offset(w * 0.655, h * 0.375), w * 0.025, shinePaint);
  }

  void _halfClosedEyes(Canvas c, double w, double h) {
    final p = _strokePaint..strokeWidth = 2.0;
    // Draw flat-bottomed arcs (U shape inverted = sleeping)
    final rect1 = Rect.fromCenter(
        center: Offset(w * 0.36, h * 0.40), width: w * 0.16, height: w * 0.12);
    final rect2 = Rect.fromCenter(
        center: Offset(w * 0.64, h * 0.40), width: w * 0.16, height: w * 0.12);
    c.drawArc(rect1, 0, pi, false, p);
    c.drawArc(rect2, 0, pi, false, p);
  }

  void _xEyes(Canvas c, double w, double h) {
    final p = _strokePaint..strokeWidth = 2.0;
    final r = w * 0.07;
    c.drawLine(Offset(w * 0.36 - r, h * 0.40 - r),
        Offset(w * 0.36 + r, h * 0.40 + r), p);
    c.drawLine(Offset(w * 0.36 + r, h * 0.40 - r),
        Offset(w * 0.36 - r, h * 0.40 + r), p);
    c.drawLine(Offset(w * 0.64 - r, h * 0.40 - r),
        Offset(w * 0.64 + r, h * 0.40 + r), p);
    c.drawLine(Offset(w * 0.64 + r, h * 0.40 - r),
        Offset(w * 0.64 - r, h * 0.40 + r), p);
  }

  // ── Mouths ─────────────────────────────────────────────────────────────────

  void _bigSmile(Canvas c, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.28, h * 0.60)
      ..quadraticBezierTo(w * 0.50, h * 0.80, w * 0.72, h * 0.60);
    c.drawPath(path, _strokePaint..strokeWidth = 2.2);
  }

  void _smile(Canvas c, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.32, h * 0.62)
      ..quadraticBezierTo(w * 0.50, h * 0.76, w * 0.68, h * 0.62);
    c.drawPath(path, _strokePaint..strokeWidth = 2.0);
  }

  void _slightSmile(Canvas c, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.35, h * 0.64)
      ..quadraticBezierTo(w * 0.50, h * 0.72, w * 0.65, h * 0.64);
    c.drawPath(path, _strokePaint..strokeWidth = 2.0);
  }

  void _flatMouth(Canvas c, double w, double h) {
    c.drawLine(
        Offset(w * 0.34, h * 0.66), Offset(w * 0.66, h * 0.66), _strokePaint..strokeWidth = 2.0);
  }

  void _slightFrown(Canvas c, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.35, h * 0.68)
      ..quadraticBezierTo(w * 0.50, h * 0.60, w * 0.65, h * 0.68);
    c.drawPath(path, _strokePaint..strokeWidth = 2.0);
  }

  void _frown(Canvas c, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.32, h * 0.70)
      ..quadraticBezierTo(w * 0.50, h * 0.58, w * 0.68, h * 0.70);
    c.drawPath(path, _strokePaint..strokeWidth = 2.0);
  }

  void _wavyMouth(Canvas c, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.32, h * 0.65)
      ..cubicTo(w * 0.40, h * 0.60, w * 0.45, h * 0.70, w * 0.50, h * 0.65)
      ..cubicTo(w * 0.55, h * 0.60, w * 0.60, h * 0.70, w * 0.68, h * 0.65);
    c.drawPath(path, _strokePaint..strokeWidth = 2.0);
  }

  // ── Eyebrows ───────────────────────────────────────────────────────────────

  void _angryBrows(Canvas c, double w, double h) {
    final p = _strokePaint..strokeWidth = 2.0;
    // Slope downward toward nose bridge
    c.drawLine(Offset(w * 0.27, h * 0.27), Offset(w * 0.44, h * 0.32), p);
    c.drawLine(Offset(w * 0.56, h * 0.32), Offset(w * 0.73, h * 0.27), p);
  }

  void _worriedBrows(Canvas c, double w, double h) {
    final p = _strokePaint..strokeWidth = 2.0;
    // Slope upward toward nose bridge
    c.drawLine(Offset(w * 0.27, h * 0.32), Offset(w * 0.44, h * 0.27), p);
    c.drawLine(Offset(w * 0.56, h * 0.27), Offset(w * 0.73, h * 0.32), p);
  }

  // ── Cheek blush ────────────────────────────────────────────────────────────

  void _blush(Canvas c, double w, double h) {
    final p = Paint()
      ..color = const Color(0xFFE8A0A0).withOpacity(0.45)
      ..style = PaintingStyle.fill;
    c.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.24, h * 0.56), width: w * 0.16, height: w * 0.10),
        p);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.76, h * 0.56), width: w * 0.16, height: w * 0.10),
        p);
  }

  // ── Per-mood draw ──────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case 'amazing':
        _shineEyes(canvas, w, h);
        _bigSmile(canvas, w, h);
        _blush(canvas, w, h);
      case 'happy':
        _shineEyes(canvas, w, h);
        _smile(canvas, w, h);
      case 'good':
        _dotEyes(canvas, w, h);
        _slightSmile(canvas, w, h);
      case 'neutral':
        _dotEyes(canvas, w, h);
        _flatMouth(canvas, w, h);
      case 'low':
        _dotEyes(canvas, w, h);
        _slightFrown(canvas, w, h);
      case 'sad':
        _dotEyes(canvas, w, h);
        _frown(canvas, w, h);
      case 'anxious':
        _worriedBrows(canvas, w, h);
        _dotEyes(canvas, w, h);
        _wavyMouth(canvas, w, h);
      case 'angry':
        _angryBrows(canvas, w, h);
        _dotEyes(canvas, w, h);
        _frown(canvas, w, h);
      case 'tired':
        _halfClosedEyes(canvas, w, h);
        _flatMouth(canvas, w, h);
      case 'stressed':
        _worriedBrows(canvas, w, h);
        _xEyes(canvas, w, h);
        _slightFrown(canvas, w, h);
    }
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.type != type;
}

// ─── Ring painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = MT.ink4
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    const dashLen = 6.0;
    const gapLen = 5.0;
    final circumference = 2 * pi * radius;
    final totalDashes = (circumference / (dashLen + gapLen)).floor();
    final actualDashAngle = (dashLen / circumference) * 2 * pi;
    final actualGapAngle = (gapLen / circumference) * 2 * pi;

    double angle = 0;
    for (int i = 0; i < totalDashes; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        actualDashAngle,
        false,
        dashPaint,
      );
      angle += actualDashAngle + actualGapAngle;
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}
