import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
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

  static const _accentPurple = Color(0xFF7A1EFE);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    // ── Initializing ─────────────────────────────────────────────────────────
    // Show a clean splash/spinner while Firebase resolves the persisted session.
    if (auth.isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              _PawLogo(),
              SizedBox(height: 32),
              CircularProgressIndicator(
                color: _accentPurple,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'PawHealth',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _accentPurple,
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

// ─────────────────────────────────────────────────────────────────────────────
// Internal widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PawLogo extends StatelessWidget {
  const _PawLogo();

  static const _accentPurple = Color(0xFF7A1EFE);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _accentPurple.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text('🐾', style: TextStyle(fontSize: 48)),
      ),
    );
  }
}
