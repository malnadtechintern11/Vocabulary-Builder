import '../entities/word.dart';
import '../repositories/word_repository.dart';

/// UseCase to toggle favorite status
class ToggleFavoriteUseCase {
  final WordRepository repository;

  const ToggleFavoriteUseCase(this.repository);

  Future<Word> call(int id, bool isFavorite) {
    return repository.toggleFavorite(id, isFavorite);
  }
}
