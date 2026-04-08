import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VesperTheme {
  // Dark Mode Colors
  static const Color darkBgBase = Color(0xFF0E0F14);
  static const Color darkBgSurface = Color(0xFF16181F);
  static const Color darkBgElevated = Color(0xFF1E2029);
  static const Color darkBorder = Color(0xFF2E3040);
  static const Color darkTextPrimary = Color(0xFFF0F0F5);
  static const Color darkTextSecondary = Color(0xFF8B8FA8);
  static const Color darkAccentPrimary = Color(0xFF7C6AF7);
  static const Color darkAccentSecondary = Color(0xFFC4A55A);
  static const Color darkDestructive = Color(0xFFE05C5C);
  static const Color darkSuccess = Color(0xFF4CAF82);

  // Light Mode Colors
  static const Color lightBgBase = Color(0xFFF7F5F0);
  static const Color lightBgSurface = Color(0xFFFFFFFF);
  static const Color lightBgElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFDDD9D0);
  static const Color lightTextPrimary = Color(0xFF18181C);
  static const Color lightTextSecondary = Color(0xFF6B6860);
  static const Color lightAccentPrimary = Color(0xFFC4901A);
  static const Color lightAccentSecondary = Color(0xFF6A5FD4);
  static const Color lightDestructive = Color(0xFFCC4444);
  static const Color lightSuccess = Color(0xFF3A9966);

  static ThemeData light() {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: lightAccentPrimary,
        primaryContainer: Color(0xFFF0E6D2),
        secondary: lightAccentSecondary,
        secondaryContainer: Color(0xFFE0DDF5),
        tertiary: lightSuccess,
        tertiaryContainer: Color(0xFFD5E8DF),
        appBarColor: lightBgBase,
        error: lightDestructive,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        defaultRadius: 4.0,
        thinBorderWidth: 1.0,
        thickBorderWidth: 2.0,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackground: lightBgBase,
    ).copyWith(
      textTheme: _textTheme(lightTextPrimary, lightTextSecondary),
    );
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: darkAccentPrimary,
        primaryContainer: Color(0xFF252140),
        secondary: darkAccentSecondary,
        secondaryContainer: Color(0xFF332D1A),
        tertiary: darkSuccess,
        tertiaryContainer: Color(0xFF1B2B24),
        appBarColor: darkBgBase,
        error: darkDestructive,
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        defaultRadius: 4.0,
        thinBorderWidth: 1.0,
        thickBorderWidth: 2.0,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackground: darkBgBase,
    ).copyWith(
      textTheme: _textTheme(darkTextPrimary, darkTextSecondary),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.25,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.3,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: secondary,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.lora(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.65,
      ),
      bodyMedium: GoogleFonts.lora(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.6,
      ),
    );
  }
}
