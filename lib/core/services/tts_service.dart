import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Singleton service managing native offline text-to-speech pronunciation
class TtsService {
  static final TtsService instance = TtsService._internal();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String? _currentlySpeakingId;
  VoidCallback? onSpeechStateChanged;
  Timer? _safetyTimer;

  TtsService._internal();

  /// Initialize TTS settings
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        debugPrint('TTS: Started speaking [$_currentlySpeakingId]');
        onSpeechStateChanged?.call();
      });

      _flutterTts.setCompletionHandler(() {
        debugPrint('TTS: Completed speaking [$_currentlySpeakingId]');
        _safetyTimer?.cancel();
        _currentlySpeakingId = null;
        onSpeechStateChanged?.call();
      });

      _flutterTts.setCancelHandler(() {
        debugPrint('TTS: Cancelled speech');
        _safetyTimer?.cancel();
        _currentlySpeakingId = null;
        onSpeechStateChanged?.call();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS error: $msg');
        _safetyTimer?.cancel();
        _currentlySpeakingId = null;
        onSpeechStateChanged?.call();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization warning: $e');
    }
  }

  /// Speaks the given text with an associated unique ID.
  Future<void> speak(String text, {String? id}) async {
    _safetyTimer?.cancel();
    _currentlySpeakingId = id ?? text;
    onSpeechStateChanged?.call();

    try {
      await init();
      // Ensure any current speech is stopped before speaking new text
      await _flutterTts.stop();
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

    // Set a safety timeout to reset speaking state if completion handler is not triggered by platform
    final wordCount = text.trim().split(RegExp(r'\s+')).length;
    final estimatedDurationMs = max(1500, wordCount * 500 + 800);
    _safetyTimer = Timer(Duration(milliseconds: estimatedDurationMs), () {
      if (_currentlySpeakingId == (id ?? text)) {
        _currentlySpeakingId = null;
        onSpeechStateChanged?.call();
      }
    });
  }

  /// Stop any active speech immediately
  Future<void> stop() async {
    _safetyTimer?.cancel();
    _currentlySpeakingId = null;
    onSpeechStateChanged?.call();
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
        _safetyTimer?.cancel();
        _currentlySpeakingId = null;
        onSpeechStateChanged?.call();
      }).catchError((err) {
        _safetyTimer?.cancel();
        _currentlySpeakingId = null;
        onSpeechStateChanged?.call();
        debugPrint('Windows SAPI fallback warning: $err');
      });
    } catch (e) {
      _safetyTimer?.cancel();
      _currentlySpeakingId = null;
      onSpeechStateChanged?.call();
      debugPrint('Windows TTS fallback failed: $e');
    }
  }

  /// Check if a specific ID is currently speaking
  bool isSpeaking(String id) => _currentlySpeakingId == id;

  /// Currently active speaking identifier
  String? get currentlySpeakingId => _currentlySpeakingId;
}

/// Reactive StateNotifier providing real-time audio playback status across widgets
class ActiveTtsNotifier extends StateNotifier<String?> {
  ActiveTtsNotifier() : super(null) {
    TtsService.instance.onSpeechStateChanged = () {
      if (mounted) {
        state = TtsService.instance.currentlySpeakingId;
      }
    };
  }

  /// Toggle speech: if currently speaking this text/id, stop it; otherwise speak it
  Future<void> toggle({required String id, required String text}) async {
    if (state == id) {
      await TtsService.instance.stop();
      state = null;
    } else {
      state = id;
      await TtsService.instance.speak(text, id: id);
    }
  }

  /// Stop speech immediately
  Future<void> stop() async {
    await TtsService.instance.stop();
    state = null;
  }
}

/// Global provider for currently active speaking identifier
final activeTtsIdProvider = StateNotifierProvider<ActiveTtsNotifier, String?>((ref) {
  return ActiveTtsNotifier();
});

/// Legacy compatibility alias provider for vocabulary words
final speakingWordProvider = Provider<String?>((ref) {
  final activeId = ref.watch(activeTtsIdProvider);
  if (activeId != null && activeId.startsWith('word_')) {
    return activeId.substring(5);
  }
  return activeId;
});

/// Unified App TTS Controller provider for all screens and components
final appTtsControllerProvider = Provider<AppTtsController>((ref) {
  return AppTtsController(ref);
});

class AppTtsController {
  final Ref ref;

  AppTtsController(this.ref);

  /// Toggle pronunciation of English text with given ID
  Future<void> toggleSpeak({required String id, required String text}) async {
    await ref.read(activeTtsIdProvider.notifier).toggle(id: id, text: text);
  }

  /// Pronounce a single vocabulary word
  Future<void> speakWord(String word) async {
    await toggleSpeak(id: 'word_$word', text: word);
  }

  /// Pronounce general text with optional custom ID
  Future<void> speakText(String text, {String? id}) async {
    final speakId = id ?? 'text_${text.hashCode}';
    await toggleSpeak(id: speakId, text: text);
  }

  /// Stop speech
  Future<void> stop() async {
    await ref.read(activeTtsIdProvider.notifier).stop();
  }
}

/// Legacy controller alias for existing word widgets
final wordTtsControllerProvider = Provider<WordTtsController>((ref) {
  return WordTtsController(ref);
});

class WordTtsController {
  final Ref ref;

  WordTtsController(this.ref);

  Future<void> speakWord(String word) async {
    await ref.read(appTtsControllerProvider).speakWord(word);
  }

  Future<void> speakText(String text, {String? id}) async {
    await ref.read(appTtsControllerProvider).speakText(text, id: id);
  }

  Future<void> stop() async {
    await ref.read(appTtsControllerProvider).stop();
  }
}
