import '../entities/quiz_question.dart';
import '../entities/quiz_result.dart';

/// Repository interface contract for Quiz operations
abstract class QuizRepository {
  /// Generate a dynamic list of randomized questions based on the local vocabulary
  Future<List<QuizQuestion>> generateQuiz({
    required QuizType type,
    String? difficulty,
    int count = 10,
  });

  /// Save a completed quiz result to database
  Future<QuizResult> saveQuizResult(QuizResult result);

  /// Fetch past quiz results
  Future<List<QuizResult>> getQuizHistory();

  /// Fetch overall quiz statistics (total taken, total correct, average score)
  Future<Map<String, dynamic>> getQuizStatistics();
}
