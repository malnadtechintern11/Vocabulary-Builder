import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/word_model.dart';

/// Contract for Word local database access
abstract class WordLocalDataSource {
  Future<List<WordModel>> getWords({
    String? difficulty,
    String? category,
    bool? onlyFavorites,
    bool? onlyLearned,
  });

  Future<WordModel> getWordById(int id);
  Future<List<WordModel>> searchWords(String query);
  Future<WordModel> updateFavoriteStatus(int id, bool isFavorite);
  Future<WordModel> updateLearnedStatus(int id, bool isLearned);
  Future<List<String>> getCategories();
  Future<Map<String, int>> getWordStatistics();
}

/// Implementation of WordLocalDataSource using SQLite
class WordLocalDataSourceImpl implements WordLocalDataSource {
  final AppDatabase databaseHelper;

  WordLocalDataSourceImpl({AppDatabase? databaseHelper})
      : databaseHelper = databaseHelper ?? AppDatabase.instance;

  @override
  Future<List<WordModel>> getWords({
    String? difficulty,
    String? category,
    bool? onlyFavorites,
    bool? onlyLearned,
  }) async {
    try {
      final db = await databaseHelper.database;
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (difficulty != null && difficulty.isNotEmpty && difficulty != 'all') {
        whereClauses.add('${DatabaseTables.colDifficulty} = ?');
        whereArgs.add(difficulty.toLowerCase());
      }

      if (category != null && category.isNotEmpty && category != 'all') {
        whereClauses.add('${DatabaseTables.colCategory} = ?');
        whereArgs.add(category.toLowerCase());
      }

      if (onlyFavorites == true) {
        whereClauses.add('${DatabaseTables.colIsFavorite} = 1');
      }

      if (onlyLearned == true) {
        whereClauses.add('${DatabaseTables.colIsLearned} = 1');
      }

      final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final results = await db.query(
        DatabaseTables.tableWords,
        where: whereString,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: '${DatabaseTables.colWord} ASC',
      );

      return results.map((row) => WordModel.fromDbMap(row)).toList();
    } catch (e) {
      throw AppDatabaseException('Failed to fetch words: $e', e);
    }
  }

  @override
  Future<WordModel> getWordById(int id) async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        DatabaseTables.tableWords,
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        throw NotFoundException('Word with ID $id not found');
      }

      return WordModel.fromDbMap(results.first);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw AppDatabaseException('Failed to fetch word with ID $id: $e', e);
    }
  }

  @override
  Future<List<WordModel>> searchWords(String query) async {
    try {
      final db = await databaseHelper.database;
      final sanitized = '%${query.toLowerCase()}%';

      final results = await db.query(
        DatabaseTables.tableWords,
        where: '${DatabaseTables.colWord} LIKE ? OR ${DatabaseTables.colMeaning} LIKE ? OR ${DatabaseTables.colCategory} LIKE ?',
        whereArgs: [sanitized, sanitized, sanitized],
        orderBy: '${DatabaseTables.colWord} ASC',
      );

      return results.map((row) => WordModel.fromDbMap(row)).toList();
    } catch (e) {
      throw AppDatabaseException('Failed to search words: $e', e);
    }
  }

  @override
  Future<WordModel> updateFavoriteStatus(int id, bool isFavorite) async {
    try {
      final db = await databaseHelper.database;
      final count = await db.update(
        DatabaseTables.tableWords,
        {DatabaseTables.colIsFavorite: isFavorite ? 1 : 0},
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Word with ID $id not found to update favorite');
      }

      return await getWordById(id);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw AppDatabaseException('Failed to update favorite: $e', e);
    }
  }

  @override
  Future<WordModel> updateLearnedStatus(int id, bool isLearned) async {
    try {
      final db = await databaseHelper.database;
      final count = await db.update(
        DatabaseTables.tableWords,
        {DatabaseTables.colIsLearned: isLearned ? 1 : 0},
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Word with ID $id not found to update learned status');
      }

      return await getWordById(id);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw AppDatabaseException('Failed to update learned status: $e', e);
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final db = await databaseHelper.database;
      final results = await db.rawQuery(
        'SELECT DISTINCT ${DatabaseTables.colCategory} FROM ${DatabaseTables.tableWords} ORDER BY ${DatabaseTables.colCategory} ASC',
      );

      return results
          .map((r) => (r[DatabaseTables.colCategory] as String?) ?? '')
          .where((cat) => cat.isNotEmpty)
          .toList();
    } catch (e) {
      throw AppDatabaseException('Failed to fetch categories: $e', e);
    }
  }

  @override
  Future<Map<String, int>> getWordStatistics() async {
    try {
      final db = await databaseHelper.database;
      final totalRes = await db.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseTables.tableWords}');
      final favRes = await db.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseTables.tableWords} WHERE ${DatabaseTables.colIsFavorite} = 1');
      final learnedRes = await db.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseTables.tableWords} WHERE ${DatabaseTables.colIsLearned} = 1');

      return {
        'total': Sqflite.firstIntValue(totalRes) ?? 0,
        'favorites': Sqflite.firstIntValue(favRes) ?? 0,
        'learned': Sqflite.firstIntValue(learnedRes) ?? 0,
      };
    } catch (e) {
      throw AppDatabaseException('Failed to fetch word statistics: $e', e);
    }
  }
}
