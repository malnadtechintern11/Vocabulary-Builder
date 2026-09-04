import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:vocabulary_builder/core/services/online_dictionary_service.dart';
import 'package:vocabulary_builder/core/services/translation_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockTranslationService extends Mock implements TranslationService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('OnlineDictionaryService Tests', () {
    test('Throws WordNotFoundOnlineException on empty search', () async {
      final mockClient = MockHttpClient();
      final mockTranslation = MockTranslationService();
      final service = OnlineDictionaryService(
        client: mockClient,
        translationService: mockTranslation,
      );

      expect(
        () => service.fetchWordDetails('   '),
        throwsA(isA<WordNotFoundOnlineException>()),
      );
    });

    test('Throws WordNoInternetException on SocketException with exact message', () async {
      final mockClient = MockHttpClient();
      final mockTranslation = MockTranslationService();
      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenThrow(const SocketException('No Internet'));

      final service = OnlineDictionaryService(
        client: mockClient,
        translationService: mockTranslation,
      );

      expect(
        () => service.fetchWordDetails('serendipity'),
        throwsA(isA<WordNoInternetException>().having(
          (e) => e.message,
          'message',
          'This word is not available offline. Please connect to the internet to search for it.',
        )),
      );
    });

    test('Throws WordNoInternetException on http.ClientException', () async {
      final mockClient = MockHttpClient();
      final mockTranslation = MockTranslationService();
      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenThrow(http.ClientException('Connection failed'));

      final service = OnlineDictionaryService(
        client: mockClient,
        translationService: mockTranslation,
      );

      expect(
        () => service.fetchWordDetails('ephemeral'),
        throwsA(isA<WordNoInternetException>()),
      );
    });

    test('Successfully parses Free Dictionary API response with Kannada meaning', () async {
      final mockClient = MockHttpClient();
      final mockTranslation = MockTranslationService();

      const dictionaryJson = '''
[
  {
    "word": "serendipity",
    "phonetic": "/ˌsɛr.ənˈdɪp.ɪ.ti/",
    "phonetics": [
      {
        "text": "/ˌsɛr.ənˈdɪp.ɪ.ti/",
        "audio": "https://api.dictionaryapi.dev/media/pronunciations/en/serendipity-us.mp3"
      }
    ],
    "meanings": [
      {
        "partOfSpeech": "noun",
        "definitions": [
          {
            "definition": "The occurrence and development of events by chance in a happy or beneficial way.",
            "synonyms": ["fluke", "chance", "fortune"],
            "antonyms": ["misfortune"],
            "example": "A fortunate stroke of serendipity brought them together."
          }
        ],
        "synonyms": ["luck"],
        "antonyms": []
      }
    ]
  }
]
''';

      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(dictionaryJson), 200),
      );

      when(() => mockTranslation.translate(
            text: any(named: 'text'),
            targetLanguageCode: any(named: 'targetLanguageCode'),
            sourceLanguageCode: any(named: 'sourceLanguageCode'),
          )).thenAnswer(
        (_) async => const TranslationResult(
          sourceText: 'serendipity',
          translatedText: 'ಅದೃಷ್ಟದ ಆಕಸ್ಮಿಕತೆ',
          targetLanguageCode: 'kn',
        ),
      );

      final service = OnlineDictionaryService(
        client: mockClient,
        translationService: mockTranslation,
      );

      final result = await service.fetchWordDetails('serendipity');

      expect(result.word, 'Serendipity');
      expect(result.phonetic, '/ˌsɛr.ənˈdɪp.ɪ.ti/');
      expect(result.partOfSpeech, 'noun');
      expect(result.meaning, 'The occurrence and development of events by chance in a happy or beneficial way.');
      expect(result.kannadaMeaning, 'ಅದೃಷ್ಟದ ಆಕಸ್ಮಿಕತೆ');
      expect(result.example, 'A fortunate stroke of serendipity brought them together.');
      expect(result.synonyms, containsAll(['fluke', 'chance', 'fortune']));
      expect(result.antonyms, contains('misfortune'));
      expect(result.isOnline, true);
    });

    test('Falls back gracefully to TranslationService when Free Dictionary returns 404', () async {
      final mockClient = MockHttpClient();
      final mockTranslation = MockTranslationService();

      when(() => mockClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response('{"title": "No Definitions Found"}', 404),
      );

      when(() => mockTranslation.translate(
            text: any(named: 'text'),
            targetLanguageCode: 'kn',
            sourceLanguageCode: any(named: 'sourceLanguageCode'),
          )).thenAnswer(
        (_) async => const TranslationResult(
          sourceText: 'techstack',
          translatedText: 'ತಂತ್ರಜ್ಞಾನದ ಜೋಡಣೆ',
          targetLanguageCode: 'kn',
        ),
      );

      when(() => mockTranslation.translate(
            text: any(named: 'text'),
            targetLanguageCode: 'en',
            sourceLanguageCode: any(named: 'sourceLanguageCode'),
          )).thenAnswer(
        (_) async => const TranslationResult(
          sourceText: 'techstack',
          translatedText: 'technology stack',
          targetLanguageCode: 'en',
        ),
      );

      final service = OnlineDictionaryService(
        client: mockClient,
        translationService: mockTranslation,
      );

      final result = await service.fetchWordDetails('techstack');

      expect(result.word, 'Techstack');
      expect(result.kannadaMeaning, 'ತಂತ್ರಜ್ಞಾನದ ಜೋಡಣೆ');
      expect(result.meaning, contains('technology stack'));
      expect(result.isOnline, true);
    });
  });
}
