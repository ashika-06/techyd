import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';
import '../providers/events_provider.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_chip.dart';
import '../widgets/common.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/event_widgets.dart';
import '../widgets/responsive.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<EventsProvider>().query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventsProvider>();
    final p = Pal.of(context);
    final mobile = screenSizeOf(context) == ScreenSize.mobile;
    final pad = pagePadding(context);
    final list = ev.filtered;
    final signature =
        '${ev.query}|${ev.category}|${ev.area}|${ev.mode}|${ev.freeOnly}';

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Events',
                subtitle: 'Upcoming tech events across Hyderabad',
                trailing: mobile
                    ? IconButton.filled(
                        tooltip: 'Submit an event',
                        style: IconButton.styleFrom(
                          backgroundColor: p.accent,
                          foregroundColor: p.onAccent,
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.submit),
                        icon: const Icon(Icons.add_rounded),
                      )
                    : AppButton(
                        label: 'Submit event',
                        icon: Icons.add_rounded,
                        compact: true,
                        onPressed: () =>
                            Navigator.pushNamed(context, Routes.submit),
                      ),
              ),

              // search
              CustomTextField(
                label: 'Search events, organisers, tags or venues',
                icon: Icons.search_rounded,
                controller: _search,
                onChanged: ev.setQuery,
              ),
              const SizedBox(height: 16),

              // category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppChip(
                      label: 'All',
                      selected: ev.category == null,
                      onTap: () => ev.setCategory(null),
                    ),
                    for (final c in EventCategory.values) ...[
                      const SizedBox(width: 8),
                      AppChip(
                        label: c.label,
                        icon: c.icon,
                        color: c.color,
                        selected: ev.category == c,
                        onTap: () => ev.setCategory(ev.category == c ? null : c),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // secondary filters
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _AreaDropdown(),
                  for (final m in EventMode.values)
                    AppChip(
                      label: m.label,
                      selected: ev.mode == m,
                      onTap: () => ev.setMode(ev.mode == m ? null : m),
                    ),
                  AppChip(
                    label: 'Free only',
                    icon: Icons.sell_outlined,
                    selected: ev.freeOnly,
                    onTap: () => ev.setFreeOnly(!ev.freeOnly),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    '${list.length} ${list.length == 1 ? 'event' : 'events'}',
                    style: TextStyle(color: p.muted, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (ev.hasActiveFilters)
                    TextButton.icon(
                      onPressed: () {
                        _search.clear();
                        ev.clearFilters();
                      },
                      style: TextButton.styleFrom(foregroundColor: p.text),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Clear filters'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: list.isEmpty
                    ? const EmptyState(
                        key: ValueKey('empty'),
                        icon: Icons.search_off_rounded,
                        title: 'No events found',
                        message:
                            'Try a different keyword or clear some filters to see more events.',
                      )
                    : EventGridView(key: ValueKey(signature), events: list),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ev = context.watch<EventsProvider>();
    final p = Pal.of(context);
    const allLabel = 'All areas';
    final items = [allLabel, ...ev.areas];
    final value = ev.area != null && items.contains(ev.area) ? ev.area! : allLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: p.surface,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(Icons.expand_more_rounded, color: p.muted, size: 20),
          style: TextStyle(
              color: p.text, fontSize: 13, fontWeight: FontWeight.w600),
          items: [
            for (final a in items) DropdownMenuItem(value: a, child: Text(a)),
          ],
          onChanged: (v) => ev.setArea(v == null || v == allLabel ? null : v),
        ),
      ),
    );
  }
}
