import '../entities/word.dart';
import '../repositories/word_repository.dart';

/// UseCase to perform query search over vocabulary
class SearchWordsUseCase {
  final WordRepository repository;

  const SearchWordsUseCase(this.repository);

  Future<List<Word>> call(String query) {
    if (query.trim().isEmpty) {
      return repository.getWords();
    }
    return repository.searchWords(query.trim());
  }
}
