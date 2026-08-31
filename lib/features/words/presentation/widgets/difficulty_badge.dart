import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
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
    Color bg;
    Color text;
    String label = difficulty.toUpperCase();

    switch (difficulty.toLowerCase()) {
      case 'beginner':
        bg = AppColors.difficultyBeginner.withValues(alpha: 0.15);
        text = AppColors.difficultyBeginner;
        break;
      case 'intermediate':
        bg = AppColors.difficultyIntermediate.withValues(alpha: 0.15);
        text = AppColors.difficultyIntermediate;
        break;
      case 'advanced':
        bg = AppColors.difficultyAdvanced.withValues(alpha: 0.15);
        text = AppColors.difficultyAdvanced;
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.15);
        text = Colors.grey;
    }

    return CustomBadge(
      label: label,
      backgroundColor: bg,
      textColor: text,
      fontSize: fontSize,
    );
  }
}
