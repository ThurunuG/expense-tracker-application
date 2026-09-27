import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth so the rest of the app never talks
/// to the Firebase SDK directly. Makes it easy to mock in tests too.
class AuthService {
  // Shared FirebaseAuth instance used by all auth operations.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Emits the current authentication state whenever it changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Returns the currently signed-in user, if any.
  User? get currentUser => _auth.currentUser;

  // Signs in an existing user with email and password.
  Future<User?> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  // Creates a new account for a user using email and password.
  Future<User?> signUp({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  // Signs the user in anonymously for guest access.
  Future<User?> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    return credential.user;
  }

  // Signs the current user out and clears the active session.
  Future<void> signOut() => _auth.signOut();

  /// Converts raw FirebaseAuthException codes into readable messages.
  // Maps Firebase auth errors to user-friendly messages for UI feedback.
  String readableError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No account found with that email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists with that email.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
