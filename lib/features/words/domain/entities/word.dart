/// Domain Entity representing a Vocabulary Word
class Word {
  final int id;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String meaning;
  final String example;
  final List<String> synonyms;
  final List<String> antonyms;
  final String difficulty; // beginner, intermediate, advanced
  final String category;
  final bool isFavorite;
  final bool isLearned;

  const Word({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.meaning,
    required this.example,
    required this.synonyms,
    required this.antonyms,
    required this.difficulty,
    required this.category,
    required this.isFavorite,
    required this.isLearned,
  });

  Word copyWith({
    int? id,
    String? word,
    String? phonetic,
    String? partOfSpeech,
    String? meaning,
    String? example,
    List<String>? synonyms,
    List<String>? antonyms,
    String? difficulty,
    String? category,
    bool? isFavorite,
    bool? isLearned,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isLearned: isLearned ?? this.isLearned,
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
          isLearned == other.isLearned;

  @override
  int get hashCode => id.hashCode ^ word.hashCode ^ isFavorite.hashCode ^ isLearned.hashCode;
}
