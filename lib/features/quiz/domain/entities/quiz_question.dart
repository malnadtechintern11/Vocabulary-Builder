enum QuizType {
  meaningMatch,
  synonymMatch,
  antonymMatch,
  fillInTheBlank,
}

/// Domain entity representing a single quiz question
class QuizQuestion {
  final String id;
  final String prompt;
  final String? contextSnippet;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final QuizType type;
  final int targetWordId;
  final String targetWord;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    this.contextSnippet,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.type,
    required this.targetWordId,
    required this.targetWord,
  });

  String get correctAnswer => options[correctOptionIndex];
}
