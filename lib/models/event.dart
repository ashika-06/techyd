import 'package:flutter/material.dart';

enum EventCategory { hackathon, aiMl, webMobile, cloud, startup, workshop }

extension EventCategoryX on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.hackathon:
        return 'Hackathon';
      case EventCategory.aiMl:
        return 'AI / ML';
      case EventCategory.webMobile:
        return 'Web & Mobile';
      case EventCategory.cloud:
        return 'Cloud & Data';
      case EventCategory.startup:
        return 'Startup';
      case EventCategory.workshop:
        return 'Workshop';
    }
  }

  IconData get icon {
    switch (this) {
      case EventCategory.hackathon:
        return Icons.terminal_rounded;
      case EventCategory.aiMl:
        return Icons.memory_rounded;
      case EventCategory.webMobile:
        return Icons.devices_rounded;
      case EventCategory.cloud:
        return Icons.cloud_outlined;
      case EventCategory.startup:
        return Icons.rocket_launch_outlined;
      case EventCategory.workshop:
        return Icons.build_circle_outlined;
    }
  }

  Color get color {
    switch (this) {
      case EventCategory.hackathon:
        return const Color(0xFFC8FF3D);
      case EventCategory.aiMl:
        return const Color(0xFF8AA2FF);
      case EventCategory.webMobile:
        return const Color(0xFF4DD0E1);
      case EventCategory.cloud:
        return const Color(0xFFB69CFF);
      case EventCategory.startup:
        return const Color(0xFFFFB84D);
      case EventCategory.workshop:
        return const Color(0xFFFF7A9A);
    }
  }

  /// Readable version of the category colour for the current theme.
  Color tone(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) return color;
    return HSLColor.fromColor(color).withLightness(0.34).toColor();
  }
}

enum EventMode { offline, online, hybrid }

extension EventModeX on EventMode {
  String get label {
    switch (this) {
      case EventMode.offline:
        return 'In person';
      case EventMode.online:
        return 'Online';
      case EventMode.hybrid:
        return 'Hybrid';
    }
  }
}

class AgendaItem {
  const AgendaItem(this.time, this.title);
  final String time;
  final String title;

  Map<String, dynamic> toJson() => {'time': time, 'title': title};
  factory AgendaItem.fromJson(Map<String, dynamic> j) =>
      AgendaItem(j['time'] as String, j['title'] as String);
}

class TechEvent {
  const TechEvent({
    required this.id,
    required this.title,
    required this.organizer,
    required this.category,
    required this.mode,
    required this.venue,
    required this.area,
    required this.start,
    required this.end,
    required this.price,
    required this.capacity,
    required this.registered,
    required this.description,
    this.tags = const [],
    this.agenda = const [],
    this.community = false,
    this.link,
  });

  final String id;
  final String title;
  final String organizer;
  final EventCategory category;
  final EventMode mode;
  final String venue;
  final String area;
  final DateTime start;
  final DateTime end;
  final int price; // INR, 0 = free
  final int capacity;
  final int registered; // seats already taken (before this user)
  final String description;
  final List<String> tags;
  final List<AgendaItem> agenda;
  final bool community; // submitted by a user through the app
  final String? link;

  bool get isPast => end.isBefore(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'organizer': organizer,
        'category': category.name,
        'mode': mode.name,
        'venue': venue,
        'area': area,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'price': price,
        'capacity': capacity,
        'registered': registered,
        'description': description,
        'tags': tags,
        'agenda': agenda.map((a) => a.toJson()).toList(),
        'community': community,
        'link': link,
      };

  factory TechEvent.fromJson(Map<String, dynamic> j) => TechEvent(
        id: j['id'] as String,
        title: j['title'] as String,
        organizer: j['organizer'] as String,
        category: EventCategory.values.byName(j['category'] as String),
        mode: EventMode.values.byName(j['mode'] as String),
        venue: j['venue'] as String,
        area: j['area'] as String,
        start: DateTime.parse(j['start'] as String),
        end: DateTime.parse(j['end'] as String),
        price: j['price'] as int,
        capacity: j['capacity'] as int,
        registered: j['registered'] as int,
        description: j['description'] as String,
        tags: (j['tags'] as List).map((e) => e as String).toList(),
        agenda: (j['agenda'] as List)
            .map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        community: j['community'] as bool? ?? false,
        link: j['link'] as String?,
      );
}
