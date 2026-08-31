import '../repositories/quiz_repository.dart';

/// UseCase to get aggregated quiz statistics
class GetQuizStatisticsUseCase {
  final QuizRepository repository;

  const GetQuizStatisticsUseCase(this.repository);

  Future<Map<String, dynamic>> call() {
    return repository.getQuizStatistics();
  }
}
