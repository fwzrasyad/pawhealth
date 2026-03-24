import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../models/veterinarian_model.dart';

class VetBookingDetailView extends StatefulWidget {
  const VetBookingDetailView({super.key});

  @override
  State<VetBookingDetailView> createState() => _VetBookingDetailViewState();
}

class _VetBookingDetailViewState extends State<VetBookingDetailView> {
  // Vibrant Purple
  final Color primaryPurple = const Color(0xFF8A2BE2);
  final Color lightPurpleBg = const Color(0xFFF3E8FF);
  
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppointmentController>();
    final vet = controller.selectedVet;

    if (vet == null) {
      return const Scaffold(body: Center(child: Text('No Vet Selected')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background/Hero Image Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                color: lightPurpleBg, // Fallback color if image is missing
                image: const DecorationImage(
                  // We simulate the hero image using the placeholder path which might fail
                  // so we add a nice purple gradient fallback
                  image: AssetImage('assets/images/vet_placeholder.jpg'), 
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Scrollable Content Sheet
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.45 - 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Vet Info ---
                        Center(
                          child: Text(
                            vet.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Specialties Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: vet.specialties.map((specialty) {
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: lightPurpleBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  specialty,
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Bio
                        Text(
                          vet.bio,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),
                        
                        // --- Schedule Details ---
                        const Text(
                          'Schedule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Horizontal Dates
                        _buildDatesList(controller, vet),
                        
                        const SizedBox(height: 24),
                        
                        // Time Slots Grid
                        _buildTimeSlotsGrid(controller, vet),
                        
                        // Bottom Padding before button
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Back Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: const Center(
              child: IgnorePointer( // ensures scrolling works properly over the title area
                child: Text(
                  'Book a Consultation',
                  style: TextStyle(
                    color: Colors.black, // Or white depending on the background contrast
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    shadows: [
                       Shadow(
                        color: Colors.white,
                        blurRadius: 10,
                      )
                    ]
                  ),
                ),
              ),
            ),
          ),

          // Fixed Bottom Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: controller.selectedTimeSlot == null || _isBooking
                    ? null
                    : () async {
                        setState(() => _isBooking = true);
                        final success = await controller.bookConsultation();
                        setState(() => _isBooking = false);
                        
                        if (success && context.mounted) {
                          // Show Success Snackbar above nav
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Vet Successfully Booked !',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              backgroundColor: primaryPurple,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          
                          // Pop back out
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  disabledBackgroundColor: primaryPurple.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isBooking
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDatesList(AppointmentController controller, Veterinarian vet) {
    // Generate next 5 days
    final now = DateTime.now();
    final dates = List.generate(5, (i) => now.add(Duration(days: i)));
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dates.map((date) {
          final isSelected = controller.selectedDate?.day == date.day && 
                             controller.selectedDate?.month == date.month;
                             
          return GestureDetector(
            onTap: () => controller.selectDate(date),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryPurple : Colors.transparent,
                shape: BoxShape.circle,
                // Alternatively a rounded rect matching the circular look for a bit more space
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(date), // Mon, Tue...
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeSlotsGrid(AppointmentController controller, Veterinarian vet) {
    if (controller.selectedDate == null) {
      return Center(
        child: Text(
          'Please select a date first',
          style: TextStyle(color: Colors.grey.shade500, fontFamily: 'Poppins'),
        ),
      );
    }

    // Mock time slots for the selected date
    final generatedSlots = [
      '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM'
    ];
    
    // We'll mock '2:00 PM' as unavailable just to demonstrate the greyed out state
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: generatedSlots.length,
      itemBuilder: (context, index) {
        final timeStr = generatedSlots[index];
        final isUnavailable = timeStr == '2:00 PM'; 
        
        // Quick parse for mock slot DateTimes
        final parts = timeStr.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        if (parts[1] == 'PM' && hour != 12) hour += 12;
        if (parts[1] == 'AM' && hour == 12) hour = 0;
        
        final slotDate = DateTime(
          controller.selectedDate!.year,
          controller.selectedDate!.month,
          controller.selectedDate!.day,
          hour,
          int.parse(timeParts[1]),
        );

        final isSelected = controller.selectedTimeSlot == slotDate;

        return GestureDetector(
          onTap: isUnavailable ? null : () => controller.selectTimeSlot(slotDate),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? primaryPurple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnavailable 
                    ? Colors.grey.shade300 
                    : isSelected 
                        ? primaryPurple 
                        : primaryPurple.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Text(
              timeStr,
              style: TextStyle(
                color: isUnavailable 
                    ? Colors.grey.shade400 
                    : isSelected 
                        ? Colors.white 
                        : primaryPurple,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        );
      },
    );
  }
}
