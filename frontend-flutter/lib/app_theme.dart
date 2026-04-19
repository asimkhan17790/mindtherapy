import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class MT {
  // Palette
  static const Color bg = Color(0xFFF4EFE5);
  static const Color paper = Color(0xFFFBF8F2);
  static const Color ink = Color(0xFF23201C);
  static const Color ink2 = Color(0xFF524D45);
  static const Color ink3 = Color(0xFF8F877B);
  static const Color ink4 = Color(0xFFC7BFB1);
  static const Color box = Color(0xFFE6E0D2);
  static const Color box2 = Color(0xFFD1C9B7);
  static const Color accent = Color(0xFFB85C3A);

  // Tint palettes
  static const Color sand = Color(0xFFE7DDC8);
  static const Color sandD = Color(0xFFD3C6AA);
  static const Color sage = Color(0xFFCFD5C3);
  static const Color sageD = Color(0xFFA9B297);
  static const Color clay = Color(0xFFE3C9B8);
  static const Color clayD = Color(0xFFC9A992);
  static const Color mist = Color(0xFFD4D8D6);
  static const Color mistD = Color(0xFFAEB5B1);
  static const Color plum = Color(0xFFD6CDD3);
  static const Color plumD = Color(0xFFB2A3AC);

  // Shared shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF23201C).withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: const Color(0xFF23201C).withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  // Text styles
  static TextStyle eyebrow({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.4,
        color: color ?? MT.ink3,
      );

  static TextStyle headlineXl({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.64,
        color: color ?? MT.ink,
        height: 1.08,
      );

  static TextStyle headlineLg({Color? color}) => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.52,
        color: color ?? MT.ink,
        height: 1.1,
      );

  static TextStyle headlineMd({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: color ?? MT.ink,
        height: 1.15,
      );

  static TextStyle headlineSm({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        color: color ?? MT.ink,
        height: 1.25,
      );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        color: color ?? MT.ink2,
        height: 1.55,
      );

  static TextStyle meta({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        color: color ?? MT.ink3,
        letterSpacing: 0.4,
      );

  static TextStyle pill({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        color: color ?? MT.ink2,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w500,
      );
}

// ─── Press-scale wrapper ──────────────────────────────────────────────────────

class MTPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HitTestBehavior? behavior;

  const MTPressable({
    super.key,
    required this.child,
    this.onTap,
    this.behavior,
  });

  @override
  State<MTPressable> createState() => _MTPressableState();
}

class _MTPressableState extends State<MTPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: widget.behavior ?? HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ─── Shared widget primitives ─────────────────────────────────────────────────

class MTCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? borderColor;
  final bool elevated;

  const MTCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? MT.paper,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: Border.all(color: borderColor ?? MT.ink4.withOpacity(0.7)),
        boxShadow: elevated ? MT.cardShadow : [
          BoxShadow(
            color: const Color(0xFF23201C).withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MTDarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const MTDarkCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MT.ink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF23201C).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MTPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Color? color;

  const MTPill({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return MTPressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? MT.ink : (color ?? MT.box),
          borderRadius: BorderRadius.circular(999),
          border: active ? null : Border.all(color: MT.ink4),
        ),
        child: Center(
          child: Text(
            label,
            style: MT.pill(color: active ? MT.paper : MT.ink2),
          ),
        ),
      ),
    );
  }
}

class MTFilledButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const MTFilledButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
  });

  @override
  State<MTFilledButton> createState() => _MTFilledButtonState();
}

class _MTFilledButtonState extends State<MTFilledButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null && !widget.loading;
    return GestureDetector(
      onTap: widget.loading ? null : widget.onTap,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.55,
          duration: const Duration(milliseconds: 150),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: widget.onTap != null ? MT.ink : MT.box2,
              borderRadius: BorderRadius.circular(999),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: MT.ink.withOpacity(0.20),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: MT.paper,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.onTap != null ? MT.paper : MT.ink3,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class MTGhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const MTGhostButton({super.key, required this.label, this.onTap});

  @override
  State<MTGhostButton> createState() => _MTGhostButtonState();
}

class _MTGhostButtonState extends State<MTGhostButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: _pressed ? MT.box : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: MT.ink),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: MT.ink,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MTBackButton extends StatelessWidget {
  const MTBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MTPressable(
      onTap: () => Navigator.maybePop(context),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MT.ink, width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back, size: 16, color: MT.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class MTNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MTNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'TODAY'),
      (Icons.trending_up_outlined, Icons.trending_up_rounded, 'TRENDS'),
      (Icons.auto_stories_outlined, Icons.auto_stories_rounded, 'LIBRARY'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'ME'),
    ];

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: MT.paper,
        border: const Border(top: BorderSide(color: MT.ink4, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: MT.ink.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          final (outlineIcon, filledIcon, label) = items[i];
          return _NavItem(
            active: active,
            outlineIcon: outlineIcon,
            filledIcon: filledIcon,
            label: label,
            onTap: () => onTap(i),
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final bool active;
  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.active,
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.active ? MT.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: widget.active
                      ? null
                      : Border.all(color: MT.ink3, width: 1.3),
                ),
                child: Icon(
                  widget.active ? widget.filledIcon : widget.outlineIcon,
                  size: 13,
                  color: widget.active ? MT.paper : MT.ink3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  letterSpacing: 0.6,
                  color: widget.active ? MT.ink : MT.ink3,
                  fontWeight:
                      widget.active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MTLogoMark extends StatelessWidget {
  final double size;
  const MTLogoMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: MT.ink, width: size * 0.04),
      ),
      child: Center(
        child: Container(
          width: size * 0.43,
          height: size * 0.43,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: MT.ink,
          ),
        ),
      ),
    );
  }
}
