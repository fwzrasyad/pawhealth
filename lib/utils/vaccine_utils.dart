import '../models/pet_model.dart';
import '../models/vaccination_record_model.dart';

class VaccineUtils {
  static const Map<String, List<String>> coreVaccines = {
    'dog': [
      'Rabies',
      'DA2PP / DHPP (Combination Vaccine)', // Distemper, Adenovirus, Parvovirus, Parainfluenza
    ],
    'cat': [
      'Feline Panleukopenia',
      'Feline Calicivirus',
      'Feline Herpesvirus',
      'Rabies',
    ],
    'rabbit': [
      'Nobivac Myxo-RHD', // Or Myxo-RHD Plus, etc.
    ],
  };

  static const Map<String, List<String>> nonCoreVaccines = {
    'dog': [
      'Leptospirosis',
      'Bordetella (Kennel Cough)',
      'Canine Influenza',
      'Lyme Disease',
    ],
    'cat': [
      'Feline Leukemia (FeLV)',
      'Bordetella',
    ],
    'rabbit': [
      'Cylap RCD',
      'YURVAC RHD',
      'ERAVAC',
      'Medgene / EverVet',
    ],
  };

  static String getVaccinationStatus(Pet pet) {
    if (pet.species.toLowerCase() == 'bird') return 'N/A';

    final speciesCore = coreVaccines[pet.species.toLowerCase()] ?? [];
    if (speciesCore.isEmpty) return 'No data';

    int completedCore = 0;
    for (final required in speciesCore) {
      final hasVaccine = pet.vaccinations.any((v) =>
          v.vaccineName.toLowerCase() == required.toLowerCase() ||
          (v.isCore && v.vaccineName.toLowerCase().contains(required.split(' ')[0].toLowerCase())));
      if (hasVaccine) {
        completedCore++;
      }
    }

    if (completedCore == speciesCore.length) {
      return 'Fully Vaccinated';
    } else {
      return 'Vaccines: $completedCore/${speciesCore.length}';
    }
  }

  static bool isFullyVaccinated(Pet pet) {
    if (pet.species.toLowerCase() == 'bird') return true;
    final speciesCore = coreVaccines[pet.species.toLowerCase()] ?? [];
    if (speciesCore.isEmpty) return true;

    int completedCore = 0;
    for (final required in speciesCore) {
      final hasVaccine = pet.vaccinations.any((v) =>
          v.vaccineName.toLowerCase() == required.toLowerCase() ||
          (v.isCore && v.vaccineName.toLowerCase().contains(required.split(' ')[0].toLowerCase())));
      if (hasVaccine) completedCore++;
    }

    return completedCore == speciesCore.length;
  }
}
