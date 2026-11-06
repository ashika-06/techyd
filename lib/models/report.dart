import 'event.dart';

/// A recap / write-up of an event that already happened.
class EventReport {
  const EventReport({
    required this.id,
    required this.eventTitle,
    required this.category,
    required this.date,
    required this.venue,
    required this.attendees,
    required this.speakers,
    required this.hours,
    required this.headline,
    required this.summary,
    required this.highlights,
    required this.takeaways,
    this.winners = const [],
  });

  final String id;
  final String eventTitle;
  final EventCategory category;
  final DateTime date;
  final String venue;
  final int attendees;
  final int speakers;
  final int hours;
  final String headline;
  final String summary;
  final List<String> highlights;
  final List<String> takeaways;
  final List<String> winners;
}
