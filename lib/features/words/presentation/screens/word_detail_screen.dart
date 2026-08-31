import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_view.dart';
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
              IconButton(
                icon: Icon(
                  word.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: word.isFavorite ? AppColors.favorite : null,
                ),
                tooltip: word.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                onPressed: () {
                  ref.read(wordControllerProvider.notifier).toggleFavorite(word);
                },
              ),
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainerLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.primaryLight.withValues(alpha: 0.2),
                    ),
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
                              ),
                            ),
                          ),
                          DifficultyBadge(
                            difficulty: word.difficulty,
                            fontSize: 12,
                          ),
                        ],
                      ),
                      if (word.phonetic.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black26 : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            word.phonetic,
                            style: TextStyle(
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : AppColors.primaryDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          PartOfSpeechChip(partOfSpeech: word.partOfSpeech),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(
                              'Topic: ${word.category[0].toUpperCase() + word.category.substring(1)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Meaning Section
                _buildSectionHeader(context, 'Definition', Icons.menu_book_rounded),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      word.meaning,
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Example Sentence Section
                _buildSectionHeader(context, 'Example in Context', Icons.format_quote_rounded),
                const SizedBox(height: 8),
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '"${word.example}"',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Synonyms Section
                if (word.synonyms.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Synonyms', Icons.compare_arrows_rounded),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: word.synonyms.map((syn) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          syn,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Antonyms Section
                if (word.antonyms.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Antonyms', Icons.swap_horiz_rounded),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: word.antonyms.map((ant) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.incorrectRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.incorrectRed.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          ant,
                          style: const TextStyle(
                            color: AppColors.incorrectRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Mastered / Status Toggle Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(wordControllerProvider.notifier).toggleLearned(word);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: word.isLearned ? AppColors.success : theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: Icon(
                      word.isLearned ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      word.isLearned ? 'Mastered Word' : 'Mark as Mastered',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
        ),
      ],
    );
  }
}
