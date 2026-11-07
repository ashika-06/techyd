import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/home_shell.dart';
import 'screens/register_screen.dart';
import 'screens/report_detail_screen.dart';
import 'screens/submit_event_screen.dart';

/// Named routes. '/' (landing / home gate) is handled by MaterialApp.home.
class Routes {
  static const landing = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home'; // optional argument: int tab index
  static const event = '/event'; // argument: event id (String)
  static const register = '/register'; // argument: event id (String)
  static const report = '/report'; // argument: report id (String)
  static const submit = '/submit';

  static Route<dynamic> generate(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case login:
        page = const AuthScreen(signUp: false);
        break;
      case signup:
        page = const AuthScreen(signUp: true);
        break;
      case event:
        page = EventDetailScreen(eventId: settings.arguments as String);
        break;
      case register:
        page = RegisterScreen(eventId: settings.arguments as String);
        break;
      case report:
        page = ReportDetailScreen(reportId: settings.arguments as String);
        break;
      case submit:
        page = const SubmitEventScreen();
        break;
      case home:
      default:
        page = HomeShell(initialTab: (settings.arguments as int?) ?? 0);
    }
    return _fadeSlide(page, settings);
  }

  /// Shared page transition: fade + small upward slide.
  static PageRouteBuilder<dynamic> _fadeSlide(Widget page, RouteSettings s) {
    return PageRouteBuilder<dynamic>(
      settings: s,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
