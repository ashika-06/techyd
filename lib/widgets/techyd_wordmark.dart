import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Minimal TECHYD logotype: heavy uppercase grotesque + a lime dot.
class TechydWordmark extends StatelessWidget {
  const TechydWordmark({super.key, this.size = 22, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'TECHYD',
          style: GoogleFonts.archivo(
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: size * 0.1,
            height: 1,
            color: color ?? p.text,
          ),
        ),
        SizedBox(width: size * 0.12),
        Padding(
          padding: EdgeInsets.only(bottom: size * 0.08),
          child: Container(
            width: size * 0.26,
            height: size * 0.26,
            decoration: const BoxDecoration(
              color: Pal.lime,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

/// Runs [child] inside the dark theme (used on top of photos).
class DarkScope extends StatelessWidget {
  const DarkScope({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(data: AppTheme.dark, child: child);
  }
}
