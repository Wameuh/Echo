import 'package:flutter/material.dart';

abstract final class EchoColors {
  static const pine = Color(0xFF17352C);
  static const lichen = Color(0xFFD8F277);
  static const clay = Color(0xFFFF7657);
  static const sky = Color(0xFFA9D8E9);
  static const oat = Color(0xFFF2EFE7);
  static const paper = Color(0xFFFBFAF6);
  static const ink = Color(0xFF10231D);
  static const muted = Color(0xFF66736E);
  static const night = Color(0xFF10221C);
  static const nightCard = Color(0xFF19352C);
}

ThemeData echoTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: dark ? EchoColors.lichen : EchoColors.pine,
    onPrimary: dark ? EchoColors.pine : Colors.white,
    secondary: EchoColors.clay,
    onSecondary: EchoColors.pine,
    error: const Color(0xFFB42318),
    onError: Colors.white,
    surface: dark ? EchoColors.nightCard : EchoColors.paper,
    onSurface: dark ? EchoColors.paper : EchoColors.ink,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'DM Sans',
    scaffoldBackgroundColor: dark ? EchoColors.night : EchoColors.oat,
  );
  final text = base.textTheme.apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  );
  return base.copyWith(
    textTheme: text.copyWith(
      displayLarge: text.displayLarge?.copyWith(
        fontFamily: 'Newsreader',
        fontSize: 58,
        height: .96,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.8,
      ),
      displayMedium: text.displayMedium?.copyWith(
        fontFamily: 'Newsreader',
        fontSize: 44,
        height: 1,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
      ),
      headlineLarge: text.headlineLarge?.copyWith(
        fontFamily: 'Newsreader',
        fontSize: 36,
        height: 1.05,
        fontWeight: FontWeight.w600,
        letterSpacing: -.8,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontFamily: 'Newsreader',
        fontSize: 28,
        height: 1.08,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 17, height: 1.5),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 15, height: 1.45),
      labelLarge: text.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerColor: scheme.onSurface.withValues(alpha: .12),
    cardTheme: CardThemeData(
      color: dark ? EchoColors.nightCard : EchoColors.paper,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: dark
            ? BorderSide(color: EchoColors.paper.withValues(alpha: .14))
            : BorderSide.none,
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: EchoColors.lichen,
        foregroundColor: EchoColors.pine,
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        side: BorderSide(color: scheme.onSurface.withValues(alpha: .24)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? Colors.white.withValues(alpha: .06) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      selectedColor: EchoColors.lichen,
      checkmarkColor: EchoColors.pine,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: scheme.onSurface.withValues(alpha: .14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? EchoColors.nightCard : EchoColors.paper,
      indicatorColor: EchoColors.lichen,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? EchoColors.pine
              : scheme.onSurface,
          size: 24,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: scheme.onSurface,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w500,
        ),
      ),
    ),
    iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
    focusColor: EchoColors.sky.withValues(alpha: .35),
    visualDensity: VisualDensity.standard,
  );
}
