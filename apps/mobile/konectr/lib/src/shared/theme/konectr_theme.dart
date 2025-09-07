import 'package:flutter/material.dart';

/// Konectr brand colors per design system
class KonectrColors {
  static const Color sunsetOrange = Color(0xFFFF774D);  // Primary CTA color
  static const Color solarAmber = Color(0xFFFFC845);    // Notifications/badges
  static const Color graphiteGrey = Color(0xFF1F1F1F);  // Text/dark elements
  static const Color cloudWhite = Color(0xFFFAFAFA);    // Background/light elements
  
  // Additional semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE91E63);
  static const Color warning = solarAmber;
  static const Color info = Color(0xFF2196F3);
}

/// Konectr typography scale
class KonectrTypography {
  static const String bodyFont = 'Inter';
  static const String headingFont = 'Manrope';
  
  static const TextStyle h1 = TextStyle(
    fontFamily: headingFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: headingFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: headingFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle button = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}

/// Konectr spacing system (8pt grid)
class KonectrSpacing {
  static const double xs = 8.0;
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;
}

/// Konectr theme configuration
class KonectrTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: KonectrColors.sunsetOrange,
      scaffoldBackgroundColor: KonectrColors.cloudWhite,
      
      colorScheme: const ColorScheme.light(
        primary: KonectrColors.sunsetOrange,
        secondary: KonectrColors.solarAmber,
        surface: Colors.white,
        background: KonectrColors.cloudWhite,
        error: KonectrColors.error,
        onPrimary: Colors.white,
        onSecondary: KonectrColors.graphiteGrey,
        onSurface: KonectrColors.graphiteGrey,
        onBackground: KonectrColors.graphiteGrey,
        onError: Colors.white,
      ),
      
      textTheme: TextTheme(
        displayLarge: KonectrTypography.h1.copyWith(color: KonectrColors.graphiteGrey),
        displayMedium: KonectrTypography.h2.copyWith(color: KonectrColors.graphiteGrey),
        displaySmall: KonectrTypography.h3.copyWith(color: KonectrColors.graphiteGrey),
        bodyLarge: KonectrTypography.body.copyWith(color: KonectrColors.graphiteGrey),
        bodyMedium: KonectrTypography.body.copyWith(color: KonectrColors.graphiteGrey),
        bodySmall: KonectrTypography.bodySmall.copyWith(color: KonectrColors.graphiteGrey),
        labelLarge: KonectrTypography.button,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KonectrColors.sunsetOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 44), // Touch target minimum
          padding: const EdgeInsets.symmetric(
            horizontal: KonectrSpacing.sm,
            vertical: KonectrSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: KonectrTypography.button,
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: KonectrColors.graphiteGrey,
        elevation: 0,
        centerTitle: true,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KonectrColors.sunsetOrange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KonectrSpacing.sm,
          vertical: KonectrSpacing.xs,
        ),
      ),
    );
  }
  
  // Dark theme can be added later if needed
  // static ThemeData get darkTheme { ... }
}
