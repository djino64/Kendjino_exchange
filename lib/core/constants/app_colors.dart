// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A886);
  static const Color primaryLight = Color(0xFF4DFFDA);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFE6B800);

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

  static const Color success = Color(0xFF2ED573);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFF9F43);
  static const Color info = Color(0xFF5352ED);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E2535), Color(0xFF0D1117)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}