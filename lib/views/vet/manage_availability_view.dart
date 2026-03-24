import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/vet_controller.dart';

class ManageAvailabilityView extends StatefulWidget {
  final bool embeddedMode;
  const ManageAvailabilityView({super.key, this.embeddedMode = false});

  @override
  State<ManageAvailabilityView> createState() => _ManageAvailabilityViewState();
}

class _ManageAvailabilityViewState extends State<ManageAvailabilityView> {
  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  late DateTime _selectedDay;
  final List<DateTime> _weekDays = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _generateWeek();
  }

  void _generateWeek() {
    _weekDays.clear();
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _weekDays.add(DateTime(now.year, now.month, now.day + i));
    }
  }

  List<DateTime> _slotsForDay(DateTime day) {
    return List.generate(8, (i) => DateTime(day.year, day.month, day.day, 9 + i, 0));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final vc = context.watch<VetController>();
    final slots = _slotsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: widget.embeddedMode
          ? null
          : AppBar(
              title: const Text('Manage Availability', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.black)),
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
                    const Text('Manage Availability', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
                  if (widget.embeddedMode) const SizedBox(height: 4),
                  Text('Tap a slot to toggle availability', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),

            // Week selector
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _weekDays.map((day) {
                    final selected = _isSameDay(day, _selectedDay);
                    final isToday = _isSameDay(day, DateTime.now());
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? _purple : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('E').format(day).substring(0, 2),
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: selected ? Colors.white70 : Colors.grey.shade500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: selected ? Colors.white : (isToday ? _purple : Colors.black),
                              ),
                            ),
                            if (isToday && !selected)
                              Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 3), decoration: const BoxDecoration(color: _purple, shape: BoxShape.circle)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(DateFormat('EEEE, MMMM d').format(_selectedDay), style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Slot legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text('Available', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(width: 16),
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Text('Unavailable', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Time slots grid
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
                  itemCount: slots.length,
                  itemBuilder: (context, i) {
                    final slot = slots[i];
                    final available = vc.isSlotAvailable(slot);
                    return GestureDetector(
                      onTap: () => vc.toggleAvailability(slot),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: available ? _lightPurple : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: available ? _purple : Colors.grey.shade300,
                            width: available ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(available ? Icons.check_circle : Icons.cancel_outlined, size: 14, color: available ? _purple : Colors.grey.shade400),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('h:mm a').format(slot),
                                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 13, color: available ? _purple : Colors.grey.shade400),
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

            // Save button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Schedule saved!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      backgroundColor: _purple,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Save Schedule', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
