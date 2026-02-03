import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String keyLanguage = 'app_language';
  static const String keyTheme = 'app_theme';

  Locale _locale = const Locale('sw'); // Default to Swahili
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Language
    final langCode = prefs.getString(keyLanguage);
    if (langCode != null) {
      _locale = Locale(langCode);
    } else {
      // If no language set, we keep 'sw' as default
      _locale = const Locale('sw');
    }

    // Load Theme
    final themeStr = prefs.getString(keyTheme);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ThemeMode.system,
      );
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'sw'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyTheme, mode.toString());
  }
}
