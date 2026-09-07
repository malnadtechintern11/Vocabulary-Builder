import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_badge.dart';

/// Pill badge representing Beginner, Intermediate, or Advanced difficulty
class DifficultyBadge extends StatelessWidget {
  final String difficulty;
  final double fontSize;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color text;
    String label = difficulty.toUpperCase();

    switch (difficulty.toLowerCase()) {
      case 'basic':
      case 'beginner':
        label = 'BASIC';
        bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
        text = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);
        break;
      case 'intermediate':
        label = 'INTERMEDIATE';
        bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        text = isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E);
        break;
      case 'advanced':
        label = 'ADVANCED';
        bg = isDark ? const Color(0xFF162C40) : const Color(0xFFE5EDF2);
        text = isDark ? const Color(0xFFA9C0CF) : const Color(0xFF183F63);
        break;
      default:
        bg = isDark ? Colors.white12 : const Color(0xFFE7ECEF);
        text = isDark ? const Color(0xFFF2F0E8) : const Color(0xFF183F63);
    }

    return CustomBadge(
      label: label,
      backgroundColor: bg,
      textColor: text,
      fontSize: fontSize,
    );
  }
}
