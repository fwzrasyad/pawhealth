import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/pet_controller.dart';
import '../../../models/pet_model.dart';

class AddEditPetView extends StatefulWidget {
  final Pet? petToEdit;

  const AddEditPetView({super.key, this.petToEdit});

  @override
  State<AddEditPetView> createState() => _AddEditPetViewState();
}

class _AddEditPetViewState extends State<AddEditPetView> {
  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController();
  late final _breedController = TextEditingController();
  late final _weightController = TextEditingController();
  late final _ageController = TextEditingController();

  String? _selectedSpecies;
  String? _selectedGender;
  bool _isSaving = false;

  final _species = ['Dog', 'Cat', 'Rabbit', 'Bird', 'Other'];
  final _genders = ['Male', 'Female'];

  bool get _isEditing => widget.petToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.petToEdit;
    if (p != null) {
      _nameController.text = p.name;
      _breedController.text = p.breed;
      _weightController.text = p.weight.toString();
      _selectedSpecies = p.species;
      _selectedGender = p.gender;
      _ageController.text = p.age.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.grey),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _purple, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final controller = context.read<PetController>();
    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.userId ?? '';

    final pet = Pet(
      petId: _isEditing
          ? widget.petToEdit!.petId
          : 'pet_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: userId,
      name: _nameController.text.trim(),
      species: _selectedSpecies!,
      breed: _breedController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      gender: _selectedGender!,
      weight: double.parse(_weightController.text.trim()),
      dailyRoutines: _isEditing ? widget.petToEdit!.dailyRoutines : [],
    );

    if (_isEditing) {
      await controller.updatePet(pet);
    } else {
      await controller.addPet(pet);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? '${pet.name}\'s profile updated!' : '${pet.name} added!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          ),
          backgroundColor: _purple,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Profile' : 'Add Pet',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo upload placeholder
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: _lightPurple,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.pets, size: 50, color: _purple.withValues(alpha: 0.6)),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: _purple,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Upload Photo',
                  style: TextStyle(
                    color: _purple,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: _fieldDecoration('Pet Name', icon: Icons.badge_outlined),
                style: const TextStyle(fontFamily: 'Poppins'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),

              // Species Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedSpecies,
                decoration: _fieldDecoration('Species', icon: Icons.category_outlined),
                style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
                items: _species.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedSpecies = v),
                validator: (v) => v == null ? 'Please select a species' : null,
              ),
              const SizedBox(height: 16),

              // Breed
              TextFormField(
                controller: _breedController,
                decoration: _fieldDecoration('Breed', icon: Icons.pets_outlined),
                style: const TextStyle(fontFamily: 'Poppins'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter a breed' : null,
              ),
              const SizedBox(height: 16),

              // Age
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Age (Years)', icon: Icons.cake_outlined),
                style: const TextStyle(fontFamily: 'Poppins'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter age';
                  if (int.tryParse(v) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: _fieldDecoration('Gender', icon: Icons.transgender_outlined),
                style: const TextStyle(fontFamily: 'Poppins', color: Colors.black),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
                validator: (v) => v == null ? 'Please select a gender' : null,
              ),
              const SizedBox(height: 16),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _fieldDecoration('Weight (kg)', icon: Icons.monitor_weight_outlined),
                style: const TextStyle(fontFamily: 'Poppins'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter weight';
                  if (double.tryParse(v) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      // Save button
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            disabledBackgroundColor: _purple.withValues(alpha: 0.5),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  _isEditing ? 'Save Changes' : 'Save Profile',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
