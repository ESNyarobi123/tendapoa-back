import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class SettingsProvider with ChangeNotifier {
  static const String keyLanguage = AppConstants.languageKey;
  static const String keyTheme = 'app_theme';

  Locale _locale;
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  SettingsProvider({Locale? initialLocale}) : _locale = initialLocale ?? const Locale('sw') {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Language (overwrite with saved so Settings screen stays in sync)
    final langCode = prefs.getString(keyLanguage);
    if (langCode != null && (langCode == 'en' || langCode == 'sw')) {
      _locale = Locale(langCode);
    }
    // else keep _locale from initialLocale / default

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
