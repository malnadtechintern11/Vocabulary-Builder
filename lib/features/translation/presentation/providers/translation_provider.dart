import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/translation_service.dart';

/// Provider for TranslationService instance
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

/// Translation state structure
class TranslationState {
  final String inputText;
  final String targetLanguageCode;
  final String sourceLanguageCode;
  final bool isLoading;
  final TranslationResult? result;
  final String? errorMessage;
  final bool isOfflineError;

  const TranslationState({
    this.inputText = '',
    this.targetLanguageCode = 'kn', // Default to Kannada
    this.sourceLanguageCode = 'auto',
    this.isLoading = false,
    this.result,
    this.errorMessage,
    this.isOfflineError = false,
  });

  TranslationState copyWith({
    String? inputText,
    String? targetLanguageCode,
    String? sourceLanguageCode,
    bool? isLoading,
    TranslationResult? result,
    String? errorMessage,
    bool? isOfflineError,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return TranslationState(
      inputText: inputText ?? this.inputText,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      sourceLanguageCode: sourceLanguageCode ?? this.sourceLanguageCode,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isOfflineError: isOfflineError ?? this.isOfflineError,
    );
  }
}

/// Notifier managing online translation operations and offline error handling
class TranslationNotifier extends StateNotifier<TranslationState> {
  final TranslationService _translationService;

  TranslationNotifier(this._translationService) : super(const TranslationState());

  /// Update input text
  void setInputText(String text) {
    state = state.copyWith(inputText: text, clearError: true);
  }

  /// Change target language
  void setTargetLanguage(String code) {
    state = state.copyWith(targetLanguageCode: code, clearError: true);
    if (state.inputText.trim().isNotEmpty) {
      translate();
    }
  }

  /// Change source language
  void setSourceLanguage(String code) {
    state = state.copyWith(sourceLanguageCode: code, clearError: true);
  }

  /// Swap source and target languages
  void swapLanguages() {
    if (state.sourceLanguageCode == 'auto') return;
    final oldSource = state.sourceLanguageCode;
    final oldTarget = state.targetLanguageCode;
    state = state.copyWith(
      sourceLanguageCode: oldTarget,
      targetLanguageCode: oldSource,
      clearError: true,
    );
    if (state.result != null) {
      state = state.copyWith(
        inputText: state.result!.translatedText,
      );
      translate();
    }
  }

  /// Execute online translation
  Future<void> translate({String? textOverride}) async {
    final text = (textOverride ?? state.inputText).trim();
    if (text.isEmpty) {
      state = state.copyWith(
        clearResult: true,
        clearError: true,
        isOfflineError: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isOfflineError: false,
    );

    try {
      final result = await _translationService.translate(
        text: text,
        targetLanguageCode: state.targetLanguageCode,
        sourceLanguageCode: state.sourceLanguageCode,
      );

      state = state.copyWith(
        isLoading: false,
        result: result,
        clearError: true,
        isOfflineError: false,
      );
    } on TranslationNoInternetException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Internet connection is required for translation',
        isOfflineError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        isOfflineError: false,
      );
    }
  }

  /// Clear inputs and results
  void clear() {
    state = state.copyWith(
      inputText: '',
      clearResult: true,
      clearError: true,
      isOfflineError: false,
    );
  }
}

/// StateNotifierProvider for translation
final translationNotifierProvider = StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  final service = ref.watch(translationServiceProvider);
  return TranslationNotifier(service);
});
