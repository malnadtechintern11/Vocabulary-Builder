import '../entities/quiz_result.dart';
import '../repositories/quiz_repository.dart';

/// UseCase to persist completed quiz attempts
class SaveQuizResultUseCase {
  final QuizRepository repository;

  const SaveQuizResultUseCase(this.repository);

  Future<QuizResult> call(QuizResult result) {
    return repository.saveQuizResult(result);
  }
}
