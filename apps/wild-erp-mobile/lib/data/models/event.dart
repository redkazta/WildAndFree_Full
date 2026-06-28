class Event {
  final String id;
  final String title;
  final String? description;
  final String type; // concert, workshop, battle, meetup, stream
  final DateTime startDate;
  final DateTime? endDate;
  final String? location;
  final String? streamUrl;
  final int? maxAttendees;
  final int currentAttendees;
  final int? tokenReward;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    this.type = 'meetup',
    required this.startDate,
    this.endDate,
    this.location,
    this.streamUrl,
    this.maxAttendees,
    this.currentAttendees = 0,
    this.tokenReward,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'meetup',
      startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ??
          DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      location: json['location'] as String?,
      streamUrl: json['stream_url'] as String?,
      maxAttendees: json['max_attendees'] as int?,
      currentAttendees: json['current_attendees'] as int? ?? 0,
      tokenReward: json['token_reward'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'stream_url': streamUrl,
      'max_attendees': maxAttendees,
      'current_attendees': currentAttendees,
      'token_reward': tokenReward,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isLive =>
      startDate.isBefore(DateTime.now()) &&
      (endDate?.isAfter(DateTime.now()) ?? true);
  bool get isPast =>
      endDate != null && endDate!.isBefore(DateTime.now());

  double get attendanceRate =>
      maxAttendees != null && maxAttendees! > 0
          ? currentAttendees / maxAttendees!
          : 0;
}
