import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/vet_controller.dart';
import '../../../models/appointment_model.dart';
import '../../../models/medical_record_model.dart';

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

  // Clinical Notes form controllers
  final _formKey = GlobalKey<FormState>();
  final _diagnosisCtrl = TextEditingController();
  final _doctorNotesCtrl = TextEditingController();
  final _medicationsCtrl = TextEditingController();
  final _followUpCtrl = TextEditingController();

  // Medications list
  List<String> _medications = [];

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _loadExistingRecord();
  }

  Future<void> _loadExistingRecord() async {
    if (_appointment.status == AppointmentStatus.completed) {
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
      setState(() => _loadingRecord = false);
    }
  }

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _doctorNotesCtrl.dispose();
    _medicationsCtrl.dispose();
    _followUpCtrl.dispose();
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
      _showSnackBar('Appointment approved', Icons.check_circle, Colors.green);
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
      _showSnackBar('Appointment declined', Icons.cancel, Colors.red);
    }
  }

  Future<void> _handleStartConsultation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Start Consultation', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This will mark the appointment as completed and allow you to write clinical notes.', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
      _showSnackBar('Consultation started — write your notes below', Icons.edit_note, AppColors.primary);
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
        _showSnackBar('Clinical notes saved successfully', Icons.check_circle, Colors.green);
      } else {
        _showSnackBar('Failed to save notes. Please try again.', Icons.error, Colors.red);
      }
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600))),
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
      backgroundColor: AppColors.lightSurface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildActionSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: AppColors.darkText),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 36),
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text('🐾', style: TextStyle(fontSize: 32))),
                ),
                const SizedBox(height: 10),
                Text(_appointment.petName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                Text('Appointment Details', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final statusConfig = _getStatusConfig(_appointment.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusConfig.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusConfig.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusConfig.iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(statusConfig.icon, color: statusConfig.iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusConfig.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: statusConfig.textColor)),
                const SizedBox(height: 2),
                Text(statusConfig.subtitle, style: TextStyle(fontSize: 12, color: statusConfig.textColor.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appointment Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
          const SizedBox(height: 16),
          _DetailRow(icon: Icons.pets, label: 'Pet', value: _appointment.petName),
          _DetailRow(icon: Icons.calendar_today, label: 'Date', value: DateFormat('EEEE, MMMM d, yyyy').format(_appointment.appointmentDate)),
          _DetailRow(icon: Icons.access_time, label: 'Time', value: DateFormat('h:mm a').format(_appointment.timeSlot)),
          _DetailRow(icon: Icons.local_hospital, label: 'Clinic', value: _appointment.clinicName.isNotEmpty ? _appointment.clinicName : 'N/A'),
          _DetailRow(icon: Icons.description_outlined, label: 'Reason', value: _appointment.reason, isLast: true),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _processing ? null : _handleDecline,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _processing ? null : _handleApprove,
                icon: _processing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check, size: 18, color: Colors.white),
                label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirmedActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _processing ? null : _handleStartConsultation,
            icon: _processing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            label: const Text('Start Consultation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.healthGreen, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(child: Text('Marks appointment as completed and unlocks clinical notes', style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
      ],
    );
  }

  Widget _buildCompletedSection() {
    if (_loadingRecord) {
      return Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primary)));
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
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.chipBg, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.edit_note, color: AppColors.primary, size: 20)),
                SizedBox(width: 12),
                Text('Clinical Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Complete the consultation notes for this visit', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            _buildFormField(controller: _diagnosisCtrl, label: 'Diagnosis', hint: 'e.g. Upper respiratory infection', icon: Icons.medical_information_outlined, validator: (v) => (v == null || v.trim().isEmpty) ? 'Diagnosis is required' : null),
            const SizedBox(height: 16),
            _buildFormField(controller: _doctorNotesCtrl, label: "Doctor's Notes", hint: 'Detailed clinical observations...', icon: Icons.notes_outlined, maxLines: 4, validator: (v) => (v == null || v.trim().isEmpty) ? 'Notes are required' : null),
            const SizedBox(height: 16),
            _buildMedicationsSection(),
            const SizedBox(height: 16),
            _buildFormField(controller: _followUpCtrl, label: 'Follow-up Instructions', hint: 'e.g. Return in 2 weeks for recheck', icon: Icons.event_repeat),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _processing ? null : _handleSubmitNotes,
                icon: _processing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, color: Colors.white),
                label: const Text('Submit Clinical Notes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
            Icon(icon, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            filled: true, fillColor: AppColors.lightSurface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
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
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.healthGreenBg, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.check_circle, color: AppColors.healthGreen, size: 20)),
              SizedBox(width: 12),
              const Expanded(child: Text('Clinical Notes Submitted', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.healthGreen))),
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

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medication_outlined, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text('Medications Prescribed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._medications.map((med) => Chip(
                  label: Text(med, style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  backgroundColor: AppColors.chipBg,
                  deleteIcon: Icon(Icons.close, size: 14, color: AppColors.primary),
                  onDeleted: () {
                    setState(() {
                      _medications.remove(med);
                    });
                  },
                )),
            ActionChip(
              label: Text('Add Medication', style: TextStyle(fontSize: 12, color: Colors.white)),
              backgroundColor: AppColors.primary,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Add Medication', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: TextField(
            controller: _medicationsCtrl,
            decoration: InputDecoration(
              hintText: 'e.g. Amoxicillin 250mg',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              filled: true,
              fillColor: AppColors.lightSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  _StatusConfig _getStatusConfig(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return _StatusConfig(
          title: 'Pending Approval', subtitle: 'This appointment is waiting for your response',
          icon: Icons.pending_actions, bgColor: AppColors.pendingBg, borderColor: const Color(0xFFFDE68A),
          iconBg: AppColors.pendingBg, iconColor: AppColors.pendingText, textColor: AppColors.pendingText,
        );
      case AppointmentStatus.confirmed:
        return _StatusConfig(
          title: 'Confirmed', subtitle: 'Ready for consultation',
          icon: Icons.event_available, bgColor: AppColors.confirmedBg, borderColor: const Color(0xFFBFDBFE),
          iconBg: const Color(0xFFDBEAFE), iconColor: AppColors.confirmedText, textColor: AppColors.confirmedText,
        );
      case AppointmentStatus.completed:
        return _StatusConfig(
          title: 'Completed', subtitle: 'Consultation finished',
          icon: Icons.check_circle_outline, bgColor: AppColors.completedBg, borderColor: const Color(0xFFBBF7D0),
          iconBg: AppColors.healthGreenBg, iconColor: AppColors.healthGreen, textColor: AppColors.completedText,
        );
      case AppointmentStatus.cancelled:
        return _StatusConfig(
          title: 'Cancelled', subtitle: 'This appointment was declined',
          icon: Icons.cancel_outlined, bgColor: AppColors.cancelledBg, borderColor: const Color(0xFFFECACA),
          iconBg: const Color(0xFFFEE2E2), iconColor: Colors.red, textColor: AppColors.cancelledText,
        );
    }
  }
}

class _StatusConfig {
  final String title, subtitle;
  final IconData icon;
  final Color bgColor, borderColor, iconBg, iconColor, textColor;
  const _StatusConfig({required this.title, required this.subtitle, required this.icon, required this.bgColor, required this.borderColor, required this.iconBg, required this.iconColor, required this.textColor});
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({required this.icon, required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              SizedBox(width: 60, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
              const SizedBox(width: 8),
              Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black))),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
      ],
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
              Icon(icon, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.lightSurface, borderRadius: BorderRadius.circular(12)),
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
