import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeasonalPalette {
  final Color background;
  final Color surface;
  final Color surfaceWarm;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color accentYellow;

  const SeasonalPalette({
    required this.background,
    required this.surface,
    required this.surfaceWarm,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.accentYellow,
  });
}

class LeveTheme {
  // Available Seasonal Palettes
  static const SeasonalPalette tropical = SeasonalPalette(
    background: Color(0xFFF5F0EB),
    surface: Color(0xFFFFFFFF),
    surfaceWarm: Color(0xFFFFF8F0),
    primary: Color(0xFFC4785B),
    secondary: Color(0xFFA8C5A0),
    tertiary: Color(0xFFC5B8D4),
    accentYellow: Color(0xFFE8D3A7),
  );

  static const SeasonalPalette spring = SeasonalPalette(
    background: Color(0xFFFAF0F2),
    surface: Color(0xFFFFFFFF),
    surfaceWarm: Color(0xFFFFFDF9),
    primary: Color(0xFFD4829E),
    secondary: Color(0xFF9ECDAA),
    tertiary: Color(0xFFE4D192),
    accentYellow: Color(0xFFF6E8BC),
  );

  static const SeasonalPalette summer = SeasonalPalette(
    background: Color(0xFFEFF6F9),
    surface: Color(0xFFFFFFFF),
    surfaceWarm: Color(0xFFFFF9ED),
    primary: Color(0xFFE58F65),
    secondary: Color(0xFF7EBDC2),
    tertiary: Color(0xFFF3C15F),
    accentYellow: Color(0xFFF5D698),
  );

  static const SeasonalPalette autumn = SeasonalPalette(
    background: Color(0xFFF3EDE6),
    surface: Color(0xFFFFFFFF),
    surfaceWarm: Color(0xFFFAF3EC),
    primary: Color(0xFFB95C38),
    secondary: Color(0xFF7D8C72),
    tertiary: Color(0xFFDCA766),
    accentYellow: Color(0xFFE3C598),
  );

  static const SeasonalPalette winter = SeasonalPalette(
    background: Color(0xFFEDF1F4),
    surface: Color(0xFFFFFFFF),
    surfaceWarm: Color(0xFFF4F7F9),
    primary: Color(0xFF4E779A),
    secondary: Color(0xFF8FA9C4),
    tertiary: Color(0xFF7D7295),
    accentYellow: Color(0xFFC9D6DF),
  );

  // Dynamic active colors (initialized with tropical)
  static Color background = tropical.background;
  static Color surface = tropical.surface;
  static Color surfaceWarm = tropical.surfaceWarm;
  static Color primary = tropical.primary;
  static Color secondary = tropical.secondary;
  static Color tertiary = tropical.tertiary;
  static Color accentYellow = tropical.accentYellow;

  // Static Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textLight = Color(0xFFB5B5B5);

  /// Updates the active theme colors
  static void updateColors(String themeName) {
    final SeasonalPalette palette;
    switch (themeName.toLowerCase()) {
      case 'spring':
      case 'primavera':
        palette = spring;
        break;
      case 'summer':
      case 'verão':
        palette = summer;
        break;
      case 'autumn':
      case 'outono':
        palette = autumn;
        break;
      case 'winter':
      case 'inverno':
        palette = winter;
        break;
      case 'tropical':
      default:
        palette = tropical;
    }

    background = palette.background;
    surface = palette.surface;
    surfaceWarm = palette.surfaceWarm;
    primary = palette.primary;
    secondary = palette.secondary;
    tertiary = palette.tertiary;
    accentYellow = palette.accentYellow;
  }

  static ThemeData getThemeData(String themeName) {
    updateColors(themeName);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: background,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 32,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.dmSerifDisplay(
          fontSize: 28,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 22,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
