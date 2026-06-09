class Clinic {
  final String clinicId;
  final String name;
  final String city;
  final String address;
  final String imageUrl;
  final String phoneNumber;
  final String googleMapsUrl;
  final String description;
  final String profilePicture;

  Clinic({
    required this.clinicId,
    required this.name,
    this.city = '',
    this.address = '',
    this.imageUrl = '',
    this.phoneNumber = '',
    this.googleMapsUrl = '',
    this.description = '',
    this.profilePicture = '',
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      clinicId: json['clinic_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      googleMapsUrl: json['google_maps_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString() ?? json['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinic_id': clinicId,
      'name': name,
      'city': city,
      'address': address,
      'image_url': imageUrl,
      'phone_number': phoneNumber,
      'google_maps_url': googleMapsUrl,
      'description': description,
      'profile_picture': profilePicture,
    };
  }
}
