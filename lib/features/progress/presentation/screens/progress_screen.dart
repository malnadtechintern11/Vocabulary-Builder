import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/learning_analytics_service.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../quiz/domain/entities/quiz_question.dart';
import '../../../quiz/presentation/providers/quiz_controller.dart';
import '../providers/learning_streak_provider.dart';
import '../providers/progress_provider.dart';
import '../widgets/achievements_view.dart';
import '../widgets/smart_revision_view.dart';
import '../widgets/weekly_activity_chart.dart';

/// Screen displaying user learning progress, daily goals, streak, achievements, weak words, and analytics
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final metricsAsync = ref.watch(progressMetricsProvider);
    final historyAsync = ref.watch(quizHistoryProvider);
    final streakAsync = ref.watch(streakInfoProvider);
    final goalTargetAsync = ref.watch(dailyGoalTargetProvider);
    final todayWordsAsync = ref.watch(todayWordsLearnedProvider);
    final weeklyActivityAsync = ref.watch(weeklyActivityProvider);
    final weakWordsAsync = ref.watch(weakWordsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final categoryAnalyticsAsync = ref.watch(categoryAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub & Progress'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? AppColors.primaryLight : AppColors.primary,
          labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
          tabs: const [
            Tab(text: 'Analytics & Goals'),
            Tab(text: 'Smart Revision'),
            Tab(text: 'Achievements'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(progressMetricsProvider);
          ref.invalidate(quizHistoryProvider);
          ref.invalidate(streakInfoProvider);
          ref.invalidate(dailyGoalTargetProvider);
          ref.invalidate(todayWordsLearnedProvider);
          ref.invalidate(weeklyActivityProvider);
          ref.invalidate(weakWordsProvider);
          ref.invalidate(achievementsProvider);
          ref.invalidate(categoryAnalyticsProvider);
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: ANALYTICS & GOALS
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Streak & Daily Goal Strip
                  _buildDailyGoalAndStreakCard(
                    context,
                    streakAsync: streakAsync,
                    goalTargetAsync: goalTargetAsync,
                    todayWordsAsync: todayWordsAsync,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // 2. Vocabulary Mastery Card
                  metricsAsync.when(
                    data: (metrics) => _buildMasteryCard(context, metrics, isDark),
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                    error: (e, _) => ErrorStateView(message: e.toString()),
                  ),
                  const SizedBox(height: 20),

                  // 3. 4-Metric Grid
                  metricsAsync.maybeWhen(
                    data: (metrics) => _buildMetricsGrid(context, metrics, isDark),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // 4. 7-Day Activity Chart
                  weeklyActivityAsync.when(
                    data: (activities) => WeeklyActivityChart(activities: activities),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // 5. Strong & Weak Categories Intelligence
                  categoryAnalyticsAsync.when(
                    data: (catAnalytics) => _buildCategoryAnalyticsCard(context, catAnalytics, isDark),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // 6. Recent Quiz History
                  Text(
                    'Recent Quiz Sessions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  historyAsync.when(
                    data: (history) => _buildQuizHistoryList(context, history, isDark),
                    loading: () => const LoadingView(message: 'Loading sessions...'),
                    error: (e, _) => ErrorStateView(message: e.toString()),
                  ),
                ],
              ),
            ),

            // TAB 2: SMART REVISION
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: weakWordsAsync.when(
                data: (weakWords) => SmartRevisionView(weakWords: weakWords),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
                error: (e, _) => ErrorStateView(message: e.toString()),
              ),
            ),

            // TAB 3: ACHIEVEMENTS & BADGES
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: achievementsAsync.when(
                data: (badges) => AchievementsView(badges: badges),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
                error: (e, _) => ErrorStateView(message: e.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildDailyGoalAndStreakCard(
    BuildContext context, {
    required AsyncValue<StreakInfo> streakAsync,
    required AsyncValue<int> goalTargetAsync,
    required AsyncValue<int> todayWordsAsync,
    required bool isDark,
  }) {
    final streak = streakAsync.value ?? const StreakInfo(currentStreak: 0, longestStreak: 0, lastActiveDate: '', isActiveToday: false);
    final target = goalTargetAsync.value ?? 10;
    final todayWords = todayWordsAsync.value ?? 0;
    final progressVal = target > 0 ? (todayWords / target).clamp(0.0, 1.0) : 0.0;
    final isGoalMet = todayWords >= target;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          // Streak Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department_rounded, size: 22, color: Color(0xFFEF4444)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${streak.currentStreak} Day Streak',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                      ),
                      Text(
                        streak.longestStreak > 0 ? 'Personal Best: ${streak.longestStreak} days' : 'Study daily to build streak',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: streak.isActiveToday
                      ? AppColors.success.withValues(alpha: isDark ? 0.2 : 0.12)
                      : const Color(0xFFEF4444).withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      streak.isActiveToday ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      size: 13,
                      color: streak.isActiveToday ? AppColors.success : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      streak.isActiveToday ? 'Active Today' : 'Study Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: streak.isActiveToday ? AppColors.success : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Daily Goal Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.track_changes_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Learning Goal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              // Target Selector
              DropdownButton<int>(
                value: target,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down_rounded, size: 20),
                items: const [5, 10, 20, 30].map((val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val words/day', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  );
                }).toList(),
                onChanged: (newTarget) async {
                  if (newTarget != null) {
                    await ref.read(learningAnalyticsServiceProvider).setDailyGoalTarget(newTarget);
                    ref.invalidate(dailyGoalTargetProvider);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Goal Animated Progress Bar
          AnimatedProgressBar(
            value: progressVal,
            height: 8,
            color: isGoalMet ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$todayWords of $target words learned today',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              if (isGoalMet)
                const Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, size: 14, color: Color(0xFFF59E0B)),
                    SizedBox(width: 4),
                    Text(
                      'Goal Completed! 🎉',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.success),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryCard(BuildContext context, ProgressMetrics metrics, bool isDark) {
    final theme = Theme.of(context);
    return Container(
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
          AnimatedProgressBar(
            value: metrics.wordMasteryPercentage / 100.0,
            height: 10,
            color: Colors.white,
            backgroundColor: Colors.white24,
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
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ProgressMetrics metrics, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
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
                title: 'Accuracy',
                value: '${metrics.averageQuizScore.toStringAsFixed(0)}%',
                icon: Icons.track_changes_rounded,
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Quizzes Taken',
                value: '${metrics.totalQuizzesTaken}',
                icon: Icons.quiz_outlined,
                color: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAnalyticsCard(BuildContext context, CategoryAnalytics analytics, bool isDark) {
    if (analytics.categoryStats.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: isDark ? 0.2 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pie_chart_rounded, size: 20, color: AppColors.secondary),
              ),
              const SizedBox(width: 10),
              const Text(
                'Category Strengths & Focus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Strongest & Weakest Category badges
          Row(
            children: [
              if (analytics.strongCategories.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.thumb_up_rounded, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text('Strongest', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          analytics.strongCategories.first.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              if (analytics.weakCategories.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.priority_high_rounded, size: 14, color: Color(0xFFF59E0B)),
                            SizedBox(width: 4),
                            Text('Needs Focus', style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w800, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          analytics.weakCategories.first.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Top Categories progress bars
          ...analytics.categoryStats.take(4).map((cat) {
            final catName = cat['category'] as String;
            final pct = cat['percentage'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        catName[0].toUpperCase() + catName.substring(1),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedProgressBar(
                    value: pct / 100.0,
                    height: 6,
                    color: pct > 60 ? AppColors.success : (pct > 30 ? AppColors.primary : const Color(0xFFF59E0B)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuizHistoryList(BuildContext context, List<dynamic> history, bool isDark) {
    final theme = Theme.of(context);
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_edu_rounded,
                size: 36,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No Quizzes Taken Yet',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Complete quizzes to build up your learning history and track performance trends.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go(RoutePaths.quiz),
              icon: const Icon(Icons.quiz_rounded, size: 16),
              label: const Text('Take a Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
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
                _formatQuizTypeName(item.quizType),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                '${item.correctAnswers}/${item.totalQuestions} correct • ${_formatDate(item.completedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              trailing: Text(
                '${item.scorePercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: item.isPassed ? AppColors.success : AppColors.incorrectRed,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMasteryTitle(double percentage) {
    if (percentage >= 80) return 'Expert';
    if (percentage >= 50) return 'Proficient';
    if (percentage >= 25) return 'Intermediate';
    return 'Novice';
  }

  String _formatQuizTypeName(QuizType type) {
    switch (type) {
      case QuizType.meaningMatch:
        return 'Definition Match';
      case QuizType.synonymMatch:
        return 'Synonym Finder';
      case QuizType.antonymMatch:
        return 'Antonym Challenge';
      case QuizType.fillInTheBlank:
        return 'Fill in the Blank';
      case QuizType.englishToKannada:
        return 'English to Kannada';
      case QuizType.kannadaToEnglish:
        return 'Kannada to English';
      case QuizType.sentenceCompletion:
        return 'Sentence Completion';
      case QuizType.weakWordsPractice:
        return 'Weak Words Practice';
      case QuizType.smartMixed:
        return 'Smart Mixed Quiz';
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
