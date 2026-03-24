class Veterinarian {
  final String vetId;
  final String name;
  final String profileImageUrl;
  final String workingHours;
  final List<String> specialties;
  final String bio;
  final List<DateTime> availableSlots;

  Veterinarian({
    required this.vetId,
    required this.name,
    required this.profileImageUrl,
    required this.workingHours,
    required this.specialties,
    required this.bio,
    required this.availableSlots,
  });

  factory Veterinarian.fromJson(Map<String, dynamic> json) {
    return Veterinarian(
      vetId: json['vet_id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      workingHours: json['working_hours'],
      specialties: List<String>.from(json['specialties'] ?? []),
      bio: json['bio'],
      availableSlots: (json['available_slots'] as List<dynamic>?)
              ?.map((timeStr) => DateTime.parse(timeStr))
              .toList() ??
          [],
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
      'available_slots':
          availableSlots.map((time) => time.toIso8601String()).toList(),
    };
  }
}
