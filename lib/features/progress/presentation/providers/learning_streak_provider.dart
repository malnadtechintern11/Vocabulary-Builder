import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/learning_analytics_service.dart';
import '../../../quiz/presentation/providers/quiz_controller.dart';

/// Provider for user streak information
final streakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  final service = ref.watch(learningAnalyticsServiceProvider);
  return service.getStreakInfo();
});

/// Provider for user's selected daily learning goal target
final dailyGoalTargetProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(learningAnalyticsServiceProvider);
  return service.getDailyGoalTarget();
});

/// Provider for words learned today towards daily goal
final todayWordsLearnedProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(learningAnalyticsServiceProvider);
  return service.getTodayWordsLearnedCount();
});

/// Provider for weak words requiring revision
final weakWordsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(learningAnalyticsServiceProvider);
  return service.getWeakWords();
});

/// Provider for achievements and badges
final achievementsProvider = FutureProvider<List<AchievementBadge>>((ref) async {
  final service = ref.watch(learningAnalyticsServiceProvider);
  return service.getAchievements();
});

/// Provider for 7-day weekly activity chart data
final weeklyActivityProvider = FutureProvider<List<DailyActivityItem>>((ref) async {
  final service = ref.watch(learningAnalyticsServiceProvider);
  return service.getWeeklyActivity();
});

/// Provider for vocabulary category strength analytics
final categoryAnalyticsProvider = FutureProvider<CategoryAnalytics>((ref) async {
  final service = ref.watch(learningAnalyticsServiceProvider);
  return service.getCategoryAnalytics();
});

/// Provider for personalized learning recommendations
final recommendationsProvider = FutureProvider<List<LearningRecommendation>>((ref) async {
  final service = ref.watch(learningAnalyticsServiceProvider);
  return service.getRecommendations();
});
