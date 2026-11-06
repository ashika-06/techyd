import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Techyd palette: near-black surfaces + a single acid-lime accent.
/// Light mode flips to off-white surfaces with a black accent.
class Pal {
  const Pal({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
  });

  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color text;
  final Color muted;
  final Color accent;
  final Color onAccent;

  static const Color lime = Color(0xFFC8FF3D);

  static const Pal dark = Pal(
    bg: Color(0xFF0A0A0A),
    surface: Color(0xFF131313),
    surfaceAlt: Color(0xFF1B1B1B),
    border: Color(0xFF282828),
    text: Color(0xFFF5F5F5),
    muted: Color(0xFF8C8C8C),
    accent: lime,
    onAccent: Color(0xFF0A0A0A),
  );

  static const Pal light = Pal(
    bg: Color(0xFFF5F5F2),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEDEDE9),
    border: Color(0xFFDCDCD6),
    text: Color(0xFF0A0A0A),
    muted: Color(0xFF6A6A6A),
    accent: Color(0xFF0A0A0A),
    onAccent: lime,
  );

  static Pal of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Bold, tight, uppercase-friendly display style (Archivo) used for headings.
TextStyle display(
  BuildContext context, {
  double size = 32,
  Color? color,
  FontWeight weight = FontWeight.w800,
  double spacing = -0.5,
  double height = 1.05,
}) {
  return GoogleFonts.archivo(
    fontSize: size,
    fontWeight: weight,
    letterSpacing: spacing,
    height: height,
    color: color ?? Pal.of(context).text,
  );
}

class AppTheme {
  static final ThemeData dark = _build(Brightness.dark);
  static final ThemeData light = _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final p = b == Brightness.dark ? Pal.dark : Pal.light;
    final base = ThemeData(brightness: b, useMaterial3: true);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    const errorColor = Color(0xFFFF5C5C);

    return base.copyWith(
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.surface,
      dividerColor: p.border,
      colorScheme: ColorScheme.fromSeed(seedColor: p.accent, brightness: b)
          .copyWith(
        primary: p.accent,
        onPrimary: p.onAccent,
        surface: p.surface,
        onSurface: p.text,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme)
          .apply(bodyColor: p.text, displayColor: p.text),
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(p.border),
        enabledBorder: border(p.border),
        focusedBorder: border(p.accent, 1.6),
        errorBorder: border(errorColor),
        focusedErrorBorder: border(errorColor, 1.6),
        labelStyle: TextStyle(color: p.muted),
        floatingLabelStyle: TextStyle(color: p.text),
        hintStyle: TextStyle(color: p.muted.withAlpha(160)),
        errorStyle: const TextStyle(color: errorColor),
        prefixIconColor: p.muted,
        suffixIconColor: p.muted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceAlt,
        contentTextStyle: TextStyle(color: p.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: p.border),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: p.muted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
