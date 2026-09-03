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

    test('Sentence should serialize to and from JSON correctly including kannadaMeaning', () {
      const sentence = Sentence(
        id: 'test_1',
        text: 'Practice makes perfect.',
        meaning: 'Doing something repeatedly helps you master it.',
        kannadaMeaning: 'ಅಭ್ಯಾಸದಿಂದ ಎಲ್ಲವೂ ಸಿದ್ಧಿಸುತ್ತದೆ.',
        difficulty: 'Beginner',
        category: 'Everyday Conversation',
        vocabularyWords: [
          SentenceWord(word: 'Practice', meaning: 'Repeated exercise'),
        ],
        isFavorite: true,
      );

      final json = sentence.toJson();
      final fromJson = Sentence.fromJson(json);

      expect(fromJson.id, 'test_1');
      expect(fromJson.text, 'Practice makes perfect.');
      expect(fromJson.meaning, 'Doing something repeatedly helps you master it.');
      expect(fromJson.englishMeaning, 'Doing something repeatedly helps you master it.');
      expect(fromJson.kannadaMeaning, 'ಅಭ್ಯಾಸದಿಂದ ಎಲ್ಲವೂ ಸಿದ್ಧಿಸುತ್ತದೆ.');
      expect(fromJson.isFavorite, true);
      expect(fromJson.vocabularyWords.length, 1);
    });

    test('Sentence copyWith should update fields properly including kannadaMeaning', () {
      const original = Sentence(
        id: 's1',
        text: 'Hello world',
        meaning: 'Greeting',
        kannadaMeaning: 'ನಮಸ್ಕಾರ ಜಗತ್ತು',
        difficulty: 'Beginner',
        category: 'General',
        vocabularyWords: [],
        isFavorite: false,
      );

      final modified = original.copyWith(
        isFavorite: true,
        difficulty: 'Intermediate',
        kannadaMeaning: 'ನಮಸ್ಕಾರ ವಿಶ್ವ',
      );
      expect(modified.isFavorite, true);
      expect(modified.difficulty, 'Intermediate');
      expect(modified.text, 'Hello world');
      expect(modified.kannadaMeaning, 'ನಮಸ್ಕಾರ ವಿಶ್ವ');
    });
  });

  group('SentencesData Quality & Count Validation', () {
    test('Should contain at least 500 total unique sentences (currently 600)', () {
      final total = SentencesData.sentences.length;
      expect(total, greaterThanOrEqualTo(500));
      expect(total, greaterThanOrEqualTo(600));
    });

    test('Should contain at least 200 Beginner sentences', () {
      final beginner = SentencesData.sentences
          .where((s) => s.difficulty.toLowerCase() == 'beginner')
          .toList();
      expect(beginner.length, greaterThanOrEqualTo(200));
    });

    test('Should contain at least 200 Intermediate sentences', () {
      final intermediate = SentencesData.sentences
          .where((s) => s.difficulty.toLowerCase() == 'intermediate')
          .toList();
      expect(intermediate.length, greaterThanOrEqualTo(200));
    });

    test('Should contain at least 200 Advanced sentences', () {
      final advanced = SentencesData.sentences
          .where((s) => s.difficulty.toLowerCase() == 'advanced')
          .toList();
      expect(advanced.length, greaterThanOrEqualTo(200));
    });

    test('All sentences must have valid non-empty fields, English and Kannada meanings, and vocabulary words', () {
      final kannadaRegex = RegExp(r'[\u0C80-\u0CFF]');

      for (final s in SentencesData.sentences) {
        expect(s.id.trim(), isNotEmpty, reason: 'ID should not be empty');
        expect(s.text.trim(), isNotEmpty, reason: 'Sentence text should not be empty for ${s.id}');
        expect(s.meaning.trim(), isNotEmpty, reason: 'Sentence English meaning should not be empty for ${s.id}');
        expect(s.kannadaMeaning.trim(), isNotEmpty, reason: 'Sentence Kannada meaning should not be empty for ${s.id}');
        expect(kannadaRegex.hasMatch(s.kannadaMeaning), isTrue,
            reason: 'Sentence Kannada meaning must contain Kannada script characters for ${s.id}: ${s.kannadaMeaning}');
        expect(s.difficulty.trim(), isNotEmpty, reason: 'Difficulty should not be empty for ${s.id}');
        expect(s.category.trim(), isNotEmpty, reason: 'Category should not be empty for ${s.id}');
        expect(s.vocabularyWords, isNotEmpty, reason: 'Should have at least 1 vocabulary word for ${s.id}');

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
