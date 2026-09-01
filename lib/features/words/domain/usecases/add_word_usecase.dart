import '../entities/word.dart';
import '../repositories/word_repository.dart';

/// Use case to insert a new custom vocabulary word
class AddWordUseCase {
  final WordRepository repository;

  AddWordUseCase(this.repository);

  Future<Word> call(Word word) async {
    return repository.addWord(word);
  }
}
