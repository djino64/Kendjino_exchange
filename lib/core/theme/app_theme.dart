import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Kouli reyitilizab sistem nan
  static const Color primaryGreen = Color(0xFF00D4AA);
  static const Color primaryGreenDark = Color(0xFF00A886);
  static const Color primaryGreenLight = Color(0xFF4DFFDA);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentGoldDark = Color(0xFFE6B800);
  static const Color darkBg = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B27);
  static const Color darkCard = Color(0xFF1E2535);
  static const Color darkBorder = Color(0xFF2A3347);
  static const Color lightBg = Color(0xFFF4F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F4F8);
  static const Color textDark = Color(0xFF0D1117);
  static const Color textLight = Color(0xFFEEF2F7);
  static const Color textMuted = Color(0xFF8A93A6);
  static const Color errorRed = Color(0xFFFF4757);
  static const Color successGreen = Color(0xFF2ED573);
  static const Color warningOrange = Color(0xFFFF9F43);
  static const Color infoBlue = Color(0xFF5352ED);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      secondary: accentGold,
      surface: lightSurface,
      background: lightBg,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: textDark,
      onSurface: textDark,
      onBackground: textDark,
      onError: Colors.white,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
      primary: primaryGreen,
      secondary: accentGold,
      surface: darkSurface,
      background: darkBg,
      error: errorRed,
      onPrimary: darkBg,
      onSecondary: darkBg,
      onSurface: textLight,
      onBackground: textLight,
      onError: Colors.white,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      fontFamily: 'Satoshi',
      scaffoldBackgroundColor: isDark ? darkBg : lightBg,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkSurface : lightSurface,
        foregroundColor: isDark ? textLight : textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? textLight : textDark,
        ),
        iconTheme: IconThemeData(color: isDark ? textLight : textDark),
      ),

      // Kat (Card)
      cardTheme: CardThemeData(
        color: isDark ? darkCard : lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? darkBorder : const Color(0xFFE8EDF2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkCard : lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? darkBorder : const Color(0xFFE0E7F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: textMuted,
          fontFamily: 'Satoshi',
          fontSize: 15,
        ),
        labelStyle: TextStyle(
          color: isDark ? textLight : textDark,
          fontFamily: 'Satoshi',
          fontSize: 14,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? darkSurface : lightSurface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
        ),
      ),

      // NavigationBar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? darkSurface : lightSurface,
        indicatorColor: primaryGreen.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreen);
          }
          return IconThemeData(color: textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryGreen,
            );
          }
          return const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 12,
            color: AppTheme.textMuted,
          );
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? darkCard : lightCard,
        selectedColor: primaryGreen.withOpacity(0.2),
        labelStyle: TextStyle(
          fontFamily: 'Satoshi',
          color: isDark ? textLight : textDark,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: isDark ? darkBorder : const Color(0xFFE0E7F0)),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: isDark ? textLight : textDark,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: isDark ? textLight : textDark,
          letterSpacing: -1,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: isDark ? textLight : textDark,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: isDark ? textLight : textDark,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? textLight : textDark,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? textLight : textDark,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: isDark ? textLight : textDark,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? textLight : textDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 16,
          color: isDark ? textLight : textDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 14,
          color: isDark ? textLight : textDark,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? textLight : textDark,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? darkBorder : const Color(0xFFE8EDF2),
        thickness: 1,
        space: 1,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGreen;
          return isDark ? darkBorder : const Color(0xFFE0E7F0);
        }),
      ),
    );
  }
}

// App-specific text styles
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle walletBalance = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 38,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
  );

  static const TextStyle walletBalanceSmall = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle transactionAmount = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle cardNumber = TextStyle(
    fontFamily: 'SpaceMono',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 4,
  );

  static const TextStyle tagline = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );
}
