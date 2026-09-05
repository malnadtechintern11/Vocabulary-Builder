import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Representation of a single word's match status in pronunciation evaluation
class WordPronunciationStatus {
  final String word;
  final bool isMatched;

  const WordPronunciationStatus({
    required this.word,
    required this.isMatched,
  });
}

/// Overall pronunciation evaluation result
class SentencePronunciationResult {
  final int accuracyScore; // 0 to 100
  final List<WordPronunciationStatus> words;
  final String spokenText;
  final String title;
  final String description;
  final Color statusColor;

  const SentencePronunciationResult({
    required this.accuracyScore,
    required this.words,
    required this.spokenText,
    required this.title,
    required this.description,
    required this.statusColor,
  });
}

/// Service to analyze and grade spoken English sentences against reference text
class SentencePronunciationService {
  const SentencePronunciationService();

  static List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s']"), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  /// Evaluates spoken user transcript against the target sentence
  static SentencePronunciationResult evaluate({
    required String targetSentence,
    required String spokenTranscript,
  }) {
    final targetTokens = _tokenize(targetSentence);
    final spokenTokens = _tokenize(spokenTranscript);

    if (targetTokens.isEmpty) {
      return const SentencePronunciationResult(
        accuracyScore: 0,
        words: [],
        spokenText: '',
        title: 'No Speech Detected',
        description: 'Please speak clearly into the microphone.',
        statusColor: AppColors.textTertiaryLight,
      );
    }

    if (spokenTokens.isEmpty) {
      return SentencePronunciationResult(
        accuracyScore: 0,
        words: targetTokens
            .map((w) => WordPronunciationStatus(word: w, isMatched: false))
            .toList(),
        spokenText: '',
        title: 'No Speech Detected',
        description: 'We could not hear your speech. Tap the mic and try speaking again.',
        statusColor: AppColors.incorrectRed,
      );
    }

    // Keep track of which spoken words have been consumed
    final remainingSpoken = List<String>.from(spokenTokens);
    final wordStatuses = <WordPronunciationStatus>[];
    int matchedCount = 0;

    for (final targetWord in targetTokens) {
      // 1. Check exact match
      final exactIndex = remainingSpoken.indexOf(targetWord);
      if (exactIndex != -1) {
        matchedCount++;
        remainingSpoken.removeAt(exactIndex);
        wordStatuses.add(WordPronunciationStatus(word: targetWord, isMatched: true));
        continue;
      }

      // 2. Check stem / prefix / suffix match (e.g. running vs run)
      int fuzzyIndex = -1;
      for (int i = 0; i < remainingSpoken.length; i++) {
        final candidate = remainingSpoken[i];
        if (_isSimilar(targetWord, candidate)) {
          fuzzyIndex = i;
          break;
        }
      }

      if (fuzzyIndex != -1) {
        matchedCount++;
        remainingSpoken.removeAt(fuzzyIndex);
        wordStatuses.add(WordPronunciationStatus(word: targetWord, isMatched: true));
      } else {
        wordStatuses.add(WordPronunciationStatus(word: targetWord, isMatched: false));
      }
    }

    // Calculate score based on ratio of matched words
    final rawRatio = matchedCount / targetTokens.length;
    final score = (rawRatio * 100).round().clamp(0, 100);

    final String title;
    final String description;
    final Color color;

    if (score >= 90) {
      title = 'Outstanding! 🌟';
      description = 'Fluent, accurate pronunciation! Excellent mastery.';
      color = AppColors.success;
    } else if (score >= 75) {
      title = 'Great Job! 👍';
      description = 'Clear pronunciation. Just a couple of words to polish!';
      color = AppColors.difficultyIntermediate;
    } else if (score >= 50) {
      title = 'Good Effort! 💪';
      description = 'Keep going! Listen to the native audio and practice the missed words.';
      color = AppColors.primary;
    } else {
      title = 'Keep Practicing! 🔄';
      description = 'Listen to the audio guide and try speaking the sentence once more.';
      color = AppColors.incorrectRed;
    }

    return SentencePronunciationResult(
      accuracyScore: score,
      words: wordStatuses,
      spokenText: spokenTranscript.trim(),
      title: title,
      description: description,
      statusColor: color,
    );
  }

  static bool _isSimilar(String a, String b) {
    if (a == b) return true;
    if (a.length > 3 && b.length > 3) {
      if (a.startsWith(b) || b.startsWith(a)) return true;
    }
    return false;
  }
}
