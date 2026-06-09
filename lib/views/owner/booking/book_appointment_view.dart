import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../controllers/pet_controller.dart';
import 'payment_summary_view.dart' as payment_view;

class BookAppointmentView extends StatefulWidget {
  final String? initialReason;
  const BookAppointmentView({super.key, this.initialReason});

  @override
  State<BookAppointmentView> createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  int _currentStep = 0;
  bool _isBooking = false;
  String? _selectedPetId;
  late final TextEditingController _reasonController;
  String _clinicSearchQuery = '';

  /// Clinic-wide default time slots
  static const List<String> _defaultTimeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(
      text: widget.initialReason ?? 'General Consultation',
    );
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
        backgroundColor: const Color(0xFFF7F5FF),
        body: AnimatedSwitcher(
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
    );
  }


  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        } else {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: Colors.white.withOpacity(0.15),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isDone = index < _currentStep;
        final isActive = index == _currentStep;
        
        return Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: (isDone || isActive) ? Colors.white : Colors.white.withOpacity(0.2),
              ),
              alignment: Alignment.center,
              child: isDone
                  ? const Icon(Icons.check, color: Color(0xFF7C3AED), size: 13)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.6),
                      ),
                    ),
            ),
            if (index < 3)
              Container(
                width: 32,
                height: 2,
                color: isDone ? Colors.white : Colors.white.withOpacity(0.2),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildGradientHeader(String title) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _buildBackButton(),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepIndicator(),
        ],
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
      case 3:
        return _buildStep4PaymentSummary(petCtrl);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Clinic Selection ──────────────────────────────────────────────
  Widget _buildStep1ClinicSelection(AppointmentController ctrl) {
    return Column(
      key: const ValueKey('step1'),
      children: [
        _buildGradientHeader('Select a Clinic'),
        Expanded(
          child: ctrl.isLoading && ctrl.clinics.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
              : _buildClinicList(ctrl),
        ),
      ],
    );
  }

  Widget _buildClinicList(AppointmentController ctrl) {
    final filteredClinics = ctrl.clinics.where((c) {
      final query = _clinicSearchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.city.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDE8F8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFFC4B5FD), size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by clinic name or city...',
                      hintStyle: TextStyle(
                        fontFamily: 'Figtree',
                        color: Color(0xFF9B8CB8),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) =>
                        setState(() => _clinicSearchQuery = val),
                    style: const TextStyle(fontFamily: 'Figtree', fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredClinics.length,
            itemBuilder: (context, index) {
              final clinic = filteredClinics[index];
              final isSelected =
                  ctrl.selectedClinic?.clinicId == clinic.clinicId;

              return GestureDetector(
                onTap: () {
                  ctrl.selectClinic(clinic);
                  setState(() => _currentStep = 1);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFDFCFF) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFEDE8F8), 
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EFFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: clinic.profilePicture.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: clinic.profilePicture,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: SizedBox(
                                          width: 20, height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.local_hospital_outlined,
                                        color: Color(0xFF7C3AED),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.local_hospital_outlined,
                                      color: Color(0xFF7C3AED),
                                      size: 24,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        clinic.name,
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF1A0F2E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF3),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: const Text(
                                        'Open now',
                                        style: TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF15803D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: Color(0xFF9B8CB8),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        clinic.address.isNotEmpty ? '${clinic.address}, ${clinic.city}' : clinic.city,
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 11,
                                          color: Color(0xFF9B8CB8),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (clinic.phoneNumber.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 12,
                                        color: Color(0xFF9B8CB8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        clinic.phoneNumber,
                                        style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          fontSize: 11,
                                          color: Color(0xFF9B8CB8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: Color(0xFFC4B5FD), size: 16),
                        ],
                      ),
                      if (clinic.description.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          clinic.description,
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 12,
                            color: Color(0xFF534AB7),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Google Maps link — falls back to address search if no explicit URL
                      Builder(
                        builder: (context) {
                          final mapsUrl = clinic.googleMapsUrl.isNotEmpty
                              ? clinic.googleMapsUrl
                              : (clinic.address.isNotEmpty
                                  ? 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(clinic.address)}'
                                  : '');
                          if (mapsUrl.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: GestureDetector(
                              onTap: () async {
                                final uri = Uri.parse(mapsUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                children: const [
                                  Icon(Icons.map, size: 14, color: Color(0xFF7C3AED)),
                                  SizedBox(width: 6),
                                  Text(
                                    'View on Google Maps',
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
    return Column(
      key: const ValueKey('step2'),
      children: [
        _buildGradientHeader('Select a Veterinarian'),
        Expanded(
          child: ctrl.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
              : _buildVetList(ctrl),
        ),
      ],
    );
  }

  Widget _buildVetList(AppointmentController ctrl) {
    final availableVets = ctrl.vets.where((v) => v.consultationFee > 0).toList();

    if (availableVets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No veterinarians found for this clinic.',
              style: TextStyle(fontFamily: 'Figtree', color: Color(0xFF9B8CB8)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableVets.length,
      itemBuilder: (context, index) {
        final vet = availableVets[index];
        final isSelected = ctrl.selectedVet?.vetId == vet.vetId;

        return GestureDetector(
          onTap: () {
            ctrl.selectVet(vet);
            setState(() => _currentStep = 2);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFDFCFF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFEDE8F8),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: vet.profileImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: vet.profileImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Text(_vetEmoji(vet.vetId), style: const TextStyle(fontSize: 24)),
                            ),
                          )
                        : Center(
                            child: Text(_vetEmoji(vet.vetId), style: const TextStyle(fontSize: 24)),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vet.name,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A0F2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: vet.specialties.take(3).map((s) {
                          final isGp = s.toLowerCase() == 'general practice';
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isGp ? const Color(0xFFECFDF3) : const Color(0xFFEDE8F8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isGp ? const Color(0xFF15803D) : const Color(0xFF534AB7),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (vet.bio.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          vet.bio,
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11,
                            color: Color(0xFF9B8CB8),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      Builder(
                        builder: (context) {
                          String scheduleStr = vet.workingHours;
                          if (vet.weeklySchedule.isNotEmpty) {
                            final days = vet.weeklySchedule.entries
                                .where((e) => e.value.isNotEmpty)
                                .map((e) => e.key.substring(0, 3))
                                .toList();
                            if (days.isNotEmpty) {
                              final firstDaySlots = vet.weeklySchedule.entries.firstWhere((e) => e.value.isNotEmpty).value;
                              final times = firstDaySlots.length > 1 
                                  ? '${firstDaySlots.first} - ${firstDaySlots.last}'
                                  : firstDaySlots.first;
                              scheduleStr = '${days.join(', ')}: $times';
                            }
                          }
                          if (scheduleStr.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.schedule, size: 12, color: Color(0xFFB0A4C8)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    scheduleStr,
                                    style: const TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 11,
                                      color: Color(0xFFB0A4C8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Price Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'RM ${vet.consultationFee.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const Text(
                      'per visit',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 10,
                        color: Color(0xFF9B8CB8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(Icons.chevron_right, color: Color(0xFFC4B5FD), size: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroContainer({required Widget child, double topPadding = 44, double bottomPadding = 28}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF6D28D9).withOpacity(0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4C1D95).withOpacity(0.3),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding, 20, bottomPadding),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3HeroHeader(AppointmentController ctrl) {
    final vet = ctrl.selectedVet;
    final clinic = ctrl.selectedClinic;

    return _buildHeroContainer(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: _buildBackButton(),
              ),
              const Text(
                'Final Details',
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepIndicator(),
          const SizedBox(height: 16),
          Container(
            width: 72,
            height: 72,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: vet?.profileImageUrl.isNotEmpty == true
                  ? CachedNetworkImage(
                      imageUrl: vet!.profileImageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)),
                      ),
                      errorWidget: (context, url, error) => Center(child: Text(_vetEmoji(vet.vetId), style: const TextStyle(fontSize: 30))),
                    )
                  : Center(child: Text(_vetEmoji(vet?.vetId ?? ''), style: const TextStyle(fontSize: 30))),
            ),
          ),
          Text(
            vet?.name ?? '',
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Text(
              clinic?.name ?? '',
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 12,
                color: Colors.white.withOpacity(0.65),
              ),
            ),
          ),
          if (vet?.bio.isNotEmpty == true)
            Text(
              vet!.bio,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  // ── Step 3: Final Details ─────────────────────────────────────────────────
  Widget _buildStep3FinalDetails(
    AppointmentController ctrl,
    PetController petCtrl,
  ) {
    final bool canBook =
        ctrl.selectedTimeSlot != null &&
        _selectedPetId != null &&
        _reasonController.text.trim().isNotEmpty &&
        !_isBooking;

    return Column(
      key: const ValueKey('step3'),
      children: [
        _buildStep3HeroHeader(ctrl),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('Consultation Type', Icons.medical_services_outlined),
                        _buildConsultationTypeSelector(ctrl),
                        const SizedBox(height: 24),

                        _sectionHeader('Select Pet', Icons.pets_outlined),
                        _buildPetSelector(petCtrl),
                        const SizedBox(height: 24),
                        
                        _sectionHeader('Pick a Date', Icons.calendar_month_outlined),
                        _buildDatesList(ctrl),
                        const SizedBox(height: 24),

                        _sectionHeader('Pick a Time', Icons.access_time_rounded),
                        _buildTimeSlotsGrid(ctrl),
                        const SizedBox(height: 24),

                        _sectionHeader('Reason for Visit', Icons.chat_bubble_outline),
                        _buildReasonField(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // Confirm Button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: canBook ? () {
                      setState(() => _currentStep = 3);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      disabledBackgroundColor: const Color(0xFFDDD8F5),
                      disabledForegroundColor: const Color(0xFFB0A4C8),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isBooking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontFamily: 'Figtree',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 4: Payment Summary ───────────────────────────────────────────────
  Widget _buildStep4PaymentSummary(PetController petCtrl) {
    final pet = petCtrl.pets.firstWhere(
      (p) => p.petId == _selectedPetId,
      orElse: () => petCtrl.pets.first,
    );

    return payment_view.PaymentSummaryView(
      key: const ValueKey('step4'),
      petId: pet.petId,
      petName: pet.name,
      reason: _reasonController.text.trim(),
      onPaymentSuccess: () {
        if (!mounted) return;
        Navigator.pop(context);
      },
    );
  }

  // ── Helper Widgets for Step 3 ─────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7C3AED), size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Figtree',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1A0F2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationTypeSelector(AppointmentController ctrl) {
    final isVirtual = ctrl.consultationType == 'virtual';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEDE8F8)),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.setConsultationType('in_person'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isVirtual ? const Color(0xFF7C3AED) : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: !isVirtual
                          ? [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_hospital_outlined,
                          size: 16,
                          color: !isVirtual ? Colors.white : const Color(0xFF9B8CB8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'In-Person',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: !isVirtual ? Colors.white : const Color(0xFF9B8CB8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => ctrl.setConsultationType('virtual'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isVirtual ? const Color(0xFF7C3AED) : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: isVirtual
                          ? [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_outlined,
                          size: 16,
                          color: isVirtual ? Colors.white : const Color(0xFF9B8CB8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Virtual',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isVirtual ? Colors.white : const Color(0xFF9B8CB8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isVirtual) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 14, color: Color(0xFF7C3AED)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'ll join a video call once the vet starts the consultation.',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 11,
                      color: Color(0xFF534AB7),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPetSelector(PetController petCtrl) {
    if (petCtrl.pets.isEmpty) {
      return const Text(
        'Add a pet first to book a consultation.',
        style: TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF9B8CB8)),
      );
    }

    return Row(
      children: petCtrl.pets.map((pet) {
        final isSelected = _selectedPetId == pet.petId;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPetId = pet.petId),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDFCFF) : const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFEDE8F8),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Text(_petEmoji(pet.species), style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1A0F2E),
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          pet.species,
                          style: const TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 11,
                            color: Color(0xFF9B8CB8),
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatesList(AppointmentController controller) {
    final now = DateTime.now();
    final dates = List.generate(14, (i) => now.add(Duration(days: i)));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              controller.selectedDate?.day == date.day &&
              controller.selectedDate?.month == date.month &&
              controller.selectedDate?.year == date.year;

          bool isAvailable = true;
          if (controller.selectedVet != null) {
            final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
            final dayName = dayNames[date.weekday - 1];
            isAvailable = controller.selectedVet!.slotsForDay(dayName).isNotEmpty;
          }

          return GestureDetector(
            onTap: isAvailable ? () => controller.selectDate(date) : null,
            child: Opacity(
              opacity: isAvailable ? 1.0 : 0.4,
              child: Container(
                width: 52,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7C3AED) : (isAvailable ? const Color(0xFFF7F5FF) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFEDE8F8),
                    width: 1.5,
                  ),
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF9B8CB8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF1A0F2E),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 11,
                      color: isSelected ? Colors.white : const Color(0xFFB0A4C8),
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotsGrid(AppointmentController controller) {
    if (controller.selectedDate == null) {
      return const Text(
        'Select a date first',
        style: TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF9B8CB8)),
      );
    }

    List<String> availableSlots = _defaultTimeSlots;
    if (controller.selectedVet != null) {
      final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final dayName = dayNames[controller.selectedDate!.weekday - 1];
      availableSlots = controller.selectedVet!.slotsForDay(dayName);
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
        hour, minute,
      );
      return MapEntry(displayStr, slotDate);
    }).where((entry) {
      final slotDate = entry.value;
      if (slotDate.isBefore(now)) return false;
      if (controller.selectedVet != null) {
        final isBooked = controller.selectedVet!.bookedSlots.any((booked) =>
            booked.year == slotDate.year && booked.month == slotDate.month &&
            booked.day == slotDate.day && booked.hour == slotDate.hour &&
            booked.minute == slotDate.minute);
        if (isBooked) return false;
      }
      return true;
    }).toList();

    if (slotEntries.isEmpty) {
      return const Text(
        'No times available on this date.',
        style: TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF9B8CB8)),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slotEntries.map((entry) {
        final isSelected = controller.selectedTimeSlot == entry.value;
        return GestureDetector(
          onTap: () => controller.selectTimeSlot(entry.value),
            child: Container(
              width: 95,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFEDE8F8),
                  width: 1.5,
                ),
              ),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF1A0F2E),
                ),
              ),
            ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: _reasonController,
      maxLines: 3,
      style: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF1A0F2E)),
      decoration: InputDecoration(
        hintText: 'e.g., General Checkup, Vaccination, Skin Issue...',
        hintStyle: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF9B8CB8)),
        contentPadding: const EdgeInsets.all(14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEDE8F8), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

}
