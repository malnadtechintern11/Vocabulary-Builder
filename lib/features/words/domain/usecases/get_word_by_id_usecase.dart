import '../entities/word.dart';
import '../repositories/word_repository.dart';

/// UseCase to get word detail by ID
class GetWordByIdUseCase {
  final WordRepository repository;

  const GetWordByIdUseCase(this.repository);

  Future<Word> call(int id) {
    return repository.getWordById(id);
  }
}
