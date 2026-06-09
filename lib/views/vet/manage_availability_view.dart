import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFF7C3AED),
      body: Column(
        children: [
          _buildHero(vc),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F5FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    children: [
                      // Day header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDay,
                            style: const TextStyle(
                              fontFamily: 'Figtree',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A0F2E),
                              letterSpacing: -0.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(vc.weeklySchedule[_selectedDay] ?? []).length} slots',
                              style: const TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Legend row
                      Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Available',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 11,
                                  color: Color(0xFF9B8CB8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE8F8),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Off',
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 11,
                                  color: Color(0xFF9B8CB8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Time slot grid
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.8,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: VetController.defaultTimeSlots.length,
                          itemBuilder: (context, i) {
                            final slot = VetController.defaultTimeSlots[i];
                            final isAvailable = vc.isDaySlotEnabled(_selectedDay, slot);
                            return GestureDetector(
                              onTap: () => vc.toggleDaySlot(_selectedDay, slot),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isAvailable ? const Color(0xFF7C3AED) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isAvailable ? const Color(0xFF7C3AED) : const Color(0xFFEDE8F8),
                                    width: isAvailable ? 1.0 : 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isAvailable ? Icons.check : Icons.close,
                                      color: isAvailable ? Colors.white : const Color(0xFFC4B5FD),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(slot),
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isAvailable ? Colors.white : const Color(0xFF9B8CB8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Save button
                      Container(
                        margin: const EdgeInsets.only(top: 14),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: vc.isLoading
                              ? null
                              : () async {
                                  final success = await vc.saveWeeklySchedule();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(success ? Icons.check_circle : Icons.error, color: Colors.white, size: 18),
                                            const SizedBox(width: 10),
                                            Text(
                                              success ? 'Weekly schedule saved!' : 'Failed to save schedule',
                                              style: const TextStyle(fontFamily: 'Figtree', fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: success ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(20),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            disabledBackgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: vc.isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Save Schedule',
                                  style: TextStyle(
                                    fontFamily: 'Figtree',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
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

  Widget _buildHero(VetController vc) {
    return Stack(
      children: [
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
          top: -20,
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
        if (!widget.embeddedMode)
          Positioned(
            top: 44,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(widget.embeddedMode ? 20 : 50, 44, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Schedule',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 3, bottom: 20),
                  child: Text(
                    'Set your recurring availability for each day',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: VetController.dayNames.length,
                    itemBuilder: (context, index) {
                      final day = VetController.dayNames[index];
                      final isSelected = day == _selectedDay;
                      final daySlots = vc.weeklySchedule[day] ?? [];
                      final hasSlots = daySlots.isNotEmpty;
                      
                      Color bgColor;
                      Color nameColor;
                      Color dotColor;
                      
                      if (isSelected) {
                        bgColor = Colors.white;
                        nameColor = const Color(0xFF7C3AED);
                        dotColor = const Color(0xFF7C3AED);
                      } else if (hasSlots) {
                        bgColor = Colors.white.withValues(alpha: 0.1);
                        nameColor = Colors.white.withValues(alpha: 0.7);
                        dotColor = Colors.white.withValues(alpha: 0.5);
                      } else {
                        bgColor = Colors.white.withValues(alpha: 0.1);
                        nameColor = Colors.white.withValues(alpha: 0.7);
                        dotColor = Colors.white.withValues(alpha: 0.2);
                      }

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          constraints: const BoxConstraints(minWidth: 36),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day.substring(0, 3),
                                style: TextStyle(
                                  fontFamily: 'Figtree',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: nameColor,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
