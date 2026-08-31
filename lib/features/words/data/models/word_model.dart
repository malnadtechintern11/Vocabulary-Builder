import 'dart:convert';
import '../../../../core/database/database_tables.dart';
import '../../domain/entities/word.dart';

/// Data Model extending Word entity with JSON and SQLite serialization
class WordModel extends Word {
  const WordModel({
    required super.id,
    required super.word,
    required super.phonetic,
    required super.partOfSpeech,
    required super.meaning,
    required super.example,
    required super.synonyms,
    required super.antonyms,
    required super.difficulty,
    required super.category,
    required super.isFavorite,
    required super.isLearned,
  });

  /// Convert SQLite Map into WordModel
  factory WordModel.fromDbMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      try {
        final decoded = json.decode(raw.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return WordModel(
      id: map[DatabaseTables.colId] as int,
      word: map[DatabaseTables.colWord] as String,
      phonetic: map[DatabaseTables.colPhonetic] as String? ?? '',
      partOfSpeech: map[DatabaseTables.colPartOfSpeech] as String,
      meaning: map[DatabaseTables.colMeaning] as String,
      example: map[DatabaseTables.colExample] as String,
      synonyms: parseList(map[DatabaseTables.colSynonyms]),
      antonyms: parseList(map[DatabaseTables.colAntonyms]),
      difficulty: map[DatabaseTables.colDifficulty] as String,
      category: map[DatabaseTables.colCategory] as String? ?? 'daily',
      isFavorite: (map[DatabaseTables.colIsFavorite] as int? ?? 0) == 1,
      isLearned: (map[DatabaseTables.colIsLearned] as int? ?? 0) == 1,
    );
  }

  /// Convert to SQLite insert/update map
  Map<String, dynamic> toDbMap() {
    return {
      DatabaseTables.colWord: word,
      DatabaseTables.colPhonetic: phonetic,
      DatabaseTables.colPartOfSpeech: partOfSpeech,
      DatabaseTables.colMeaning: meaning,
      DatabaseTables.colExample: example,
      DatabaseTables.colSynonyms: json.encode(synonyms),
      DatabaseTables.colAntonyms: json.encode(antonyms),
      DatabaseTables.colDifficulty: difficulty,
      DatabaseTables.colCategory: category,
      DatabaseTables.colIsFavorite: isFavorite ? 1 : 0,
      DatabaseTables.colIsLearned: isLearned ? 1 : 0,
    };
  }

  /// Create WordModel from domain Word entity
  factory WordModel.fromEntity(Word entity) {
    return WordModel(
      id: entity.id,
      word: entity.word,
      phonetic: entity.phonetic,
      partOfSpeech: entity.partOfSpeech,
      meaning: entity.meaning,
      example: entity.example,
      synonyms: entity.synonyms,
      antonyms: entity.antonyms,
      difficulty: entity.difficulty,
      category: entity.category,
      isFavorite: entity.isFavorite,
      isLearned: entity.isLearned,
    );
  }
}
