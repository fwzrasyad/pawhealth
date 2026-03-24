import 'daily_routine_model.dart'; // Import the new log model

class Pet {
  final String petId;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final double weight;
  final List<DailyRoutineLog> dailyRoutines;

  Pet({
    required this.petId,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.weight,
    this.dailyRoutines = const [],
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      petId: json['pet_id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      weight: (json['weight'] as num).toDouble(),
      dailyRoutines:
          (json['daily_routines'] as List<dynamic>?)
              ?.map((e) => DailyRoutineLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pet_id': petId,
      'owner_id': ownerId,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'weight': weight,
      'daily_routines': dailyRoutines.map((log) => log.toJson()).toList(),
    };
  }

  Pet copyWith({
    String? petId,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? gender,
    double? weight,
    List<DailyRoutineLog>? dailyRoutines,
  }) {
    return Pet(
      petId: petId ?? this.petId,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      dailyRoutines: dailyRoutines ?? this.dailyRoutines,
    );
  }
}
