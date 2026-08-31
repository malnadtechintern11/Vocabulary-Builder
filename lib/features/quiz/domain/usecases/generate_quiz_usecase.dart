import '../entities/quiz_question.dart';
import '../repositories/quiz_repository.dart';

/// UseCase to generate dynamic quiz questions
class GenerateQuizUseCase {
  final QuizRepository repository;

  const GenerateQuizUseCase(this.repository);

  Future<List<QuizQuestion>> call({
    required QuizType type,
    String? difficulty,
    int count = 10,
  }) {
    return repository.generateQuiz(
      type: type,
      difficulty: difficulty,
      count: count,
    );
  }
}
