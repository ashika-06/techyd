import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/event.dart';
import '../models/registration.dart';
import '../models/report.dart';

/// Holds events, filters, bookmarks and registrations.
class EventsProvider extends ChangeNotifier {
  EventsProvider(this._prefs) {
    _bookmarks.addAll(_prefs.getStringList('bookmarks') ?? const <String>[]);
    _registrations = _decodeList(
        'registrations', (m) => Registration.fromJson(m));
    _community = _decodeList('community', (m) => TechEvent.fromJson(m));
  }

  final SharedPreferences _prefs;
  final List<TechEvent> _sample = sampleEvents();
  final List<EventReport> reports = sampleReports();
  List<TechEvent> _community = [];
  final Set<String> _bookmarks = {};
  List<Registration> _registrations = [];

  // ---- filter state ----
  String query = '';
  EventCategory? category;
  String? area;
  EventMode? mode;
  bool freeOnly = false;

  List<T> _decodeList<T>(String key, T Function(Map<String, dynamic>) from) {
    final out = <T>[];
    for (final s in _prefs.getStringList(key) ?? const <String>[]) {
      try {
        out.add(from(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {
        // ignore corrupt entries
      }
    }
    return out;
  }

  // ---- events ----
  List<TechEvent> get all => [..._sample, ..._community];

  List<TechEvent> get upcoming {
    final list = all.where((e) => !e.isPast).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  TechEvent? byId(String id) {
    for (final e in all) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<String> get areas {
    final set = upcoming.map((e) => e.area).toSet().toList()..sort();
    return set;
  }

  List<TechEvent> get filtered {
    final q = query.trim().toLowerCase();
    return upcoming.where((e) {
      if (category != null && e.category != category) return false;
      if (area != null && e.area != area) return false;
      if (mode != null && e.mode != mode) return false;
      if (freeOnly && e.price > 0) return false;
      if (q.isNotEmpty) {
        final hay =
            '${e.title} ${e.organizer} ${e.venue} ${e.area} ${e.tags.join(' ')}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  bool get hasActiveFilters =>
      query.trim().isNotEmpty ||
      category != null ||
      area != null ||
      mode != null ||
      freeOnly;

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void setCategory(EventCategory? c) {
    category = c;
    notifyListeners();
  }

  void setArea(String? a) {
    area = a;
    notifyListeners();
  }

  void setMode(EventMode? m) {
    mode = m;
    notifyListeners();
  }

  void setFreeOnly(bool v) {
    freeOnly = v;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    category = null;
    area = null;
    mode = null;
    freeOnly = false;
    notifyListeners();
  }

  // ---- bookmarks ----
  bool isBookmarked(String id) => _bookmarks.contains(id);

  List<TechEvent> get bookmarked =>
      all.where((e) => _bookmarks.contains(e.id)).toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  void toggleBookmark(String id) {
    if (!_bookmarks.remove(id)) _bookmarks.add(id);
    _prefs.setStringList('bookmarks', _bookmarks.toList());
    notifyListeners();
  }

  // ---- registrations ----
  List<Registration> get registrations => List.unmodifiable(
      _registrations.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  bool isRegistered(String eventId) =>
      _registrations.any((r) => r.eventId == eventId);

  int seatsLeft(TechEvent e) {
    final taken = e.registered + (isRegistered(e.id) ? 1 : 0);
    return max(0, e.capacity - taken);
  }

  Registration register({
    required String eventId,
    required String name,
    required String email,
    required String phone,
    required String organisation,
    required String role,
    required String level,
  }) {
    final reg = Registration(
      ticketId: 'TCH-${1000 + Random().nextInt(9000)}-${eventId.toUpperCase()}',
      eventId: eventId,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      organisation: organisation.trim(),
      role: role,
      level: level,
      createdAt: DateTime.now(),
    );
    _registrations.add(reg);
    _saveRegistrations();
    notifyListeners();
    return reg;
  }

  void cancelRegistration(String ticketId) {
    _registrations.removeWhere((r) => r.ticketId == ticketId);
    _saveRegistrations();
    notifyListeners();
  }

  void _saveRegistrations() => _prefs.setStringList(
      'registrations', _registrations.map((r) => jsonEncode(r.toJson())).toList());

  // ---- community submitted events ----
  void addCommunityEvent(TechEvent e) {
    _community.add(e);
    _prefs.setStringList(
        'community', _community.map((x) => jsonEncode(x.toJson())).toList());
    notifyListeners();
  }
}
