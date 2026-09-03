import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../core/services/translation_service.dart';
import '../../../words/domain/entities/word.dart';
import '../../../words/domain/repositories/word_repository.dart';
import '../../../words/presentation/providers/words_provider.dart';
import '../../../translation/presentation/providers/translation_provider.dart';

/// Provider for OcrService instance
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// OCR Screen & operation state with text understanding and multi-language translation
class OcrState {
  final XFile? imageFile;
  final bool isProcessing;
  final OcrResult? result;
  final String? errorMessage;
  final List<Word> matchedWords;
  final String selectedLanguageCode;
  final String? translatedText;
  final String? kannadaMeaning;
  final bool isTranslating;
  final String? translationError;

  const OcrState({
    this.imageFile,
    this.isProcessing = false,
    this.result,
    this.errorMessage,
    this.matchedWords = const [],
    this.selectedLanguageCode = 'kn',
    this.translatedText,
    this.kannadaMeaning,
    this.isTranslating = false,
    this.translationError,
  });

  OcrState copyWith({
    XFile? imageFile,
    bool? isProcessing,
    OcrResult? result,
    String? errorMessage,
    List<Word>? matchedWords,
    String? selectedLanguageCode,
    String? translatedText,
    String? kannadaMeaning,
    bool? isTranslating,
    String? translationError,
    bool clearError = false,
    bool clearTranslationError = false,
    bool clearTranslatedText = false,
  }) {
    return OcrState(
      imageFile: imageFile ?? this.imageFile,
      isProcessing: isProcessing ?? this.isProcessing,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      matchedWords: matchedWords ?? this.matchedWords,
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
      translatedText: clearTranslatedText ? null : (translatedText ?? this.translatedText),
      kannadaMeaning: clearTranslatedText ? null : (kannadaMeaning ?? this.kannadaMeaning),
      isTranslating: isTranslating ?? this.isTranslating,
      translationError: clearTranslationError ? null : (translationError ?? this.translationError),
    );
  }
}

/// Notifier handling camera/gallery capture, on-device OCR, and instant language transformation
class OcrNotifier extends StateNotifier<OcrState> {
  final OcrService _ocrService;
  final WordRepository? wordRepository;
  final TranslationService? translationService;

  OcrNotifier(
    this._ocrService, {
    this.wordRepository,
    this.translationService,
  }) : super(const OcrState());

  /// Pick an image with optional cropping and perform on-device OCR
  Future<void> pickAndRecognize(ImageSource source, {bool shouldCrop = true}) async {
    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearTranslationError: true,
      clearTranslatedText: true,
    );
    try {
      final file = await _ocrService.pickImage(source: source);
      if (file == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      String finalPath = file.path;
      if (shouldCrop) {
        final croppedPath = await _ocrService.cropImage(file.path);
        if (croppedPath != null && croppedPath.isNotEmpty) {
          finalPath = croppedPath;
        }
      }

      final effectiveFile = XFile(finalPath);
      state = state.copyWith(imageFile: effectiveFile, isProcessing: true);
      final ocrResult = await _ocrService.recognizeText(finalPath);

      // Find matching vocabulary words from local database
      final matched = await _findMatchingWords(ocrResult.words);

      state = state.copyWith(
        isProcessing: false,
        result: ocrResult,
        matchedWords: matched,
        errorMessage: ocrResult.isEmpty ? 'No text detected in this image. Try capturing or cropping clearer text.' : null,
      );

      // Automatically translate into the selected language
      if (ocrResult.isNotEmpty) {
        await translateCurrentText(state.selectedLanguageCode);
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'OCR Processing error: ${e.toString()}',
      );
    }
  }

