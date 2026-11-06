import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/registration.dart';
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

/// "My Tickets": registered events + bookmarked events.
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  int _tab = 0; // 0 registered, 1 bookmarked

  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventsProvider>();
    final auth = context.watch<AuthProvider>();
    final pad = pagePadding(context);

    final regs = ev.registrations;
    final saved = ev.bookmarked;

    Widget content;
    if (_tab == 0) {
      if (!auth.isLoggedIn) {
        content = EmptyState(
          key: const ValueKey('guest'),
          icon: Icons.lock_outline_rounded,
          title: 'Sign in to see tickets',
          message: 'Create an account to register for events and keep your tickets here.',
          action: AppButton(
            label: 'Sign in',
            onPressed: () => Navigator.pushNamed(context, Routes.login),
          ),
        );
      } else if (regs.isEmpty) {
        content = const EmptyState(
          key: ValueKey('noregs'),
          icon: Icons.confirmation_number_outlined,
          title: 'No tickets yet',
          message: 'Register for an event and your ticket will show up here.',
        );
      } else {
        content = ResponsiveWrap(
          key: const ValueKey('regs'),
          minItemWidth: 420,
          children: [
            for (var i = 0; i < regs.length; i++)
              if (ev.byId(regs[i].eventId) != null)
                FadeSlideIn(
                  index: i,
                  child: _TicketCard(
                    reg: regs[i],
                    event: ev.byId(regs[i].eventId)!,
                  ),
                ),
          ],
        );
      }
    } else {
      content = saved.isEmpty
          ? const EmptyState(
              key: ValueKey('nosaved'),
              icon: Icons.bookmark_border_rounded,
              title: 'Nothing bookmarked',
              message: 'Tap the bookmark icon on any event to save it for later.',
            )
          : EventGridView(key: const ValueKey('saved'), events: saved);
    }

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'My tickets',
                subtitle: 'Your registrations and saved events',
              ),
              Row(
                children: [
                  AppChip(
                    label: 'Registered (${regs.length})',
                    icon: Icons.confirmation_number_outlined,
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  const SizedBox(width: 8),
                  AppChip(
                    label: 'Bookmarked (${saved.length})',
                    icon: Icons.bookmark_border_rounded,
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.reg, required this.event});
  final Registration reg;
  final TechEvent event;

  Future<void> _cancel(BuildContext context) async {
    final p = Pal.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: p.border),
        ),
        title: const Text('Cancel registration?'),
        content: Text('You will give up your seat for "${event.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: p.muted),
            child: const Text('Keep ticket'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF6B6B)),
            child: const Text('Cancel registration'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<EventsProvider>().cancelRegistration(reg.ticketId);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration cancelled')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final tone = event.category.tone(context);

    return InteractiveCard(
      hoverColor: event.category.color,
      onTap: () => Navigator.pushNamed(context, Routes.event, arguments: event.id),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // date stub
            Container(
              width: 84,
              color: p.surfaceAlt,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(monthShort(event.start),
                      style: TextStyle(
                          color: tone,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5)),
                  Text('${event.start.day}',
                      style: display(context, size: 34)),
                  Text(fmtTime(event.start),
                      style: TextStyle(color: p.muted, fontSize: 11.5)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.w700, height: 1.25)),
                    const SizedBox(height: 6),
                    Text(event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: p.muted, fontSize: 12.5)),
                    const SizedBox(height: 10),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: p.border),
                      ),
                      child: Text(reg.ticketId,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4)),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _cancel(context),
                        style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFF6B6B),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 30)),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
