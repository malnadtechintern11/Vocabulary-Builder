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
    await db.execute(DatabaseTables.createWordQuizStatsTable);
    await db.execute(DatabaseTables.createDailyActivityTable);
    await db.execute(DatabaseTables.createAchievementsTable);
    await db.execute(DatabaseTables.createCustomSentencesTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE ${DatabaseTables.tableWords} ADD COLUMN ${DatabaseTables.colKannadaMeaning} TEXT;');
      } catch (e) {
        debugPrint('Column ${DatabaseTables.colKannadaMeaning} might already exist: $e');
      }
    }
    if (oldVersion < 5) {
      try {
        await db.delete(DatabaseTables.tableWords);
      } catch (e) {
        debugPrint('Resetting words table for 50+ words per topic dataset: $e');
      }
    }
    if (oldVersion < 6) {
      try {
        await db.execute(DatabaseTables.createWordQuizStatsTable);
        await db.execute(DatabaseTables.createDailyActivityTable);
        await db.execute(DatabaseTables.createAchievementsTable);
      } catch (e) {
        debugPrint('Error creating learning analytics tables: $e');
      }
    }
    try {
      await db.execute(DatabaseTables.createCustomSentencesTable);
    } catch (e) {
      debugPrint('Ensuring custom sentences table exists: $e');
    }
  }

  /// Syncs newly added words from JSON asset without overwriting existing user data
  Future<void> _syncSeedData(Database db) async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.vocabularySeedAssetPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      final batch = db.batch();
      final now = DateTime.now().toIso8601String();

      for (final item in jsonList) {
        final rawDiff = item['level']?.toString() ?? item['difficulty']?.toString() ?? 'Basic';
        final rawCat = item['topic']?.toString() ?? item['category']?.toString() ?? 'General';

        batch.rawInsert(
          '''
          INSERT INTO ${DatabaseTables.tableWords} (
            ${DatabaseTables.colWord},
            ${DatabaseTables.colPhonetic},
            ${DatabaseTables.colPartOfSpeech},
            ${DatabaseTables.colMeaning},
            ${DatabaseTables.colKannadaMeaning},
            ${DatabaseTables.colExample},
            ${DatabaseTables.colSynonyms},
            ${DatabaseTables.colAntonyms},
            ${DatabaseTables.colDifficulty},
            ${DatabaseTables.colCategory},
            ${DatabaseTables.colIsFavorite},
            ${DatabaseTables.colIsLearned},
            ${DatabaseTables.colCreatedAt}
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?)
          ON CONFLICT(${DatabaseTables.colWord}) DO UPDATE SET
            ${DatabaseTables.colKannadaMeaning} = excluded.${DatabaseTables.colKannadaMeaning},
            ${DatabaseTables.colMeaning} = excluded.${DatabaseTables.colMeaning},
            ${DatabaseTables.colExample} = excluded.${DatabaseTables.colExample},
            ${DatabaseTables.colDifficulty} = excluded.${DatabaseTables.colDifficulty},
            ${DatabaseTables.colCategory} = excluded.${DatabaseTables.colCategory},
            ${DatabaseTables.colPhonetic} = excluded.${DatabaseTables.colPhonetic}
          ''',
          [
            item['word'],
            item['phonetic'] ?? '',
            item['partOfSpeech'] ?? 'noun',
            item['meaning'] ?? '',
            item['kannadaMeaning'] ?? '',
            item['example'] ?? '',
            json.encode(item['synonyms'] ?? []),
            json.encode(item['antonyms'] ?? []),
            rawDiff.toLowerCase(),
            rawCat.toLowerCase(),
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
