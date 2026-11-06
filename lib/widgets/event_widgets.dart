import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../models/report.dart';
import '../providers/events_provider.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'animations.dart';
import 'common.dart';

/// Generated cover art for an event: dark grid + category glow + icon.
class EventBanner extends StatelessWidget {
  const EventBanner({super.key, required this.event, this.large = false});
  final TechEvent event;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final c = event.category;
    return Container(
      color: p.surfaceAlt,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _GridPainter(line: p.border.withAlpha(130), glow: c.color),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(large ? 28 : 14),
              child: Icon(
                c.icon,
                size: large ? 120 : 52,
                color: c.tone(context).withAlpha(large ? 95 : 140),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.line, required this.glow});
  final Color line;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [glow.withAlpha(75), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.15),
        radius: size.shortestSide * 1.2,
      ));
    canvas.drawRect(rect, glowPaint);

    final paint = Paint()
      ..color = line
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.line != line || old.glow != glow;
}

/// Animated bookmark toggle bound to EventsProvider.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final ev = context.watch<EventsProvider>();
    final on = ev.isBookmarked(eventId);
    return IconButton(
      tooltip: on ? 'Remove bookmark' : 'Bookmark',
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(backgroundColor: p.bg.withAlpha(150)),
      onPressed: () => ev.toggleBookmark(eventId),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          on ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          key: ValueKey(on),
          size: 22,
          color: on ? p.accent : p.text,
        ),
      ),
    );
  }
}

/// Card used in grids and horizontal lists. Fixed content height: 316.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, this.hero = true});
  final TechEvent event;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final ev = context.watch<EventsProvider>();
    final e = event;
    final left = ev.seatsLeft(e);

    final banner = EventBanner(event: e);

    return InteractiveCard(
      hoverColor: e.category.color,
      onTap: () => Navigator.pushNamed(context, Routes.event, arguments: e.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 108,
            child: Stack(
              children: [
                Positioned.fill(
                  child: hero ? Hero(tag: 'banner-${e.id}', child: banner) : banner,
                ),
                Positioned(top: 10, left: 10, child: CategoryPill(category: e.category)),
                Positioned(top: 4, right: 4, child: BookmarkButton(eventId: e.id)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    text: '${fmtDate(e.start)} · ${fmtTime(e.start)}',
                  ),
                  const SizedBox(height: 5),
                  _MetaRow(icon: Icons.place_outlined, text: e.venue),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        fmtPrice(e.price),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Text(
                        left == 0 ? 'Sold out' : '$left seats left',
                        style: TextStyle(
                          color: left == 0 || left < 15
                              ? const Color(0xFFFF8A5C)
                              : p.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: p.muted),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: p.muted, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

/// Responsive grid of EventCards (max 380px wide each, fixed height).
class EventGridView extends StatelessWidget {
  const EventGridView({super.key, required this.events, this.hero = true});
  final List<TechEvent> events;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisExtent: 316,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, i) => FadeSlideIn(
        index: i,
        child: EventCard(event: events[i], hero: hero),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.report});
  final EventReport report;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final r = report;
    return InteractiveCard(
      hoverColor: r.category.color,
      onTap: () => Navigator.pushNamed(context, Routes.report, arguments: r.id),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryPill(category: r.category),
              const Spacer(),
              Text(fmtDateLong(r.date),
                  style: TextStyle(color: p.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            r.headline,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: display(context, size: 20, height: 1.15, spacing: -0.2),
          ),
          const SizedBox(height: 10),
          Text(
            r.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: p.muted, height: 1.4, fontSize: 13.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.groups_2_outlined, size: 16, color: p.muted),
              const SizedBox(width: 6),
              Text('${r.attendees} attended',
                  style: TextStyle(color: p.muted, fontSize: 12.5)),
              const Spacer(),
              Text('Read report',
                  style: TextStyle(
                      color: p.text, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 16, color: p.text),
            ],
          ),
        ],
      ),
    );
  }
}
