import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_account.dart';

/// Demo authentication stored on the device (no backend).
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._prefs) {
    final raw = _prefs.getString('account');
    if (raw != null) {
      try {
        _account = UserAccount.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _account = null;
      }
    }
    _loggedIn = (_prefs.getBool('loggedIn') ?? false) && _account != null;
  }

  final SharedPreferences _prefs;
  UserAccount? _account;
  bool _loggedIn = false;

  bool get isLoggedIn => _loggedIn;
  UserAccount? get user => _loggedIn ? _account : null;

  /// Returns an error message, or null on success.
  Future<String?> signUp(String name, String email, String password) async {
    final mail = email.trim().toLowerCase();
    if (_account != null && _account!.email == mail) {
      return 'An account with this email already exists. Please sign in.';
    }
    _account = UserAccount(name: name.trim(), email: mail, password: password);
    _loggedIn = true;
    await _prefs.setString('account', jsonEncode(_account!.toJson()));
    await _prefs.setBool('loggedIn', true);
    notifyListeners();
    return null;
  }

  /// Returns an error message, or null on success.
  Future<String?> login(String email, String password) async {
    if (_account == null) {
      return 'No account found on this device yet. Please sign up first.';
    }
    if (_account!.email != email.trim().toLowerCase() ||
        _account!.password != password) {
      return 'Incorrect email or password.';
    }
    _loggedIn = true;
    await _prefs.setBool('loggedIn', true);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _loggedIn = false;
    await _prefs.setBool('loggedIn', false);
    notifyListeners();
  }
}
