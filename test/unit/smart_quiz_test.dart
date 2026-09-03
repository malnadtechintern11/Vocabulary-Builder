import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vocabulary_builder/core/database/app_database.dart';
import 'package:vocabulary_builder/core/database/database_tables.dart';
import 'package:vocabulary_builder/features/quiz/data/datasources/quiz_local_data_source.dart';
import 'package:vocabulary_builder/features/quiz/domain/entities/quiz_question.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database testDb;
  late QuizLocalDataSource dataSource;

  setUp(() async {
    testDb = await openDatabase(
      inMemoryDatabasePath,
      version: 6,
      onCreate: (db, version) async {
        await db.execute(DatabaseTables.createWordsTable);
        await db.execute(DatabaseTables.createQuizResultsTable);
        await db.execute(DatabaseTables.createWordQuizStatsTable);
        await db.execute(DatabaseTables.createDailyActivityTable);
        await db.execute(DatabaseTables.createAchievementsTable);
      },
    );

    // Insert 5 test words with rich attributes and Kannada meanings
    final testWords = [
      {
        DatabaseTables.colId: 1,
        DatabaseTables.colWord: 'Abundant',
        DatabaseTables.colPhonetic: '/əˈbʌndənt/',
        DatabaseTables.colPartOfSpeech: 'adjective',
        DatabaseTables.colMeaning: 'Existing or available in large quantities; plentiful',
        DatabaseTables.colKannadaMeaning: 'ವಿಪುಲವಾದ',
        DatabaseTables.colExample: 'There was abundant evidence to support the theory.',
        DatabaseTables.colSynonyms: '["plentiful", "copious"]',
        DatabaseTables.colAntonyms: '["scarce"]',
        DatabaseTables.colDifficulty: 'basic',
        DatabaseTables.colCategory: 'nature',
        DatabaseTables.colIsFavorite: 0,
        DatabaseTables.colIsLearned: 0,
        DatabaseTables.colCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        DatabaseTables.colId: 2,
        DatabaseTables.colWord: 'Benevolent',
        DatabaseTables.colPhonetic: '/bəˈnevələnt/',
        DatabaseTables.colPartOfSpeech: 'adjective',
        DatabaseTables.colMeaning: 'Well meaning and kindly',
        DatabaseTables.colKannadaMeaning: 'ದಯಾಪರ',
        DatabaseTables.colExample: 'A benevolent smile greeted every guest.',
        DatabaseTables.colSynonyms: '["kind", "charitable"]',
        DatabaseTables.colAntonyms: '["malevolent"]',
        DatabaseTables.colDifficulty: 'intermediate',
        DatabaseTables.colCategory: 'emotions',
        DatabaseTables.colIsFavorite: 1,
        DatabaseTables.colIsLearned: 0,
        DatabaseTables.colCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        DatabaseTables.colId: 3,
        DatabaseTables.colWord: 'Candid',
        DatabaseTables.colPhonetic: '/ˈkændɪd/',
        DatabaseTables.colPartOfSpeech: 'adjective',
        DatabaseTables.colMeaning: 'Truthful and straightforward; frank',
        DatabaseTables.colKannadaMeaning: 'ಸ್ಪಷ್ಟವಾದ',
        DatabaseTables.colExample: 'His candid reply surprised everyone in the room.',
        DatabaseTables.colSynonyms: '["frank", "honest"]',
        DatabaseTables.colAntonyms: '["evasive"]',
        DatabaseTables.colDifficulty: 'basic',
        DatabaseTables.colCategory: 'communication',
        DatabaseTables.colIsFavorite: 0,
        DatabaseTables.colIsLearned: 0,
        DatabaseTables.colCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        DatabaseTables.colId: 4,
        DatabaseTables.colWord: 'Diligent',
        DatabaseTables.colPhonetic: '/ˈdɪlɪdʒənt/',
        DatabaseTables.colPartOfSpeech: 'adjective',
        DatabaseTables.colMeaning: 'Having or showing care and conscientiousness in work',
        DatabaseTables.colKannadaMeaning: 'ಶ್ರಮಶೀಲ',
        DatabaseTables.colExample: 'She was a diligent student who never gave up.',
        DatabaseTables.colSynonyms: '["hardworking", "assiduous"]',
        DatabaseTables.colAntonyms: '["lazy"]',
        DatabaseTables.colDifficulty: 'intermediate',
        DatabaseTables.colCategory: 'work',
        DatabaseTables.colIsFavorite: 0,
        DatabaseTables.colIsLearned: 1,
        DatabaseTables.colCreatedAt: DateTime.now().toIso8601String(),
      },
      {
        DatabaseTables.colId: 5,
        DatabaseTables.colWord: 'Eloquent',
        DatabaseTables.colPhonetic: '/ˈeləkwənt/',
        DatabaseTables.colPartOfSpeech: 'adjective',
        DatabaseTables.colMeaning: 'Fluent or persuasive in speaking or writing',
        DatabaseTables.colKannadaMeaning: 'ಸ್ಪಷ್ಟ ಮಾತುಗಾರಿಕೆಯ',
        DatabaseTables.colExample: 'An eloquent speaker captivated the entire audience.',
        DatabaseTables.colSynonyms: '["articulate", "persuasive"]',
        DatabaseTables.colAntonyms: '["inarticulate"]',
        DatabaseTables.colDifficulty: 'advanced',
        DatabaseTables.colCategory: 'academic',
        DatabaseTables.colIsFavorite: 0,
        DatabaseTables.colIsLearned: 0,
        DatabaseTables.colCreatedAt: DateTime.now().toIso8601String(),
      },
    ];

    for (final word in testWords) {
      await testDb.insert(DatabaseTables.tableWords, word);
    }

    final mockAppDb = _MockAppDatabase(testDb);
    dataSource = QuizLocalDataSourceImpl(databaseHelper: mockAppDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  group('Smart Quiz Generation - English to Kannada', () {
    test('generates questions with Kannada options and correct answer', () async {
      final questions = await dataSource.generateQuestions(
        type: QuizType.englishToKannada,
        count: 3,
      );

      expect(questions.length, 3);
      for (final q in questions) {
        expect(q.prompt.contains('Kannada meaning'), isTrue);
        expect(q.options.length, 4);
        expect(q.correctOptionIndex >= 0 && q.correctOptionIndex < 4, isTrue);
        // Correct answer should be non-empty Kannada text
        expect(q.correctAnswer.isNotEmpty, isTrue);
      }
    });
  });

  group('Smart Quiz Generation - Kannada to English', () {
    test('generates questions with English word options for given Kannada prompt', () async {
      final questions = await dataSource.generateQuestions(
        type: QuizType.kannadaToEnglish,
        count: 3,
      );

      expect(questions.length, 3);
      for (final q in questions) {
        expect(q.prompt.contains('corresponds to the Kannada meaning'), isTrue);
        expect(q.options.length, 4);
        // Target word must be in options
        expect(q.options.contains(q.targetWord), isTrue);
        expect(q.correctAnswer, q.targetWord);
      }
    });
  });

  group('Smart Quiz Generation - Sentence Completion', () {
    test('generates cloze sentence completion with blank and options', () async {
      final questions = await dataSource.generateQuestions(
        type: QuizType.sentenceCompletion,
        count: 3,
      );

      expect(questions.length, 3);
      for (final q in questions) {
        expect(q.contextSnippet != null, isTrue);
        expect(q.contextSnippet!.contains('__________'), isTrue);
        expect(q.options.length, 4);
        expect(q.correctAnswer, q.targetWord);
      }
    });
  });

  group('Smart Quiz Generation - Smart Mixed Mode', () {
    test('generates interleaved questions successfully', () async {
      final questions = await dataSource.generateQuestions(
        type: QuizType.smartMixed,
        count: 5,
      );

      expect(questions.length, 5);
      for (final q in questions) {
        expect(q.options.length, 4);
        expect(q.explanation.isNotEmpty, isTrue);
      }
    });
  });

  group('Smart Quiz Generation - Weak Words Practice', () {
    test('targets words with recorded incorrect answers', () async {
      // Record word 2 (Benevolent) as weak
      await testDb.insert(DatabaseTables.tableWordQuizStats, {
        DatabaseTables.colStatsWordId: 2,
        DatabaseTables.colStatsWord: 'Benevolent',
        DatabaseTables.colStatsTimesTested: 2,
        DatabaseTables.colStatsTimesCorrect: 0,
        DatabaseTables.colStatsTimesIncorrect: 2,
        DatabaseTables.colStatsLastTestedAt: DateTime.now().toIso8601String(),
      });

      final questions = await dataSource.generateQuestions(
        type: QuizType.weakWordsPractice,
        count: 2,
      );

      expect(questions.isNotEmpty, isTrue);
      // At least one question should be for 'Benevolent'
      expect(questions.any((q) => q.targetWord == 'Benevolent'), isTrue);
    });
  });
}

class _MockAppDatabase implements AppDatabase {
  final Database _db;
  _MockAppDatabase(this._db);

  @override
  Future<Database> get database async => _db;

  @override
  Future<void> close() async => _db.close();
}
