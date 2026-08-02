import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'snow_dance_theme_mode';
  late ThemeMode _themeMode;

  ThemeProvider({String? initialSavedTheme}) {
    _themeMode = _parseThemeMode(initialSavedTheme);
  }

  static ThemeMode _parseThemeMode(String? saved) {
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => switch (_themeMode) {
        ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
        ThemeMode.dark => true,
        ThemeMode.light => false,
      };

  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeString = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_themeKey, modeString);
    } catch (_) {
      // Ignore write errors
    }
  }

  void toggleTheme() {
    final nextMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    setThemeMode(nextMode);
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _saveTheme(mode);
    notifyListeners();
  }
}
