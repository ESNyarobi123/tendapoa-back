import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../core/constants/app_constants.dart';

class SettingsProvider with ChangeNotifier {
  static const String keyLanguage = AppConstants.languageKey;
  static const String keyTheme = 'app_theme';
  static const String keyNotificationsEnabled = 'notifications_enabled';

  Locale _locale;
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider({Locale? initialLocale})
      : _locale = initialLocale ?? const Locale('sw') {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final langCode = prefs.getString(keyLanguage);
    if (langCode != null && (langCode == 'en' || langCode == 'sw')) {
      _locale = Locale(langCode);
    }

    final themeStr = prefs.getString(keyTheme);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ThemeMode.system,
      );
    }

    _notificationsEnabled = prefs.getBool(keyNotificationsEnabled) ?? true;

    timeago.setDefaultLocale(_locale.languageCode);

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'sw'].contains(locale.languageCode)) return;
    _locale = locale;
    timeago.setDefaultLocale(locale.languageCode);
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

  /// Mapendeleo ya arifa kwenye kifaa (haiunganishi FCM bado).
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyNotificationsEnabled, value);
  }
}
