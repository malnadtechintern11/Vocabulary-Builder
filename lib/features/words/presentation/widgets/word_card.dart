import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/word.dart';
import '../providers/words_provider.dart';
import 'difficulty_badge.dart';
import 'part_of_speech_chip.dart';

/// Card component to display word preview in lists and search results
class WordCard extends ConsumerWidget {
  final Word word;

  const WordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('${RoutePaths.words}/${word.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Word name, phonetic, and favorite action
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              word.word,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (word.isLearned) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (word.phonetic.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            word.phonetic,
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black45,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      word.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: word.isFavorite ? AppColors.favorite : (isDark ? Colors.white38 : Colors.black38),
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ref.read(wordControllerProvider.notifier).toggleFavorite(word);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Meaning description
              Text(
                word.meaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (word.kannadaMeaning.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ಕನ್ನಡ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        word.kannadaMeaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (word.example.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    '"${word.example}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Bottom Row: Part of Speech, Category & Difficulty Badge
              Row(
                children: [
                  PartOfSpeechChip(partOfSpeech: word.partOfSpeech),
                  const SizedBox(width: 8),
                  DifficultyBadge(difficulty: word.difficulty),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#${word.category}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
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
    );
  }
}
