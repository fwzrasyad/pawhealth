import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/constants.dart';
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
      backgroundColor: AppColors.lightSurface,
      appBar: AppDecor.tabAppBar(title: 'My Pets'),
      body: petController.isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                _buildSummaryChips(petController.pets.length),
                Expanded(
                  child: petController.pets.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: petController.pets.length + 1,
                          itemBuilder: (context, index) {
                            if (index == petController.pets.length) {
                              return _buildAddNewPetRow(context);
                            }
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
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryChips(int totalPets) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDE8F8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalPets.toString(),
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const Text(
                    'Total pets',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Color(0xFF9B8CB8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDE8F8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalPets.toString(),
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const Text(
                    'Healthy pets',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Color(0xFF9B8CB8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewPetRow(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPetView()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDDD8F5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add, color: Color(0xFFC4B5FD), size: 22),
            ),
            const SizedBox(width: 16),
            const Text(
              "Add a new pet",
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF9B8CB8),
              ),
            ),
          ],
        ),
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
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.pets, size: 60, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'No pets yet!',
            style: TextStyle(
              fontFamily: 'Figtree',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A0F2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to add your first pet.',
            style: TextStyle(
              fontFamily: 'Figtree',
              color: Color(0xFF9B8CB8),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildAddNewPetRow(context),
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
    final isMale = pet.gender.toLowerCase() == 'male';
    final genderBg = isMale ? const Color(0xFFEDE8F8) : const Color(0xFFFDF2F8);
    final genderColor = isMale ? const Color(0xFF534AB7) : const Color(0xFF993556);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDE8F8)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFFF),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.hardEdge,
              child: (pet.profileImageUrl != null && pet.profileImageUrl.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: pet.profileImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text(_emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    )
                  : Center(
                      child: Text(_emoji, style: const TextStyle(fontSize: 24)),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A0F2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pet.species} · ${pet.breed} · ${pet.gender} · ${pet.age} yrs',
                    style: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9B8CB8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: genderBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pet.gender,
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: genderColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC4B5FD), size: 20),
          ],
        ),
      ),
    );
  }
}
