import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";

// Global authentication state with ChangeNotifier for reactivity
class AuthenticationState extends ChangeNotifier {
  factory AuthenticationState() => _instance;
  AuthenticationState._internal();
  static final AuthenticationState _instance = AuthenticationState._internal();

  bool _isAuthenticated = false;
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  // Initialize and start listening to auth changes
  Future<void> initialize() async {
    if (_isInitialized) return;

    logger.d("🔐 AuthenticationState: Starting initialization...");

    // Check initial auth status
    await _checkAuthenticationStatus();

    // Listen to Firebase auth state changes
    logger.d("🔐 AuthenticationState: Setting up Firebase auth listener...");
    FirebaseAuth.instance.authStateChanges().listen((user) {
      logger.d(
        '🔐 AuthenticationState: Firebase auth state changed - User: ${user?.email ?? 'null'}',
      );
      _checkAuthenticationStatus();
    });

    _isInitialized = true;
    logger.d(
      "🔐 AuthenticationState: Initialization complete. Current status: $_isAuthenticated",
    );
    notifyListeners();
  }

  // Check current authentication status
  Future<void> _checkAuthenticationStatus() async {
    try {
      // Check Firebase auth state
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final isFirebaseAuthenticated = firebaseUser != null;

      // Check local session
      final isLocalAuthenticated = await SessionManager.isAuthenticated();

      final wasAuthenticated = _isAuthenticated;

      // Allow authentication if either Firebase OR local session is valid
      // This makes the system more flexible and handles Firebase-only auth
      _isAuthenticated = isFirebaseAuthenticated || isLocalAuthenticated;

      logger.d(
        "🔐 AuthenticationState: Checking status - Firebase: $isFirebaseAuthenticated, Local: $isLocalAuthenticated, Combined: $_isAuthenticated",
      );
      if (firebaseUser != null) {
        logger.d(
          "🔐 AuthenticationState: Firebase user email: ${firebaseUser.email}",
        );
      }
      if (isLocalAuthenticated) {
        logger.d("🔐 AuthenticationState: Local session is valid");
      } else {
        logger.d("🔐 AuthenticationState: Local session is NOT valid");
      }

      // Apply system theme on first login when user has no saved preference
      if (!wasAuthenticated && _isAuthenticated) {
        ThemeState().applySystemThemeIfFirstTime();
      }

      // Always notify listeners to ensure UI updates
      if (wasAuthenticated != _isAuthenticated) {
        logger.d(
          "🔐 AuthenticationState: Status changed from $wasAuthenticated to $_isAuthenticated - notifying listeners",
        );
      } else {
        logger.d(
          "🔐 AuthenticationState: Status unchanged ($_isAuthenticated) - notifying listeners anyway for UI sync",
        );
      }
      notifyListeners();
    } catch (e) {
      logger.d("❌ AuthenticationState: Error checking authentication: $e");
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  // Force refresh authentication status
  Future<void> refreshAuthenticationStatus() async {
    await _checkAuthenticationStatus();
  }

  // Manually set authentication status (for testing/debugging)
  void setAuthenticationStatus(bool status) {
    if (_isAuthenticated != status) {
      _isAuthenticated = status;
      logger.d("🔐 AuthenticationState: Manually set to $_isAuthenticated");
      notifyListeners();
    }
  }

  // Force logout - clear authentication state
  Future<void> logout() async {
    logger.d("🔐 AuthenticationState: Force logout called");
    _isAuthenticated = false;
    notifyListeners();
    logger.d("🔐 AuthenticationState: Logout completed, notifying listeners");
  }
}
