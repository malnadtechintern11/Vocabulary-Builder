import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabulary_builder/app/theme/app_colors.dart';
import 'package:vocabulary_builder/core/widgets/error_state_view.dart';
import 'package:vocabulary_builder/core/widgets/loading_view.dart';
import 'package:vocabulary_builder/features/quiz/domain/entities/quiz_question.dart';
import 'package:vocabulary_builder/features/quiz/presentation/providers/quiz_controller.dart';
import '../providers/progress_provider.dart';

/// Screen displaying user learning progress, mastery metrics, and recent quiz history
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(progressMetricsProvider);
    final historyAsync = ref.watch(quizHistoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress & Stats'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(progressMetricsProvider);
          ref.invalidate(quizHistoryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Learning Metrics Grid
              metricsAsync.when(
                data: (metrics) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Overview Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              AppColors.primaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Vocabulary Mastery',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getMasteryTitle(metrics.wordMasteryPercentage),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: metrics.wordMasteryPercentage / 100.0,
                                minHeight: 10,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${metrics.masteredWords} of ${metrics.totalWords} words mastered (${metrics.wordMasteryPercentage.toStringAsFixed(0)}%)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Metric Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              title: 'Mastered',
                              value: '${metrics.masteredWords}',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              title: 'Saved Words',
                              value: '${metrics.favoriteWords}',
                              icon: Icons.favorite_border_rounded,
                              color: AppColors.favorite,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              title: 'Quizzes Taken',
                              value: '${metrics.totalQuizzesTaken}',
                              icon: Icons.quiz_outlined,
                              color: AppColors.primary,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              context,
                              title: 'Average Score',
                              value: '${metrics.averageQuizScore.toStringAsFixed(0)}%',
                              icon: Icons.analytics_outlined,
                              color: AppColors.secondary,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const LoadingView(message: 'Calculating metrics...'),
                error: (err, _) => ErrorStateView(message: err.toString()),
              ),
              const SizedBox(height: 32),

              // Recent Quiz History Section
              Text(
                'Recent Quiz Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              historyAsync.when(
                data: (history) {
                  if (history.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_edu_rounded,
                            size: 40,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Quizzes Taken Yet',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete quizzes to build up your learning history and track performance trends.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                        ),
                        child: Material(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              width: 1.2,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: item.isPassed
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : AppColors.incorrectRed.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.isPassed ? Icons.check_rounded : Icons.close_rounded,
                                color: item.isPassed ? AppColors.success : AppColors.incorrectRed,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              _getQuizTypeTitle(item.quizType),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                            ),
                            subtitle: Text(
                              '${item.correctAnswers}/${item.totalQuestions} correct • ${_formatDate(item.completedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                              decoration: BoxDecoration(
                                color: item.isPassed
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : AppColors.incorrectRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.scorePercentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: item.isPassed ? AppColors.success : AppColors.incorrectRed,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (err, _) => ErrorStateView(message: err.toString()),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _getMasteryTitle(double percentage) {
    if (percentage >= 80) return 'Vocabulary Master 🎓';
    if (percentage >= 50) return 'Proficient Scholar 📖';
    if (percentage >= 20) return 'Active Explorer 🔍';
    return 'Novice Learner 🌱';
  }

  String _getQuizTypeTitle(QuizType type) {
    switch (type) {
      case QuizType.meaningMatch:
        return 'Definition Match';
      case QuizType.synonymMatch:
        return 'Synonym Finder';
      case QuizType.antonymMatch:
        return 'Antonym Challenge';
      case QuizType.fillInTheBlank:
        return 'Fill in the Blank';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
