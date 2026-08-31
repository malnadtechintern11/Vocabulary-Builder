import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'database_tables.dart';

/// Singleton SQLite database manager
class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      String dbPath;
      if (kIsWeb) {
        dbPath = AppConstants.databaseName;
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        dbPath = join(docsDir.path, AppConstants.databaseName);
      }

      final db = await openDatabase(
        dbPath,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      // Seed & sync vocabulary words from seed asset
      await _syncSeedData(db);

      return db;
    } catch (e) {
      throw AppDatabaseException('Failed to initialize database: $e', e);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createWordsTable);
    await db.execute(DatabaseTables.createWordsIndex);
    await db.execute(DatabaseTables.createQuizResultsTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration strategy for future schema versions
  }

  /// Syncs newly added words from JSON asset without overwriting existing user data
  Future<void> _syncSeedData(Database db) async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.vocabularySeedAssetPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      final batch = db.batch();
      final now = DateTime.now().toIso8601String();

      for (final item in jsonList) {
        batch.rawInsert(
          '''
          INSERT OR IGNORE INTO ${DatabaseTables.tableWords} (
            ${DatabaseTables.colWord},
            ${DatabaseTables.colPhonetic},
            ${DatabaseTables.colPartOfSpeech},
            ${DatabaseTables.colMeaning},
            ${DatabaseTables.colExample},
            ${DatabaseTables.colSynonyms},
            ${DatabaseTables.colAntonyms},
            ${DatabaseTables.colDifficulty},
            ${DatabaseTables.colCategory},
            ${DatabaseTables.colIsFavorite},
            ${DatabaseTables.colIsLearned},
            ${DatabaseTables.colCreatedAt}
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?)
          ''',
          [
            item['word'],
            item['phonetic'] ?? '',
            item['partOfSpeech'],
            item['meaning'],
            item['example'],
            json.encode(item['synonyms'] ?? []),
            json.encode(item['antonyms'] ?? []),
            item['difficulty'],
            item['category'] ?? 'daily',
            now,
          ],
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Warning: Seed data failed to sync: $e');
    }
  }

  /// Helper to close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
