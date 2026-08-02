// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

String? getWebStorageItem(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } catch (_) {
    return null;
  }
}

void setWebStorageItem(String key, String value) {
  try {
    web.window.localStorage.setItem(key, value);
  } catch (_) {}
}
