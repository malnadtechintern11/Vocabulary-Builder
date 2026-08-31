import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/quiz_result.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_local_data_source.dart';
import '../models/quiz_result_model.dart';

/// Implementation of domain QuizRepository
class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDataSource localDataSource;

  QuizRepositoryImpl({required this.localDataSource});

  @override
  Future<List<QuizQuestion>> generateQuiz({
    required QuizType type,
    String? difficulty,
    int count = 10,
  }) async {
    return localDataSource.generateQuestions(
      type: type,
      difficulty: difficulty,
      count: count,
    );
  }

  @override
  Future<QuizResult> saveQuizResult(QuizResult result) async {
    final model = QuizResultModel.fromEntity(result);
    return localDataSource.saveQuizResult(model);
  }

  @override
  Future<List<QuizResult>> getQuizHistory() async {
    return localDataSource.getQuizHistory();
  }

  @override
  Future<Map<String, dynamic>> getQuizStatistics() async {
    return localDataSource.getQuizStatistics();
  }
}
