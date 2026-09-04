import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/animated_favorite_button.dart';
import '../../../../core/widgets/audio_pronounce_button.dart';
import '../../domain/entities/word.dart';
import '../providers/words_provider.dart';
import 'difficulty_badge.dart';
import 'part_of_speech_chip.dart';

/// Modern, elevated card component to display word preview in lists and search results
class WordCard extends ConsumerWidget {
  final Word word;

  const WordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            context.push('${RoutePaths.words}/${word.id}', extra: word);
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Online Result Banner if fetched from Web
                if (word.isOnline) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.public_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 5),
                            Text(
                              'Online Dictionary Result',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final saved = await ref.read(wordControllerProvider.notifier).addWord(word);
                          if (saved != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Saved "${word.word}" to offline vocabulary!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.bookmark_add_rounded, size: 14),
                        label: const Text('Add to Vocabulary'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Top Row: Word name, phonetic, and actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  word.word,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                              if (word.isLearned) ...[
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: 'Mastered',
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (word.phonetic.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              word.phonetic,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textSecondaryLight,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Speaker Button
                    AudioPronounceButton(
                      id: 'word_${word.word}',
                      text: word.word,
                      tooltip: 'Pronounce "${word.word}"',
                      iconSize: 22,
                    ),
                    const SizedBox(width: 4),
                    // Animated Favorite Toggle Button with micro-bounce
                    if (!word.isOnline)
                      AnimatedFavoriteButton(
                        isFavorite: word.isFavorite,
                        itemName: word.word,
                        onToggle: () {
                          ref.read(wordControllerProvider.notifier).toggleFavorite(word);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // English Meaning description with mini speaker button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        word.meaning,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    AudioPronounceButton(
                      id: 'word_meaning_${word.id}',
                      text: word.meaning,
                      tooltip: 'Listen to meaning',
                      iconSize: 17,
                    ),
                  ],
                ),

                // Kannada Meaning Box
                if (word.kannadaMeaning.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.25)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.secondary.withValues(alpha: 0.4)
                            : const Color(0xFF86EFAC),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.secondary.withValues(alpha: 0.3)
                                : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ಕನ್ನಡ',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.secondaryLight : const Color(0xFF15803D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            word.kannadaMeaning,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Contextual Example Box
                if (word.example.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.035)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(
                          color: isDark
                              ? AppColors.primaryLight.withValues(alpha: 0.8)
                              : AppColors.primary,
                          width: 3.5,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '"${word.example}"',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        AudioPronounceButton(
                          id: 'word_example_${word.id}',
                          text: word.example,
                          tooltip: 'Listen to example sentence',
                          iconSize: 16,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Bottom Row: Badges & Tags
                Row(
                  children: [
                    PartOfSpeechChip(partOfSpeech: word.partOfSpeech),
                    const SizedBox(width: 8),
                    DifficultyBadge(difficulty: word.difficulty),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceVariantDark
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '#${word.category}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
