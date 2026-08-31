import '../repositories/word_repository.dart';

/// UseCase to get aggregated learning counts
class GetWordStatisticsUseCase {
  final WordRepository repository;

  const GetWordStatisticsUseCase(this.repository);

  Future<Map<String, int>> call() {
    return repository.getWordStatistics();
  }
}
