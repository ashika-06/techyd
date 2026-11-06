import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../providers/theme_provider.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/app_button.dart';
import '../widgets/common.dart';
import '../widgets/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final p = Pal.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: p.border),
        ),
        title: const Text('Sign out?'),
        content: const Text('Your bookmarks and tickets stay saved on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: p.muted),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF6B6B)),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final auth = context.read<AuthProvider>();
    // Navigate first so the old tree is gone before auth state flips.
    Navigator.pushNamedAndRemoveUntil(context, Routes.landing, (r) => false);
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final auth = context.watch<AuthProvider>();
    final ev = context.watch<EventsProvider>();
    final theme = context.watch<ThemeProvider>();
    final pad = pagePadding(context);
    final user = auth.user;

    return SingleChildScrollView(
      child: MaxWidth(
        maxWidth: 760,
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Profile'),

              // identity card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.border),
                ),
                child: user == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YOU’RE BROWSING AS A GUEST',
                              style: display(context, size: 18)),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to register for events and keep your tickets.',
                            style: TextStyle(color: p.muted),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              AppButton(
                                label: 'Sign in',
                                compact: true,
                                onPressed: () =>
                                    Navigator.pushNamed(context, Routes.login),
                              ),
                              AppButton(
                                label: 'Create account',
                                outlined: true,
                                compact: true,
                                onPressed: () =>
                                    Navigator.pushNamed(context, Routes.signup),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Pal.lime,
                            child: Text(
                              initials(user.name),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: display(context, size: 22)),
                                const SizedBox(height: 4),
                                Text(user.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: p.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // stats
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                        label: 'Tickets', value: '${ev.registrations.length}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                        label: 'Bookmarks', value: '${ev.bookmarked.length}'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // settings
              Container(
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.border),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: theme.isDark,
                      onChanged: (_) => theme.toggle(),
                      secondary: Icon(
                        theme.isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: p.muted,
                      ),
                      title: const Text('Dark mode',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Easy on the eyes after dark',
                          style: TextStyle(color: p.muted, fontSize: 12.5)),
                    ),
                    Divider(height: 1, color: p.border),
                    ListTile(
                      leading: Icon(Icons.add_circle_outline_rounded, color: p.muted),
                      title: const Text('Submit an event',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Icon(Icons.chevron_right_rounded, color: p.muted),
                      onTap: () => Navigator.pushNamed(context, Routes.submit),
                    ),
                    Divider(height: 1, color: p.border),
                    ListTile(
                      leading: Icon(Icons.info_outline_rounded, color: p.muted),
                      title: const Text('About Techyd',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Icon(Icons.chevron_right_rounded, color: p.muted),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: p.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: p.border),
                          ),
                          title: const Text('About Techyd'),
                          content: const Text(
                            'Techyd is a Flutter demo app that reports on Hyderabad '
                            'tech events. All events, organisers and reports are sample '
                            'data. Accounts, bookmarks and tickets are stored locally '
                            'on this device only.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (user != null) ...[
                      Divider(height: 1, color: p.border),
                      ListTile(
                        leading: const Icon(Icons.logout_rounded,
                            color: Color(0xFFFF6B6B)),
                        title: const Text('Sign out',
                            style: TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w600)),
                        onTap: () => _logout(context),
                      ),
                    ],
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: display(context, size: 30)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: p.muted, fontSize: 13)),
        ],
      ),
    );
  }
}
