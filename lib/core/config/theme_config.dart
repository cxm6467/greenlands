import 'package:flutter/material.dart';

class GreenlandsTheme {
  // Color palette - Fantasy/16-bit inspired
  static const Color primaryGreen = Color(0xFF2F4F2F); // Dark forest green
  static const Color secondaryBrown = Color(0xFF8B4513); // Saddle brown
  static const Color accentGold = Color(0xFFFFD700); // Gold
  static const Color accentBlue = Color(0xFF4169E1); // Royal blue
  static const Color backgroundDark = Color(0xFF1A1A1A); // Very dark gray
  static const Color surfaceDark = Color(0xFF3F2F1F); // Dark wood
  static const Color errorRed = Color(0xFFDC143C); // Crimson
  static const Color successGreen = Color(0xFF32CD32); // Lime green
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB0B0B0); // Light gray
  static const Color borderColor = Color(
    0xFFFFFFFF,
  ); // White borders for pixel art effect

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: secondaryBrown,
      scaffoldBackgroundColor: primaryGreen,
      cardColor: surfaceDark,

      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: accentBlue,
        surface: surfaceDark,
        error: errorRed,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryBrown,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Courier New', // Monospace for retro feel
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 2.0,
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: accentGold,
          letterSpacing: 2.0,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1.5,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 16,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 14,
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 14,
          color: textPrimary,
          letterSpacing: 1.0,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Sharp corners for pixel art
          side: const BorderSide(color: borderColor, width: 2),
        ),
        margin: const EdgeInsets.all(8.0),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Sharp corners
            side: const BorderSide(color: borderColor, width: 3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Courier New',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          elevation: 4,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentGold,
          side: const BorderSide(color: accentGold, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Courier New',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGold,
          textStyle: const TextStyle(
            fontFamily: 'Courier New',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundDark,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: accentGold, width: 3),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: errorRed, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Courier New',
          color: textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Courier New',
          color: textSecondary,
          fontSize: 14,
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentGold,
        linearTrackColor: surfaceDark,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 2,
        space: 16,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: borderColor, width: 3),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Courier New',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: accentGold,
          letterSpacing: 1.5,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Courier New',
          fontSize: 14,
          color: textPrimary,
          height: 1.5,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceDark,
        contentTextStyle: const TextStyle(
          fontFamily: 'Courier New',
          fontSize: 14,
          color: textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: borderColor, width: 2),
        ),
        elevation: 4,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryBrown,
        selectedItemColor: accentGold,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 12,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(color: accentGold, size: 24),
    );
  }

  // Custom box decoration for pixel-art style containers
  static BoxDecoration pixelBoxDecoration({
    Color? backgroundColor,
    Color borderColor = borderColor,
    double borderWidth = 3.0,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? surfaceDark,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((0.5 * 255).toInt()),
          offset: const Offset(4, 4),
          blurRadius: 0, // No blur for pixel-perfect shadow
        ),
      ],
    );
  }

  // Get color for item rarity
  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF9E9E9E); // Gray
      case 'uncommon':
        return const Color(0xFF4CAF50); // Green
      case 'rare':
        return const Color(0xFF2196F3); // Blue
      case 'epic':
        return const Color(0xFF9C27B0); // Purple
      case 'legendary':
        return accentGold; // Gold
      default:
        return textSecondary;
    }
  }

  // Get color for quest difficulty
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return successGreen;
      case 'medium':
        return accentGold;
      case 'hard':
        return errorRed;
      default:
        return textSecondary;
    }
  }
}
