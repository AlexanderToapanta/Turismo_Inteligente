import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TemaPersona5 {
  static final ThemeData temaClaro = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      tertiary: tertiaryColor,
      onTertiary: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimary,
    ),

    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.bebasNeue(fontSize: 40, color: textPrimary),
      displayMedium: GoogleFonts.bebasNeue(fontSize: 34, color: textPrimary),
      titleLarge: GoogleFonts.bebasNeue(fontSize: 28, color: textPrimary),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textPrimary),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textSecondary),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.white),
    ),

    cardTheme: CardThemeData(
      elevation: 6,
      shadowColor: Colors.black87,
      color: surfaceColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: primaryColor, width: 1.5),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Color(0xFF8A8A8A),
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 4,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
  );

  // Paleta Persona 5
  static const Color primaryColor = Color(0xFFE60012); // Rojo fuerte
  static const Color secondaryColor = Color(0xFFFFFFFF); // Blanco
  static const Color tertiaryColor = Color(0xFF111111); // Negro

  static const Color backgroundColor = Color(0xFF050505);
  static const Color surfaceColor = Color(0xFF151515);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCFCFCF);

  static const Color dividerColor = Color(0xFF2A2A2A);
}
