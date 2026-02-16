// Importing necessary packages
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme provider
// This class manages light/dark theme
class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = true;

  bool get isDarkTheme => _isDarkTheme;

  // Load theme from shared preferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? true;
    notifyListeners();
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    notifyListeners();
  }
}
