import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/widgets/animated_favorite_button.dart';
import '../../../../core/widgets/audio_pronounce_button.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/success_celebration_dialog.dart';
import '../providers/words_provider.dart';
import '../widgets/difficulty_badge.dart';
import '../widgets/part_of_speech_chip.dart';

/// Screen displaying the complete dictionary information for a selected word
class WordDetailScreen extends ConsumerWidget {
  final int wordId;

  const WordDetailScreen({super.key, required this.wordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordAsync = ref.watch(wordDetailProvider(wordId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return wordAsync.when(
      data: (word) {
        return Scaffold(
          appBar: AppBar(
            title: Text(word.word),
            actions: [
              AudioPronounceButton(
                id: 'word_${word.word}',
                text: word.word,
                tooltip: 'Pronounce "${word.word}"',
                iconSize: 22,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              AnimatedFavoriteButton(
                isFavorite: word.isFavorite,
                itemName: word.word,
                onToggle: () {
                  ref.read(wordControllerProvider.notifier).toggleFavorite(word);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card: Word, Phonetic, Badges
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainerLight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? AppColors.primaryLight.withValues(alpha: 0.3)
                          : AppColors.primaryLight.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                    boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              word.word,
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: isDark ? Colors.white : AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          DifficultyBadge(
                            difficulty: word.difficulty,
                            fontSize: 12,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          if (word.phonetic.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black38 : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                word.phonetic,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white70 : AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          AudioPronounceTonalButton(
                            id: 'word_${word.word}',
                            text: word.word,
                            label: 'Pronounce',
                            playingLabel: 'Playing...',
                            fontSize: 13,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          PartOfSpeechChip(partOfSpeech: word.partOfSpeech),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Topic: ${word.category[0].toUpperCase() + word.category.substring(1)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Meaning Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader(context, 'English Definition', Icons.menu_book_rounded),
                    AudioPronounceButton(
                      id: 'detail_meaning_${word.id}',
                      text: word.meaning,
                      tooltip: 'Listen to English definition',
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                  ),
                  child: Text(
                    word.meaning,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Kannada Meaning Section
                if (word.kannadaMeaning.isNotEmpty) ...[
                  _buildSectionHeader(context, 'ಕನ್ನಡ ಅರ್ಥ (Kannada Meaning)', Icons.translate_rounded),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.22)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? AppColors.secondary.withValues(alpha: 0.4)
                            : const Color(0xFF86EFAC),
                        width: 1.2,
                      ),
                      boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.g_translate_rounded,
                            color: AppColors.success,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            word.kannadaMeaning,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              color: isDark ? Colors.white : const Color(0xFF14532D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Example Sentence Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader(context, 'Example in Context', Icons.format_quote_rounded),
                    if (word.example.isNotEmpty)
                      AudioPronounceButton(
                        id: 'detail_example_${word.id}',
                        text: word.example,
                        tooltip: 'Listen to example sentence',
                        iconSize: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Text(
                      '"${word.example}"',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 15.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Synonyms Section
                if (word.synonyms.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Synonyms', Icons.compare_arrows_rounded),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: word.synonyms.map((syn) {
                      return Material(
                        color: AppColors.secondary.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            ref.read(appTtsControllerProvider).toggleSpeak(
                                  id: 'synonym_${word.id}_$syn',
                                  text: syn,
                                );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: isDark ? 0.35 : 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  syn,
                                  style: TextStyle(
                                    color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AudioPronounceButton(
                                  id: 'synonym_${word.id}_$syn',
                                  text: syn,
                                  tooltip: 'Pronounce "$syn"',
                                  iconSize: 15,
                                  activeColor: AppColors.secondary,
                                  inactiveColor: AppColors.secondary.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Antonyms Section
                if (word.antonyms.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Antonyms', Icons.swap_horiz_rounded),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: word.antonyms.map((ant) {
                      return Material(
                        color: AppColors.incorrectRed.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            ref.read(appTtsControllerProvider).toggleSpeak(
                                  id: 'antonym_${word.id}_$ant',
                                  text: ant,
                                );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.incorrectRed.withValues(alpha: isDark ? 0.35 : 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ant,
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFFCA5A5) : AppColors.incorrectRed,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                AudioPronounceButton(
                                  id: 'antonym_${word.id}_$ant',
                                  text: ant,
                                  tooltip: 'Pronounce "$ant"',
                                  iconSize: 15,
                                  activeColor: AppColors.incorrectRed,
                                  inactiveColor: AppColors.incorrectRed.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                ],

                // Mastered / Status Toggle Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final goalCompleted = await ref.read(wordControllerProvider.notifier).toggleLearned(word);
                      if (goalCompleted && context.mounted) {
                        SuccessCelebrationDialog.show(
                          context: context,
                          title: 'Daily Goal Completed! 🎯',
                          message: 'Congratulations! You reached your daily learning goal. Keep up the streak and build your vocabulary!',
                          scoreText: 'Goal 100%',
                          primaryButtonLabel: 'Awesome!',
                          onPrimaryPressed: () => Navigator.of(context).pop(),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: word.isLearned ? AppColors.success : theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(
                      word.isLearned ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      word.isLearned ? 'Mastered Word' : 'Mark as Mastered',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: LoadingView(message: 'Loading word details...'),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: ErrorStateView(
          message: err.toString(),
          onRetry: () => ref.invalidate(wordDetailProvider(wordId)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
