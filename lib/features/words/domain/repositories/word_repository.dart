import '../entities/word.dart';

/// Repository interface contract for Word operations
abstract class WordRepository {
  /// Fetch all vocabulary words with optional filtering
  Future<List<Word>> getWords({
    String? difficulty,
    String? category,
    bool? onlyFavorites,
    bool? onlyLearned,
  });

  /// Get a single word by its identifier
  Future<Word> getWordById(int id);

  /// Search words by query matching word, meaning, or tags
  Future<List<Word>> searchWords(String query);

  /// Toggle favorite status of a word and return the updated word
  Future<Word> toggleFavorite(int id, bool isFavorite);

  /// Toggle learned / mastered status of a word and return the updated word
  Future<Word> toggleLearned(int id, bool isLearned);

  /// Get distinct categories available in vocabulary
  Future<List<String>> getCategories();

  /// Get word statistics (total, favorites count, learned count)
  Future<Map<String, int>> getWordStatistics();
}
