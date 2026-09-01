import '../../domain/entities/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../datasources/word_local_data_source.dart';
import '../models/word_model.dart';

/// Concrete implementation of WordRepository
class WordRepositoryImpl implements WordRepository {
  final WordLocalDataSource localDataSource;

  WordRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Word>> getWords({
    String? difficulty,
    String? category,
    bool? onlyFavorites,
    bool? onlyLearned,
  }) async {
    return localDataSource.getWords(
      difficulty: difficulty,
      category: category,
      onlyFavorites: onlyFavorites,
      onlyLearned: onlyLearned,
    );
  }

  @override
  Future<Word> getWordById(int id) async {
    return localDataSource.getWordById(id);
  }

  @override
  Future<Word> addWord(Word word) async {
    final model = WordModel.fromEntity(word);
    return localDataSource.insertWord(model);
  }

  @override
  Future<List<Word>> searchWords(String query) async {
    return localDataSource.searchWords(query);
  }

  @override
  Future<Word> toggleFavorite(int id, bool isFavorite) async {
    return localDataSource.updateFavoriteStatus(id, isFavorite);
  }

  @override
  Future<Word> toggleLearned(int id, bool isLearned) async {
    return localDataSource.updateLearnedStatus(id, isLearned);
  }

  @override
  Future<List<String>> getCategories() async {
    return localDataSource.getCategories();
  }

  @override
  Future<Map<String, int>> getWordStatistics() async {
    return localDataSource.getWordStatistics();
  }
}
