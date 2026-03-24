import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../models/veterinarian_model.dart';
import 'vet_booking_detail_view.dart';

class AvailableVetsView extends StatelessWidget {
  const AvailableVetsView({super.key});

  static const _purple = Color(0xFF8A2BE2);

  String _emojiForVet(String id) {
    const map = {'vet_001': '👨‍⚕️', 'vet_002': '🩺', 'vet_003': '🔬', 'vet_004': '🌿'};
    return map[id] ?? '⚕️';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppointmentController>();
    final vets = ctrl.vets;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Book a Consultation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text(
              'Choose from our trusted veterinarians',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade500),
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search vets, specialties...',
                        hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Specialty filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: ['All', 'Dermatology', 'Surgery', 'Nutrition', 'Exotic Pets', 'General'].map((label) {
                final selected = label == 'All';
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? _purple : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: selected ? _purple : Colors.grey.shade300),
                    boxShadow: selected ? [BoxShadow(color: _purple.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : [],
                  ),
                  child: Text(label, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12, color: selected ? Colors.white : Colors.grey.shade600)),
                );
              }).toList(),
            ),
          ),

          // Vet list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: vets.length,
              itemBuilder: (context, index) {
                final vet = vets[index];
                return _VetCard(
                  vet: vet,
                  emoji: _emojiForVet(vet.vetId),
                  onTap: () {
                    ctrl.selectVet(vet);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VetBookingDetailView()));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VetCard extends StatelessWidget {
  final Veterinarian vet;
  final String emoji;
  final VoidCallback onTap;

  static const _purple = Color(0xFF8A2BE2);
  static const _lightPurple = Color(0xFFF3E8FF);

  const _VetCard({required this.vet, required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji avatar
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: _lightPurple, shape: BoxShape.circle),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vet.name, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 4),
                  // Specialties chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: vet.specialties.take(2).map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: _lightPurple, borderRadius: BorderRadius.circular(8)),
                      child: Text(s, style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.w600, color: _purple)),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(vet.workingHours, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),

            // Rating + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: const [
                      Icon(Icons.star, color: Color(0xFFF59E0B), size: 13),
                      SizedBox(width: 3),
                      Text('4.9', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFB45309))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
