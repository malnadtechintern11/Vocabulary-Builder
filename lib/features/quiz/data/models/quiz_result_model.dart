import 'package:vocabulary_builder/core/database/database_tables.dart';
import 'package:vocabulary_builder/features/quiz/domain/entities/quiz_question.dart';
import 'package:vocabulary_builder/features/quiz/domain/entities/quiz_result.dart';

/// Data Model for QuizResult mapping to SQLite
class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.id,
    required super.quizType,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.scorePercentage,
    required super.completedAt,
  });

  factory QuizResultModel.fromDbMap(Map<String, dynamic> map) {
    QuizType parseQuizType(String typeStr) {
      return QuizType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => QuizType.meaningMatch,
      );
    }

    return QuizResultModel(
      id: map[DatabaseTables.colQuizId] as int,
      quizType: parseQuizType(map[DatabaseTables.colQuizType] as String),
      totalQuestions: map[DatabaseTables.colTotalQuestions] as int,
      correctAnswers: map[DatabaseTables.colCorrectAnswers] as int,
      scorePercentage: (map[DatabaseTables.colScorePercentage] as num).toDouble(),
      completedAt: DateTime.parse(map[DatabaseTables.colCompletedAt] as String),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      DatabaseTables.colQuizType: quizType.name,
      DatabaseTables.colTotalQuestions: totalQuestions,
      DatabaseTables.colCorrectAnswers: correctAnswers,
      DatabaseTables.colScorePercentage: scorePercentage,
      DatabaseTables.colCompletedAt: completedAt.toIso8601String(),
    };
  }

  factory QuizResultModel.fromEntity(QuizResult entity) {
    return QuizResultModel(
      id: entity.id,
      quizType: entity.quizType,
      totalQuestions: entity.totalQuestions,
      correctAnswers: entity.correctAnswers,
      scorePercentage: entity.scorePercentage,
      completedAt: entity.completedAt,
    );
  }
}
