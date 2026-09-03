/// Model representing an individual vocabulary word within a sentence
class SentenceWord {
  final String word;
  final String meaning;

  const SentenceWord({
    required this.word,
    required this.meaning,
  });

  factory SentenceWord.fromJson(Map<String, dynamic> json) {
    return SentenceWord(
      word: json['word'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentenceWord &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          meaning == other.meaning;

  @override
  int get hashCode => word.hashCode ^ meaning.hashCode;
}

/// Model representing a learning sentence with difficulty, category, English meaning, Kannada meaning, and key vocabulary
class Sentence {
  final String id;
  final String text;
  final String meaning; // English meaning
  final String kannadaMeaning; // Kannada meaning translation
  final List<SentenceWord> vocabularyWords;
  final String difficulty; // 'Beginner', 'Intermediate', 'Advanced'
  final String category; // e.g. 'Daily Conversation', 'Work & Career', 'Travel', etc.
  final bool isFavorite;
  final bool isPracticed;

  const Sentence({
    required this.id,
    required this.text,
    required this.meaning,
    this.kannadaMeaning = '',
    required this.vocabularyWords,
    required this.difficulty,
    required this.category,
    this.isFavorite = false,
    this.isPracticed = false,
  });

  /// Alias for meaning for clearer semantic distinction from kannadaMeaning
  String get englishMeaning => meaning;

  Sentence copyWith({
    String? id,
    String? text,
    String? meaning,
    String? kannadaMeaning,
    List<SentenceWord>? vocabularyWords,
    String? difficulty,
    String? category,
    bool? isFavorite,
    bool? isPracticed,
  }) {
    return Sentence(
      id: id ?? this.id,
      text: text ?? this.text,
      meaning: meaning ?? this.meaning,
      kannadaMeaning: kannadaMeaning ?? this.kannadaMeaning,
      vocabularyWords: vocabularyWords ?? this.vocabularyWords,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isPracticed: isPracticed ?? this.isPracticed,
    );
  }

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      kannadaMeaning: json['kannadaMeaning'] as String? ?? '',
      vocabularyWords: (json['vocabularyWords'] as List<dynamic>? ?? [])
          .map((item) => SentenceWord.fromJson(item as Map<String, dynamic>))
          .toList(),
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      category: json['category'] as String? ?? 'General',
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPracticed: json['isPracticed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'meaning': meaning,
      'kannadaMeaning': kannadaMeaning,
      'vocabularyWords': vocabularyWords.map((v) => v.toJson()).toList(),
      'difficulty': difficulty,
      'category': category,
      'isFavorite': isFavorite,
      'isPracticed': isPracticed,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sentence && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

