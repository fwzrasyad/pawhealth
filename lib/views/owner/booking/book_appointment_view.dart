import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../controllers/pet_controller.dart';

class BookAppointmentView extends StatefulWidget {
  final String? initialReason;
  const BookAppointmentView({super.key, this.initialReason});

  @override
  State<BookAppointmentView> createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);
  static const _softPurple = Color(0xFFEDE9FE);

  int _currentStep = 0;
  bool _isBooking = false;
  String? _selectedPetId;
  late final TextEditingController _reasonController;
  String _clinicSearchQuery = '';

  /// Clinic-wide default time slots
  static const List<String> _defaultTimeSlots = [
    '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.initialReason ?? 'General Consultation');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<AppointmentController>();
      ctrl.resetBookingForm();
      ctrl.fetchClinics();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

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

  String _vetEmoji(String id) {
    final icons = ['👨‍⚕️', '👩‍⚕️', '🩺', '⚕️', '🔬', '💊'];
    return icons[id.hashCode % icons.length];
  }

  void _onPopInvoked(bool didPop) {
    if (didPop) return;
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppointmentController>();
    final petCtrl = context.watch<PetController>();

    return PopScope(
      canPop: false,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: _purple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            _getStepTitle(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressBar(),

            // Step Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildCurrentStep(controller, petCtrl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Select a Clinic';
      case 1:
        return 'Select a Veterinarian';
      case 2:
        return 'Final Details';
      default:
        return 'Book Consultation';
    }
  }

  Widget _buildProgressBar() {
    return Container(
      color: _purple,
      padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: index < _currentStep
                        ? const Icon(Icons.check, color: _purple, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: isActive ? _purple : Colors.white,
                            ),
                          ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(AppointmentController ctrl, PetController petCtrl) {
    switch (_currentStep) {
      case 0:
        return _buildStep1ClinicSelection(ctrl);
      case 1:
        return _buildStep2VetSelection(ctrl);
      case 2:
        return _buildStep3FinalDetails(ctrl, petCtrl);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Clinic Selection ──────────────────────────────────────────────
  Widget _buildStep1ClinicSelection(AppointmentController ctrl) {
    if (ctrl.isLoading && ctrl.clinics.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _purple));
    }

    final filteredClinics = ctrl.clinics.where((c) {
      final query = _clinicSearchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.city.toLowerCase().contains(query);
    }).toList();

    return Column(
      key: const ValueKey('step1'),
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by clinic name or city...',
                      hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade400,
                          fontSize: 14),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) => setState(() => _clinicSearchQuery = val),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: filteredClinics.length,
            itemBuilder: (context, index) {
              final clinic = filteredClinics[index];
              final isSelected = ctrl.selectedClinic?.clinicId == clinic.clinicId;

              return GestureDetector(
                onTap: () {
                  ctrl.selectClinic(clinic);
                  setState(() => _currentStep = 1);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: _purple, width: 2)
                        : Border.all(color: Colors.transparent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _lightPurple,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.local_hospital, color: _purple, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinic.name,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    clinic.city,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (clinic.address.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.home_work_outlined, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      clinic.address,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Step 2: Vet Selection ─────────────────────────────────────────────────
  Widget _buildStep2VetSelection(AppointmentController ctrl) {
    if (ctrl.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _purple));
    }

    if (ctrl.vets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No veterinarians found for this clinic.',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.all(24),
      itemCount: ctrl.vets.length,
      itemBuilder: (context, index) {
        final vet = ctrl.vets[index];
        final isSelected = ctrl.selectedVet?.vetId == vet.vetId;

        return GestureDetector(
          onTap: () {
            ctrl.selectVet(vet);
            setState(() => _currentStep = 2);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: _purple, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: _lightPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(_vetEmoji(vet.vetId), style: const TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vet.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: vet.specialties.take(3).map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _lightPurple,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _purple,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (vet.bio.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          vet.bio,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (vet.workingHours.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              vet.workingHours,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Step 3: Final Details ─────────────────────────────────────────────────
  Widget _buildStep3FinalDetails(AppointmentController ctrl, PetController petCtrl) {
    final bool canBook = ctrl.selectedTimeSlot != null &&
        _selectedPetId != null &&
        _reasonController.text.trim().isNotEmpty &&
        !_isBooking;

    return Column(
      key: const ValueKey('step3'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Clinic & Vet Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _softPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: _purple, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ctrl.selectedClinic?.name ?? '',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: _purple,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'with ${ctrl.selectedVet?.name ?? ''}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: _purple.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Pet Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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

                // Date Picker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('Pick a Date', Icons.calendar_month_outlined),
                      const SizedBox(height: 14),
                      _buildDatesList(ctrl),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Time Picker
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('Available Times', Icons.access_time_rounded),
                      const SizedBox(height: 14),
                      _buildTimeSlotsGrid(ctrl),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reason
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('Reason for Visit', Icons.note_outlined),
                      const SizedBox(height: 14),
                      _buildReasonField(),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Confirm Button
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: ElevatedButton(
            onPressed: canBook ? () => _handleBooking(ctrl, petCtrl) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              disabledBackgroundColor: Colors.grey.shade300,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: canBook ? 4 : 0,
            ),
            child: _isBooking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Helper Widgets for Step 3 ─────────────────────────────────────────────

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [Color(0xFF9333EA), _purple])
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
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Text(_petEmoji(pet.species), style: const TextStyle(fontSize: 24)),
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
                          color: isSelected ? Colors.white70 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatesList(AppointmentController controller) {
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
                border: isSelected ? null : Border.all(color: Colors.grey.shade200),
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
                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
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
                      color: isSelected ? Colors.white60 : Colors.grey.shade400,
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

  Widget _buildTimeSlotsGrid(AppointmentController controller) {
    if (controller.selectedDate == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Select a date first.',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade400, fontSize: 14),
        ),
      );
    }

    // Use default time slots if selectedVet doesn't have a schedule for that day
    List<String> availableSlots = _defaultTimeSlots;
    if (controller.selectedVet != null) {
      final dayNames = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];
      final dayName = dayNames[controller.selectedDate!.weekday - 1];
      final vetSlots = controller.selectedVet!.slotsForDay(dayName);
      if (vetSlots.isNotEmpty) {
        availableSlots = vetSlots;
      }
    }

    if (availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No times available on this date.',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500, fontSize: 14),
        ),
      );
    }

    final now = DateTime.now();
    final slotEntries = availableSlots.map((time24) {
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
    }).where((entry) {
      final slotDate = entry.value;
      if (slotDate.isBefore(now)) return false;
      
      if (controller.selectedVet != null) {
        final isBooked = controller.selectedVet!.bookedSlots.any((booked) => 
            booked.year == slotDate.year && 
            booked.month == slotDate.month && 
            booked.day == slotDate.day && 
            booked.hour == slotDate.hour && 
            booked.minute == slotDate.minute);
        if (isBooked) return false;
      }
      return true;
    }).toList();

    if (slotEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'No times available on this date.',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500, fontSize: 14),
        ),
      );
    }

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
                  ? const LinearGradient(colors: [Color(0xFF9333EA), _purple])
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: isSelected ? null : Border.all(color: Colors.grey.shade200),
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

  Widget _buildReasonField() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: TextField(
        controller: _reasonController,
        maxLines: 3,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'e.g., General Checkup, Vaccination, Skin Issue...',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ── Handle Booking ────────────────────────────────────────────────────────
  Future<void> _handleBooking(AppointmentController controller, PetController petCtrl) async {
    setState(() => _isBooking = true);

    final targetPet = petCtrl.pets.firstWhere((p) => p.petId == _selectedPetId);
    final success = await controller.bookConsultation(
      petId: targetPet.petId,
      petName: targetPet.name,
      reason: _reasonController.text.trim(),
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
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: _purple,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      Navigator.pop(context);
    }
  }
}
