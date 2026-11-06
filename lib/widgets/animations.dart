import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fade + slide-up entrance. Higher [index] = slightly slower, which gives a
/// staggered feel in lists and grids.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ms = 380 + (index > 8 ? 8 : index) * 80;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: child),
      ),
    );
  }
}

/// Number that counts up to [value].
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, this.style});
  final int value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('$v', style: style),
    );
  }
}

/// Live countdown (days / hours / mins / secs) to [target].
class Countdown extends StatefulWidget {
  const Countdown({super.key, required this.target});
  final DateTime target;

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;
  Duration _left = Duration.zero;

  void _tick() {
    final d = widget.target.difference(DateTime.now());
    _left = d.isNegative ? Duration.zero : d;
  }

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_tick);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final units = [
      ('DAYS', two(_left.inDays)),
      ('HRS', two(_left.inHours % 24)),
      ('MIN', two(_left.inMinutes % 60)),
      ('SEC', two(_left.inSeconds % 60)),
    ];
    return Row(
      children: [
        for (var i = 0; i < units.length; i++) ...[
          Expanded(child: _Unit(label: units[i].$1, value: units[i].$2)),
          if (i != units.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Unit extends StatelessWidget {
  const _Unit({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: Text(
              value,
              key: ValueKey(value),
              style: display(context, size: 26),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: p.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
