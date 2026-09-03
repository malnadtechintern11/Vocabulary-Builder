import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/database_tables.dart';
import '../../../../core/widgets/audio_pronounce_button.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../quiz/domain/entities/quiz_question.dart';
import '../../../quiz/presentation/providers/quiz_controller.dart';
import '../providers/learning_streak_provider.dart';

/// Smart revision view displaying words frequently answered incorrectly with direct quiz practice
class SmartRevisionView extends ConsumerWidget {
  final List<Map<String, dynamic>> weakWords;

  const SmartRevisionView({super.key, required this.weakWords});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (weakWords.isEmpty) {
      return EmptyStateView(
        icon: Icons.check_circle_outline_rounded,
        title: 'No Weak Words! 🎉',
        description: 'You have answered your vocabulary quizzes with high accuracy! Continue taking quizzes to keep tracking words that need practice.',
        actionLabel: 'Take a Quiz',
        actionIcon: Icons.quiz_rounded,
        onActionPressed: () => context.go(RoutePaths.quiz),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Action Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF59E0B),
                const Color(0xFFD97706),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${weakWords.length} Words to Review',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Focus on Your Weak Spots',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'These words were answered incorrectly in quizzes. Practice them now to build long-term memory.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(quizControllerProvider.notifier).startQuiz(
                          type: QuizType.weakWordsPractice,
                          questionCount: weakWords.length > 10 ? 10 : weakWords.length,
                        );
                    context.push(RoutePaths.quizActive);
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text('Practice Weak Words Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFB45309),
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Weak Words List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: weakWords.length,
          itemBuilder: (context, index) {
            final item = weakWords[index];
            final wordId = item[DatabaseTables.colStatsWordId] as int;
            final word = item[DatabaseTables.colStatsWord] as String;
            final incorrect = item[DatabaseTables.colStatsTimesIncorrect] as int;
            final phonetic = item[DatabaseTables.colPhonetic] as String? ?? '';
            final meaning = item[DatabaseTables.colMeaning] as String? ?? '';
            final knMeaning = item[DatabaseTables.colKannadaMeaning] as String? ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
                        child: Row(
                          children: [
                            Text(
                              word,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            if (phonetic.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                phonetic,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.incorrectRed.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.incorrectRed.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 12, color: AppColors.incorrectRed),
                            const SizedBox(width: 4),
                            Text(
                              '$incorrect missed',
                              style: const TextStyle(
                                color: AppColors.incorrectRed,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meaning,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.4,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                    ),
                  ),
                  if (knMeaning.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.secondary.withValues(alpha: 0.4) : const Color(0xFF86EFAC),
                        ),
                      ),
                      child: Text(
                        'ಕನ್ನಡ: $knMeaning',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryDark,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AudioPronounceButton(
                        id: 'weak_word_$wordId',
                        text: word,
                        tooltip: 'Pronounce "$word"',
                        iconSize: 20,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await ref.read(learningAnalyticsServiceProvider).resolveWeakWord(wordId);
                          ref.invalidate(weakWordsProvider);
                        },
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Mark Resolved'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.success,
                          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
