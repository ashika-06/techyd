import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

/// Breakpoints used across the app (MediaQuery based).
ScreenSize screenSizeOf(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 700) return ScreenSize.mobile;
  if (w < 1100) return ScreenSize.tablet;
  return ScreenSize.desktop;
}

double pagePadding(BuildContext context) {
  switch (screenSizeOf(context)) {
    case ScreenSize.mobile:
      return 16;
    case ScreenSize.tablet:
      return 24;
    case ScreenSize.desktop:
      return 32;
  }
}

/// Centers content and caps its width on large screens.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.maxWidth = 1180});
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Lays children out in as many equal columns as fit (min width per item).
class ResponsiveWrap extends StatelessWidget {
  const ResponsiveWrap({
    super.key,
    required this.children,
    this.minItemWidth = 300,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      int cols = ((c.maxWidth + spacing) / (minItemWidth + spacing)).floor();
      if (cols < 1) cols = 1;
      final w = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    });
  }
}

/// Two fields side by side on wide layouts, stacked on narrow ones.
class TwoCol extends StatelessWidget {
  const TwoCol({super.key, required this.left, required this.right});
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth >= 520) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 14),
            Expanded(child: right),
          ],
        );
      }
      return Column(children: [left, const SizedBox(height: 16), right]);
    });
  }
}
