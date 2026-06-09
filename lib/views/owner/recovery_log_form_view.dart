import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pet_controller.dart';
import '../../models/recovery_plan_model.dart';
import '../../utils/constants.dart';

class RecoveryLogFormView extends StatefulWidget {
  final RecoveryPlan plan;

  const RecoveryLogFormView({super.key, required this.plan});

  @override
  State<RecoveryLogFormView> createState() => _RecoveryLogFormViewState();
}

class _RecoveryLogFormViewState extends State<RecoveryLogFormView> {
  final _notesController = TextEditingController();
  final Map<String, String> _symptomStatus = {
    'eating': 'normal',
    'energy': 'normal',
    'pain': 'none',
  };
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _isSubmitting = true);

    final petCtrl = context.read<PetController>();
    final log = RecoveryLog(
      id: '',
      recoveryPlanId: widget.plan.id,
      date: DateTime.now(),
      symptomStatus: _symptomStatus,
      ownerNotes: _notesController.text,
    );

    await petCtrl.addRecoveryLog(widget.plan.id, log);

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recovery log added successfully',
            style: AppFonts.body(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: Text(
          'Add Recovery Log',
          style: AppFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A0F2E),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A0F2E),
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Vet Instructions Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F5FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDE8F8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.medical_information_outlined,
                          size: 18,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Vet Instructions',
                        style: AppFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A0F2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.plan.instructions,
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Symptom Tracking ──
            Text(
              'SYMPTOM TRACKING',
              style: AppFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9B8CB8),
                letterSpacing: 0.08,
              ),
            ),
            const SizedBox(height: 14),

            _buildSymptomSelector(
              icon: Icons.restaurant_outlined,
              label: 'Eating',
              key: 'eating',
              options: ['poor', 'normal', 'excellent'],
              colors: {
                'poor': const Color(0xFFDC2626),
                'normal': const Color(0xFFF59E0B),
                'excellent': const Color(0xFF16A34A),
              },
            ),
            const SizedBox(height: 12),

            _buildSymptomSelector(
              icon: Icons.bolt_outlined,
              label: 'Energy',
              key: 'energy',
              options: ['lethargic', 'normal', 'active'],
              colors: {
                'lethargic': const Color(0xFFDC2626),
                'normal': const Color(0xFFF59E0B),
                'active': const Color(0xFF16A34A),
              },
            ),
            const SizedBox(height: 12),

            _buildSymptomSelector(
              icon: Icons.healing_outlined,
              label: 'Pain',
              key: 'pain',
              options: ['none', 'mild', 'severe'],
              colors: {
                'none': const Color(0xFF16A34A),
                'mild': const Color(0xFFF59E0B),
                'severe': const Color(0xFFDC2626),
              },
            ),

            const SizedBox(height: 28),

            // ── Notes ──
            Text(
              'ADDITIONAL NOTES',
              style: AppFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9B8CB8),
                letterSpacing: 0.08,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEDE8F8)),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                style: AppFonts.dmSans(
                  fontSize: 14,
                  color: const Color(0xFF1A0F2E),
                ),
                decoration: InputDecoration(
                  hintText: 'Any other observations...',
                  hintStyle: AppFonts.dmSans(
                    fontSize: 14,
                    color: const Color(0xFF9B8CB8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Recovery Log',
                        style: AppFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomSelector({
    required IconData icon,
    required String label,
    required String key,
    required List<String> options,
    required Map<String, Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A0F2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((option) {
              final isSelected = _symptomStatus[key] == option;
              final color = colors[option] ?? const Color(0xFF7C3AED);

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: option != options.last ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _symptomStatus[key] = option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.12)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          option[0].toUpperCase() + option.substring(1),
                          style: AppFonts.dmSans(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected ? color : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
