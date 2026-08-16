import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snow_dance/core/utils/web_storage_stub.dart'
    if (dart.library.js_interop) 'package:snow_dance/core/utils/web_storage_real.dart' as web_storage;

class ThemeStorage {
  static const String key = 'snow_dance_theme_mode';

  static Future<String?> getSavedTheme() async {
    if (kIsWeb) {
      final webVal = web_storage.getWebStorageItem(key);
      if (webVal != null && webVal.isNotEmpty) {
        return webVal;
      }
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  static String? getSavedThemeSync() {
    if (kIsWeb) {
      return web_storage.getWebStorageItem(key);
    }
    return null;
  }

  static Future<void> saveTheme(String mode) async {
    if (kIsWeb) {
      web_storage.setWebStorageItem(key, mode);
      web_storage.setWebStorageItem('flutter.$key', mode);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, mode);
    } catch (_) {}
  }
}
