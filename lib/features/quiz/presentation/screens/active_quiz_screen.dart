import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
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
                          Text(
                            'Question $currentNum of $total',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          Text(
                            'Score: ${state.correctAnswersCount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: state.currentProgress,
                          minHeight: 8,
                          backgroundColor: isDark ? Colors.white12 : Colors.black12,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
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
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.prompt,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                              if (q.contextSnippet != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black26 : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    q.contextSnippet!,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                                    ),
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
                                  ? AppColors.correctGreen.withValues(alpha: 0.1)
                                  : AppColors.incorrectRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: state.selectedOptionIndex == q.correctOptionIndex
                                    ? AppColors.correctGreen.withValues(alpha: 0.4)
                                    : AppColors.incorrectRed.withValues(alpha: 0.4),
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
                                      size: 18,
                                      color: state.selectedOptionIndex == q.correctOptionIndex
                                          ? AppColors.correctGreen
                                          : AppColors.incorrectRed,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      state.selectedOptionIndex == q.correctOptionIndex
                                          ? 'Correct!'
                                          : 'Explanation',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: state.selectedOptionIndex == q.correctOptionIndex
                                            ? AppColors.correctGreen
                                            : AppColors.incorrectRed,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  q.explanation,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
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
                      height: 50,
                      child: !state.isAnswerSubmitted
                          ? ElevatedButton(
                              onPressed: state.selectedOptionIndex != null
                                  ? () {
                                      ref.read(quizControllerProvider.notifier).submitAnswer();
                                    }
                                  : null,
                              child: const Text(
                                'Check Answer',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                ref.read(quizControllerProvider.notifier).nextQuestion();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child: Text(
                                state.hasMoreQuestions ? 'Next Question →' : 'Finish Quiz 🎉',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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
