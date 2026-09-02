import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/data/sentences_data.dart';
import 'package:vocabulary_builder/models/sentence.dart';

void main() {
  group('Sentence and SentenceWord Models', () {
    test('SentenceWord should serialize to and from JSON', () {
      const vocab = SentenceWord(word: 'Resilience', meaning: 'Ability to recover');
      final json = vocab.toJson();
      final fromJson = SentenceWord.fromJson(json);

      expect(fromJson.word, 'Resilience');
      expect(fromJson.meaning, 'Ability to recover');
      expect(fromJson, equals(vocab));
    });

    test('Sentence should serialize to and from JSON correctly', () {
      const sentence = Sentence(
        id: 'test_1',
        text: 'Practice makes perfect.',
        meaning: 'Doing something repeatedly helps you master it.',
        difficulty: 'Beginner',
        category: 'Everyday Conversation',
        vocabularyWords: [
          SentenceWord(word: 'Practice', meaning: 'Repeated exercise'),
        ],
        isFavorite: true,
      );

      final json = sentence.toJson();
      final fromJson = Sentence(
        id: json['id'] as String,
        text: json['text'] as String,
        meaning: json['meaning'] as String,
        difficulty: json['difficulty'] as String,
        category: json['category'] as String,
        vocabularyWords: (json['vocabularyWords'] as List)
            .map((e) => SentenceWord.fromJson(e as Map<String, dynamic>))
            .toList(),
        isFavorite: json['isFavorite'] as bool,
      );

      expect(fromJson.id, 'test_1');
      expect(fromJson.text, 'Practice makes perfect.');
      expect(fromJson.meaning, 'Doing something repeatedly helps you master it.');
      expect(fromJson.isFavorite, true);
      expect(fromJson.vocabularyWords.length, 1);
    });

    test('Sentence copyWith should update fields properly', () {
      const original = Sentence(
        id: 's1',
        text: 'Hello world',
        meaning: 'Greeting',
        difficulty: 'Beginner',
        category: 'General',
        vocabularyWords: [],
        isFavorite: false,
      );

      final modified = original.copyWith(isFavorite: true, difficulty: 'Intermediate');
      expect(modified.isFavorite, true);
      expect(modified.difficulty, 'Intermediate');
      expect(modified.text, 'Hello world');
    });
  });

  group('SentencesData Quality & Count Validation', () {
    test('Should contain at least 120 total sentences', () {
      final total = SentencesData.sentences.length;
      expect(total, greaterThanOrEqualTo(120));
    });

    test('Should contain at least 40 Beginner sentences', () {
      final beginner = SentencesData.sentences
          .where((s) => s.difficulty.toLowerCase() == 'beginner')
          .toList();
      expect(beginner.length, greaterThanOrEqualTo(40));
    });

    test('Should contain at least 40 Intermediate sentences', () {
      final intermediate = SentencesData.sentences
          .where((s) => s.difficulty.toLowerCase() == 'intermediate')
          .toList();
      expect(intermediate.length, greaterThanOrEqualTo(40));
    });

    test('Should contain at least 40 Advanced sentences', () {
      final advanced = SentencesData.sentences
          .where((s) => s.difficulty.toLowerCase() == 'advanced')
          .toList();
      expect(advanced.length, greaterThanOrEqualTo(40));
    });

    test('All sentences must have valid non-empty fields and vocabulary words', () {
      for (final s in SentencesData.sentences) {
        expect(s.id.trim(), isNotEmpty, reason: 'ID should not be empty');
        expect(s.text.trim(), isNotEmpty, reason: 'Sentence text should not be empty');
        expect(s.meaning.trim(), isNotEmpty, reason: 'Sentence meaning should not be empty');
        expect(s.difficulty.trim(), isNotEmpty, reason: 'Difficulty should not be empty');
        expect(s.category.trim(), isNotEmpty, reason: 'Category should not be empty');
        expect(s.vocabularyWords, isNotEmpty, reason: 'Should have at least 1 vocabulary word');

        for (final v in s.vocabularyWords) {
          expect(v.word.trim(), isNotEmpty);
          expect(v.meaning.trim(), isNotEmpty);
        }
      }
    });

    test('Should contain no duplicate sentence IDs or duplicate texts', () {
      final ids = <String>{};
      final texts = <String>{};

      for (final s in SentencesData.sentences) {
        final addedId = ids.add(s.id);
        expect(addedId, isTrue, reason: 'Duplicate ID detected: ${s.id}');

        final normalizedText = s.text.trim().toLowerCase();
        final addedText = texts.add(normalizedText);
        expect(addedText, isTrue, reason: 'Duplicate sentence detected: ${s.text}');
      }
    });
  });
}
