import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabulary_builder/features/quiz/presentation/providers/quiz_controller.dart';
import 'package:vocabulary_builder/features/words/presentation/providers/words_provider.dart';

/// Aggregated user learning and quiz progress metrics
class ProgressMetrics {
  final int totalWords;
  final int masteredWords;
  final int favoriteWords;
  final int totalQuizzesTaken;
  final double averageQuizScore;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;

  const ProgressMetrics({
    required this.totalWords,
    required this.masteredWords,
    required this.favoriteWords,
    required this.totalQuizzesTaken,
    required this.averageQuizScore,
    required this.totalQuestionsAnswered,
    required this.totalCorrectAnswers,
  });

  double get wordMasteryPercentage => totalWords > 0 ? (masteredWords / totalWords) * 100.0 : 0.0;
}

final progressMetricsProvider = FutureProvider<ProgressMetrics>((ref) async {
  final wordStatsUseCase = ref.watch(getWordStatisticsUseCaseProvider);
  final wordStats = await wordStatsUseCase();

  final quizStatsUseCase = ref.watch(getQuizStatisticsUseCaseProvider);
  final quizStats = await quizStatsUseCase();

  return ProgressMetrics(
    totalWords: wordStats['total'] ?? 0,
    masteredWords: wordStats['learned'] ?? 0,
    favoriteWords: wordStats['favorites'] ?? 0,
    totalQuizzesTaken: quizStats['totalQuizzes'] ?? 0,
    averageQuizScore: (quizStats['averageScore'] as num?)?.toDouble() ?? 0.0,
    totalQuestionsAnswered: quizStats['totalQuestionsAnswered'] ?? 0,
    totalCorrectAnswers: quizStats['totalCorrectAnswers'] ?? 0,
  );
});
