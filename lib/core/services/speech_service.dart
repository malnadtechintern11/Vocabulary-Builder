import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Singleton service managing voice recognition and speech-to-text functionality
class SpeechService {
  static final SpeechService instance = SpeechService._internal();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isAvailable = false;
  VoidCallback? onListeningStateChanged;

  SpeechService._internal();

  bool get isAvailable => _isAvailable;
  bool get isListening => _speechToText.isListening;

  /// Initialize speech recognition
  Future<bool> init() async {
    if (_isInitialized) return _isAvailable;

    try {
      _isAvailable = await _speechToText.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: kDebugMode,
      );
      _isInitialized = true;
      return _isAvailable;
    } catch (e) {
      debugPrint('SpeechService init warning: $e');
      _isAvailable = false;
      _isInitialized = true;
      return false;
    }
  }

  void _onError(SpeechRecognitionError error) {
    debugPrint('SpeechService error: ${error.errorMsg}');
    onListeningStateChanged?.call();
  }

  void _onStatus(String status) {
    debugPrint('SpeechService status: $status');
    onListeningStateChanged?.call();
  }

  String? _cachedEnglishLocale;

  /// Returns the preferred English locale supported on this device (e.g. en_US, en_IN, en_GB)
  Future<String?> getPreferredEnglishLocale() async {
    if (_cachedEnglishLocale != null) return _cachedEnglishLocale;
    try {
      final locales = await _speechToText.locales();
      for (final loc in locales) {
        final id = loc.localeId.toLowerCase();
        if (id == 'en_us' || id == 'en_in' || id == 'en_gb' || id.startsWith('en_') || id.startsWith('en-')) {
          _cachedEnglishLocale = loc.localeId;
          return _cachedEnglishLocale;
        }
      }
    } catch (e) {
      debugPrint('SpeechService getPreferredEnglishLocale warning: $e');
    }
    return null;
  }

  /// Start listening for user speech
  Future<bool> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    Function(double soundLevel)? onSoundLevelChange,
    String? localeId,
    Duration listenFor = const Duration(seconds: 25),
    Duration pauseFor = const Duration(seconds: 4),
    ListenMode listenMode = ListenMode.dictation,
  }) async {
    try {
      final hasInit = await init();
      if (!hasInit) {
        return false;
      }

      final resolvedLocale = localeId ?? await getPreferredEnglishLocale();

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords, result.finalResult);
          onListeningStateChanged?.call();
        },
        onSoundLevelChange: onSoundLevelChange,
        listenOptions: SpeechListenOptions(
          listenFor: listenFor,
          pauseFor: pauseFor,
          partialResults: true,
          cancelOnError: false,
          listenMode: listenMode,
          localeId: resolvedLocale,
        ),
      );

      onListeningStateChanged?.call();
      return true;
    } catch (e) {
      debugPrint('SpeechService startListening error: $e');
      onListeningStateChanged?.call();
      return false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      debugPrint('SpeechService stopListening error: $e');
    } finally {
      onListeningStateChanged?.call();
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
    } catch (e) {
      debugPrint('SpeechService cancelListening error: $e');
    } finally {
      onListeningStateChanged?.call();
    }
  }
}

/// State notifier tracking whether the mic is currently listening
class VoiceListeningNotifier extends StateNotifier<bool> {
  VoiceListeningNotifier() : super(false) {
    SpeechService.instance.onListeningStateChanged = () {
      if (mounted) {
        state = SpeechService.instance.isListening;
      }
    };
  }

  void setListening(bool value) {
    state = value;
  }
}

/// Provider exposing whether voice search is actively listening
final voiceListeningProvider = StateNotifierProvider<VoiceListeningNotifier, bool>((ref) {
  return VoiceListeningNotifier();
});
