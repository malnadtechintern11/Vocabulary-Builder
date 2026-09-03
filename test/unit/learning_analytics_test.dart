import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vocabulary_builder/core/database/app_database.dart';
import 'package:vocabulary_builder/core/database/database_tables.dart';
import 'package:vocabulary_builder/core/services/learning_analytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database testDb;
  late LearningAnalyticsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
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

    // Seed test words
    await testDb.insert(DatabaseTables.tableWords, {
      DatabaseTables.colId: 1,
      DatabaseTables.colWord: 'Benevolent',
      DatabaseTables.colPhonetic: '/bəˈnevələnt/',
      DatabaseTables.colPartOfSpeech: 'adjective',
      DatabaseTables.colMeaning: 'Well meaning and kindly',
      DatabaseTables.colKannadaMeaning: 'ದಯಾಪರ',
      DatabaseTables.colExample: 'A benevolent smile',
      DatabaseTables.colSynonyms: '["kind", "generous"]',
      DatabaseTables.colAntonyms: '["malevolent"]',
      DatabaseTables.colDifficulty: 'intermediate',
      DatabaseTables.colCategory: 'emotions',
      DatabaseTables.colIsFavorite: 0,
      DatabaseTables.colIsLearned: 1,
      DatabaseTables.colCreatedAt: DateTime.now().toIso8601String(),
    });

    await testDb.insert(DatabaseTables.tableWords, {
      DatabaseTables.colId: 2,
      DatabaseTables.colWord: 'Eloquent',
      DatabaseTables.colPhonetic: '/ˈeləkwənt/',
      DatabaseTables.colPartOfSpeech: 'adjective',
      DatabaseTables.colMeaning: 'Fluent or persuasive in speaking or writing',
      DatabaseTables.colKannadaMeaning: 'ಸ್ಪಷ್ಟ ಮಾತುಗಾರಿಕೆಯ',
      DatabaseTables.colExample: 'An eloquent speaker',
      DatabaseTables.colSynonyms: '["articulate"]',
      DatabaseTables.colAntonyms: '["inarticulate"]',
      DatabaseTables.colDifficulty: 'advanced',
      DatabaseTables.colCategory: 'academic',
      DatabaseTables.colIsFavorite: 1,
      DatabaseTables.colIsLearned: 0,
      DatabaseTables.colCreatedAt: DateTime.now().toIso8601String(),
    });

    // Create a mock AppDatabase wrapping our in-memory DB
    final mockAppDb = _MockAppDatabase(testDb);
    service = LearningAnalyticsService(databaseHelper: mockAppDb);
  });

  tearDown(() async {
    await testDb.close();
  });

  group('LearningAnalyticsService - Daily Goal', () {
    test('default daily goal target should be 10', () async {
      final target = await service.getDailyGoalTarget();
      expect(target, 10);
    });

    test('setting daily goal target should update preference', () async {
      await service.setDailyGoalTarget(20);
      final target = await service.getDailyGoalTarget();
      expect(target, 20);
    });

    test('recordWordLearned increments today count and detects goal completion', () async {
      await service.setDailyGoalTarget(2);

      // Record first word
      final achieved1 = await service.recordWordLearned(1);
      expect(achieved1, isFalse);

      var count = await service.getTodayWordsLearnedCount();
      expect(count, 1);

      // Record second word -> completes target of 2!
      final achieved2 = await service.recordWordLearned(2);
      expect(achieved2, isTrue);

      count = await service.getTodayWordsLearnedCount();
      expect(count, 2);
    });
  });

  group('LearningAnalyticsService - Learning Streak', () {
    test('initial streak should be 0 when no activity recorded', () async {
      final streak = await service.getStreakInfo();
      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.isActiveToday, isFalse);
    });

    test('recording activity sets streak to 1 and isActiveToday to true', () async {
      final streak = await service.recordActivityToday();
      expect(streak.currentStreak, 1);
      expect(streak.longestStreak, 1);
      expect(streak.isActiveToday, isTrue);
    });

    test('subsequent activity on same day does not artificially increment streak', () async {
      await service.recordActivityToday();
      final streak2 = await service.recordActivityToday();
      expect(streak2.currentStreak, 1);
      expect(streak2.longestStreak, 1);
    });
  });

  group('LearningAnalyticsService - Weak Words Tracking', () {
    test('recording incorrect quiz attempt marks word as weak', () async {
      await service.recordQuizQuestionAttempt(
        wordId: 1,
        word: 'Benevolent',
        isCorrect: false,
      );

      final weakWords = await service.getWeakWords();
      expect(weakWords.length, 1);
      expect(weakWords.first[DatabaseTables.colStatsWord], 'Benevolent');
      expect(weakWords.first[DatabaseTables.colStatsTimesIncorrect], 1);
      expect(weakWords.first[DatabaseTables.colKannadaMeaning], 'ದಯಾಪರ');
    });

    test('resolving weak word sets times_incorrect to 0', () async {
      await service.recordQuizQuestionAttempt(
        wordId: 1,
        word: 'Benevolent',
        isCorrect: false,
      );

      var weakWords = await service.getWeakWords();
      expect(weakWords.length, 1);

      await service.resolveWeakWord(1);

      weakWords = await service.getWeakWords();
      expect(weakWords.isEmpty, isTrue);
    });
  });

  group('LearningAnalyticsService - Achievements & Badges', () {
    test('first_word badge unlocks when masteredWords >= 1', () async {
      final badges = await service.getAchievements();
      expect(badges.isNotEmpty, isTrue);

      final firstWordBadge = badges.firstWhere((b) => b.id == 'first_word');
      expect(firstWordBadge.isUnlocked, isTrue);
      expect(firstWordBadge.progress, 1.0);

      final words50Badge = badges.firstWhere((b) => b.id == 'words_50');
      expect(words50Badge.isUnlocked, isFalse);
      expect(words50Badge.currentValue, 1);
      expect(words50Badge.targetValue, 50);
    });
  });

  group('LearningAnalyticsService - Category Analytics', () {
    test('computes mastery per category correctly', () async {
      final analytics = await service.getCategoryAnalytics();
      expect(analytics.categoryStats.length, 2);

      // 'emotions' has 1 total and 1 learned = 100%
      final emotionsStat = analytics.categoryStats.firstWhere((c) => c['category'] == 'emotions');
      expect(emotionsStat['percentage'], 100.0);

      // 'academic' has 1 total and 0 learned = 0%
      final academicStat = analytics.categoryStats.firstWhere((c) => c['category'] == 'academic');
      expect(academicStat['percentage'], 0.0);

      expect(analytics.strongCategories.contains('emotions'), isTrue);
      expect(analytics.weakCategories.contains('academic'), isTrue);
    });
  });

  group('LearningAnalyticsService - Recommendations', () {
    test('suggests daily goal when not met', () async {
      final recs = await service.getRecommendations();
      expect(recs.any((r) => r.id == 'daily_goal'), isTrue);
    });

    test('suggests weak words when student missed questions', () async {
      await service.recordQuizQuestionAttempt(
        wordId: 1,
        word: 'Benevolent',
        isCorrect: false,
      );

      final recs = await service.getRecommendations();
      expect(recs.any((r) => r.id == 'weak_words'), isTrue);
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
