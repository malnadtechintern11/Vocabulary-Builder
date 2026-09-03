import 'package:flutter/material.dart';

/// Semantic and Theme Color Palette
class AppColors {
  // Brand Primary
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryContainerLight = Color(0xFFEEF2FF);
  static const Color primaryContainerDark = Color(0xFF1E1B4B);

  // Secondary / Accent
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryDark = Color(0xFF115E59);

  // Success / Learned
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  // Favorite / Bookmark
  static const Color favorite = Color(0xFFE11D48); // Rose 600
  static const Color favoriteLight = Color(0xFFFFE4E6);

  // Difficulty Badges
  static const Color difficultyBeginner = Color(0xFF10B981); // Green
  static const Color difficultyIntermediate = Color(0xFFF59E0B); // Amber
  static const Color difficultyAdvanced = Color(0xFF8B5CF6); // Purple

  // Neutral Light Theme
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400

  // Neutral Dark Theme
  static const Color backgroundDark = Color(0xFF0B0F19); // Deep Slate
  static const Color surfaceDark = Color(0xFF131B2E); // Dark Navy Slate
  static const Color surfaceVariantDark = Color(0xFF1E293B); // Slate 800
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500

  // Status Colors
  static const Color correctGreen = Color(0xFF22C55E);
  static const Color incorrectRed = Color(0xFFEF4444);
  static const Color error = Color(0xFFEF4444);

  // Subtle Card Shadows
  static const List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Color(0x0A0F172A), // 4% Slate 900
      blurRadius: 10,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x060F172A),
      blurRadius: 3,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Color(0x35000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Elevated Shadows for interactive cards & active dialogs
  static const List<BoxShadow> elevatedShadowLight = [
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevatedShadowDark = [
    BoxShadow(
      color: Color(0x50000000),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  // Primary Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
