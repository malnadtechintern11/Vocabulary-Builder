import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/tts_service.dart';
import '../../../data/sentences_data.dart';
import '../../../models/sentence.dart';

/// Persistence key for storing favorite sentence IDs
const String _kFavoriteSentencesPrefsKey = 'favorite_sentence_ids';

/// Provider for managing favorite sentence IDs backed by SharedPreferences
final favoriteSentenceIdsProvider =
    StateNotifierProvider<FavoriteSentencesNotifier, Set<String>>((ref) {
  final notifier = FavoriteSentencesNotifier();
  notifier.loadFavorites();
  return notifier;
});

class FavoriteSentencesNotifier extends StateNotifier<Set<String>> {
  FavoriteSentencesNotifier() : super(<String>{});

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kFavoriteSentencesPrefsKey) ?? [];
      state = list.toSet();
    } catch (_) {
      // Graceful fallback to in-memory set
    }
  }

  Future<void> toggleFavorite(String sentenceId) async {
    final next = Set<String>.from(state);
    if (next.contains(sentenceId)) {
      next.remove(sentenceId);
    } else {
      next.add(sentenceId);
    }
    state = next;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kFavoriteSentencesPrefsKey, next.toList());
    } catch (_) {}
  }

  bool isFavorite(String sentenceId) => state.contains(sentenceId);
}

/// Search query provider for filtering sentences
final sentenceSearchQueryProvider = StateProvider<String>((ref) => '');

/// Selected difficulty filter: 'All', 'Beginner', 'Intermediate', 'Advanced', or 'Favorites'
final sentenceDifficultyFilterProvider = StateProvider<String>((ref) => 'All');

/// Provider returning all 120+ sentences enriched with user favorite status
final allSentencesProvider = Provider<List<Sentence>>((ref) {
  final favoriteIds = ref.watch(favoriteSentenceIdsProvider);
  return SentencesData.sentences.map((s) {
    return s.copyWith(isFavorite: favoriteIds.contains(s.id));
  }).toList();
});

/// Provider returning sentences filtered by selected difficulty and active search query
final filteredSentencesProvider = Provider<List<Sentence>>((ref) {
  final all = ref.watch(allSentencesProvider);
  final filter = ref.watch(sentenceDifficultyFilterProvider);
  final query = ref.watch(sentenceSearchQueryProvider).trim().toLowerCase();

  return all.where((sentence) {
    // 1. Difficulty & Tab filtering
    if (filter == 'Favorites') {
      if (!sentence.isFavorite) return false;
    } else if (filter != 'All') {
      if (sentence.difficulty.toLowerCase() != filter.toLowerCase()) {
        return false;
      }
    }

    // 2. Search query filtering
    if (query.isEmpty) return true;

    final inText = sentence.text.toLowerCase().contains(query);
    final inMeaning = sentence.meaning.toLowerCase().contains(query);
    final inCategory = sentence.category.toLowerCase().contains(query);
    final inVocab = sentence.vocabularyWords.any((v) =>
        v.word.toLowerCase().contains(query) ||
        v.meaning.toLowerCase().contains(query));

    return inText || inMeaning || inCategory || inVocab;
  }).toList();
});

/// Current sentence index in Practice Mode
final sentencePracticeIndexProvider = StateProvider<int>((ref) => 0);

/// Currently playing TTS sentence ID
final ttsSpeakingSentenceIdProvider = StateProvider<String?>((ref) => null);

/// Controller for TTS operations connected to Riverpod
final ttsControllerProvider = Provider<TtsController>((ref) {
  return TtsController(ref);
});

class TtsController {
  final Ref ref;
  final TtsService _service = TtsService.instance;

  TtsController(this.ref);

  Future<void> speakSentence(Sentence sentence) async {
    final currentSpeaking = ref.read(ttsSpeakingSentenceIdProvider);
    if (currentSpeaking == sentence.id) {
      await _service.stop();
      ref.read(ttsSpeakingSentenceIdProvider.notifier).state = null;
      return;
    }

    ref.read(ttsSpeakingSentenceIdProvider.notifier).state = sentence.id;
    try {
      await _service.speak(sentence.text, sentenceId: sentence.id);
    } finally {
      // Delay slightly for speech duration completion
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (ref.read(ttsSpeakingSentenceIdProvider) == sentence.id) {
          ref.read(ttsSpeakingSentenceIdProvider.notifier).state = null;
        }
      });
    }
  }

  Future<void> stop() async {
    await _service.stop();
    ref.read(ttsSpeakingSentenceIdProvider.notifier).state = null;
  }
}
