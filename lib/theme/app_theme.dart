import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TextSize { small, medium, large }

extension TextSizeInfo on TextSize {
  String get label => switch (this) {
    TextSize.small => 'Small',
    TextSize.medium => 'Medium',
    TextSize.large => 'Large',
  };

  double get scale => switch (this) {
    TextSize.small => 0.9,
    TextSize.medium => 1.0,
    TextSize.large => 1.2,
  };
}

class AppTheme {
  AppTheme._();
  static bool highContrast = false;
  static void setHighContrast(bool value) {
    if (highContrast == value) return;
    highContrast = value;
    _rebuildAll();
  }

  static TextSize textSize = TextSize.medium;

  static void setTextSize(TextSize value) {
    if (textSize == value) return;
    textSize = value;
    _rebuildAll();
  }

  static void _rebuildAll() {
    void markDirty(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markDirty);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(markDirty);
  }

  // Color palette
  static const Color primary = Color(0xFF943B41);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static Color get secondary =>
      highContrast ? const Color(0xFF73ADCD) : const Color(0xFF9DC3D8);
  static const Color surface = Color(0xFFFBF9EC);
  static const Color surfaceVariant = Color(0xFFD8E4E4);
  static Color get onSurface =>
      highContrast ? const Color(0xFF495A82) : const Color(0xFF66769A);
  static Color get error =>
      highContrast ? const Color(0xFF8A1620) : const Color(0xFFB02D35);
  static const Color storyTintBeige = Color(0xFFD9BFA0);
  static Color get navSelected =>
      highContrast ? const Color(0xFF943B41) : error;
  static Color get navUnselected =>
      highContrast ? onPrimary.withValues(alpha: 0.85) : onPrimary;

  // Spacing rules
  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceListGap = 12;
  static const double spaceSectionGap = 32;

  static const double storyCardAspectRatio = 7 / 10;

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: surface,
        onSurface: onSurface,
        error: error,
        onError: onPrimary,
      ),

      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Railey',
          fontSize: 38,
          color: secondary,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodySmall: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
    );
  }
}
