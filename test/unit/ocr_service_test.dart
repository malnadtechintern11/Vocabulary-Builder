import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/services/ocr_service.dart';
import 'package:vocabulary_builder/features/ocr/presentation/providers/ocr_provider.dart';

void main() {
  group('OcrResult and OcrState Unit Tests', () {
    test('OcrResult properties and empty checks work correctly', () {
      const emptyResult = OcrResult(
        rawText: '   ',
        lines: [],
        words: [],
        imagePath: '/tmp/test.png',
      );
      expect(emptyResult.isEmpty, isTrue);
      expect(emptyResult.isNotEmpty, isFalse);

      const validResult = OcrResult(
        rawText: 'The quick brown fox jumps over the lazy dog.',
        lines: ['The quick brown fox jumps over the lazy dog.'],
        words: ['The', 'quick', 'brown', 'fox', 'jumps', 'over', 'lazy', 'dog'],
        imagePath: '/tmp/test.png',
      );
      expect(validResult.isEmpty, isFalse);
      expect(validResult.isNotEmpty, isTrue);
      expect(validResult.words.length, 8);
      expect(validResult.lines.length, 1);
    });

    test('OcrState copyWith updates fields properly', () {
      const initialState = OcrState();
      expect(initialState.isProcessing, isFalse);
      expect(initialState.result, isNull);
      expect(initialState.errorMessage, isNull);

      final processingState = initialState.copyWith(isProcessing: true);
      expect(processingState.isProcessing, isTrue);

      const mockResult = OcrResult(
        rawText: 'Vocabulary learning',
        lines: ['Vocabulary learning'],
        words: ['Vocabulary', 'learning'],
        imagePath: '/path/img.jpg',
      );

      final resultState = processingState.copyWith(
        isProcessing: false,
        result: mockResult,
      );

      expect(resultState.isProcessing, isFalse);
      expect(resultState.result!.rawText, 'Vocabulary learning');
      expect(resultState.result!.words, contains('Vocabulary'));

      final errorState = resultState.copyWith(errorMessage: 'No text detected');
      expect(errorState.errorMessage, 'No text detected');

      final clearedState = errorState.copyWith(clearError: true);
      expect(clearedState.errorMessage, isNull);
    });

    test('OcrNotifier cropCurrentImage gracefully handles empty image state and clears', () async {
      final notifier = OcrNotifier(OcrService());
      expect(notifier.state.imageFile, isNull);

      await notifier.cropCurrentImage();
      expect(notifier.state.imageFile, isNull);

      notifier.clear();
      expect(notifier.state.imageFile, isNull);
      expect(notifier.state.result, isNull);
      expect(notifier.state.errorMessage, isNull);
    });

    test('OcrNotifier setTargetLanguage updates selected language code', () async {
      final notifier = OcrNotifier(OcrService());
      expect(notifier.state.selectedLanguageCode, 'kn');

      await notifier.setTargetLanguage('hi');
      expect(notifier.state.selectedLanguageCode, 'hi');

      await notifier.setTargetLanguage('te');
      expect(notifier.state.selectedLanguageCode, 'te');
    });
  });
}
