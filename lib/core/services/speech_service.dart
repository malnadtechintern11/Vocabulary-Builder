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

  /// Start listening for user speech
  Future<bool> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    Duration listenFor = const Duration(seconds: 10),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    try {
      final hasInit = await init();
      if (!hasInit) {
        return false;
      }

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords, result.finalResult);
          onListeningStateChanged?.call();
        },
        listenOptions: SpeechListenOptions(
          listenFor: listenFor,
          pauseFor: pauseFor,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.search,
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
