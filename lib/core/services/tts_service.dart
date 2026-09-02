import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service managing text-to-speech pronunciation for sentences and vocabulary
class TtsService {
  static final TtsService instance = TtsService._internal();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String? _currentlySpeakingId;

  TtsService._internal();

  /// Initialize TTS settings
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.46);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        debugPrint('TTS started speaking');
      });

      _flutterTts.setCompletionHandler(() {
        _currentlySpeakingId = null;
        debugPrint('TTS completed speaking');
      });

      _flutterTts.setErrorHandler((msg) {
        _currentlySpeakingId = null;
        debugPrint('TTS error handler: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization warning: $e');
    }
  }

  /// Speaks the given text. Falls back gracefully on desktop if needed.
  Future<void> speak(String text, {String? sentenceId}) async {
    _currentlySpeakingId = sentenceId;
    try {
      await init();
      final result = await _flutterTts.speak(text);
      if (result != 1 && !kIsWeb && Platform.isWindows) {
        _speakWindowsFallback(text);
      }
    } catch (e) {
      debugPrint('FlutterTts failed: $e. Attempting fallback if on Windows.');
      if (!kIsWeb && Platform.isWindows) {
        _speakWindowsFallback(text);
      }
    }
  }

  /// Stop any active speech
  Future<void> stop() async {
    _currentlySpeakingId = null;
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Platform fallback using built-in Windows System.Speech SAPI
  void _speakWindowsFallback(String text) {
    try {
      final sanitized = text.replaceAll("'", "''").replaceAll('"', ' ');
      Process.run('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        'Add-Type -AssemblyName System.Speech; \$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer; \$synth.Rate = 0; \$synth.Speak(\'$sanitized\');',
      ]).then((res) {
        _currentlySpeakingId = null;
      }).catchError((err) {
        _currentlySpeakingId = null;
        debugPrint('Windows SAPI fallback warning: $err');
      });
    } catch (e) {
      _currentlySpeakingId = null;
      debugPrint('Windows TTS fallback failed: $e');
    }
  }

  /// Whether a specific sentence is currently speaking
  bool isSpeaking(String sentenceId) => _currentlySpeakingId == sentenceId;
}
