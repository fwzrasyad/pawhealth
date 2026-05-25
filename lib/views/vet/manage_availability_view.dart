import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../controllers/vet_controller.dart';

class ManageAvailabilityView extends StatefulWidget {
  final bool embeddedMode;
  const ManageAvailabilityView({super.key, this.embeddedMode = false});

  @override
  State<ManageAvailabilityView> createState() => _ManageAvailabilityViewState();
}

class _ManageAvailabilityViewState extends State<ManageAvailabilityView> {
  
  

  String _selectedDay = VetController.dayNames.first; // "Monday"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VetController>().fetchMyVetProfile();
    });
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${parts[1]} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final vc = context.watch<VetController>();

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: widget.embeddedMode
          ? null
          : AppBar(
              title: const Text('Manage Availability',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.embeddedMode)
                    const Text('Weekly Schedule',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
                  if (widget.embeddedMode) const SizedBox(height: 4),
                  Text('Set your recurring availability for each day',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),

            // ── Day of Week Selector ──────────────────────────────────────
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: VetController.dayNames.map((day) {
                      final selected = day == _selectedDay;
                      final daySlots = vc.weeklySchedule[day] ?? [];
                      final hasSlots = daySlots.isNotEmpty;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                day.substring(0, 3),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: selected ? Colors.white : Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white
                                      : (hasSlots ? AppColors.primary : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Day label + slot count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(_selectedDay,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(vc.weeklySchedule[_selectedDay] ?? []).length} slots',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Slot legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text('Available', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(width: 16),
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text('Off', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Time Slots Grid ───────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: VetController.defaultTimeSlots.length,
                  itemBuilder: (context, i) {
                    final slot = VetController.defaultTimeSlots[i];
                    final enabled = vc.isDaySlotEnabled(_selectedDay, slot);
                    return GestureDetector(
                      onTap: () => vc.toggleDaySlot(_selectedDay, slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: enabled ? AppColors.chipBg : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: enabled ? AppColors.primary : Colors.grey.shade300,
                            width: enabled ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                enabled ? Icons.check_circle : Icons.cancel_outlined,
                                size: 14,
                                color: enabled ? AppColors.primary : Colors.grey.shade400,
                              ),
                              SizedBox(width: 6),
                              Text(
                                _formatTime(slot),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: enabled ? AppColors.primary : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Save Button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vc.isLoading
                      ? null
                      : () async {
                          final success = await vc.saveWeeklySchedule();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                success ? '✓ Weekly schedule saved!' : '✗ Failed to save schedule',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: success ? AppColors.primary : Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(24),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: vc.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Save Schedule',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
