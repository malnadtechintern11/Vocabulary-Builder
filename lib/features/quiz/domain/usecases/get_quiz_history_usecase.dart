import '../entities/quiz_result.dart';
import '../repositories/quiz_repository.dart';

/// UseCase to retrieve user's past quiz history
class GetQuizHistoryUseCase {
  final QuizRepository repository;

  const GetQuizHistoryUseCase(this.repository);

  Future<List<QuizResult>> call() {
    return repository.getQuizHistory();
  }
}
