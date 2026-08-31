import '../entities/word.dart';
import '../repositories/word_repository.dart';

/// UseCase to retrieve words with optional filter criteria
class GetWordsUseCase {
  final WordRepository repository;

  const GetWordsUseCase(this.repository);

  Future<List<Word>> call({
    String? difficulty,
    String? category,
    bool? onlyFavorites,
    bool? onlyLearned,
  }) {
    return repository.getWords(
      difficulty: difficulty,
      category: category,
      onlyFavorites: onlyFavorites,
      onlyLearned: onlyLearned,
    );
  }
}
