import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/database/database_tables.dart';
import 'package:vocabulary_builder/features/quiz/data/models/quiz_result_model.dart';
import 'package:vocabulary_builder/features/quiz/domain/entities/quiz_question.dart';

void main() {
  group('QuizResultModel', () {
    test('should correctly parse from and convert to DB map', () {
      final now = DateTime.now();
      final dbMap = {
        DatabaseTables.colQuizId: 1,
        DatabaseTables.colQuizType: 'meaningMatch',
        DatabaseTables.colTotalQuestions: 10,
        DatabaseTables.colCorrectAnswers: 8,
        DatabaseTables.colScorePercentage: 80.0,
        DatabaseTables.colCompletedAt: now.toIso8601String(),
      };

      final model = QuizResultModel.fromDbMap(dbMap);

      expect(model.id, 1);
      expect(model.quizType, QuizType.meaningMatch);
      expect(model.totalQuestions, 10);
      expect(model.correctAnswers, 8);
      expect(model.scorePercentage, 80.0);
      expect(model.isPassed, isTrue);

      final serialized = model.toDbMap();
      expect(serialized[DatabaseTables.colQuizType], 'meaningMatch');
      expect(serialized[DatabaseTables.colScorePercentage], 80.0);
    });

    test('isPassed should return true if score is 70% or higher', () {
      final passed = QuizResultModel(
        id: 1,
        quizType: QuizType.synonymMatch,
        totalQuestions: 10,
        correctAnswers: 7,
        scorePercentage: 70.0,
        completedAt: DateTime.now(),
      );

      final failed = QuizResultModel(
        id: 2,
        quizType: QuizType.synonymMatch,
        totalQuestions: 10,
        correctAnswers: 6,
        scorePercentage: 60.0,
        completedAt: DateTime.now(),
      );

      expect(passed.isPassed, isTrue);
      expect(failed.isPassed, isFalse);
    });
  });
}
