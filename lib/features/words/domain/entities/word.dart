/// Domain Entity representing a Vocabulary Word
class Word {
  final int id;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String meaning;
  final String kannadaMeaning;
  final String example;
  final List<String> synonyms;
  final List<String> antonyms;
  final String difficulty; // basic, intermediate, advanced
  final String category; // actions, nature, food, etc.
  final bool isFavorite;
  final bool isLearned;
  final bool isOnline;

  /// Aliases for user-facing Level & Topic
  String get level => difficulty[0].toUpperCase() + difficulty.substring(1);
  String get topic => category[0].toUpperCase() + category.substring(1);

  const Word({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.meaning,
    this.kannadaMeaning = '',
    required this.example,
    required this.synonyms,
    required this.antonyms,
    required this.difficulty,
    required this.category,
    required this.isFavorite,
    required this.isLearned,
    this.isOnline = false,
  });

  Word copyWith({
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
    bool? isOnline,
  }) {
    return Word(
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
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          word == other.word &&
          isFavorite == other.isFavorite &&
          isLearned == other.isLearned &&
          isOnline == other.isOnline;

  @override
  int get hashCode => id.hashCode ^ word.hashCode ^ isFavorite.hashCode ^ isLearned.hashCode ^ isOnline.hashCode;
}
