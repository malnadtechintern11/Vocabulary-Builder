import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../../../core/widgets/audio_pronounce_button.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../providers/quiz_controller.dart';
import '../widgets/quiz_option_card.dart';

/// Screen managing active quiz question presentation and answer submission
class ActiveQuizScreen extends ConsumerWidget {
  const ActiveQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizStateAsync = ref.watch(quizControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Quit Quiz?'),
            content: const Text('Are you sure you want to exit? Your current quiz progress will not be saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Quit'),
              ),
            ],
          ),
        );
        if (shouldExit == true && context.mounted) {
          ref.read(quizControllerProvider.notifier).resetQuiz();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz in Progress'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Quit Quiz?'),
                  content: const Text('Are you sure you want to exit? Current progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Quit'),
                    ),
                  ],
                ),
              );
              if (shouldExit == true && context.mounted) {
                ref.read(quizControllerProvider.notifier).resetQuiz();
                context.pop();
              }
            },
          ),
        ),
        body: quizStateAsync.when(
          data: (state) {
            if (state == null) {
              return const Center(child: Text('No active quiz'));
            }

            if (state.isCompleted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(RoutePaths.quizResult);
              });
              return const LoadingView(message: 'Saving your results...');
            }

            final q = state.currentQuestion;
            final currentNum = state.currentIndex + 1;
            final total = state.totalQuestions;
            final letters = ['A', 'B', 'C', 'D'];

            return Column(
              children: [
                // Linear Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFC7D2FE),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Question $currentNum of $total',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF312E81),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Score: ${state.correctAnswersCount}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF14532D),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AnimatedProgressBar(
                        value: state.currentProgress,
                        height: 8,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Question & Options Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      q.prompt,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AudioPronounceButton(
                                    id: 'quiz_q_${currentNum}_prompt',
                                    text: q.contextSnippet != null ? '${q.prompt}. ${q.contextSnippet}' : q.prompt,
                                    tooltip: 'Listen to question',
                                    iconSize: 22,
                                  ),
                                ],
                              ),
                              if (q.contextSnippet != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          q.contextSnippet!,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      AudioPronounceButton(
                                        id: 'quiz_q_${currentNum}_snippet',
                                        text: q.contextSnippet!,
                                        tooltip: 'Listen to contextual sentence',
                                        iconSize: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Options List
                        ...List.generate(q.options.length, (optIndex) {
                          final optionText = q.options[optIndex];
                          final isSelected = state.selectedOptionIndex == optIndex;
                          final isCorrect = optIndex == q.correctOptionIndex;

                          return QuizOptionCard(
                            text: optionText,
                            optionLetter: letters[optIndex % letters.length],
                            isSelected: isSelected,
                            isAnswerSubmitted: state.isAnswerSubmitted,
                            isCorrectOption: isCorrect,
                            onTap: () {
                              ref.read(quizControllerProvider.notifier).selectOption(optIndex);
                            },
                          );
                        }),

                        // Explanation Callout (after submission)
                        if (state.isAnswerSubmitted) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: state.selectedOptionIndex == q.correctOptionIndex
                                  ? AppColors.correctGreen.withValues(alpha: 0.12)
                                  : AppColors.incorrectRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: state.selectedOptionIndex == q.correctOptionIndex
                                    ? AppColors.correctGreen.withValues(alpha: 0.45)
                                    : AppColors.incorrectRed.withValues(alpha: 0.45),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      state.selectedOptionIndex == q.correctOptionIndex
                                          ? Icons.check_circle_rounded
                                          : Icons.info_outline_rounded,
                                      size: 20,
                                      color: state.selectedOptionIndex == q.correctOptionIndex
                                          ? AppColors.correctGreen
                                          : AppColors.incorrectRed,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        state.selectedOptionIndex == q.correctOptionIndex
                                            ? 'Correct!'
                                            : 'Explanation',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: state.selectedOptionIndex == q.correctOptionIndex
                                              ? AppColors.correctGreen
                                              : AppColors.incorrectRed,
                                        ),
                                      ),
                                    ),
                                    AudioPronounceButton(
                                      id: 'quiz_q_${currentNum}_explanation',
                                      text: q.explanation,
                                      tooltip: 'Listen to explanation',
                                      iconSize: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  q.explanation,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: !state.isAnswerSubmitted
                          ? ElevatedButton(
                              onPressed: state.selectedOptionIndex != null
                                  ? () {
                                      ref.read(quizControllerProvider.notifier).submitAnswer();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                elevation: state.selectedOptionIndex != null ? 2 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Check Answer',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                ref.read(quizControllerProvider.notifier).nextQuestion();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                state.hasMoreQuestions ? 'Next Question →' : 'Finish Quiz 🎉',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingView(message: 'Generating quiz questions...'),
          error: (err, _) => ErrorStateView(
            message: err.toString(),
            onRetry: () => context.pop(),
          ),
        ),
      ),
    );
  }
}
