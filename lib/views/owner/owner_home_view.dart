import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/pet_controller.dart';
import '../../utils/constants.dart';
import 'medical_record_list_view.dart';

class OwnerHomeView extends StatefulWidget {
  const OwnerHomeView({super.key});

  @override
  State<OwnerHomeView> createState() => _OwnerHomeViewState();
}

class _OwnerHomeViewState extends State<OwnerHomeView> {
  @override
  void initState() {
    super.initState();
    // Fetch user's pets on view init
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
    final petController = Provider.of<PetController>(context);

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: Text(
          'My Pets',
          style: AppFonts.fraunces(fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: petController.isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: AppColors.primary,
            ))
          : petController.pets.isEmpty
              ? Center(
                  child: Text(
                  'No pets found. Add one!',
                  style: AppFonts.body(color: AppColors.mutedText, fontSize: 16),
                ))
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: petController.pets.length,
                  itemBuilder: (context, index) {
                    final pet = petController.pets[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedicalRecordListView(pet: pet),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecor.card(),
                        child: Row(
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: AppDecor.squareChip(),
                              child: Icon(
                                Icons.pets,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pet.name,
                                    style: AppFonts.fraunces(fontSize: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${pet.species} • ${pet.breed}',
                                    style: AppFonts.caption(color: AppColors.metaText),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.navInactive,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
