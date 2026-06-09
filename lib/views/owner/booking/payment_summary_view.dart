import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../utils/constants.dart';

class PaymentSummaryView extends StatefulWidget {
  final String petId;
  final String petName;
  final String reason;

  final VoidCallback onPaymentSuccess;

  const PaymentSummaryView({
    super.key,
    required this.petId,
    required this.petName,
    required this.reason,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentSummaryView> createState() => _PaymentSummaryViewState();
}

class _PaymentSummaryViewState extends State<PaymentSummaryView> {
  bool _isProcessing = false;
  String? _paymentIntentId;
  double? _amount;
  bool _readyToPay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPaymentSheet();
    });
  }

  Future<void> _initPaymentSheet() async {
    setState(() => _isProcessing = true);
    try {
      final ctrl = context.read<AppointmentController>();
      
      final paymentData = await ctrl.createPaymentIntent(
        petId: widget.petId,
        petName: widget.petName,
        reason: widget.reason,
      );

      if (paymentData != null) {
        _paymentIntentId = paymentData['payment_intent_id'];
        _amount = double.tryParse(paymentData['amount'].toString());

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentData['client_secret'],
            merchantDisplayName: 'PawHealth Clinic',
            returnURL: 'pawhealth://stripe-redirect',
            billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
              name: CollectionMode.always,
              email: CollectionMode.always,
            ),
            appearance: PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(
                primary: AppColors.primary,
              ),
            ),
          ),
        );
        setState(() => _readyToPay = true);
      } else {
        _showError('Could not initialize payment. Please try again.');
      }
    } catch (e) {
      _showError('Error setting up payment sheet: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    try {
      await Stripe.instance.presentPaymentSheet();
      
      // If we reach here, payment was successful or user didn't cancel (if cancelled it throws Exception)
      final ctrl = context.read<AppointmentController>();
      final success = await ctrl.confirmBookingWithPayment(
        paymentIntentId: _paymentIntentId!,
        petId: widget.petId,
        petName: widget.petName,
        reason: widget.reason,
      );

      if (success) {
        _showSuccess('Payment successful! Booking confirmed.');
        widget.onPaymentSuccess();
      } else {
        _showError('Payment succeeded but failed to confirm booking. Please contact support.');
      }
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        _showError('Payment cancelled.');
      } else {
        _showError('Payment failed: ${e.error.message}');
      }
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Pop the payment summary widget and go back to step 3? Wait, this is part of the animated switcher
        // So I can't just pop. I need a way to go back to Step 3. 
        // Wait, the parent `book_appointment_view.dart` manages the steps. I am inside an AnimatedSwitcher!
        // But the parent doesn't expose a method to go back. 
        // Wait! The user's specification says "Do not change: Navigation or routing between steps".
        // In the original, the appbar back button did: `if (_currentStep > 0) setState(() => _currentStep--);`
        // But here I'm isolated in `PaymentSummaryView`. 
        // Actually, the parent wrapped the *entire* Scaffold in PopScope to prevent pop and manually go back.
        // Wait, I can trigger the parent's pop using Navigator.maybePop(context). Wait, PopScope in parent intercepts `Navigator.pop`.
        // Let's use `Navigator.maybePop(context);` which will trigger the parent's PopScope!
        Navigator.maybePop(context);
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
        return Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check, color: Color(0xFF7C3AED), size: 13),
            ),
            if (index < 3)
              Container(
                width: 32,
                height: 2,
                color: Colors.white,
              ),
          ],
        );
      }),
    );
  }

  Widget _buildHeroContainer({required Widget child}) {
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
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 28),
            child: child,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppointmentController>();
    final vet = ctrl.selectedVet;
    final clinic = ctrl.selectedClinic;
    final date = ctrl.selectedDate;
    final time = ctrl.selectedTimeSlot;

    return Column(
      children: [
        _buildHeroContainer(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildBackButton(context),
                  ),
                  const Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStepIndicator(),
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total amount due',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _amount != null ? 'RM ${_amount!.toStringAsFixed(2)}' : 'RM 0.00',
                      style: const TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${clinic?.name ?? ''} • ${vet?.name ?? ''}',
                      style: TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: _isProcessing && !_readyToPay
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking summary',
                          style: TextStyle(
                            fontFamily: 'Figtree',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A0F2E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Clinic', clinic?.name ?? ''),
                        _buildSummaryRow('Veterinarian', vet?.name ?? ''),
                        _buildSummaryRow('Pet', widget.petName),
                        _buildSummaryRow('Date', date != null ? DateFormat('EEEE, MMM d, yyyy').format(date) : ''),
                        _buildSummaryRow('Time', time != null ? DateFormat('h:mm a').format(time) : ''),
                        _buildSummaryRow('Type', ctrl.consultationType == 'virtual' ? '📹 Virtual Consultation' : '🏥 In-Person Visit'),
                        _buildSummaryRow('Consultation Fee', _amount != null ? 'RM ${_amount!.toStringAsFixed(2)}' : 'RM 0.00', isFee: true),
                        
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _readyToPay && !_isProcessing ? _processPayment : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            disabledBackgroundColor: const Color(0xFFDDD8F5),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: _isProcessing && _readyToPay
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_outline, color: Colors.white, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Pay & Confirm',
                                      style: TextStyle(
                                        fontFamily: 'Figtree',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.shield_outlined, color: Color(0xFFB0A4C8), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Secured payment via Stripe',
                              style: TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 11,
                                color: Color(0xFFB0A4C8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isFee = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF7F5FF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Figtree',
              color: Color(0xFF9B8CB8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Figtree',
                color: isFee ? const Color(0xFF7C3AED) : const Color(0xFF1A0F2E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
