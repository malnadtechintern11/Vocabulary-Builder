import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../features/sentences/providers/sentences_provider.dart';
import '../../models/sentence.dart';

/// Clean, learner-friendly card displaying an English sentence, meaning, and key vocabulary
class SentenceCard extends ConsumerWidget {
  final Sentence sentence;
  final VoidCallback? onPractice;

  const SentenceCard({
    super.key,
    required this.sentence,
    this.onPractice,
  });

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.difficultyBeginner;
      case 'intermediate':
        return AppColors.difficultyIntermediate;
      case 'advanced':
        return AppColors.difficultyAdvanced;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diffColor = _getDifficultyColor(sentence.difficulty);
    final currentlySpeakingId = ref.watch(ttsSpeakingSentenceIdProvider);
    final isSpeakingThis = currentlySpeakingId == sentence.id;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSpeakingThis
              ? AppColors.primary
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isSpeakingThis ? 1.8 : 1.0,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Difficulty Badge, Category Chip & Favorite
            Row(
              children: [
                // Difficulty Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: diffColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: diffColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        sentence.difficulty,
                        style: TextStyle(
                          color: diffColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Category Chip
                Expanded(
                  child: Text(
                    sentence.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),

                // Favorite Button
                IconButton(
                  icon: Icon(
                    sentence.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: sentence.isFavorite
                        ? AppColors.favorite
                        : (isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight),
                    size: 22,
                  ),
                  tooltip: sentence.isFavorite
                      ? 'Remove from saved'
                      : 'Save sentence',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    ref
                        .read(favoriteSentenceIdsProvider.notifier)
                        .toggleFavorite(sentence.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // English Sentence Text
            SelectableText(
              sentence.text,
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            // Simple Meaning Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark.withValues(alpha: 0.6)
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderDark.withValues(alpha: 0.4)
                      : AppColors.borderLight.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 17,
                    color: isDark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sentence.meaning,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textPrimaryLight.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Important Vocabulary Words Section
            if (sentence.vocabularyWords.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Key Vocabulary',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: sentence.vocabularyWords.map((vocab) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryContainerDark.withValues(alpha: 0.45)
                          : AppColors.primaryContainerLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.primaryLight.withValues(alpha: 0.25)
                            : AppColors.primaryLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${vocab.word}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: vocab.meaning,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 6),

            // Action Buttons Row: Speaker (TTS), Copy, Practice
            Row(
              children: [
                // Speaker Button
                FilledButton.tonalIcon(
                  onPressed: () {
                    ref.read(ttsControllerProvider).speakSentence(sentence);
                  },
                  icon: Icon(
                    isSpeakingThis
                        ? Icons.volume_up_rounded
                        : Icons.volume_down_rounded,
                    size: 18,
                    color: isSpeakingThis
                        ? Colors.white
                        : (isDark ? AppColors.primaryLight : AppColors.primary),
                  ),
                  label: Text(
                    isSpeakingThis ? 'Listening...' : 'Pronounce',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isSpeakingThis
                          ? Colors.white
                          : (isDark ? AppColors.primaryLight : AppColors.primary),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: isSpeakingThis
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.primaryContainerLight),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),

                // Copy Button
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'Copy sentence',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: sentence.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sentence copied to clipboard!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Practice Button
                if (onPractice != null)
                  TextButton.icon(
                    onPressed: onPractice,
                    icon: const Icon(Icons.school_outlined, size: 16),
                    label: const Text(
                      'Practice',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
