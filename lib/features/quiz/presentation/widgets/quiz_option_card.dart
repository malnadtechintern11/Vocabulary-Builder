import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Interactive answer option card with selected, correct, and incorrect states
class QuizOptionCard extends StatelessWidget {
  final String text;
  final String optionLetter;
  final bool isSelected;
  final bool isAnswerSubmitted;
  final bool isCorrectOption;
  final VoidCallback onTap;

  const QuizOptionCard({
    super.key,
    required this.text,
    required this.optionLetter,
    required this.isSelected,
    required this.isAnswerSubmitted,
    required this.isCorrectOption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    Color bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    Color letterBg = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);
    Color letterColor = isDark ? Colors.white70 : Colors.black87;
    IconData? stateIcon;
    Color? iconColor;

    if (isAnswerSubmitted) {
      if (isCorrectOption) {
        borderColor = AppColors.correctGreen;
        bgColor = AppColors.correctGreen.withValues(alpha: 0.12);
        letterBg = AppColors.correctGreen;
        letterColor = Colors.white;
        stateIcon = Icons.check_circle_rounded;
        iconColor = AppColors.correctGreen;
      } else if (isSelected && !isCorrectOption) {
        borderColor = AppColors.incorrectRed;
        bgColor = AppColors.incorrectRed.withValues(alpha: 0.12);
        letterBg = AppColors.incorrectRed;
        letterColor = Colors.white;
        stateIcon = Icons.cancel_rounded;
        iconColor = AppColors.incorrectRed;
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      bgColor = theme.colorScheme.primary.withValues(alpha: 0.08);
      letterBg = theme.colorScheme.primary;
      letterColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: isSelected || (isAnswerSubmitted && isCorrectOption) ? 2 : 1),
        ),
        child: InkWell(
          onTap: isAnswerSubmitted ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Option Letter Badge (A, B, C, D)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    optionLetter,
                    style: TextStyle(
                      color: letterColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Option Text
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (stateIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(stateIcon, color: iconColor, size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
