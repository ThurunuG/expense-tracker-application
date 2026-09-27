import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

// Provides authentication state and actions across the app.
class AuthProvider with ChangeNotifier {
  // Service used to communicate with Firebase authentication.
  final AuthService _authService = AuthService();

  // Subscription to Firebase auth state changes.
  StreamSubscription<User?>? _sub;

  // Current authenticated user, if any.
  User? _user;

  // Indicates whether an auth operation is in progress.
  bool _isLoading = false;

  // Stores the latest user-friendly error message.
  String? _errorMessage;

  // Listen for Firebase auth changes and update state.
  AuthProvider() {
    _sub = _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // Returns the current Firebase user.
  User? get user => _user;

  // Whether a user is currently signed in.
  bool get isAuthenticated => _user != null;

  // Whether an auth request is currently running.
  bool get isLoading => _isLoading;

  // Last error message raised by authentication operations.
  String? get errorMessage => _errorMessage;

  // Sign in using email and password.
  Future<bool> signIn(String email, String password) => _run(
        () => _authService.signIn(email: email, password: password),
      );

  // Create a new account with email and password.
  Future<bool> signUp(String email, String password) => _run(
        () => _authService.signUp(email: email, password: password),
      );

  // Sign in as a guest user.
  Future<bool> continueAsGuest() => _run(_authService.signInAnonymously);

  // Sign out the current user.
  Future<void> signOut() => _authService.signOut();

  // Clear the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Runs an authentication operation while updating loading/error state.
  Future<bool> _run(Future<User?> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _authService.readableError(e);
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    // Cancel the stream subscription to avoid memory leaks.
    _sub?.cancel();
    super.dispose();
  }
}
