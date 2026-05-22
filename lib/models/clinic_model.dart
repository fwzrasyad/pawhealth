class Clinic {
  final String clinicId;
  final String name;
  final String city;
  final String address;
  final String imageUrl;

  Clinic({
    required this.clinicId,
    required this.name,
    this.city = '',
    this.address = '',
    this.imageUrl = '',
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      clinicId: json['clinic_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinic_id': clinicId,
      'name': name,
      'city': city,
      'address': address,
      'image_url': imageUrl,
    };
  }
}
