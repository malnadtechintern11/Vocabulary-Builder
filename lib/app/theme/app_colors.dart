import 'package:flutter/material.dart';

/// Semantic and Theme Color Palette: Professional Blue & Ivory Theme
/// - Steel Blue (#4F7691): Primary color
/// - Dusty Blue (#6F91A8): Secondary color
/// - Deep Navy Blue (#183F63): Important accents & bold headings
/// - Soft Blue (#A9C0CF): Light highlights & secondary accents
/// - Ivory (#F2F0E8): Backgrounds/cards & warm dark text
/// - Blue Grey (#78909F): Supporting elements & subtle borders
class AppColors {
  // Brand Palette Core Tokens
  static const Color steelBlue = Color(0xFF4F7691);
  static const Color dustyBlue = Color(0xFF6F91A8);
  static const Color deepNavyBlue = Color(0xFF183F63);
  static const Color softBlue = Color(0xFFA9C0CF);
  static const Color ivory = Color(0xFFF2F0E8);
  static const Color blueGrey = Color(0xFF78909F);

  // Brand Primary (Steel Blue based)
  static const Color primary = steelBlue; // #4F7691
  static const Color primaryLight = dustyBlue; // #6F91A8
  static const Color primaryDark = deepNavyBlue; // #183F63
  static const Color primaryContainerLight = Color(0xFFE5EDF2); // Soft Blue-Ivory Tint
  static const Color primaryContainerDark = Color(0xFF162C40); // Deep Navy Container

  // Secondary / Accent (Dusty Blue based)
  static const Color secondary = dustyBlue; // #6F91A8
  static const Color secondaryLight = softBlue; // #A9C0CF
  static const Color secondaryDark = deepNavyBlue; // #183F63

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
  static const Color difficultyAdvanced = steelBlue; // Steel Blue (#4F7691)

  // Neutral Light Theme (Ivory backdrop with crisp floating cards & Deep Navy typography)
  static const Color backgroundLight = ivory; // #F2F0E8
  static const Color surfaceLight = Color(0xFFFFFFFF); // Clean surface
  static const Color surfaceVariantLight = Color(0xFFE7ECEF); // Soft Blue-Ivory tint
  static const Color borderLight = Color(0xFFD0DCE3); // Blue-Grey border
  static const Color textPrimaryLight = deepNavyBlue; // #183F63
  static const Color textSecondaryLight = Color(0xFF536E82); // Steel Blue-Grey
  static const Color textTertiaryLight = blueGrey; // #78909F

  // Neutral Dark Theme (Deep Navy Slate with Ivory typography & Soft Blue highlights)
  static const Color backgroundDark = Color(0xFF0C1824); // Deep Navy Black
  static const Color surfaceDark = Color(0xFF132537); // Deep Navy Card Surface
  static const Color surfaceVariantDark = Color(0xFF1B354E); // Navy Slate
  static const Color borderDark = Color(0xFF274A6B); // Subtle Steel Navy border
  static const Color textPrimaryDark = ivory; // #F2F0E8
  static const Color textSecondaryDark = softBlue; // #A9C0CF
  static const Color textTertiaryDark = blueGrey; // #78909F

  // Status Colors
  static const Color correctGreen = Color(0xFF22C55E);
  static const Color incorrectRed = Color(0xFFEF4444);
  static const Color error = Color(0xFFEF4444);

  // Subtle Card Shadows (Infused with Deep Navy for rich depth)
  static const List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Color(0x0E183F63), // 5.5% Deep Navy
      blurRadius: 10,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x06183F63),
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
      color: Color(0x16183F63), // 8.5% Deep Navy
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

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [deepNavyBlue, steelBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [steelBlue, dustyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientLight = LinearGradient(
    colors: [ivory, Color(0xFFE5EDF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    colors: [Color(0xFF132537), deepNavyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
