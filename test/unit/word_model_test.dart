import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/database/database_tables.dart';
import 'package:vocabulary_builder/features/words/data/models/word_model.dart';
import 'package:vocabulary_builder/features/words/domain/entities/word.dart';

void main() {
  group('WordModel', () {
    const testWord = Word(
      id: 1,
      word: 'Eloquent',
      phonetic: '/ˈel.ə.kwənt/',
      partOfSpeech: 'adjective',
      meaning: 'Fluent or persuasive in speaking or writing.',
      kannadaMeaning: 'ವಾಕ್ಪಟುತ್ವವುಳ್ಳ / ಪ್ರಭಾವಿ ಭಾಷಣದ',
      example: 'An eloquent speaker.',
      synonyms: ['articulate', 'fluent'],
      antonyms: ['inarticulate'],
      difficulty: 'intermediate',
      category: 'communication',
      isFavorite: true,
      isLearned: false,
    );

    test('should correctly instantiate fromDbMap and serialize toDbMap', () {
      final dbMap = {
        DatabaseTables.colId: 1,
        DatabaseTables.colWord: 'Eloquent',
        DatabaseTables.colPhonetic: '/ˈel.ə.kwənt/',
        DatabaseTables.colPartOfSpeech: 'adjective',
        DatabaseTables.colMeaning: 'Fluent or persuasive in speaking or writing.',
        DatabaseTables.colKannadaMeaning: 'ವಾಕ್ಪಟುತ್ವವುಳ್ಳ / ಪ್ರಭಾವಿ ಭಾಷಣದ',
        DatabaseTables.colExample: 'An eloquent speaker.',
        DatabaseTables.colSynonyms: '["articulate","fluent"]',
        DatabaseTables.colAntonyms: '["inarticulate"]',
        DatabaseTables.colDifficulty: 'intermediate',
        DatabaseTables.colCategory: 'communication',
        DatabaseTables.colIsFavorite: 1,
        DatabaseTables.colIsLearned: 0,
      };

      final model = WordModel.fromDbMap(dbMap);

      expect(model.id, 1);
      expect(model.word, 'Eloquent');
      expect(model.phonetic, '/ˈel.ə.kwənt/');
      expect(model.kannadaMeaning, 'ವಾಕ್ಪಟುತ್ವವುಳ್ಳ / ಪ್ರಭಾವಿ ಭಾಷಣದ');
      expect(model.synonyms, contains('articulate'));
      expect(model.isFavorite, isTrue);
      expect(model.isLearned, isFalse);

      final serialized = model.toDbMap();
      expect(serialized[DatabaseTables.colWord], 'Eloquent');
      expect(serialized[DatabaseTables.colKannadaMeaning], 'ವಾಕ್ಪಟುತ್ವವುಳ್ಳ / ಪ್ರಭಾವಿ ಭಾಷಣದ');
      expect(serialized[DatabaseTables.colIsFavorite], 1);
      expect(serialized[DatabaseTables.colIsLearned], 0);
    });

    test('should correctly instantiate from entity', () {
      final model = WordModel.fromEntity(testWord);
      expect(model.id, testWord.id);
      expect(model.word, testWord.word);
      expect(model.kannadaMeaning, testWord.kannadaMeaning);
      expect(model.level, 'Intermediate');
      expect(model.topic, 'Communication');
      expect(model.isFavorite, testWord.isFavorite);
    });

    test('should correctly parse fromJson and export toJson', () {
      final jsonMap = {
        'id': 1,
        'word': 'Apple',
        'meaning': 'A round fruit',
        'kannadaMeaning': 'ಸೇಬು',
        'example': 'I eat an apple every day.',
        'level': 'Basic',
        'topic': 'Food',
      };

      final model = WordModel.fromJson(jsonMap);
      expect(model.word, 'Apple');
      expect(model.level, 'Basic');
      expect(model.topic, 'Food');
      expect(model.kannadaMeaning, 'ಸೇಬು');

      final exported = model.toJson();
      expect(exported['word'], 'Apple');
      expect(exported['level'], 'Basic');
      expect(exported['topic'], 'Food');
    });
  });
}
