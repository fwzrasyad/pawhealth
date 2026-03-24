import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Result types – the service never throws; it returns success or failure.
// ─────────────────────────────────────────────────────────────────────────────

/// Base class for the result of every auth operation.
sealed class AuthResult {}

/// Returned when an auth operation succeeds.
class AuthSuccess extends AuthResult {
  /// The authenticated Firebase [User].
  final User user;
  AuthSuccess(this.user);
}

/// Returned when an auth operation fails.
class AuthFailure extends AuthResult {
  /// A human-friendly error message safe to show in a SnackBar.
  final String message;
  AuthFailure(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseAuthService
// ─────────────────────────────────────────────────────────────────────────────

/// Encapsulates all Firebase Authentication SDK calls.
///
/// The rest of the app (controllers, UI) must **never** import
/// `firebase_auth` directly — they use this service exclusively.
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // ── Public surface ────────────────────────────────────────────────────────

  /// Stream that emits the current [User] whenever auth state changes.
  /// Emits `null` when the user is logged out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently signed-in Firebase [User], or `null`.
  User? get currentFirebaseUser => _auth.currentUser;

  /// Signs in an existing user with [email] and [password].
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return AuthFailure('Sign-in succeeded but no user was returned. Please try again.');
      }
      return AuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseError(e));
    } catch (e) {
      return AuthFailure('An unexpected error occurred. Please try again.');
    }
  }

  /// Creates a new user account with [email] and [password].
  Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return AuthFailure('Account created but no user was returned. Please try again.');
      }
      return AuthSuccess(user);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapFirebaseError(e));
    } catch (e) {
      return AuthFailure('An unexpected error occurred. Please try again.');
    }
  }

  /// Updates the display name of the currently signed-in user.
  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name.trim());
    } catch (_) {
      // Non-critical — we silently fail and the controller falls back to the
      // name passed in local state.
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Maps Firebase error codes to clean, user-friendly messages.
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      // ── Login errors ──
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        // Firebase v9+ collapses wrong-password + user-not-found into this.
        return 'Invalid email or password. Please check your credentials.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';

      // ── Registration errors ──
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Contact support.';

      // ── Network errors ──
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';

      // ── Fallback ──
      default:
        return e.message ?? 'An unknown error occurred. Please try again.';
    }
  }
}
