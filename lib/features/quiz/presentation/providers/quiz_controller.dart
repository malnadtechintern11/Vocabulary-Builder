import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/quiz_local_data_source.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/quiz_result.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/generate_quiz_usecase.dart';
import '../../domain/usecases/get_quiz_history_usecase.dart';
import '../../domain/usecases/get_quiz_statistics_usecase.dart';
import '../../domain/usecases/save_quiz_result_usecase.dart';

// --- Quiz DI Providers ---

final quizLocalDataSourceProvider = Provider<QuizLocalDataSource>((ref) {
  return QuizLocalDataSourceImpl();
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final dataSource = ref.watch(quizLocalDataSourceProvider);
  return QuizRepositoryImpl(localDataSource: dataSource);
});

final generateQuizUseCaseProvider = Provider<GenerateQuizUseCase>((ref) {
  return GenerateQuizUseCase(ref.watch(quizRepositoryProvider));
});

final saveQuizResultUseCaseProvider = Provider<SaveQuizResultUseCase>((ref) {
  return SaveQuizResultUseCase(ref.watch(quizRepositoryProvider));
});

final getQuizHistoryUseCaseProvider = Provider<GetQuizHistoryUseCase>((ref) {
  return GetQuizHistoryUseCase(ref.watch(quizRepositoryProvider));
});

final getQuizStatisticsUseCaseProvider = Provider<GetQuizStatisticsUseCase>((ref) {
  return GetQuizStatisticsUseCase(ref.watch(quizRepositoryProvider));
});

// --- Active Quiz Session State ---

class QuizSessionState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedOptionIndex;
  final bool isAnswerSubmitted;
  final int correctAnswersCount;
  final bool isCompleted;
  final QuizResult? finalResult;
  final QuizType quizType;

  const QuizSessionState({
    required this.questions,
    this.currentIndex = 0,
    this.selectedOptionIndex,
    this.isAnswerSubmitted = false,
    this.correctAnswersCount = 0,
    this.isCompleted = false,
    this.finalResult,
    this.quizType = QuizType.meaningMatch,
  });

  QuizQuestion get currentQuestion => questions[currentIndex];
  bool get hasMoreQuestions => currentIndex < questions.length - 1;
  int get totalQuestions => questions.length;
  double get currentProgress => totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;

  QuizSessionState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedOptionIndex,
    bool? isAnswerSubmitted,
    int? correctAnswersCount,
    bool? isCompleted,
    QuizResult? finalResult,
    QuizType? quizType,
  }) {
    return QuizSessionState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOptionIndex: selectedOptionIndex,
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
      isCompleted: isCompleted ?? this.isCompleted,
      finalResult: finalResult ?? this.finalResult,
      quizType: quizType ?? this.quizType,
    );
  }
}

class QuizController extends StateNotifier<AsyncValue<QuizSessionState?>> {
  final Ref _ref;

  QuizController(this._ref) : super(const AsyncValue.data(null));

  Future<void> startQuiz({
    required QuizType type,
    String? difficulty,
    int questionCount = 10,
  }) async {
    state = const AsyncValue.loading();
    try {
      final generateQuizUseCase = _ref.read(generateQuizUseCaseProvider);
      final questions = await generateQuizUseCase(
        type: type,
        difficulty: difficulty,
        count: questionCount,
      );

      if (questions.isEmpty) {
        state = AsyncValue.error(
          'Not enough vocabulary words found for this level. Try selecting "All Levels".',
          StackTrace.current,
        );
        return;
      }

      state = AsyncValue.data(
        QuizSessionState(
          questions: questions,
          quizType: type,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void selectOption(int optionIndex) {
    final current = state.value;
    if (current == null || current.isAnswerSubmitted) return;

    state = AsyncValue.data(
      current.copyWith(selectedOptionIndex: optionIndex),
    );
  }

  void submitAnswer() {
    final current = state.value;
    if (current == null || current.selectedOptionIndex == null || current.isAnswerSubmitted) return;

    final isCorrect = current.selectedOptionIndex == current.currentQuestion.correctOptionIndex;
    final updatedCorrectCount = isCorrect ? current.correctAnswersCount + 1 : current.correctAnswersCount;

    state = AsyncValue.data(
      current.copyWith(
        isAnswerSubmitted: true,
        correctAnswersCount: updatedCorrectCount,
      ),
    );
  }

  Future<void> nextQuestion() async {
    final current = state.value;
    if (current == null) return;

    if (current.hasMoreQuestions) {
      state = AsyncValue.data(
        current.copyWith(
          currentIndex: current.currentIndex + 1,
          selectedOptionIndex: null,
          isAnswerSubmitted: false,
        ),
      );
    } else {
      // Quiz finished, save results
      await _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final current = state.value;
    if (current == null) return;

    final total = current.totalQuestions;
    final correct = current.correctAnswersCount;
    final percentage = total > 0 ? (correct / total) * 100.0 : 0.0;

    final result = QuizResult(
      id: 0,
      quizType: current.quizType,
      totalQuestions: total,
      correctAnswers: correct,
      scorePercentage: double.parse(percentage.toStringAsFixed(1)),
      completedAt: DateTime.now(),
    );

    try {
      final saveUseCase = _ref.read(saveQuizResultUseCaseProvider);
      final savedResult = await saveUseCase(result);

      // Invalidate history provider to update progress dashboard
      _ref.invalidate(quizHistoryProvider);
      _ref.invalidate(quizStatsProvider);

      state = AsyncValue.data(
        current.copyWith(
          isCompleted: true,
          finalResult: savedResult,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void resetQuiz() {
    state = const AsyncValue.data(null);
  }
}

final quizControllerProvider = StateNotifierProvider<QuizController, AsyncValue<QuizSessionState?>>((ref) {
  return QuizController(ref);
});

// --- Quiz History & Stats Providers ---

final quizHistoryProvider = FutureProvider<List<QuizResult>>((ref) async {
  final getHistoryUseCase = ref.watch(getQuizHistoryUseCaseProvider);
  return getHistoryUseCase();
});

final quizStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final getStatsUseCase = ref.watch(getQuizStatisticsUseCaseProvider);
  return getStatsUseCase();
});
