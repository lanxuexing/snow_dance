import 'package:flutter/material.dart';
import 'package:snow_dance/core/utils/theme_storage.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeMode _themeMode;

  ThemeProvider({String? initialSavedTheme}) {
    final syncTheme = initialSavedTheme ?? ThemeStorage.getSavedThemeSync();
    _themeMode = _parseThemeMode(syncTheme);
    if (initialSavedTheme == null) {
      _loadThemeAsync();
    }
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

  Future<void> _loadThemeAsync() async {
    final saved = await ThemeStorage.getSavedTheme();
    if (saved != null) {
      final mode = _parseThemeMode(saved);
      if (mode != _themeMode) {
        _themeMode = mode;
        notifyListeners();
      }
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
    final modeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    ThemeStorage.saveTheme(modeString);
    notifyListeners();
  }
}
