import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/pet_controller.dart';
import 'pet_detail_view.dart';
import 'add_edit_pet_view.dart';

class MyPetsListView extends StatefulWidget {
  const MyPetsListView({super.key});

  @override
  State<MyPetsListView> createState() => _MyPetsListViewState();
}

class _MyPetsListViewState extends State<MyPetsListView> {
  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<PetController>(context, listen: false)
            .fetchPets(auth.currentUser!.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final petController = context.watch<PetController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Pets',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPetView()),
          );
        },
        backgroundColor: _purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: petController.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _purple),
            )
          : petController.pets.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: petController.pets.length,
                  itemBuilder: (context, index) {
                    final pet = petController.pets[index];
                    return _PetCard(
                      pet: pet,
                      onTap: () {
                        petController.selectPet(pet);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PetDetailView(),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: _lightPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, size: 60, color: _purple),
          ),
          const SizedBox(height: 24),
          const Text(
            'No pets yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first pet.',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  final dynamic pet;
  final VoidCallback onTap;

  const _PetCard({required this.pet, required this.onTap});

  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  String get _emoji {
    switch (pet.species.toLowerCase()) {
      case 'cat': return '🐱';
      case 'dog': return '🐶';
      case 'rabbit': return '🐰';
      case 'bird': return '🦜';
      default: return '🐾';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Avatar
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: _lightPurple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(_emoji, style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(width: 16),
            // Pet Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.species} • ${pet.breed}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _lightPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pet.gender,
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
