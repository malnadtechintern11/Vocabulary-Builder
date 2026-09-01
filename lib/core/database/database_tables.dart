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
}
