import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:vocabulary_builder/core/services/translation_service.dart';
import 'package:vocabulary_builder/features/translation/presentation/providers/translation_provider.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('TranslationService Tests', () {
    test('Supported languages include exactly the 10 requested languages', () {
      final languages = TranslationService.supportedLanguages;
      expect(languages.length, 10);

      final codes = languages.map((l) => l.code).toSet();
      expect(codes, containsAll(['en', 'kn', 'hi', 'mr', 'te', 'ta', 'ml', 'bn', 'gu', 'pa']));

      expect(TranslationService.getLanguage('kn').name, 'Kannada');
      expect(TranslationService.getLanguage('hi').name, 'Hindi');
      expect(TranslationService.getLanguage('mr').name, 'Marathi');
      expect(TranslationService.getLanguage('te').name, 'Telugu');
      expect(TranslationService.getLanguage('ta').name, 'Tamil');
      expect(TranslationService.getLanguage('ml').name, 'Malayalam');
      expect(TranslationService.getLanguage('bn').name, 'Bengali');
      expect(TranslationService.getLanguage('gu').name, 'Gujarati');
      expect(TranslationService.getLanguage('pa').name, 'Punjabi');
      expect(TranslationService.getLanguage('en').name, 'English');
    });

    test('Translates empty text without making network requests', () async {
      final mockClient = MockHttpClient();
      final service = TranslationService(client: mockClient);

      final result = await service.translate(text: '   ', targetLanguageCode: 'kn');
      expect(result.translatedText, isEmpty);
      verifyNever(() => mockClient.get(any()));
    });

    test('Throws TranslationNoInternetException with exact required message on SocketException', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any())).thenThrow(const SocketException('No Internet'));

      final service = TranslationService(client: mockClient);

      expect(
        () => service.translate(text: 'Hello world', targetLanguageCode: 'kn'),
        throwsA(isA<TranslationNoInternetException>().having(
          (e) => e.message,
          'message',
          'Internet connection is required for translation',
        )),
      );
    });

    test('Throws TranslationNoInternetException on http.ClientException', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any())).thenThrow(http.ClientException('Network failure'));

      final service = TranslationService(client: mockClient);

      expect(
        () => service.translate(text: 'Courage', targetLanguageCode: 'hi'),
        throwsA(isA<TranslationNoInternetException>().having(
          (e) => e.message,
          'message',
          'Internet connection is required for translation',
        )),
      );
    });

    test('Parses successful Google Translate API response', () async {
      final mockClient = MockHttpClient();
      const mockResponse = '[[["ಧೈರ್ಯ","Courage",null,null,10]],null,"en"]';
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response.bytes(utf8.encode(mockResponse), 200),
      );

      final service = TranslationService(client: mockClient);
      final result = await service.translate(text: 'Courage', targetLanguageCode: 'kn');

      expect(result.sourceText, 'Courage');
      expect(result.translatedText, 'ಧೈರ್ಯ');
      expect(result.targetLanguageCode, 'kn');
    });
  });

  group('TranslationNotifier Provider Tests', () {
    test('Updates target language and sets state correctly', () {
      final mockClient = MockHttpClient();
      final service = TranslationService(client: mockClient);
      final notifier = TranslationNotifier(service);

      notifier.setTargetLanguage('hi');
      expect(notifier.state.targetLanguageCode, 'hi');

      notifier.setInputText('Resilience');
      expect(notifier.state.inputText, 'Resilience');

      notifier.clear();
      expect(notifier.state.inputText, '');
      expect(notifier.state.result, isNull);
    });

    test('Captures offline error and sets isOfflineError flag with exact message', () async {
      final mockClient = MockHttpClient();
      when(() => mockClient.get(any())).thenThrow(const SocketException('Failed host lookup'));

      final service = TranslationService(client: mockClient);
      final notifier = TranslationNotifier(service);

      notifier.setInputText('Perseverance');
      await notifier.translate();

      expect(notifier.state.isOfflineError, isTrue);
      expect(notifier.state.errorMessage, 'Internet connection is required for translation');
      expect(notifier.state.isLoading, isFalse);
    });
  });
}
