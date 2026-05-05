import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../controllers/pet_controller.dart';
import '../../../models/veterinarian_model.dart';

class VetBookingDetailView extends StatefulWidget {
  const VetBookingDetailView({super.key});

  @override
  State<VetBookingDetailView> createState() => _VetBookingDetailViewState();
}

class _VetBookingDetailViewState extends State<VetBookingDetailView> {
  static const _purple = Color(0xFF8A2BE2);
  static const _deepPurple = Color(0xFF6B21A8);
  static const _lightPurple = Color(0xFFF3E8FF);
  static const _softPurple = Color(0xFFEDE9FE);

  bool _isBooking = false;
  String? _selectedPetId;

  String _petEmoji(String species) {
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppointmentController>();
    final petCtrl = context.watch<PetController>();
    final vet = controller.selectedVet;

    if (vet == null) {
      return const Scaffold(body: Center(child: Text('No Vet Selected')));
    }

    final bool canBook =
        controller.selectedTimeSlot != null && _selectedPetId != null && !_isBooking;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // ── Entire scrollable area ──────────────────────────────────
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Collapsing header with vet photo ──────────────────
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  stretch: true,
                  backgroundColor: _purple,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  title: const Text(
                    'Book Consultation',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF9333EA), _purple, _deepPurple],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles
                          Positioned(
                            top: -30, right: -30,
                            child: Container(
                              width: 140, height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 40, left: -20,
                            child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.04),
                              ),
                            ),
                          ),
                          // Vet profile picture
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: vet.profileImageUrl.isNotEmpty
                                      ? Image.network(
                                          vet.profileImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _vetPlaceholder(),
                                        )
                                      : _vetPlaceholder(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Content below the header ─────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Vet info card
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _purple.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              vet.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Veterinarian',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Specialties
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: vet.specialties.map((s) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _softPurple,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      s,
                                      style: const TextStyle(
                                        color: _purple,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            if (vet.bio.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Text(
                                vet.bio,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Select Pet ───────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('Select Pet', Icons.pets_outlined),
                            const SizedBox(height: 14),
                            _buildPetSelector(petCtrl),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Pick a Date ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                                'Pick a Date', Icons.calendar_month_outlined),
                            const SizedBox(height: 14),
                            _buildDatesList(controller, vet),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Available Times ──────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                                'Available Times', Icons.access_time_rounded),
                            const SizedBox(height: 14),
                            _buildTimeSlotsGrid(controller, vet),
                          ],
                        ),
                      ),

                      // Extra bottom padding so content isn't hidden behind the button
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed bottom button ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: GestureDetector(
              onTap: canBook ? () => _handleBooking(controller, petCtrl) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 56,
                decoration: BoxDecoration(
                  gradient: canBook
                      ? const LinearGradient(
                          colors: [Color(0xFF9333EA), _purple, _deepPurple])
                      : null,
                  color: canBook ? null : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: canBook
                      ? [
                          BoxShadow(
                            color: _purple.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: _isBooking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm Booking',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: canBook
                                    ? Colors.white
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color:
                                  canBook ? Colors.white : Colors.grey.shade500,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Vet placeholder avatar ──────────────────────────────────────────────
  Widget _vetPlaceholder() {
    return Container(
      color: _lightPurple,
      child: const Center(
        child: Icon(Icons.local_hospital_rounded, color: _purple, size: 42),
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _lightPurple,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _purple, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ── Pet Selector ────────────────────────────────────────────────────────
  Widget _buildPetSelector(PetController petCtrl) {
    if (petCtrl.pets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _lightPurple,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _purple.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: _purple, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Add a pet first to book a consultation.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: petCtrl.pets.map((pet) {
          final isSelected = _selectedPetId == pet.petId;
          return GestureDetector(
            onTap: () => setState(() => _selectedPetId = pet.petId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF9333EA), _purple])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade200, width: 1.5),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _purple.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Text(_petEmoji(pet.species),
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${pet.species} • ${pet.breed}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Date Selector ───────────────────────────────────────────────────────
  Widget _buildDatesList(AppointmentController controller, Veterinarian vet) {
    final now = DateTime.now();
    final dates = List.generate(14, (i) => now.add(Duration(days: i)));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = controller.selectedDate?.day == date.day &&
              controller.selectedDate?.month == date.month &&
              controller.selectedDate?.year == date.year;
          final isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;

          return GestureDetector(
            onTap: () => controller.selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 62,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF9333EA), _purple],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: isToday && !isSelected
                    ? Border.all(
                        color: _purple.withValues(alpha: 0.4), width: 1.5)
                    : isSelected
                        ? null
                        : Border.all(color: Colors.grey.shade200),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _purple.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color:
                          isSelected ? Colors.white60 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Time Slots ──────────────────────────────────────────────────────────
  Widget _buildTimeSlotsGrid(
      AppointmentController controller, Veterinarian vet) {
    if (controller.selectedDate == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.touch_app_rounded, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              'Select a date to see available times',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday'
    ];
    final dayOfWeek = controller.selectedDate!.weekday;
    final dayName = dayNames[dayOfWeek - 1];
    final availableSlots24 = vet.slotsForDay(dayName);

    if (availableSlots24.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded,
                size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              'No slots available on ${dayName}s',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final slotEntries = availableSlots24.map((time24) {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final suffix = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final displayStr = '$displayHour:${parts[1]} $suffix';

      final slotDate = DateTime(
        controller.selectedDate!.year,
        controller.selectedDate!.month,
        controller.selectedDate!.day,
        hour,
        minute,
      );
      return MapEntry(displayStr, slotDate);
    }).toList();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slotEntries.length,
      itemBuilder: (context, index) {
        final entry = slotEntries[index];
        final timeStr = entry.key;
        final slotDate = entry.value;
        final isSelected = controller.selectedTimeSlot == slotDate;

        return GestureDetector(
          onTap: () => controller.selectTimeSlot(slotDate),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF9333EA), _purple])
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  isSelected ? null : Border.all(color: Colors.grey.shade200),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _purple.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              timeStr,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Handle Booking ──────────────────────────────────────────────────────
  Future<void> _handleBooking(
      AppointmentController controller, PetController petCtrl) async {
    setState(() => _isBooking = true);

    final targetPet =
        petCtrl.pets.firstWhere((p) => p.petId == _selectedPetId);
    final success = await controller.bookConsultation(
      petId: targetPet.petId,
      petName: targetPet.name,
    );
    setState(() => _isBooking = false);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: _purple,
          behavior: SnackBarBehavior.floating,
          margin:
              const EdgeInsets.only(bottom: 20, left: 24, right: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      Navigator.pop(context);
    }
  }
}
