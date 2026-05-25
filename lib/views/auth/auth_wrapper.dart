import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../onboarding/onboarding_view.dart';
import '../owner/owner_dashboard_view.dart';
import '../vet/vet_home_view.dart';

/// AuthWrapper is the root routing widget for the application.
///
/// It listens to [AuthController] and automatically navigates to the correct
/// screen based on authentication state and user role — completely removing
/// the need for any view to perform its own post-login navigation.
///
/// State machine:
///   isInitializing == true  →  Loading spinner (waiting for Firebase)
///   isAuthenticated == false →  OnboardingView (login / register)
///   role == vet              →  VetHomeView
///   role == owner (default)  →  OwnerDashboardView
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    // ── Initializing ─────────────────────────────────────────────────────────
    // Show a clean splash/spinner while Firebase resolves the persisted session.
    if (auth.isInitializing) {
      return Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Image.asset(
                'assets/pawhealth_logo.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'PawHealth',
                style: AppFonts.fraunces(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Not authenticated ─────────────────────────────────────────────────────
    if (!auth.isAuthenticated) {
      return const OnboardingView();
    }

    // ── Authenticated — route by role ─────────────────────────────────────────
    final role = auth.currentRole;

    if (role == UserRole.vet) {
      return const VetHomeView();
    }

    // Default: Pet Owner
    return const OwnerDashboardView();
  }
}
