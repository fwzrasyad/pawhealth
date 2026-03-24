class AIScan {
  final String scanId;
  final String petId;
  final DateTime scanDate;
  final String imageUrl;
  final String aiResultLabel;
  final double confidenceScore;

  AIScan({
    required this.scanId,
    required this.petId,
    required this.scanDate,
    required this.imageUrl,
    required this.aiResultLabel,
    required this.confidenceScore,
  });

  factory AIScan.fromJson(Map<String, dynamic> json) {
    return AIScan(
      scanId: json['scan_id'] as String,
      petId: json['pet_id'] as String,
      scanDate: DateTime.parse(json['scan_date'] as String),
      imageUrl: json['image_url'] as String,
      aiResultLabel: json['ai_result_label'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scan_id': scanId,
      'pet_id': petId,
      'scan_date': scanDate.toIso8601String(),
      'image_url': imageUrl,
      'ai_result_label': aiResultLabel,
      'confidence_score': confidenceScore,
    };
  }
}
