import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/animations.dart';
import '../widgets/app_button.dart';
import '../widgets/app_chip.dart';
import '../widgets/common.dart';
import '../widgets/event_widgets.dart';
import '../widgets/responsive.dart';
import '../widgets/techyd_wordmark.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  /// Switches the bottom/side navigation tab (0 home, 1 events, 2 reports...).
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventsProvider>();
    final auth = context.watch<AuthProvider>();
    final p = Pal.of(context);
    final size = screenSizeOf(context);
    final mobile = size == ScreenSize.mobile;
    final pad = pagePadding(context);

    final upcoming = ev.upcoming;
    final soon = upcoming.take(6).toList();
    final featured = upcoming.skip(6).take(3).toList();
    final next = upcoming.isEmpty ? null : upcoming.first;
    final name = auth.user?.name.split(' ').first;

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- top bar ----
              Row(
                children: [
                  if (mobile)
                    const TechydWordmark(size: 22)
                  else
                    Text(
                      name == null ? greeting() : '${greeting()}, $name',
                      style: TextStyle(color: p.muted, fontSize: 15),
                    ),
                  const Spacer(),
                  if (mobile) const ThemeToggleButton(),
                ],
              ),
              const SizedBox(height: 16),

              // ---- hero ----
              FadeSlideIn(
                child: _Hero(
                  mobile: mobile,
                  greetingText: name == null ? greeting() : '${greeting()}, $name',
                  onExplore: () => onNavigate(1),
                  onReports: () => onNavigate(2),
                ),
              ),
              const SizedBox(height: 16),

              // ---- stats ----
              FadeSlideIn(
                index: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(
                          label: 'Upcoming events', value: upcoming.length),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                          label: 'Event reports', value: ev.reports.length),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                          label: 'My tickets', value: ev.registrations.length),
                    ),
                  ],
                ),
              ),

              // ---- next up ----
              if (next != null) ...[
                const SizedBox(height: 16),
                FadeSlideIn(index: 2, child: _NextUp(event: next)),
              ],

              // ---- happening soon (horizontal list) ----
              SectionHeader(
                title: 'Happening soon',
                action: 'All events',
                onAction: () => onNavigate(1),
              ),
              SizedBox(
                height: 316,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: soon.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, i) => SizedBox(
                    width: 300,
                    child: EventCard(event: soon[i], hero: false),
                  ),
                ),
              ),

              // ---- categories ----
              const SectionHeader(title: 'Browse by category'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in EventCategory.values)
                    AppChip(
                      label: c.label,
                      icon: c.icon,
                      selected: false,
                      onTap: () {
                        context.read<EventsProvider>().clearFilters();
                        context.read<EventsProvider>().setCategory(c);
                        onNavigate(1);
                      },
                    ),
                ],
              ),

              // ---- featured ----
              if (featured.isNotEmpty) ...[
                SectionHeader(
                  title: 'More to explore',
                  action: 'See all',
                  onAction: () => onNavigate(1),
                ),
                EventGridView(events: featured),
              ],

              // ---- reports ----
              SectionHeader(
                title: 'Latest reports',
                action: 'All reports',
                onAction: () => onNavigate(2),
              ),
              ResponsiveWrap(
                minItemWidth: 320,
                children: [
                  for (final r in ev.reports.take(3)) ReportCard(report: r),
                ],
              ),

              // ---- CTA ----
              const SizedBox(height: 40),
              InteractiveCard(
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HOSTING SOMETHING?',
                              style: display(context, size: 22)),
                          const SizedBox(height: 6),
                          Text(
                            'Submit your event and it shows up for the whole community.',
                            style: TextStyle(color: p.muted),
                          ),
                        ],
                      ),
                    ),
                    AppButton(
                      label: 'Submit an event',
                      icon: Icons.add_rounded,
                      onPressed: () => Navigator.pushNamed(context, Routes.submit),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  'Techyd · demo project · all events and reports are sample data',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.muted.withAlpha(170), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.mobile,
    required this.greetingText,
    required this.onExplore,
    required this.onReports,
  });

  final bool mobile;
  final String greetingText;
  final VoidCallback onExplore;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    return DarkScope(
      child: Builder(builder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: mobile ? 340 : 400,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/hyd_night.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Pal.dark.surface),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(40),
                        Colors.black.withAlpha(120),
                        Colors.black.withAlpha(235),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(mobile ? 20 : 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        greetingText.toUpperCase(),
                        style: const TextStyle(
                          color: Pal.lime,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'WHAT’S HAPPENING\nIN HYDERABAD TECH.',
                        style: display(
                          context,
                          size: mobile ? 30 : 52,
                          color: Colors.white,
                          weight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          AppButton(
                            label: 'Explore events',
                            icon: Icons.arrow_forward_rounded,
                            compact: mobile,
                            onPressed: onExplore,
                          ),
                          AppButton(
                            label: 'Read reports',
                            outlined: true,
                            compact: mobile,
                            onPressed: onReports,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountUp(value: value, style: display(context, size: 32)),
          const SizedBox(height: 4),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: p.muted, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _NextUp extends StatelessWidget {
  const _NextUp({required this.event});
  final TechEvent event;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final mobile = screenSizeOf(context) == ScreenSize.mobile;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: event.category.tone(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('NEXT UP',
                style: TextStyle(
                    color: p.muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6)),
          ],
        ),
        const SizedBox(height: 10),
        Text(event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: display(context, size: 22, height: 1.15, spacing: -0.2)),
        const SizedBox(height: 8),
        Text(
          '${fmtDate(event.start)} · ${fmtTime(event.start)} · ${event.venue}',
          style: TextStyle(color: p.muted, fontSize: 13),
        ),
      ],
    );

    return InteractiveCard(
      padding: const EdgeInsets.all(20),
      hoverColor: event.category.color,
      onTap: () => Navigator.pushNamed(context, Routes.event, arguments: event.id),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 18),
                Countdown(target: event.start),
              ],
            )
          : Row(
              children: [
                Expanded(child: info),
                const SizedBox(width: 24),
                SizedBox(width: 360, child: Countdown(target: event.start)),
              ],
            ),
    );
  }
}
