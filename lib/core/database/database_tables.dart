/// Schema and table name definitions for SQLite database
class DatabaseTables {
  static const String tableWords = 'words';
  static const String tableQuizResults = 'quiz_results';

  // Words table columns
  static const String colId = 'id';
  static const String colWord = 'word';
  static const String colPhonetic = 'phonetic';
  static const String colPartOfSpeech = 'part_of_speech';
  static const String colMeaning = 'meaning';
  static const String colKannadaMeaning = 'kannada_meaning';
  static const String colExample = 'example';
  static const String colSynonyms = 'synonyms';
  static const String colAntonyms = 'antonyms';
  static const String colDifficulty = 'difficulty';
  static const String colCategory = 'category';
  static const String colIsFavorite = 'is_favorite';
  static const String colIsLearned = 'is_learned';
  static const String colCreatedAt = 'created_at';

  // Quiz results table columns
  static const String colQuizId = 'id';
  static const String colQuizType = 'quiz_type';
  static const String colTotalQuestions = 'total_questions';
  static const String colCorrectAnswers = 'correct_answers';
  static const String colScorePercentage = 'score_percentage';
  static const String colCompletedAt = 'completed_at';

  // New Learning Feature Tables
  static const String tableWordQuizStats = 'word_quiz_stats';
  static const String tableDailyActivity = 'daily_activity';
  static const String tableAchievements = 'achievements';

  // Word quiz stats columns
  static const String colStatsWordId = 'word_id';
  static const String colStatsWord = 'word';
  static const String colStatsTimesTested = 'times_tested';
  static const String colStatsTimesCorrect = 'times_correct';
  static const String colStatsTimesIncorrect = 'times_incorrect';
  static const String colStatsLastTestedAt = 'last_tested_at';

  // Daily activity columns
  static const String colActivityDate = 'date';
  static const String colActivityWordsLearned = 'words_learned';
  static const String colActivityQuizzesCompleted = 'quizzes_completed';
  static const String colActivityGoalTarget = 'goal_target';
  static const String colActivityGoalAchieved = 'goal_achieved';

  // Achievements columns
  static const String colBadgeId = 'badge_id';
  static const String colUnlockedAt = 'unlocked_at';

  static const String createWordsTable = '''
    CREATE TABLE $tableWords (
      $colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colWord TEXT NOT NULL UNIQUE,
      $colPhonetic TEXT,
      $colPartOfSpeech TEXT NOT NULL,
      $colMeaning TEXT NOT NULL,
      $colKannadaMeaning TEXT,
      $colExample TEXT NOT NULL,
      $colSynonyms TEXT NOT NULL,
      $colAntonyms TEXT NOT NULL,
      $colDifficulty TEXT NOT NULL,
      $colCategory TEXT NOT NULL,
      $colIsFavorite INTEGER NOT NULL DEFAULT 0,
      $colIsLearned INTEGER NOT NULL DEFAULT 0,
      $colCreatedAt TEXT NOT NULL
    );
  ''';

  static const String createWordsIndex = '''
    CREATE INDEX idx_words_word ON $tableWords ($colWord);
  ''';

  static const String createQuizResultsTable = '''
    CREATE TABLE $tableQuizResults (
      $colQuizId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colQuizType TEXT NOT NULL,
      $colTotalQuestions INTEGER NOT NULL,
      $colCorrectAnswers INTEGER NOT NULL,
      $colScorePercentage REAL NOT NULL,
      $colCompletedAt TEXT NOT NULL
    );
  ''';

  static const String createWordQuizStatsTable = '''
    CREATE TABLE $tableWordQuizStats (
      $colStatsWordId INTEGER PRIMARY KEY,
      $colStatsWord TEXT NOT NULL,
      $colStatsTimesTested INTEGER NOT NULL DEFAULT 0,
      $colStatsTimesCorrect INTEGER NOT NULL DEFAULT 0,
      $colStatsTimesIncorrect INTEGER NOT NULL DEFAULT 0,
      $colStatsLastTestedAt TEXT NOT NULL
    );
  ''';

  static const String createDailyActivityTable = '''
    CREATE TABLE $tableDailyActivity (
      $colActivityDate TEXT PRIMARY KEY,
      $colActivityWordsLearned INTEGER NOT NULL DEFAULT 0,
      $colActivityQuizzesCompleted INTEGER NOT NULL DEFAULT 0,
      $colActivityGoalTarget INTEGER NOT NULL DEFAULT 10,
      $colActivityGoalAchieved INTEGER NOT NULL DEFAULT 0
    );
  ''';

  static const String createAchievementsTable = '''
    CREATE TABLE $tableAchievements (
      $colBadgeId TEXT PRIMARY KEY,
      $colUnlockedAt TEXT NOT NULL
    );
  ''';
}
