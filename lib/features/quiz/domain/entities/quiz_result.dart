import 'quiz_question.dart';

/// Domain entity representing a completed quiz attempt result
class QuizResult {
  final int id;
  final QuizType quizType;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final DateTime completedAt;

  const QuizResult({
    required this.id,
    required this.quizType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.completedAt,
  });

  bool get isPassed => scorePercentage >= 70.0;
}
