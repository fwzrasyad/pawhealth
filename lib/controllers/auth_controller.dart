import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

/// AuthController manages all authentication state for the app.
///
/// It consumes [FirebaseAuthService] (raw Firebase calls) and exposes
/// clean, UI-friendly state to every widget via [ChangeNotifier].
class AuthController extends ChangeNotifier {
  // ── Dependencies ─────────────────────────────────────────────────────────

  final FirebaseAuthService _authService;

  // ── State ─────────────────────────────────────────────────────────────────

  User? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true; // true until the first auth state event fires
  bool _profileUpdated = false;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get currentRole => _currentUser?.role;
  bool get isLoading => _isLoading;

  /// True while waiting for the first Firebase auth-state event (app startup).
  /// AuthWrapper shows a spinner until this is false.
  bool get isInitializing => _isInitializing;

  bool get profileUpdated => _profileUpdated;
  String? get errorMessage => _errorMessage;

  // ── Constructor ───────────────────────────────────────────────────────────

  AuthController({FirebaseAuthService? authService})
      : _authService = authService ?? FirebaseAuthService() {
    // Subscribe to Firebase auth state changes.
    // This fires immediately with the current session (or null) on app start,
    // which enables the persistent-login UX through AuthWrapper.
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // ── Auth-state listener ───────────────────────────────────────────────────

  void _onAuthStateChanged(firebase.User? firebaseUser) {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      // Rebuild the local User from Firebase state.
      // _currentUser is preserved if it already exists (has richer data like
      // the role set after a successful login/register call).
      _currentUser ??= _userFromFirebase(firebaseUser);
    }

    _isInitializing = false; // First event received — AuthWrapper can proceed.
    notifyListeners();
  }

  // ── Public methods ────────────────────────────────────────────────────────

  /// Signs in with [email] and [password].
  ///
  /// Returns the authenticated [UserRole] on success, or `null` on failure.
  /// Check [errorMessage] for a UI-ready failure reason.
  Future<UserRole?> login(String email, String password) async {
    _setLoading(true);

    final result = await _authService.signIn(email: email, password: password);

    if (result is AuthSuccess) {
      // TODO(phase-12): Fetch the user's Role from the Laravel API using
      //   result.user.uid as the identifier. Replace the inline inference below.
      final role = _inferRole(result.user.email);

      _currentUser = User(
        userId: result.user.uid,
        name: result.user.displayName ?? (role == UserRole.vet ? 'Dr. Vet' : 'Owner'),
        email: result.user.email ?? email,
        password: '',
        role: role,
        phoneNumber: result.user.phoneNumber ?? '',
      );

      _setLoading(false);
      return role;
    } else if (result is AuthFailure) {
      _errorMessage = result.message;
    }

    _setLoading(false);
    return null;
  }

  /// Creates a new account, then stores user data in local state.
  Future<UserRole?> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required UserRole role,
  }) async {
    _setLoading(true);

    final result = await _authService.signUp(email: email, password: password);

    if (result is AuthSuccess) {
      // Update Firebase profile with the display name (best-effort).
      await _authService.updateDisplayName(name);

      // TODO(phase-12): POST to the Laravel API to persist the new user's
      //   { name, phone_number, role } in the MySQL database. Use
      //   result.user.uid as the Firebase UID foreign key.

      _currentUser = User(
        userId: result.user.uid,
        name: name.trim(),
        email: result.user.email ?? email,
        password: '',
        role: role,
        phoneNumber: phoneNumber.trim(),
      );

      _setLoading(false);
      return role;
    } else if (result is AuthFailure) {
      _errorMessage = result.message;
    }

    _setLoading(false);
    return null;
  }

  /// Updates the current user's display name and phone number.
  Future<void> updateUserProfile(String name, String phone) async {
    if (_currentUser == null) return;
    _isLoading = true;
    _profileUpdated = false;
    notifyListeners();

    try {
      await _authService.updateDisplayName(name);

      // TODO(phase-12): PATCH the Laravel API to update name/phone in MySQL.

      _currentUser = User(
        userId: _currentUser!.userId,
        name: name.trim(),
        email: _currentUser!.email,
        password: _currentUser!.password,
        role: _currentUser!.role,
        phoneNumber: phone.trim(),
      );
      _profileUpdated = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();

      // Reset the flag so the UI can re-trigger on the next update.
      await Future.delayed(const Duration(milliseconds: 200));
      _profileUpdated = false;
      notifyListeners();
    }
  }

  /// Signs out the current user and clears all local state.
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _profileUpdated = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears any pending error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null; // Clear stale errors on new requests.
    notifyListeners();
  }

  /// Builds a local [User] from a Firebase [firebase.User].
  User _userFromFirebase(firebase.User fbUser) {
    final role = _inferRole(fbUser.email);
    return User(
      userId: fbUser.uid,
      name: fbUser.displayName ?? (role == UserRole.vet ? 'Dr. Vet' : 'Owner'),
      email: fbUser.email ?? '',
      password: '',
      role: role,
      phoneNumber: fbUser.phoneNumber ?? '',
    );
  }

  /// Temporary role inference from email.
  ///
  /// TODO(phase-12): Remove this and fetch the actual role from the Laravel API.
  UserRole _inferRole(String? email) {
    return email?.toLowerCase().contains('vet') == true
        ? UserRole.vet
        : UserRole.owner;
  }
}
