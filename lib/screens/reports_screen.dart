import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/events_provider.dart';
import '../widgets/animations.dart';
import '../widgets/app_chip.dart';
import '../widgets/common.dart';
import '../widgets/event_widgets.dart';
import '../widgets/responsive.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  EventCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventsProvider>();
    final pad = pagePadding(context);
    final reports = ev.reports
        .where((r) => _filter == null || r.category == _filter)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Event reports',
                subtitle: 'Recaps, highlights and takeaways from recent events',
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppChip(
                      label: 'All',
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final c in EventCategory.values) ...[
                      const SizedBox(width: 8),
                      AppChip(
                        label: c.label,
                        icon: c.icon,
                        color: c.color,
                        selected: _filter == c,
                        onTap: () =>
                            setState(() => _filter = _filter == c ? null : c),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: reports.isEmpty
                    ? const EmptyState(
                        key: ValueKey('empty'),
                        icon: Icons.article_outlined,
                        title: 'No reports yet',
                        message: 'There are no reports in this category yet.',
                      )
                    : ResponsiveWrap(
                        key: ValueKey(_filter),
                        minItemWidth: 340,
                        children: [
                          for (var i = 0; i < reports.length; i++)
                            FadeSlideIn(
                              index: i,
                              child: ReportCard(report: reports[i]),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
