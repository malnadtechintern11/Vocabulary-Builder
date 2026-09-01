import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vocabulary_builder/features/quiz/domain/entities/quiz_question.dart';
import 'package:vocabulary_builder/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:vocabulary_builder/features/quiz/domain/usecases/generate_quiz_usecase.dart';
import 'package:vocabulary_builder/features/words/domain/entities/word.dart';
import 'package:vocabulary_builder/features/words/domain/repositories/word_repository.dart';
import 'package:vocabulary_builder/features/words/domain/usecases/add_word_usecase.dart';
import 'package:vocabulary_builder/features/words/domain/usecases/get_words_usecase.dart';
import 'package:vocabulary_builder/features/words/domain/usecases/search_words_usecase.dart';
import 'package:vocabulary_builder/features/words/domain/usecases/toggle_favorite_usecase.dart';

class MockWordRepository extends Mock implements WordRepository {}
class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late MockWordRepository mockWordRepository;
  late MockQuizRepository mockQuizRepository;

  setUp(() {
    mockWordRepository = MockWordRepository();
    mockQuizRepository = MockQuizRepository();
  });

  const sampleWord = Word(
    id: 1,
    word: 'Serendipity',
    phonetic: '/ˌser.ənˈdɪp.ə.ti/',
    partOfSpeech: 'noun',
    meaning: 'Good fortune by chance',
    kannadaMeaning: 'ಆಕಸ್ಮಿಕ ಲಾಭ / ಅನಿರೀಕ್ಷಿತ ಅದೃಷ್ಟ',
    example: 'Pure serendipity.',
    synonyms: ['fortune', 'chance'],
    antonyms: ['misfortune'],
    difficulty: 'advanced',
    category: 'literature',
    isFavorite: false,
    isLearned: false,
  );

  group('Word UseCases', () {
    test('GetWordsUseCase forwards filter parameters to repository', () async {
      final useCase = GetWordsUseCase(mockWordRepository);
      when(() => mockWordRepository.getWords(
            difficulty: any(named: 'difficulty'),
            category: any(named: 'category'),
            onlyFavorites: any(named: 'onlyFavorites'),
            onlyLearned: any(named: 'onlyLearned'),
          )).thenAnswer((_) async => [sampleWord]);

      final result = await useCase(difficulty: 'advanced', onlyFavorites: true);

      expect(result.length, 1);
      expect(result.first.word, 'Serendipity');
      verify(() => mockWordRepository.getWords(
            difficulty: 'advanced',
            category: null,
            onlyFavorites: true,
            onlyLearned: null,
          )).called(1);
    });

    test('SearchWordsUseCase calls getWords when query is empty, otherwise searchWords', () async {
      final useCase = SearchWordsUseCase(mockWordRepository);
      when(() => mockWordRepository.getWords()).thenAnswer((_) async => [sampleWord]);
      when(() => mockWordRepository.searchWords('seren')).thenAnswer((_) async => [sampleWord]);

      final emptyResult = await useCase('');
      expect(emptyResult.length, 1);
      verify(() => mockWordRepository.getWords()).called(1);

      final searchResult = await useCase('seren');
      expect(searchResult.length, 1);
      verify(() => mockWordRepository.searchWords('seren')).called(1);
    });

    test('ToggleFavoriteUseCase toggles favorite flag', () async {
      final useCase = ToggleFavoriteUseCase(mockWordRepository);
      final updatedWord = sampleWord.copyWith(isFavorite: true);

      when(() => mockWordRepository.toggleFavorite(1, true))
          .thenAnswer((_) async => updatedWord);

      final result = await useCase(1, true);
      expect(result.isFavorite, isTrue);
      verify(() => mockWordRepository.toggleFavorite(1, true)).called(1);
    });

    test('AddWordUseCase adds word to repository', () async {
      final useCase = AddWordUseCase(mockWordRepository);
      when(() => mockWordRepository.addWord(sampleWord))
          .thenAnswer((_) async => sampleWord);

      final result = await useCase(sampleWord);
      expect(result.word, 'Serendipity');
      verify(() => mockWordRepository.addWord(sampleWord)).called(1);
    });
  });

  group('Quiz UseCases', () {
    test('GenerateQuizUseCase generates dynamic questions', () async {
      final useCase = GenerateQuizUseCase(mockQuizRepository);
      const question = QuizQuestion(
        id: 'q1',
        prompt: 'What is serendipity?',
        options: ['Chance', 'Plan', 'Hate', 'Fear'],
        correctOptionIndex: 0,
        explanation: 'Serendipity is chance.',
        type: QuizType.meaningMatch,
        targetWordId: 1,
        targetWord: 'Serendipity',
      );

      when(() => mockQuizRepository.generateQuiz(
            type: QuizType.meaningMatch,
            difficulty: 'advanced',
            count: 5,
          )).thenAnswer((_) async => [question]);

      final result = await useCase(
        type: QuizType.meaningMatch,
        difficulty: 'advanced',
        count: 5,
      );

      expect(result.length, 1);
      expect(result.first.targetWord, 'Serendipity');
    });
  });
}
