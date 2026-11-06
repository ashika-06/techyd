import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/responsive.dart';
import '../widgets/techyd_wordmark.dart';
import 'events_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'tickets_screen.dart';

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _items = [
  _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
  _NavItem(Icons.event_outlined, Icons.event_rounded, 'Events'),
  _NavItem(Icons.article_outlined, Icons.article_rounded, 'Reports'),
  _NavItem(Icons.confirmation_number_outlined, Icons.confirmation_number_rounded, 'Tickets'),
  _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

/// Adaptive navigation: bottom bar on mobile, side rail on tablet, full
/// sidebar on desktop.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialTab.clamp(0, _items.length - 1).toInt();

  void _go(int i) => setState(() => _index = i);

  Widget _page() {
    switch (_index) {
      case 0:
        return HomeScreen(onNavigate: _go);
      case 1:
        return const EventsScreen();
      case 2:
        return const ReportsScreen();
      case 3:
        return const TicketsScreen();
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);
    final p = Pal.of(context);

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(_index), child: _page()),
    );

    if (size == ScreenSize.mobile) {
      return Scaffold(
        body: SafeArea(bottom: false, child: body),
        bottomNavigationBar: _BottomBar(index: _index, onTap: _go),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _Sidebar(
              index: _index,
              onTap: _go,
              extended: size == ScreenSize.desktop,
            ),
            Container(width: 1, color: p.border),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 2,
                        width: i == index ? 28 : 0,
                        color: p.accent,
                      ),
                      const SizedBox(height: 10),
                      Icon(
                        i == index ? _items[i].activeIcon : _items[i].icon,
                        size: 24,
                        color: i == index ? p.accent : p.muted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _items[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: i == index ? p.text : p.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
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

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.index, required this.onTap, required this.extended});
  final int index;
  final ValueChanged<int> onTap;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: extended ? 240 : 76,
      color: p.bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Column(
        crossAxisAlignment:
            extended ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: extended ? 10 : 0, bottom: 32),
            child: extended
                ? const TechydWordmark(size: 22)
                : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Pal.lime,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text('T',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 20)),
                  ),
          ),
          for (var i = 0; i < _items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _SideButton(
                item: _items[i],
                selected: i == index,
                extended: extended,
                onTap: () => onTap(i),
              ),
            ),
          const Spacer(),
          if (extended)
            Row(
              children: [
                const ThemeToggleButton(),
                Text('Theme', style: TextStyle(color: p.muted, fontSize: 13)),
              ],
            )
          else
            const ThemeToggleButton(),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.item,
    required this.selected,
    required this.extended,
    required this.onTap,
  });
  final _NavItem item;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0),
          alignment: extended ? Alignment.centerLeft : Alignment.center,
          decoration: BoxDecoration(
            color: selected ? p.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? p.border : Colors.transparent),
          ),
          child: Row(
            mainAxisSize: extended ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: 22,
                color: selected ? p.accent : p.muted,
              ),
              if (extended) ...[
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? p.text : p.muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
