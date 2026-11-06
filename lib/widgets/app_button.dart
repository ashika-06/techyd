import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable primary / outlined button with loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.loading = false,
    this.expand = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool loading;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final pad = EdgeInsets.symmetric(
        horizontal: compact ? 16 : 22, vertical: compact ? 12 : 17);

    final content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: outlined ? p.text : p.onAccent,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              // Flexible only when the button is full-width; inside a Row with
              // unbounded width (e.g. page header) it would throw.
              if (expand)
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis))
              else
                Text(label),
            ],
          );

    const textStyle = TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2);

    final Widget button = outlined
        ? OutlinedButton(
            onPressed: loading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: p.text,
              side: BorderSide(color: p.border),
              shape: shape,
              padding: pad,
              textStyle: textStyle,
            ),
            child: content,
          )
        : ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: p.accent,
              foregroundColor: p.onAccent,
              disabledBackgroundColor: p.surfaceAlt,
              disabledForegroundColor: p.muted,
              elevation: 0,
              shape: shape,
              padding: pad,
              textStyle: textStyle,
            ),
            child: content,
          );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
