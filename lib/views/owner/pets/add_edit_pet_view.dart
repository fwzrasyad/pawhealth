import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  String _emoji(String species) {
    switch (species.toLowerCase()) {
      case 'cat':
        return '🐱';
      case 'dog':
        return '🐶';
      case 'rabbit':
        return '🐰';
      case 'bird':
        return '🦜';
      default:
        return '🐾';
    }
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon, bool isDropdown = false}) {
    return InputDecoration(
      labelText: label.toUpperCase(),
      labelStyle: const TextStyle(
        fontFamily: 'Figtree',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF7C3AED),
        letterSpacing: 0.08,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: InputBorder.none,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFEDE8F8), width: 1.5),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF7C3AED), width: 1.5),
      ),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFC4B5FD), size: 18) : null,
      suffixIcon: isDropdown
          ? const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFC4B5FD), size: 20)
          : null,
      contentPadding: const EdgeInsets.only(bottom: 10, top: 10),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final controller = context.read<PetController>();
    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.userId ?? '';

    final latestPet = _isEditing
        ? controller.pets.firstWhere((p) => p.petId == widget.petToEdit!.petId, orElse: () => widget.petToEdit!)
        : null;

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
      profileImageUrl: latestPet?.profileImageUrl,
      dailyRoutines: latestPet?.dailyRoutines ?? [],
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF7C3AED),
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
    const fieldTextStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1A0F2E),
      fontFamily: 'Figtree',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEDE8F8)),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_back, color: Color(0xFF7C3AED), size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Edit Profile' : 'Add Pet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A0F2E),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable body ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Photo Upload ────────────────────────────────
                    Consumer<PetController>(
                      builder: (context, controller, child) {
                        final currentPet = _isEditing
                            ? controller.pets.firstWhere(
                                (p) => p.petId == widget.petToEdit!.petId,
                                orElse: () => widget.petToEdit!)
                            : null;
                        final imageUrl = currentPet?.profileImageUrl;
                        final speciesEmoji = _isEditing
                            ? _emoji(currentPet?.species ?? 'other')
                            : (_selectedSpecies != null ? _emoji(_selectedSpecies!) : '🐾');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 28),
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3EFFF),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: (imageUrl != null && imageUrl.isNotEmpty)
                                        ? CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                            errorWidget: (context, url, error) => Center(
                                              child: Text(speciesEmoji, style: const TextStyle(fontSize: 44)),
                                            ),
                                          )
                                        : Center(
                                            child: Text(speciesEmoji, style: const TextStyle(fontSize: 44)),
                                          ),
                                  ),
                                  Positioned(
                                    bottom: -4,
                                    right: -4,
                                    child: GestureDetector(
                                      onTap: (controller.isLoading)
                                          ? null
                                          : () async {
                                              if (!_isEditing) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Please save the pet profile first before uploading a picture!',
                                                    ),
                                                    backgroundColor: Color(0xFF7C3AED),
                                                  ),
                                                );
                                                return;
                                              }
                                              await controller.uploadProfilePicture(widget.petToEdit!.petId);
                                            },
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7C3AED),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFFF7F5FF), width: 2),
                                        ),
                                        child: controller.isLoading
                                            ? const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 1.5,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Center(
                                                child: Icon(Icons.camera_alt, color: Colors.white, size: 13),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: const Text(
                                  'Change photo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // ── Form fields container ────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEDE8F8)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          // Pet Name
                          TextFormField(
                            controller: _nameController,
                            decoration: _fieldDecoration('Pet Name', icon: Icons.badge_outlined),
                            style: fieldTextStyle,
                            validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
                          ),
                          const SizedBox(height: 20),

                          // Species Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedSpecies,
                            decoration: _fieldDecoration('Species', icon: Icons.category_outlined, isDropdown: true),
                            style: fieldTextStyle,
                            icon: const SizedBox.shrink(),
                            items: _species.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _selectedSpecies = v),
                            validator: (v) => v == null ? 'Please select a species' : null,
                          ),
                          const SizedBox(height: 20),

                          // Breed
                          TextFormField(
                            controller: _breedController,
                            decoration: _fieldDecoration('Breed', icon: Icons.pets_outlined),
                            style: fieldTextStyle,
                            validator: (v) => v == null || v.isEmpty ? 'Please enter a breed' : null,
                          ),
                          const SizedBox(height: 20),

                          // Age
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: _fieldDecoration('Age (Years)', icon: Icons.cake_outlined),
                            style: fieldTextStyle,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Please enter age';
                              if (int.tryParse(v) == null) return 'Please enter a valid number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Gender Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: _fieldDecoration('Gender', icon: Icons.transgender_outlined, isDropdown: true),
                            style: fieldTextStyle,
                            icon: const SizedBox.shrink(),
                            items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (v) => setState(() => _selectedGender = v),
                            validator: (v) => v == null ? 'Please select a gender' : null,
                          ),
                          const SizedBox(height: 20),

                          // Weight
                          TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _fieldDecoration('Weight (kg)', icon: Icons.monitor_weight_outlined),
                            style: fieldTextStyle,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Please enter weight';
                              if (double.tryParse(v) == null) return 'Please enter a valid number';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    // ── Save button ──────────────────────────────────
                    Container(
                      margin: const EdgeInsets.only(top: 24, bottom: 16),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          disabledBackgroundColor: const Color(0xFF7C3AED).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shadowColor: Colors.transparent,
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Figtree',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
