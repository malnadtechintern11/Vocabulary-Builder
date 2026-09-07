/// Global Application Constants
class AppConstants {
  static const String appName = 'Vocabulary Builder';
  static const String appTagline = 'Master English Words, Daily & Offline';
  static const String vocabularySeedAssetPath = 'assets/words.json';
  static const String databaseName = 'vocabulary_builder.db';
  static const int databaseVersion = 6;

  // Words limits & defaults
  static const int defaultQuizQuestionCount = 10;
  static const int minWordsRequiredForQuiz = 4;

  // Google Play Store Details
  static const String playStorePackageName = 'com.vocabularybuilder.vocabulary_builder';
  static const String playStoreMarketUrl = 'market://details?id=$playStorePackageName';
  static const String playStoreWebUrl = 'https://play.google.com/store/apps/details?id=$playStorePackageName';
}
