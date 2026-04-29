import 'package:flutter/material.dart';

/// Rangi zinazofuata [ThemeMode] (mwanga / giza) kutoka [ColorScheme].
extension TendapoaThemeX on BuildContext {
  ColorScheme get tpScheme => Theme.of(this).colorScheme;

  Brightness get tpBrightness => Theme.of(this).brightness;

  /// Ubao wa Scaffold
  Color get tpSurface => tpScheme.surface;

  /// Kadi / vipengee vilivyoinuka
  Color get tpCard => tpScheme.surfaceContainerLow;

  /// Kadi inayoonekana juu ya ubao (korti za kazi, stat, kategoria).
  Color get tpCardElevated => tpScheme.surfaceContainerHigh;

  /// Vipengee vidogo: chip, placeholder, sehemu ya picha.
  Color get tpMutedFill => tpScheme.surfaceContainerHighest;

  /// Kivuli kinachofaa giza (si nyeupe kali juu ya mandhari ya giza).
  Color get tpShadowSoft => tpScheme.shadow.withValues(
        alpha: tpBrightness == Brightness.dark ? 0.42 : 0.07,
      );

  Color get tpOnSurface => tpScheme.onSurface;
  Color get tpMuted => tpScheme.onSurfaceVariant;
  Color get tpOutline => tpScheme.outlineVariant;
}
