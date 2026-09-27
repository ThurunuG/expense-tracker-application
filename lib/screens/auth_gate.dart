import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Watches auth state and swaps between the login flow and the main app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the authentication state so the gate can react when users log in or out.
    final auth = context.watch<AuthProvider>();

    // If the user is authenticated, show the main app screen.
    if (auth.isAuthenticated) {
      // Ensure the ExpenseProvider is (re)wired to the current user.
      return const HomeScreen();
    }

    // If the user is logged out, stop any active expense tracking so stale data is not kept alive.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().stop();
    });

    // Otherwise, show the login flow.
    return const LoginScreen();
  }
}
