import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/quiz_controller.dart';

/// Screen summarizing completed quiz score, accuracy, and options to retake or return
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _QuizResultView();
  }
}

class _QuizResultView extends ConsumerWidget {
  const _QuizResultView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider).value;
    final result = quizState?.finalResult;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No result found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.quiz),
                child: const Text('Back to Quizzes'),
              ),
            ],
          ),
        ),
      );
    }

    final isPassed = result.isPassed;
    final percentage = result.scorePercentage;
    final incorrect = result.totalQuestions - result.correctAnswers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Animated Celebration Avatar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPassed
                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                        : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isPassed ? AppColors.success : AppColors.difficultyIntermediate)
                          .withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events_rounded : Icons.psychology_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title & Praise
            Text(
              isPassed ? 'Outstanding Work!' : 'Good Effort!',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 26,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPassed
                  ? 'You demonstrated strong mastery of this vocabulary set.'
                  : 'Practice makes permanent! Review the words and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // Score Card with Animated Percentage Counter
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: percentage),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) {
                      return Text(
                        '${val.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: isPassed ? AppColors.success : AppColors.primary,
                          letterSpacing: -1.5,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overall Accuracy',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBadge(
                          label: 'Total',
                          value: '${result.totalQuestions}',
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatBadge(
                          label: 'Correct',
                          value: '${result.correctAnswers}',
                          color: AppColors.correctGreen,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatBadge(
                          label: 'Incorrect',
                          value: '$incorrect',
                          color: AppColors.incorrectRed,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(quizControllerProvider.notifier).resetQuiz();
                  context.go(RoutePaths.quiz);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Take Another Quiz',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(quizControllerProvider.notifier).resetQuiz();
                  context.go(RoutePaths.words);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text(
                  'Explore Words',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
