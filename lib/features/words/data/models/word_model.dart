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
    super.kannadaMeaning = '',
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
      kannadaMeaning: map[DatabaseTables.colKannadaMeaning] as String? ?? '',
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
      DatabaseTables.colKannadaMeaning: kannadaMeaning,
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
      kannadaMeaning: entity.kannadaMeaning,
      example: entity.example,
      synonyms: entity.synonyms,
      antonyms: entity.antonyms,
      difficulty: entity.difficulty,
      category: entity.category,
      isFavorite: entity.isFavorite,
      isLearned: entity.isLearned,
    );
  }

  /// Create WordModel from JSON map
  factory WordModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    final diff = json['level']?.toString() ?? json['difficulty']?.toString() ?? 'Basic';
    final cat = json['topic']?.toString() ?? json['category']?.toString() ?? 'General';

    return WordModel(
      id: json['id'] is int ? json['id'] as int : 0,
      word: json['word']?.toString() ?? '',
      phonetic: json['phonetic']?.toString() ?? '',
      partOfSpeech: json['partOfSpeech']?.toString() ?? 'noun',
      meaning: json['meaning']?.toString() ?? '',
      kannadaMeaning: json['kannadaMeaning']?.toString() ?? '',
      example: json['example']?.toString() ?? '',
      synonyms: parseList(json['synonyms']),
      antonyms: parseList(json['antonyms']),
      difficulty: diff.toLowerCase(),
      category: cat.toLowerCase(),
      isFavorite: json['isFavorite'] == true,
      isLearned: json['isLearned'] == true,
    );
  }

  @override
  WordModel copyWith({
    int? id,
    String? word,
    String? phonetic,
    String? partOfSpeech,
    String? meaning,
    String? kannadaMeaning,
    String? example,
    List<String>? synonyms,
    List<String>? antonyms,
    String? difficulty,
    String? category,
    bool? isFavorite,
    bool? isLearned,
  }) {
    return WordModel(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      meaning: meaning ?? this.meaning,
      kannadaMeaning: kannadaMeaning ?? this.kannadaMeaning,
      example: example ?? this.example,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isLearned: isLearned ?? this.isLearned,
    );
  }

  /// Export to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'phonetic': phonetic,
      'partOfSpeech': partOfSpeech,
      'meaning': meaning,
      'kannadaMeaning': kannadaMeaning,
      'example': example,
      'level': level,
      'topic': topic,
      'difficulty': difficulty,
      'category': category,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'isFavorite': isFavorite,
      'isLearned': isLearned,
    };
  }
}
