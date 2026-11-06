import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/events_provider.dart';
import 'providers/theme_provider.dart';
import 'routes.dart';
import 'screens/home_shell.dart';
import 'screens/landing_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => EventsProvider(prefs)),
      ],
      child: const TechydApp(),
    ),
  );
}

class TechydApp extends StatelessWidget {
  const TechydApp({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<ThemeProvider>().mode;
    return MaterialApp(
      title: 'Techyd - Hyderabad tech events',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: const AuthGate(),
      onGenerateRoute: Routes.generate,
    );
  }
}

/// Signed-in users go straight to the app; everyone else sees the landing page.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.watch<AuthProvider>().isLoggedIn;
    return loggedIn ? const HomeShell() : const LandingScreen();
  }
}
