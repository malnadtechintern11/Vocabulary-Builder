import '../entities/word.dart';
import '../repositories/word_repository.dart';

/// UseCase to toggle learned/mastered status
class ToggleLearnedUseCase {
  final WordRepository repository;

  const ToggleLearnedUseCase(this.repository);

  Future<Word> call(int id, bool isLearned) {
    return repository.toggleLearned(id, isLearned);
  }
}
