import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners(); 
    }
  }

  // Helper to map ThemeOption to ThemeMode
  static ThemeMode mapThemeOptionToThemeMode(ThemeOption option) {
    switch (option) {
      case ThemeOption.automatic:
        return ThemeMode.system;
      case ThemeOption.light:
        return ThemeMode.light;
      case ThemeOption.dark:
        return ThemeMode.dark;
    }
  }

  // Helper to map ThemeMode to ThemeOption for displaying the current selection
  static ThemeOption mapThemeModeToThemeOption(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return ThemeOption.automatic;
      case ThemeMode.light:
        return ThemeOption.light;
      case ThemeMode.dark:
        return ThemeOption.dark;
    }
  }
}

enum ThemeOption {
  automatic,
  light,
  dark,
}
