import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/api_service.dart';
import 'vet_controller.dart';

import '../services/notification_service.dart';

/// AuthController manages all authentication state for the app.
///
/// It consumes [FirebaseAuthService] (raw Firebase calls) and [ApiService]
/// (Laravel backend sync), exposing clean, UI-friendly state via [ChangeNotifier].
class AuthController extends ChangeNotifier {
  // ── Dependencies ─────────────────────────────────────────────────────────

  final FirebaseAuthService _authService;
  final ApiService _apiService = ApiService();

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

  void _onAuthStateChanged(firebase.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else if (_currentUser == null) {
      // On app restart / hot-reload, re-sync with the backend to get the
      // authoritative user record (including role).
      try {
        final token = await firebaseUser.getIdToken();
        final response = await _apiService.post('/auth/sync', {
          'name': firebaseUser.displayName ?? '',
          'email': firebaseUser.email ?? '',
        }, token);

        final userData = response['data'] ?? response;
        _currentUser = User.fromJson(userData);
        
        // Sync FCM token
        if (token != null) {
          await NotificationService().syncTokenWithBackend(token);
        }
      } catch (e) {
        // Fallback: build a minimal local user so the app isn't stuck.
        _currentUser = User(
          userId: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          password: '',
          role: UserRole.owner,
          phoneNumber: firebaseUser.phoneNumber ?? '',
        );
        print('Auth sync on state change failed: $e');
      }
    }

    _isInitializing = false; // First event received — AuthWrapper can proceed.
    notifyListeners();
  }

  // ── Helper: get Firebase ID Token ─────────────────────────────────────────

  Future<String?> _getToken() async {
    return await firebase.FirebaseAuth.instance.currentUser?.getIdToken();
  }

  // ── Public methods ────────────────────────────────────────────────────────

  /// Signs in with [email] and [password].
  ///
  /// After Firebase authentication succeeds, POSTs to `/auth/sync` so the
  /// Laravel backend creates or updates the MySQL user record.
  /// Returns the authenticated [UserRole] on success, or `null` on failure.
  Future<UserRole?> login(String email, String password) async {
    _setLoading(true);

    final result = await _authService.signIn(email: email, password: password);

    if (result is AuthSuccess) {
      try {
        final token = await result.user.getIdToken();

        // Sync with Laravel backend
        final response = await _apiService.post('/auth/sync', {
          'name': result.user.displayName ?? '',
          'email': result.user.email ?? email,
        }, token);

        final userData = response['data'] ?? response;
        _currentUser = User.fromJson(userData);

        _setLoading(false);
        return _currentUser!.role;
      } catch (e) {
        _errorMessage = 'Signed in but failed to sync with server: $e';
        print('Auth sync error on login: $e');
      }
    } else if (result is AuthFailure) {
      _errorMessage = result.message;
    }

    _setLoading(false);
    return null;
  }

  /// Creates a new account, then syncs user data with the Laravel backend.
  /// If the role is [UserRole.vet], also creates a veterinarian profile.
  ///
  /// Accepts an optional [vetController] so the caller (RegisterView) can
  /// pass in the VetController from the widget tree.
  Future<UserRole?> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required UserRole role,
    VetController? vetController,
  }) async {
    _setLoading(true);

    final result = await _authService.signUp(email: email, password: password);

    if (result is AuthSuccess) {
      // Update Firebase profile with the display name (best-effort).
      await _authService.updateDisplayName(name);

      try {
        final token = await result.user.getIdToken();

        // POST to Laravel to persist the new user in MySQL
        final response = await _apiService.post('/auth/sync', {
          'name': name.trim(),
          'email': result.user.email ?? email,
          'role': role.name,
          'phone_number': phoneNumber.trim(),
        }, token);

        final userData = response['data'] ?? response;
        _currentUser = User.fromJson(userData);

        // If registering as vet, also create the veterinarian profile
        if (role == UserRole.vet && vetController != null) {
          await vetController.createVetProfile(name: name.trim());
        }

        _setLoading(false);
        return _currentUser!.role;
      } catch (e) {
        _errorMessage = 'Account created but failed to sync with server: $e';
        debugPrint('Auth sync error on register: $e');
      }
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

      final token = await _getToken();

      // Sync updated profile to Laravel
      final response = await _apiService.put('/auth/profile', {
        'name': name.trim(),
        'phone_number': phone.trim(),
      }, token);

      final userData = response['data'] ?? response;
      _currentUser = User.fromJson(userData);
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
}
