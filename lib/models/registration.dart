class Registration {
  const Registration({
    required this.ticketId,
    required this.eventId,
    required this.name,
    required this.email,
    required this.phone,
    required this.organisation,
    required this.role,
    required this.level,
    required this.createdAt,
  });

  final String ticketId;
  final String eventId;
  final String name;
  final String email;
  final String phone;
  final String organisation;
  final String role;
  final String level;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'eventId': eventId,
        'name': name,
        'email': email,
        'phone': phone,
        'organisation': organisation,
        'role': role,
        'level': level,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Registration.fromJson(Map<String, dynamic> j) => Registration(
        ticketId: j['ticketId'] as String,
        eventId: j['eventId'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String,
        organisation: j['organisation'] as String,
        role: j['role'] as String,
        level: j['level'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}
