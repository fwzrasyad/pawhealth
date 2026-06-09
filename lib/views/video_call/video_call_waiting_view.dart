import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/appointment_controller.dart';
import '../../models/appointment_model.dart';
import 'video_call_view.dart';

/// Waiting room shown to the pet owner before the vet starts the call.
///
/// Polls the call status every 5 seconds. When the call becomes active,
/// automatically navigates to [VideoCallView].
class VideoCallWaitingView extends StatefulWidget {
  final Appointment appointment;

  const VideoCallWaitingView({super.key, required this.appointment});

  @override
  State<VideoCallWaitingView> createState() => _VideoCallWaitingViewState();
}

class _VideoCallWaitingViewState extends State<VideoCallWaitingView>
    with SingleTickerProviderStateMixin {
  Timer? _pollTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _joining = false;

  @override
  void initState() {
    super.initState();
    // Pulse animation for waiting indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start polling
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkCallStatus());
    // Also check immediately
    _checkCallStatus();
  }

  Future<void> _checkCallStatus() async {
    if (_joining || !mounted) return;

    final ctrl = context.read<AppointmentController>();
    final response = await ctrl.getCallStatus(widget.appointment.appointmentId);

    if (response != null && response['active'] == true && mounted) {
      setState(() => _joining = true);
      _pollTimer?.cancel();

      // Navigate to the video call
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallView(
            appId: response['app_id'],
            token: response['token'],
            channelName: response['channel'],
            uid: response['uid'] ?? 2,
            remoteName: widget.appointment.vetName,
            onCallEnded: () {
              // End the call via API and pop back
              ctrl.endVideoCall(widget.appointment.appointmentId).catchError((e) {
                debugPrint('Call ended or error: $e');
              });
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back/cancel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Video Consultation',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40), // Balance
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated avatar ring
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7C3AED).withOpacity(_pulseAnimation.value),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withOpacity(_pulseAnimation.value * 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF7C3AED).withOpacity(0.15),
                              ),
                              child: Center(
                                child: Text(
                                  _vetInitials(widget.appointment.vetName),
                                  style: const TextStyle(
                                    fontFamily: 'Figtree',
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Vet name
                      Text(
                        widget.appointment.vetName,
                        style: const TextStyle(
                          fontFamily: 'Figtree',
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.appointment.clinicName,
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Status message
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF7C3AED).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: const Color(0xFF7C3AED),
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Waiting for vet to start...',
                              style: TextStyle(
                                fontFamily: 'Figtree',
                                color: Color(0xFFB794F6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'You\'ll be connected automatically\nwhen the consultation begins',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Figtree',
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Cancel button at bottom
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(context).padding.bottom + 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Leave Waiting Room',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _vetInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
