import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._prefs) {
    _mode = (_prefs.getBool('darkMode') ?? true) ? ThemeMode.dark : ThemeMode.light;
  }

  final SharedPreferences _prefs;
  late ThemeMode _mode;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setBool('darkMode', isDark);
    notifyListeners();
  }
}
