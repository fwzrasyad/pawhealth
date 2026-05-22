import 'dart:convert';

class Veterinarian {
  final String vetId;
  final String name;
  final String profileImageUrl;
  final String workingHours;
  final List<String> specialties;
  final String bio;

  /// Weekly schedule: keys are day names ("Monday", "Tuesday", etc.),
  /// values are lists of available time strings like ["09:00", "10:00"].
  final Map<String, List<String>> weeklySchedule;
  final List<DateTime> bookedSlots;

  Veterinarian({
    required this.vetId,
    required this.name,
    this.profileImageUrl = '',
    this.workingHours = '',
    this.specialties = const [],
    this.bio = '',
    this.weeklySchedule = const {},
    this.bookedSlots = const [],
  });

  factory Veterinarian.fromJson(Map<String, dynamic> json) {
    // Parse weekly_schedule: could be a JSON map or null
    Map<String, List<String>> schedule = {};
    if (json['weekly_schedule'] != null) {
      final raw = json['weekly_schedule'];
      if (raw is Map) {
        raw.forEach((key, value) {
          schedule[key as String] = List<String>.from(value ?? []);
        });
      }
    }

    // Handle specialties which might be a JSON string or a List
    List<String> parsedSpecialties = [];
    if (json['specialties'] != null) {
      if (json['specialties'] is String) {
        try {
          final decoded = jsonDecode(json['specialties']);
          parsedSpecialties = List<String>.from(decoded ?? []);
        } catch (e) {
          parsedSpecialties = [];
        }
      } else if (json['specialties'] is Iterable) {
        parsedSpecialties = List<String>.from(json['specialties']);
      }
    }

    List<DateTime> parsedBookedSlots = [];
    if (json['booked_slots'] != null && json['booked_slots'] is Iterable) {
      parsedBookedSlots = (json['booked_slots'] as Iterable)
          .map((e) => DateTime.tryParse(e.toString()))
          .where((e) => e != null)
          .cast<DateTime>()
          .toList();
    }

    return Veterinarian(
      vetId: json['vet_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      profileImageUrl: json['profile_image_url']?.toString() ?? json['profile_image']?.toString() ?? '',
      workingHours: json['working_hours']?.toString() ?? '',
      specialties: parsedSpecialties,
      bio: json['bio']?.toString() ?? '',
      weeklySchedule: schedule,
      bookedSlots: parsedBookedSlots,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vet_id': vetId,
      'name': name,
      'profile_image_url': profileImageUrl,
      'working_hours': workingHours,
      'specialties': specialties,
      'bio': bio,
      'weekly_schedule': weeklySchedule,
      'booked_slots': bookedSlots.map((e) => e.toIso8601String()).toList(),
    };
  }

  Veterinarian copyWith({
    String? vetId,
    String? name,
    String? profileImageUrl,
    String? workingHours,
    List<String>? specialties,
    String? bio,
    Map<String, List<String>>? weeklySchedule,
    List<DateTime>? bookedSlots,
  }) {
    return Veterinarian(
      vetId: vetId ?? this.vetId,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      workingHours: workingHours ?? this.workingHours,
      specialties: specialties ?? this.specialties,
      bio: bio ?? this.bio,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      bookedSlots: bookedSlots ?? this.bookedSlots,
    );
  }

  /// Returns the available time slots for a given day of the week.
  /// [dayName] should be "Monday", "Tuesday", etc.
  List<String> slotsForDay(String dayName) {
    return weeklySchedule[dayName] ?? [];
  }
}
