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
import '../widgets/common.dart';
import '../widgets/event_widgets.dart';
import '../widgets/responsive.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventsProvider>();
    final auth = context.watch<AuthProvider>();
    final p = Pal.of(context);
    final e = ev.byId(eventId);

    if (e == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Event not found',
          message: 'This event may have been removed.',
        ),
      );
    }

    final pad = pagePadding(context);
    final mobile = screenSizeOf(context) == ScreenSize.mobile;
    final left = ev.seatsLeft(e);
    final filled = e.capacity == 0
        ? 0.0
        : ((e.capacity - left) / e.capacity).clamp(0.0, 1.0).toDouble();
    final registered = ev.isRegistered(e.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 230,
            backgroundColor: p.bg,
            surfaceTintColor: Colors.transparent,
            actions: [
              BookmarkButton(eventId: e.id),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'banner-${e.id}',
                child: EventBanner(event: e, large: true),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MaxWidth(
              maxWidth: 900,
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 24, pad, 48),
                child: FadeSlideIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          CategoryPill(category: e.category),
                          _Tag(text: e.mode.label),
                          if (e.community) const _Tag(text: 'Community submitted'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(e.title,
                          style: display(context,
                              size: mobile ? 30 : 42, height: 1.05)),
                      const SizedBox(height: 10),
                      Text('Organised by ${e.organizer}',
                          style: TextStyle(color: p.muted, fontSize: 15)),
                      const SizedBox(height: 24),

                      if (e.isPast)
                        _Notice(
                          icon: Icons.history_rounded,
                          text: 'This event has ended.',
                        )
                      else ...[
                        Text('STARTS IN',
                            style: TextStyle(
                                color: p.muted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6)),
                        const SizedBox(height: 10),
                        Countdown(target: e.start),
                      ],
                      const SizedBox(height: 24),

                      ResponsiveWrap(
                        minItemWidth: 250,
                        spacing: 12,
                        children: [
                          _Info(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date',
                            value: fmtDate(e.start),
                          ),
                          _Info(
                            icon: Icons.schedule_rounded,
                            label: 'Time',
                            value: '${fmtTime(e.start)} - ${fmtTime(e.end)}',
                          ),
                          _Info(
                            icon: Icons.place_outlined,
                            label: 'Venue',
                            value: '${e.venue}${e.area == 'Online' ? '' : ' · ${e.area}'}',
                          ),
                          _Info(
                            icon: Icons.sell_outlined,
                            label: 'Entry',
                            value: fmtPrice(e.price),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // seats progress
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: p.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Seats',
                                    style: TextStyle(
                                        color: p.muted,
                                        fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(
                                  left == 0 ? 'Sold out' : '$left of ${e.capacity} left',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: filled),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) => ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: v,
                                  minHeight: 8,
                                  backgroundColor: p.surfaceAlt,
                                  color: filled > 0.85
                                      ? const Color(0xFFFF8A5C)
                                      : p.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const _H('About'),
                      Text(e.description,
                          style: TextStyle(color: p.text.withAlpha(215), height: 1.6, fontSize: 15)),

                      if (e.agenda.isNotEmpty) ...[
                        const _H('Agenda'),
                        for (final a in e.agenda) _AgendaRow(item: a),
                      ],

                      if (e.tags.isNotEmpty) ...[
                        const _H('Topics'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [for (final t in e.tags) _Tag(text: t)],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ActionBar(
        event: e,
        left: left,
        registered: registered,
        loggedIn: auth.isLoggedIn,
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.event,
    required this.left,
    required this.registered,
    required this.loggedIn,
  });
  final TechEvent event;
  final int left;
  final bool registered;
  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    String label;
    IconData icon;
    VoidCallback? onTap;

    if (event.isPast) {
      label = 'Event ended';
      icon = Icons.history_rounded;
      onTap = null;
    } else if (registered) {
      label = 'Registered - view ticket';
      icon = Icons.check_circle_outline_rounded;
      onTap = () => Navigator.pushNamedAndRemoveUntil(
          context, Routes.home, (r) => false, arguments: 3);
    } else if (left == 0) {
      label = 'Sold out';
      icon = Icons.block_rounded;
      onTap = null;
    } else if (!loggedIn) {
      label = 'Sign in to register';
      icon = Icons.login_rounded;
      onTap = () => Navigator.pushNamed(context, Routes.login);
    } else {
      label = 'Register now';
      icon = Icons.arrow_forward_rounded;
      onTap = () =>
          Navigator.pushNamed(context, Routes.register, arguments: event.id);
    }

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: MaxWidth(
          maxWidth: 900,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ENTRY',
                        style: TextStyle(
                            color: p.muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4)),
                    Text(fmtPrice(event.price), style: display(context, size: 24)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: AppButton(
                    label: label,
                    icon: icon,
                    expand: true,
                    onPressed: onTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 32, bottom: 12),
        child: Text(text.toUpperCase(),
            style: display(context, size: 16, spacing: 1.2)),
      );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: Text(text,
          style: TextStyle(
              color: p.muted, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: p.muted, size: 20),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: p.muted)),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: p.text),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: TextStyle(
                        color: p.muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2)),
                const SizedBox(height: 3),
                Text(value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({required this.item});
  final AgendaItem item;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 96,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(item.time,
                  style: TextStyle(
                      color: p.muted, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
              ),
              Expanded(child: Container(width: 1, color: p.border)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(item.title,
                  style: const TextStyle(fontSize: 15, height: 1.35)),
            ),
          ),
        ],
      ),
    );
  }
}
