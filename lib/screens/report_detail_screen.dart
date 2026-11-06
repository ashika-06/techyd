import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/report.dart';
import '../providers/events_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/animations.dart';
import '../widgets/common.dart';
import '../widgets/responsive.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.reportId});
  final String reportId;

  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventsProvider>();
    final p = Pal.of(context);
    final pad = pagePadding(context);
    final mobile = screenSizeOf(context) == ScreenSize.mobile;

    EventReport? r;
    for (final x in ev.reports) {
      if (x.id == reportId) r = x;
    }

    if (r == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.article_outlined,
          title: 'Report not found',
          message: 'This report may have been removed.',
        ),
      );
    }
    final report = r;
    final tone = report.category.tone(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: SingleChildScrollView(
        child: MaxWidth(
          maxWidth: 800,
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 8, pad, 56),
            child: FadeSlideIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryPill(category: report.category),
                      const SizedBox(width: 12),
                      Text(fmtDateLong(report.date),
                          style: TextStyle(color: p.muted, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(report.headline,
                      style: display(context,
                          size: mobile ? 30 : 44, height: 1.05)),
                  const SizedBox(height: 14),
                  Text('${report.eventTitle} · ${report.venue}',
                      style: TextStyle(color: p.muted, fontSize: 15)),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(child: _Metric(label: 'Attendees', value: report.attendees)),
                      const SizedBox(width: 10),
                      Expanded(child: _Metric(label: 'Speakers', value: report.speakers)),
                      const SizedBox(width: 10),
                      Expanded(child: _Metric(label: 'Hours', value: report.hours)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Text(report.summary,
                      style: TextStyle(
                          fontSize: 17, height: 1.6, color: p.text.withAlpha(225))),

                  _Section(
                    title: 'Highlights',
                    items: report.highlights,
                    icon: Icons.bolt_rounded,
                    color: tone,
                  ),
                  _Section(
                    title: 'Key takeaways',
                    items: report.takeaways,
                    icon: Icons.lightbulb_outline_rounded,
                    color: tone,
                  ),
                  if (report.winners.isNotEmpty)
                    _Section(
                      title: 'Winners',
                      items: report.winners,
                      icon: Icons.emoji_events_outlined,
                      color: tone,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountUp(value: value, style: display(context, size: 32)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: p.muted, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 36, bottom: 14),
          child: Text(title.toUpperCase(),
              style: display(context, size: 18, spacing: 0.6)),
        ),
        for (final item in items)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item,
                      style: const TextStyle(fontSize: 15, height: 1.4)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
