import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mandhari ya M3 zinazolingana na light/dark — maandishi ya ubao na rangi za kujaza zinafuatana na `ColorScheme`.
abstract final class TendapoaMaterialThemes {
  static const Color _seed = Color(0xFF2563EB);

  static ThemeData light() {
    final cs = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light);
    return _build(cs, Brightness.light);
  }

  /// Mandhari giza ya kitaalamu: ubao na kadi ziko **karibu rangi** (sio mweupe kali).
  /// `fromSeed` peke yake huongeza surfaceContainer sana → kadi zinaonekana "uweupe" sana.
  static ThemeData dark() {
    final base = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    const surfaceBase = Color(0xFF0B0F17);
    const cardLift1 = Color(0xFF121826);
    const cardLift2 = Color(0xFF151D2A);
    const cardLift3 = Color(0xFF1A2230);
    const cardLift4 = Color(0xFF1F2838);

    final cs = base.copyWith(
      surface: surfaceBase,
      surfaceContainerLowest: surfaceBase,
      surfaceContainerLow: cardLift1,
      surfaceContainer: cardLift2,
      surfaceContainerHigh: cardLift3,
      surfaceContainerHighest: cardLift4,
      outline: const Color(0xFF2A3544),
      outlineVariant: const Color(0xFF222A38),
      shadow: Colors.black,
    );
    return _build(cs, Brightness.dark);
  }

  static ThemeData _build(ColorScheme cs, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
    );

    final borderRadius = BorderRadius.circular(12);

    final inputDecoration = InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: cs.error),
      ),
      labelStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
      hintStyle: TextStyle(
        color: cs.onSurfaceVariant.withValues(alpha: 0.75),
        fontSize: 14,
      ),
      floatingLabelStyle: TextStyle(color: cs.primary, fontSize: 12),
    );

    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: cs.surface,
      textTheme: textTheme,
      primaryTextTheme: GoogleFonts.poppinsTextTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: inputDecoration,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cs.primary,
        selectionColor: cs.primary.withValues(alpha: 0.35),
        selectionHandleColor: cs.primary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface),
      ),
    );
  }
}
