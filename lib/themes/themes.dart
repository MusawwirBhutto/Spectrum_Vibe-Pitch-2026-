import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Action Color (Amethyst Purple)
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Monochrome Scale for Premium Look
  static const Color darkText = Color(0xFF0A0A0A); // Jet Black (High Contrast)
  static const Color lightText = Color(
    0xFF707070,
  ); // Medium Slate Gray (Secondary/Helper Text)

  // Pre-calculated colors to avoid using .withOpacity()
  static const Color lightHint = Color(0xB3707070); // 70% opacity for hint text
  static const Color shadowPurple = Color(
    0x4D8B5CF6,
  ); // 30% opacity for Purple shadow
  static const Color shadowBlack = Color(
    0x14000000,
  ); // 8% opacity for Black card shadow

  static const Color backgroundWhite = Color(
    0xFFFFFFFF,
  ); // Pure Canvas White (Main Background)
  static const Color cardBackground = Color(0xFFFFFFFF); // Card Background
  static const Color dividerColor = Color(
    0xFFE5E5E5,
  ); // Soft Gray Divider/Border
  static const Color errorRed = Color(0xFFEF4444); // Modern Error Color
  static const Color successGreen = Color(0xFF10B981); // Success Indicator
}

// --- 🚀 Premium Theme Data ---
final ThemeData appTheme = ThemeData(
  // Use Material 3, the modern design language
  useMaterial3: true,

  // Set the canvas color to pure white
  scaffoldBackgroundColor: AppColors.backgroundWhite,

  // Define a modern color scheme
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.accentPurple,
    primary: AppColors.accentPurple,
    secondary: AppColors.accentPurple,
    surface: AppColors.cardBackground,
    onPrimary: Colors.white,
    onSecondary: AppColors.darkText,
    onSurface: AppColors.darkText,
    error: AppColors.errorRed,
  ),

  // --- Typography: Unified, Bold Poppins (Like Major Platforms) ---
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w800,
      fontSize: 32,
      color: AppColors.darkText,
    ),
    titleLarge: GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: AppColors.darkText,
    ),
    titleMedium: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: AppColors.darkText,
    ),
    bodyMedium: GoogleFonts.poppins(fontSize: 15, color: AppColors.darkText),
    bodySmall: GoogleFonts.poppins(fontSize: 13, color: AppColors.lightText),
  ),

  // --- UI Component Styling ---

  // App Bar: Clean, white, no shadow (Instagram/X style)
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.backgroundWhite,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: AppColors.darkText,
    ),
    iconTheme: const IconThemeData(color: AppColors.darkText),
  ),

  // Buttons: Reserved for Amethyst Purple, generous padding, fully rounded
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accentPurple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      shadowColor: AppColors.shadowPurple,
    ),
  ),

  // --- NEW: Text Button Theme ---
  // Ensures all link-style buttons use our brand color and font
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor:
          AppColors.accentPurple, // Use our brand color for the text
      textStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w600, // Make links slightly bold
        fontSize: 14,
      ),
    ),
  ),

  // Text Fields: Clean borders, focused accent color
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundWhite,
    hintStyle: const TextStyle(color: AppColors.lightHint),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.dividerColor, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.dividerColor, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accentPurple, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
    ),
  ),

  // Cards: Subtle shadow, rounded for a floating effect
  cardTheme: CardThemeData(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18.0),
      side: const BorderSide(color: AppColors.dividerColor, width: 0.5),
    ),
    color: AppColors.cardBackground,
    shadowColor: AppColors.shadowBlack,
    margin: EdgeInsets.zero,
  ),

  // SnackBar: Premium, dark notification bar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.darkText,
    contentTextStyle: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    behavior: SnackBarBehavior.floating,
  ),

  // Icon Theme: Default icons should be deep gray unless interacting
  iconTheme: const IconThemeData(color: AppColors.darkText),

  // --- NEW: Bottom Navigation Bar Theme ---
  // A premium, clean style for the main app navigation
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundWhite,
    elevation: 8, // Give it a slight lift
    selectedItemColor:
        AppColors.accentPurple, // Active icon uses our brand color
    unselectedItemColor: AppColors.lightText, // Inactive icons are gray
    selectedLabelStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    unselectedLabelStyle: GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
    type:
        BottomNavigationBarType.fixed, // Ensures all labels are always visible
    showUnselectedLabels: true,
  ),
);
