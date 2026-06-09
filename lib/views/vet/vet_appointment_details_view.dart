import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/vet_controller.dart';
import '../../../models/appointment_model.dart';
import '../../../models/medical_record_model.dart';
import '../video_call/video_call_view.dart';

class VetAppointmentDetailsView extends StatefulWidget {
  final Appointment appointment;
  const VetAppointmentDetailsView({super.key, required this.appointment});

  @override
  State<VetAppointmentDetailsView> createState() => _VetAppointmentDetailsViewState();
}

class _VetAppointmentDetailsViewState extends State<VetAppointmentDetailsView> {
  late Appointment _appointment;
  MedicalRecord? _existingRecord;
  bool _loadingRecord = true;
  bool _processing = false;
  bool _notesSubmitted = false;

  final _formKey = GlobalKey<FormState>();
  final _diagnosisCtrl = TextEditingController();
  final _doctorNotesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _followUpCtrl = TextEditingController();

  // Recovery Plan
  bool _startRecoveryPlan = false;
  final _recoveryDurationCtrl = TextEditingController(text: '7');
  final _recoveryInstructionsCtrl = TextEditingController();

  List<String> _medications = [];
  List<Map<String, dynamic>> _administeredVaccines = [];

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingRecord();
    });
  }

  Future<void> _loadExistingRecord() async {
    if (_appointment.status == AppointmentStatus.completed) {
      if (_appointment.medicalRecord != null) {
        if (mounted) {
          setState(() {
            _existingRecord = _appointment.medicalRecord;
            _loadingRecord = false;
            _notesSubmitted = true;
          });
        }
        return;
      }
      final vc = context.read<VetController>();
      final record = await vc.fetchMedicalRecordForAppointment(_appointment.appointmentId);
      if (mounted) {
        setState(() {
          _existingRecord = record;
          _loadingRecord = false;
          _notesSubmitted = record != null;
        });
      }
    } else {
      if (mounted) setState(() => _loadingRecord = false);
    }
  }

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _doctorNotesCtrl.dispose();
    _medicationsCtrl.dispose();
    _followUpCtrl.dispose();
    _recoveryDurationCtrl.dispose();
    _recoveryInstructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleApprove() async {
    setState(() => _processing = true);
    final vc = context.read<VetController>();
    await vc.acceptAppointment(_appointment.appointmentId);
    if (mounted) {
      setState(() {
        _appointment = _appointment.copyWith(status: AppointmentStatus.confirmed);
        _processing = false;
      });
      _showSnackBar('Appointment approved', Icons.check_circle, const Color(0xFF15803D));
    }
  }

  Future<void> _handleDecline() async {
    setState(() => _processing = true);
    final vc = context.read<VetController>();
    await vc.rejectAppointment(_appointment.appointmentId);
    if (mounted) {
      setState(() {
        _appointment = _appointment.copyWith(status: AppointmentStatus.cancelled);
        _processing = false;
      });
      _showSnackBar('Appointment declined', Icons.cancel, const Color(0xFFB45309));
    }
  }

  Future<void> _handleStartConsultation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Start Consultation', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold)),
        content: const Text('This will mark the appointment as completed and allow you to write clinical notes.', style: TextStyle(fontFamily: 'Figtree', fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(fontFamily: 'Figtree', color: Colors.grey.shade600))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Confirm', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _processing = true);
    final vc = context.read<VetController>();
    await vc.completeAppointment(_appointment.appointmentId);
    if (mounted) {
      setState(() {
        _appointment = _appointment.copyWith(status: AppointmentStatus.completed);
        _processing = false;
        _loadingRecord = false;
      });
      _showSnackBar('Consultation started — write your notes below', Icons.edit_note, const Color(0xFF7C3AED));
    }
  }

  Future<void> _handleStartVideoCall() async {
    setState(() => _processing = true);
    final vc = context.read<VetController>();
    final response = await vc.startVideoCall(_appointment.appointmentId);

    if (response == null) {
      if (mounted) {
        setState(() => _processing = false);
        _showSnackBar('Failed to start video call. Please try again.', Icons.error, const Color(0xFFB45309));
      }
      return;
    }

    if (mounted) {
      setState(() => _processing = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallView(
            appId: response['app_id'],
            token: response['token'],
            channelName: response['channel'],
            uid: response['uid'] ?? 1,
            remoteName: _appointment.petName,
            onCallEnded: () async {
              try {
                await vc.endVideoCall(_appointment.appointmentId);
              } catch (e) {
                debugPrint('Error ending call: $e');
              }
              if (mounted) {
                setState(() {
                  _appointment = _appointment.copyWith(
                    status: AppointmentStatus.completed,
                    videoCallStatus: 'ended',
                  );
                  _loadingRecord = false;
                });
                _showSnackBar('Video call ended — write your clinical notes below', Icons.edit_note, const Color(0xFF7C3AED));
              }
            },
          ),
        ),
      );
    }
  }

  Future<void> _handleSubmitNotes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _processing = true);
    final vc = context.read<VetController>();
    final record = await vc.submitClinicalNotes(
      appointmentId: _appointment.appointmentId,
      petId: _appointment.petId,
      diagnosis: _diagnosisCtrl.text.trim(),
      doctorNotes: _doctorNotesCtrl.text.trim(),
      medicationsPrescribed: _medications,
      followUpInstructions: _followUpCtrl.text.trim(),
      startRecoveryPlan: _startRecoveryPlan,
      recoveryDurationDays: int.tryParse(_recoveryDurationCtrl.text.trim()) ?? 7,
      recoveryInstructions: _recoveryInstructionsCtrl.text.trim(),
      administeredVaccines: _administeredVaccines,
    );

    if (mounted) {
      setState(() {
        _processing = false;
        if (record != null) {
          _existingRecord = record;
          _notesSubmitted = true;
        }
      });
      if (record != null) {
        _showSnackBar('Clinical notes saved successfully', Icons.check_circle, const Color(0xFF15803D));
      } else {
        _showSnackBar('Failed to save notes. Please try again.', Icons.error, const Color(0xFFB45309));
      }
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7C3AED),
      body: Column(
        children: [
          _buildHeroHeader(context),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F5FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChipsRow(),
                      const SizedBox(height: 14),
                      _buildInfoCard(),
                      const SizedBox(height: 14),
                      _buildActionSection(),
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

  Widget _buildHeroHeader(BuildContext context) {
    final vc = context.read<VetController>();
    final fallbackPet = vc.getPetById(_appointment.petId);
    final imgUrl = (_appointment.petProfileUrl != null && _appointment.petProfileUrl!.isNotEmpty)
        ? _appointment.petProfileUrl
        : fallbackPet?.profileImageUrl;

    String badgeText = '';
    Color badgeDotColor = Colors.transparent;
    if (_appointment.status == AppointmentStatus.confirmed) {
      badgeDotColor = const Color(0xFFA7F3D0);
      badgeText = 'Confirmed · Ready for consultation';
    } else if (_appointment.status == AppointmentStatus.pending) {
      badgeDotColor = const Color(0xFFFDE68A);
      badgeText = 'Pending · Awaiting confirmation';
    } else if (_appointment.status == AppointmentStatus.completed) {
      badgeDotColor = const Color(0xFFBBF7D0);
      badgeText = 'Completed';
    } else if (_appointment.status == AppointmentStatus.cancelled) {
      badgeDotColor = const Color(0xFFFECACA);
      badgeText = 'Cancelled';
    }

    return Stack(
      children: [
        // Blobs
        Positioned(
          top: -40,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6D28D9).withValues(alpha: 0.4),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          right: -20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4C1D95).withValues(alpha: 0.3),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                Container(
                  width: 76,
                  height: 76,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: imgUrl != null && imgUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const SizedBox(),
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              vc.getPetEmoji(fallbackPet?.species ?? ''),
                              style: const TextStyle(fontSize: 42),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            vc.getPetEmoji(fallbackPet?.species ?? ''),
                            style: const TextStyle(fontSize: 42),
                          ),
                        ),
                ),
                Text(
                  _appointment.petName,
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 14, top: 3),
                  child: Text(
                    'Owner: ${_appointment.ownerName ?? 'Unknown'} · Appointment Details',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badgeDotColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        badgeText,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 44,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipsRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _appointment.isVirtual ? const Color(0xFF0369A1) : const Color(0xFF534AB7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _appointment.isVirtual ? Icons.videocam : Icons.local_hospital,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _appointment.isVirtual ? 'Virtual' : 'In-Person',
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (_appointment.amount != null && _appointment.amount! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF15803D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '\$${_appointment.amount!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          _buildInfoRow(Icons.pets, 'Pet', _appointment.petName),
          const Divider(color: Color(0xFFEDE8F8), height: 1),
          _buildInfoRow(Icons.calendar_today_outlined, 'Date', DateFormat('MMM d, yyyy').format(_appointment.appointmentDate)),
          const Divider(color: Color(0xFFEDE8F8), height: 1),
          _buildInfoRow(Icons.access_time, 'Time', DateFormat('h:mm a').format(_appointment.timeSlot)),
          const Divider(color: Color(0xFFEDE8F8), height: 1),
          _buildInfoRow(Icons.storefront_outlined, 'Clinic', _appointment.clinicName.isNotEmpty ? _appointment.clinicName : 'N/A'),
          const Divider(color: Color(0xFFEDE8F8), height: 1),
          _buildInfoRow(Icons.description_outlined, 'Reason', _appointment.reason),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7C3AED), size: 16),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9B8CB8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Figtree',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A0F2E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    switch (_appointment.status) {
      case AppointmentStatus.pending:
        return _buildPendingActions();
      case AppointmentStatus.confirmed:
        return _buildConfirmedActions();
      case AppointmentStatus.completed:
        return _buildCompletedSection();
      case AppointmentStatus.cancelled:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPendingActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _processing ? null : _handleDecline,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Reject',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B8CB8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _processing ? null : _handleApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _processing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Accept',
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmedActions() {
    final isVirtual = _appointment.isVirtual;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF15803D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ready to begin',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Ensure you are prepared for the consultation.',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (isVirtual) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _processing ? null : _handleStartVideoCall,
              icon: _processing
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.videocam, color: Colors.white, size: 15),
              label: const Text('Start Video Call', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _processing ? null : _handleStartConsultation,
              icon: _processing
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.play_arrow, color: Colors.white, size: 15),
              label: const Text('Start Consultation', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6),
            child: const Text(
              'Marks appointment as completed and unlocks clinical notes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Figtree',
                fontSize: 11,
                color: Color(0xFFB0A4C8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedSection() {
    if (_loadingRecord) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: Color(0xFF7C3AED))));
    }
    if (_notesSubmitted && _existingRecord != null) {
      return _buildReadOnlyNotes(_existingRecord!);
    }
    return _buildClinicalNotesForm();
  }

  Widget _buildClinicalNotesForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, color: Color(0xFF7C3AED), size: 16),
                const SizedBox(width: 12),
                const Text('Clinical Notes', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A0F2E))),
              ],
            ),
            const SizedBox(height: 6),
            Text('Complete the consultation notes for this visit', style: TextStyle(fontFamily: 'Figtree', fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            _buildFormField(controller: _diagnosisCtrl, label: 'Diagnosis', hint: 'e.g. Upper respiratory infection', icon: Icons.medical_information_outlined, validator: (v) => (v == null || v.trim().isEmpty) ? 'Diagnosis is required' : null),
            const SizedBox(height: 16),
            _buildFormField(controller: _doctorNotesCtrl, label: "Doctor's Notes", hint: 'Detailed clinical observations...', icon: Icons.notes_outlined, maxLines: 4, validator: (v) => (v == null || v.trim().isEmpty) ? 'Notes are required' : null),
            const SizedBox(height: 16),
            _buildMedicationsSection(),
            const SizedBox(height: 16),
            _buildVaccinesSection(),
            const SizedBox(height: 16),
            _buildRecoveryPlanSection(),
            const SizedBox(height: 16),
            _buildFormField(controller: _followUpCtrl, label: 'Follow-up Instructions', hint: 'e.g. Return in 2 weeks for recheck', icon: Icons.event_repeat),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processing ? null : _handleSubmitNotes,
                icon: _processing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, color: Colors.white, size: 16),
                label: const Text('Submit Clinical Notes', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF7C3AED)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF9B8CB8))),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF1A0F2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFFB0A4C8)),
            filled: true,
            fillColor: const Color(0xFFF7F5FF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDE8F8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDE8F8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyNotes(MedicalRecord record) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF15803D), size: 16),
              const SizedBox(width: 12),
              const Expanded(child: Text('Clinical Notes Submitted', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF15803D)))),
            ],
          ),
          const SizedBox(height: 18),
          _ReadOnlyField(label: 'Diagnosis', value: record.diagnosis, icon: Icons.medical_information_outlined),
          if (record.doctorNotes != null && record.doctorNotes!.isNotEmpty)
            _ReadOnlyField(label: "Doctor's Notes", value: record.doctorNotes!, icon: Icons.notes_outlined),
          if (record.medicationsPrescribed != null && record.medicationsPrescribed!.isNotEmpty)
            _ReadOnlyField(label: 'Medications', value: record.medicationsPrescribed!.join(', '), icon: Icons.medication_outlined),
          if (record.followUpInstructions != null && record.followUpInstructions!.isNotEmpty)
            _ReadOnlyField(label: 'Follow-up', value: record.followUpInstructions!, icon: Icons.event_repeat),
        ],
      ),
    );
  }

  Widget _buildRecoveryPlanSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _startRecoveryPlan,
                onChanged: (v) {
                  setState(() {
                    _startRecoveryPlan = v ?? false;
                  });
                },
                activeColor: const Color(0xFF7C3AED),
              ),
              Expanded(
                child: const Text('Start Recovery Plan (Targeted Health Journal)', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, color: Color(0xFF1A0F2E))),
              ),
            ],
          ),
          if (_startRecoveryPlan) ...[
            const SizedBox(height: 8),
            _buildFormField(
              controller: _recoveryDurationCtrl,
              label: 'Duration (Days)',
              hint: 'e.g. 7',
              icon: Icons.timer,
            ),
            const SizedBox(height: 12),
            _buildFormField(
              controller: _recoveryInstructionsCtrl,
              label: 'Recovery Instructions',
              hint: 'Instructions for the pet owner during recovery...',
              icon: Icons.healing,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVaccinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.vaccines_outlined, size: 14, color: Color(0xFF7C3AED)),
            const SizedBox(width: 6),
            const Text('Vaccines Administered', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF9B8CB8))),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._administeredVaccines.map((v) => Chip(
                  label: Text(v['vaccine_name'], style: const TextStyle(fontFamily: 'Figtree', fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w500)),
                  backgroundColor: const Color(0xFFF0FDF4),
                  side: const BorderSide(color: Color(0xFFBBF7D0)),
                  deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF166534)),
                  onDeleted: () {
                    setState(() {
                      _administeredVaccines.remove(v);
                    });
                  },
                )),
            ActionChip(
              label: const Text('Add Vaccine', style: TextStyle(fontFamily: 'Figtree', fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF16A34A),
              side: BorderSide.none,
              avatar: const Icon(Icons.add, size: 14, color: Colors.white),
              onPressed: () => _showAddVaccineDialog(),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddVaccineDialog() {
    final nameCtrl = TextEditingController();
    bool isCore = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Add Vaccine', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A0F2E))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Vaccine Name (e.g. Rabies)',
                    filled: true,
                    fillColor: const Color(0xFFF7F5FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: isCore,
                      onChanged: (v) => setStateDialog(() => isCore = v ?? false),
                      activeColor: const Color(0xFF16A34A),
                    ),
                    const Text('Is Core Vaccine?'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _administeredVaccines.add({
                        'vaccine_name': nameCtrl.text.trim(),
                        'is_core': isCore,
                        'date_administered': DateTime.now().toIso8601String(),
                      });
                    });
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                child: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication_outlined, size: 14, color: Color(0xFF7C3AED)),
            const SizedBox(width: 6),
            const Text('Medications Prescribed', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF9B8CB8))),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._medications.map((med) => Chip(
                  label: Text(med, style: const TextStyle(fontFamily: 'Figtree', fontSize: 12, color: Color(0xFF7C3AED), fontWeight: FontWeight.w500)),
                  backgroundColor: const Color(0xFFF7F5FF),
                  side: const BorderSide(color: Color(0xFFEDE8F8)),
                  deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF7C3AED)),
                  onDeleted: () {
                    setState(() {
                      _medications.remove(med);
                    });
                  },
                )),
            ActionChip(
              label: const Text('Add Medication', style: TextStyle(fontFamily: 'Figtree', fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF7C3AED),
              side: BorderSide.none,
              avatar: const Icon(Icons.add, size: 14, color: Colors.white),
              onPressed: () => _showAddMedicationDialog(),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Medication', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A0F2E))),
          content: TextField(
            controller: _medicationsCtrl,
            style: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFF1A0F2E)),
            decoration: InputDecoration(
              hintText: 'e.g. Amoxicillin 250mg',
              hintStyle: const TextStyle(fontFamily: 'Figtree', fontSize: 13, color: Color(0xFFB0A4C8)),
              filled: true,
              fillColor: const Color(0xFFF7F5FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDE8F8))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDE8F8))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Figtree', color: Color(0xFF9B8CB8), fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_medicationsCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _medications.add(_medicationsCtrl.text.trim());
                  });
                  _medicationsCtrl.clear();
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
              child: const Text('Add', style: TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _ReadOnlyField({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF7C3AED)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF9B8CB8))),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF7F5FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEDE8F8))),
            child: Text(value, style: const TextStyle(fontFamily: 'Figtree', fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1A0F2E))),
          ),
        ],
      ),
    );
  }
}
