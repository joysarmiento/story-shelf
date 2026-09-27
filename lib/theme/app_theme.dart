import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Color palette
  static const Color primary = Color(0xFF943B41); // buttons, active states
  static const Color onPrimary = Color(0xFFFFFFFF); // text/icons on primary
  static const Color secondary = Color(0xFF9DC3D8); // nav bar, chips, cards
  static const Color surface = Color(0xFFFBF9EC); // scaffold background
  static const Color surfaceVariant = Color(0xFFD8E4E4); // cards, fields
  static const Color onSurface = Color(0xFF66769A); // body text
  static const Color error = Color(0xFFB02D35); // headings, tags, destructive
  static const Color storyTintBeige = Color(0xFFD9BFA0);

  // Spacing rules
  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24; // screen edge padding
  static const double spaceListGap = 12; // between list items / cards
  static const double spaceSectionGap = 32; // between sections

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: surface,
        onSurface: onSurface,
        error: error,
        onError: onPrimary,
      ),

      textTheme: TextTheme(
        displayMedium: GoogleFonts.montserrat(
          fontSize: 26,
          fontWeight: FontWeight.w700, // bold
          color: primary,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700, // bold
          color: primary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600, // medium
          color: onSurface,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w500, // medium
          color: onSurface,
        ),
        labelSmall: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w500, // medium
          color: onSurface,
        ),
      ),
    );
  }
}