  /// Crop the currently selected image and re-run OCR
  Future<void> cropCurrentImage() async {
    if (state.imageFile == null) return;
    try {
      final currentPath = state.imageFile!.path;
      final croppedPath = await _ocrService.cropImage(currentPath);
      if (croppedPath != null && croppedPath.isNotEmpty && croppedPath != currentPath) {
        state = state.copyWith(
          imageFile: XFile(croppedPath),
          isProcessing: true,
          clearError: true,
          clearTranslationError: true,
          clearTranslatedText: true,
        );
        final ocrResult = await _ocrService.recognizeText(croppedPath);
        final matched = await _findMatchingWords(ocrResult.words);

        state = state.copyWith(
          isProcessing: false,
          result: ocrResult,
          matchedWords: matched,
          errorMessage: ocrResult.isEmpty ? 'No text detected in the cropped area.' : null,
        );

        // Automatically translate newly cropped text
        if (ocrResult.isNotEmpty) {
          await translateCurrentText(state.selectedLanguageCode);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Crop error: ${e.toString()}',
      );
    }
  }

  /// Change target language and immediately translate the scanned text
  Future<void> setTargetLanguage(String languageCode) async {
    if (state.selectedLanguageCode == languageCode && state.translatedText != null) {
      return;
    }
    state = state.copyWith(
      selectedLanguageCode: languageCode,
      clearTranslationError: true,
    );
    if (state.result != null && state.result!.isNotEmpty) {
      await translateCurrentText(languageCode);
    }
  }

  /// Translate the scanned text into the specified language
  Future<void> translateCurrentText([String? languageCode]) async {
    final targetCode = languageCode ?? state.selectedLanguageCode;
    if (state.result == null || state.result!.isEmpty) return;
    if (translationService == null) return;

    state = state.copyWith(
      isTranslating: true,
      selectedLanguageCode: targetCode,
      clearTranslationError: true,
    );

    try {
      final res = await translationService!.translate(
        text: state.result!.rawText,
        targetLanguageCode: targetCode,
      );
      state = state.copyWith(
        isTranslating: false,
        translatedText: res.translatedText,
        kannadaMeaning: targetCode == 'kn' ? res.translatedText : state.kannadaMeaning,
      );
    } on TranslationNoInternetException {
      state = state.copyWith(
        isTranslating: false,
        translationError: 'Internet connection is required for translation into ${TranslationService.getLanguageName(targetCode)}. Offline vocabulary definitions are shown below.',
      );
    } catch (e) {
      state = state.copyWith(
        isTranslating: false,
        translationError: 'Could not translate text: ${e.toString()}',
      );
    }
  }

  /// Process an existing image file path
  Future<void> processImagePath(String path) async {
    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearTranslationError: true,
    );
    try {
      final ocrResult = await _ocrService.recognizeText(path);
      final matched = await _findMatchingWords(ocrResult.words);
      state = state.copyWith(
        isProcessing: false,
        result: ocrResult,
        matchedWords: matched,
        errorMessage: ocrResult.isEmpty ? 'No text detected in this image.' : null,
      );
      if (ocrResult.isNotEmpty) {
        await translateCurrentText(state.selectedLanguageCode);
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'OCR Processing error: ${e.toString()}',
      );
    }
  }

  /// Backward compatible helper for Kannada
  Future<void> understandInKannada() => translateCurrentText('kn');

  /// Search offline dictionary for words appearing in the scanned text
  Future<List<Word>> _findMatchingWords(List<String> words) async {
    if (wordRepository == null || words.isEmpty) return const [];
    try {
      final allWords = await wordRepository!.getWords();
      final wordsSet = words.map((w) => w.toLowerCase()).toSet();
      return allWords.where((w) => wordsSet.contains(w.word.toLowerCase())).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Find a specific word in local dictionary
  Future<Word?> findWord(String wordText) async {
    if (wordRepository == null) return null;
    try {
      final allWords = await wordRepository!.getWords();
      final target = wordText.trim().toLowerCase();
      final matches = allWords.where((w) => w.word.toLowerCase() == target);
      return matches.isNotEmpty ? matches.first : null;
    } catch (_) {
      return null;
    }
  }

  /// Reset OCR state
  void clear() {
    state = const OcrState();
  }
}

/// StateNotifierProvider for OCR with dependency injection
final ocrNotifierProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  final service = ref.watch(ocrServiceProvider);
  final wordRepo = ref.watch(wordRepositoryProvider);
  final translationService = ref.watch(translationServiceProvider);
  return OcrNotifier(
    service,
    wordRepository: wordRepo,
    translationService: translationService,
  );
});
