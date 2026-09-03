import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/audio_pronounce_button.dart';

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
    Color bgColor = isDark ? AppColors.surfaceDark : Colors.white;
    Color letterBg = isDark ? Colors.white10 : const Color(0xFFF1F5F9);
    Color letterColor = isDark ? Colors.white70 : const Color(0xFF334155);
    IconData? stateIcon;
    Color? iconColor;

    if (isAnswerSubmitted) {
      if (isCorrectOption) {
        borderColor = AppColors.correctGreen;
        bgColor = isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.3)
            : const Color(0xFFF0FDF4);
        letterBg = AppColors.correctGreen;
        letterColor = Colors.white;
        stateIcon = Icons.check_circle_rounded;
        iconColor = AppColors.correctGreen;
      } else if (isSelected && !isCorrectOption) {
        borderColor = AppColors.incorrectRed;
        bgColor = isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
            : const Color(0xFFFEF2F2);
        letterBg = AppColors.incorrectRed;
        letterColor = Colors.white;
        stateIcon = Icons.cancel_rounded;
        iconColor = AppColors.incorrectRed;
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      bgColor = isDark
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.primaryContainerLight;
      letterBg = theme.colorScheme.primary;
      letterColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: Material(
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: borderColor,
              width: isSelected || (isAnswerSubmitted && isCorrectOption) ? 2.0 : 1.2,
            ),
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
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: letterBg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      optionLetter,
                      style: TextStyle(
                        color: letterColor,
                        fontWeight: FontWeight.w800,
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
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 15.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AudioPronounceButton(
                    id: 'quiz_opt_${optionLetter}_${text.hashCode}',
                    text: text,
                    tooltip: 'Pronounce "$text"',
                    iconSize: 18,
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
      ),
    );
  }
}
