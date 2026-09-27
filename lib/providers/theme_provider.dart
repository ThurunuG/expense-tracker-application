import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Manages the app's theme state and persists it across app restarts.
class ThemeProvider with ChangeNotifier {
  // Key used to store the theme preference in SharedPreferences.
  static const _prefKey = 'isDarkMode';

  // Tracks whether dark mode is currently enabled.
  bool _isDarkMode = false;

  // Loads the saved theme preference when the provider is created.
  ThemeProvider() {
    _loadPreference();
  }

  // Returns whether dark mode is currently enabled.
  bool get isDarkMode => _isDarkMode;

  // Converts the boolean state into a ThemeMode value for Flutter widgets.
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Reads the saved theme preference from persistent storage.
  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_prefKey) ?? false;
    notifyListeners();
  }

  // Toggles the current theme and saves it for future sessions.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, _isDarkMode);
  }
}
