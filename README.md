# TECHYD — Hyderabad tech events, reported

A responsive Flutter web app (also runs on Android) that lists upcoming tech
events in Hyderabad, publishes recaps of past ones, and lets users register,
bookmark and submit events. Dark, minimal, solid-colour UI (black + acid lime).

> All events, organisers and reports are **sample data** made up for the demo.
> There is no backend: accounts, bookmarks, tickets and submitted events are
> stored on the device with `shared_preferences`.

## 1. Run it (Android Studio or terminal)

You need the Flutter SDK (stable) with web enabled: `flutter doctor`.

```bash
# 1) put this folder somewhere and name it exactly "techyd"
cd techyd

# 2) generate the platform folders (web/, android/) - keeps all my files
flutter create . --platforms=web,android --project-name techyd

# 3) install packages
flutter pub get

# 4) run in Chrome
flutter run -d chrome
```

**Android Studio:** File → Open → select the `techyd` folder → run step 2 in
the Terminal tab → pick **Chrome (web)** in the device dropdown → press Run.
(Pick an Android emulator instead to see the mobile version.)

If `flutter create` created `test/widget_test.dart` again, keep mine (it tests
the validators). Run tests with `flutter test`.

## 2. Test different screen sizes (needed for screenshots)

- Run `flutter run -d chrome`, then in Chrome press **F12 → Ctrl+Shift+M**
  (device toolbar) and choose: **iPhone 12 / Pixel** (mobile), **iPad** (tablet),
  or just drag the window wide (desktop).
- Layout breakpoints: **mobile < 700px** (bottom nav), **tablet 700–1100px**
  (icon rail), **desktop ≥ 1100px** (full sidebar, 3-column grids).

Suggested screenshots (each at mobile + desktop): Landing, Sign up (with a
validation error), Home, Events (filtered), Event details, Registration form
(with errors) and success dialog, My Tickets, Reports + report detail,
Submit event form, Profile in dark and light mode.

## 3. Deploy to GitHub Pages (recommended)

1. Create a GitHub repo and push this folder to the `main` branch.
2. Repo → **Settings → Pages → Build and deployment → Source: GitHub Actions**.
3. The included workflow `.github/workflows/deploy.yml` builds and publishes
   on every push. Your site: `https://<username>.github.io/<repo-name>/`

Manual alternative:
```bash
flutter build web --release --base-href "/<repo-name>/"
# then publish the contents of build/web (e.g. to a gh-pages branch)
```
Vercel/Netlify also work but need the pre-built `build/web` folder or a custom
Flutter build step; GitHub Pages is the simplest for this assignment.

## 4. How each requirement is covered

| Requirement | Where |
|---|---|
| **Widgets** | Container, Row, Column, Stack (hero image, banners), ListView (horizontal "Happening soon"), GridView.builder (events), Card-style `InteractiveCard`, Wrap, SliverAppBar, Dialogs, buttons, chips, switches, dropdown, date/time pickers |
| **Responsive UI** | `MediaQuery` breakpoints in `widgets/responsive.dart`; `LayoutBuilder` in `ResponsiveWrap`/`TwoCol`; adaptive nav (bottom bar / rail / sidebar) in `screens/home_shell.dart`; `SliverGridDelegateWithMaxCrossAxisExtent` |
| **Navigation** | Named routes + `onGenerateRoute` with route arguments (`routes.dart`), `pushNamed`, `pushReplacementNamed`, `pushNamedAndRemoveUntil`, auth gate, custom fade/slide page transition |
| **Animations** | `Hero` (event banner → details), page transitions, `AnimatedSwitcher` (tabs, filters, bookmark icon, theme icon), `AnimatedContainer` (chips, hover lift, nav), `TweenAnimationBuilder` (staggered fade-slide-in, count-up stats, seat progress bar, success check), live `Countdown`, landing photo zoom |
| **State management** | `Provider` + `ChangeNotifier`: `ThemeProvider`, `AuthProvider`, `EventsProvider` (filters, bookmarks, registrations, community events); `StatefulWidget` for forms/tabs; persistence with `shared_preferences` |
| **Themes & custom widgets** | `theme/app_theme.dart` (dark + light, one palette class `Pal`), reusable `AppButton`, `CustomTextField`, `AppChip`, `ChipSelectField`, `EventCard`, `ReportCard`, `EventBanner`, `PageHeader`, `SectionHeader`, `EmptyState`, `TechydWordmark` |
| **Forms & validation** | Sign up / Sign in, **Event registration** (name, email, 10-digit phone, org, role, level, terms checkbox), **Submit event** (title, date & time pickers, fee, capacity, description length, optional URL) — all in `utils/validators.dart` with live validation |

## 5. Project structure

```
lib/
  main.dart               app entry, MultiProvider, auth gate
  routes.dart             named routes + page transition
  theme/app_theme.dart    palette, dark/light ThemeData, display font
  models/                 TechEvent, EventReport, Registration, UserAccount
  data/sample_data.dart   sample events + reports (dates relative to today)
  providers/              theme, auth, events (Provider/ChangeNotifier)
  utils/                  validators, formatting helpers
  widgets/                reusable UI components
  screens/                landing, auth, home shell, home, events, event detail,
                          register, tickets, reports, report detail, submit, profile
assets/images/hyd_night.jpg   hero photo (HITEC City at night)
```

## 6. Notes

- Fonts (Archivo for headings, Inter for body) load through the `google_fonts`
  package, so the first load needs internet.
- Demo auth stores the password locally in plain text — fine for a lab
  project, never for a real app.
