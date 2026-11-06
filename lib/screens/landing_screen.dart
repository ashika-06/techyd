import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/app_button.dart';
import '../widgets/responsive.dart';
import '../widgets/techyd_wordmark.dart';

/// Front page: full-bleed Hyderabad night photo, wordmark and calls to action.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DarkScope(
      child: Builder(builder: (context) {
        final mobile = screenSizeOf(context) == ScreenSize.mobile;
        final pad = mobile ? 22.0 : 56.0;

        return Scaffold(
          backgroundColor: Pal.dark.bg,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Slow settle-in zoom on the photo.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.14, end: 1.0),
                duration: const Duration(seconds: 3),
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Image.asset(
                  'assets/images/hyd_night.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => Container(color: Pal.dark.surface),
                ),
              ),
              // Darken for legibility.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(150),
                      Colors.black.withAlpha(70),
                      Colors.black.withAlpha(235),
                    ],
                    stops: const [0, 0.35, 0.95],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: Row(
                          children: [
                            TechydWordmark(size: mobile ? 22 : 26, color: Colors.white),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, Routes.login),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.white),
                              child: const Text('Sign in',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeSlideIn(
                                index: 1,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Pal.lime,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'LIVE FROM HYDERABAD',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              FadeSlideIn(
                                index: 2,
                                child: Text(
                                  'HYDERABAD,\nWE HAVE\nEVENTS.',
                                  style: display(
                                    context,
                                    size: mobile ? 42 : 80,
                                    color: Colors.white,
                                    weight: FontWeight.w900,
                                    spacing: -1.5,
                                    height: 0.98,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              FadeSlideIn(
                                index: 3,
                                child: Text(
                                  'Hackathons, meetups, workshops and the stories '
                                  'behind them. One place for everything happening '
                                  'in the city’s tech scene.',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(190),
                                    fontSize: mobile ? 15 : 17,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              FadeSlideIn(
                                index: 4,
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    AppButton(
                                      label: 'Get started',
                                      icon: Icons.arrow_forward_rounded,
                                      onPressed: () => Navigator.pushNamed(
                                          context, Routes.signup),
                                    ),
                                    AppButton(
                                      label: 'Browse as guest',
                                      outlined: true,
                                      onPressed: () =>
                                          Navigator.pushReplacementNamed(
                                              context, Routes.home),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'Demo project · sample data',
                                style: TextStyle(
                                    color: Colors.white.withAlpha(110),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
