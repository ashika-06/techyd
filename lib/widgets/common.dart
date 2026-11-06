import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'responsive.dart';

/// Card with a hover lift + border highlight (desktop) and tap handling.
class InteractiveCard extends StatefulWidget {
  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.hoverColor,
    this.radius = 16,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? hoverColor;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
          padding: widget.padding,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: _hover ? (widget.hoverColor ?? p.accent) : p.border,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final mobile = screenSizeOf(context) == ScreenSize.mobile;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(),
                    style: display(context, size: mobile ? 30 : 40)),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: TextStyle(color: p.muted, fontSize: 14)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: display(context, size: 20, spacing: 0.4),
            ),
          ),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: p.muted),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(action!),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: p.border),
              ),
              child: Icon(icon, size: 32, color: p.muted),
            ),
            const SizedBox(height: 18),
            Text(title.toUpperCase(),
                textAlign: TextAlign.center, style: display(context, size: 20)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.muted, height: 1.4)),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class CategoryPill extends StatelessWidget {
  const CategoryPill({super.key, required this.category});
  final EventCategory category;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final tone = category.tone(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: p.bg.withAlpha(215),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withAlpha(110)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 12, color: tone),
          const SizedBox(width: 5),
          Text(
            category.label.toUpperCase(),
            style: TextStyle(
              color: tone,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark / light toggle wired to ThemeProvider.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return IconButton(
      tooltip: theme.isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: theme.toggle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (c, a) => RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1).animate(a),
          child: FadeTransition(opacity: a, child: c),
        ),
        child: Icon(
          theme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(theme.isDark),
        ),
      ),
    );
  }
}
