import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/tts_service.dart';
import '../../../data/sentences_data.dart';
import '../../../models/sentence.dart';

/// Persistence key for storing favorite sentence IDs
const String _kFavoriteSentencesPrefsKey = 'favorite_sentence_ids';

/// Persistence key for storing practiced/learned sentence IDs
const String _kPracticedSentencesPrefsKey = 'practiced_sentence_ids';

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
    } catch (_) {}
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

/// Provider for managing practiced/learned sentence IDs backed by SharedPreferences
final practicedSentenceIdsProvider =
    StateNotifierProvider<PracticedSentencesNotifier, Set<String>>((ref) {
  final notifier = PracticedSentencesNotifier();
  notifier.loadPracticed();
  return notifier;
});

class PracticedSentencesNotifier extends StateNotifier<Set<String>> {
  PracticedSentencesNotifier() : super(<String>{});

  Future<void> loadPracticed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kPracticedSentencesPrefsKey) ?? [];
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> markAsPracticed(String sentenceId) async {
    if (state.contains(sentenceId)) return;
    final next = Set<String>.from(state)..add(sentenceId);
    state = next;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kPracticedSentencesPrefsKey, next.toList());
    } catch (_) {}
  }

  Future<void> togglePracticed(String sentenceId) async {
    final next = Set<String>.from(state);
    if (next.contains(sentenceId)) {
      next.remove(sentenceId);
    } else {
      next.add(sentenceId);
    }
    state = next;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kPracticedSentencesPrefsKey, next.toList());
    } catch (_) {}
  }

  bool isPracticed(String sentenceId) => state.contains(sentenceId);
}

/// Search query provider for filtering sentences
final sentenceSearchQueryProvider = StateProvider<String>((ref) => '');

/// Selected difficulty filter: 'All', 'Beginner', 'Intermediate', 'Advanced', 'Favorites', or 'Practiced'
final sentenceDifficultyFilterProvider = StateProvider<String>((ref) => 'All');

/// Selected category filter: 'All' or specific category name
final sentenceCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// Available categories extracted from sentence dataset
final sentenceCategoriesListProvider = Provider<List<String>>((ref) {
  return [
    'All',
    'Daily Conversation',
    'Family',
    'School',
    'Work',
    'Travel',
    'Shopping',
    'Food',
    'Hobbies',
    'Health',
    'Weather',
    'Technology',
    'Everyday English',
  ];
});

/// Provider returning all 600 sentences enriched with user favorite and practiced status
final allSentencesProvider = Provider<List<Sentence>>((ref) {
  final favoriteIds = ref.watch(favoriteSentenceIdsProvider);
  final practicedIds = ref.watch(practicedSentenceIdsProvider);

  return SentencesData.sentences.map((s) {
    return s.copyWith(
      isFavorite: favoriteIds.contains(s.id),
      isPracticed: practicedIds.contains(s.id),
    );
  }).toList();
});

/// Progress statistics data structure
class SentenceProgressStats {
  final int totalSentences;
  final int totalPracticed;
  final int totalFavorites;
  final int beginnerPracticed;
  final int beginnerTotal;
  final int intermediatePracticed;
  final int intermediateTotal;
  final int advancedPracticed;
  final int advancedTotal;

  const SentenceProgressStats({
    required this.totalSentences,
    required this.totalPracticed,
    required this.totalFavorites,
    required this.beginnerPracticed,
    required this.beginnerTotal,
    required this.intermediatePracticed,
    required this.intermediateTotal,
    required this.advancedPracticed,
    required this.advancedTotal,
  });

  double get overallPercentage =>
      totalSentences == 0 ? 0.0 : (totalPracticed / totalSentences);

  double get beginnerPercentage =>
      beginnerTotal == 0 ? 0.0 : (beginnerPracticed / beginnerTotal);

  double get intermediatePercentage =>
      intermediateTotal == 0 ? 0.0 : (intermediatePracticed / intermediateTotal);

  double get advancedPercentage =>
      advancedTotal == 0 ? 0.0 : (advancedPracticed / advancedTotal);
}

/// Provider computing real-time learning progress across all 600 sentences
final sentenceProgressStatsProvider = Provider<SentenceProgressStats>((ref) {
  final all = ref.watch(allSentencesProvider);
  final practicedIds = ref.watch(practicedSentenceIdsProvider);
  final favoriteIds = ref.watch(favoriteSentenceIdsProvider);

  int bTotal = 0;
  int bPracticed = 0;
  int iTotal = 0;
  int iPracticed = 0;
  int aTotal = 0;
  int aPracticed = 0;

  for (final s in all) {
    final isDone = practicedIds.contains(s.id);
    switch (s.difficulty.toLowerCase()) {
      case 'beginner':
        bTotal++;
        if (isDone) bPracticed++;
        break;
      case 'intermediate':
        iTotal++;
        if (isDone) iPracticed++;
        break;
      case 'advanced':
        aTotal++;
        if (isDone) aPracticed++;
        break;
    }
  }

  return SentenceProgressStats(
    totalSentences: all.length,
    totalPracticed: practicedIds.length,
    totalFavorites: favoriteIds.length,
    beginnerPracticed: bPracticed,
    beginnerTotal: bTotal,
    intermediatePracticed: iPracticed,
    intermediateTotal: iTotal,
    advancedPracticed: aPracticed,
    advancedTotal: aTotal,
  );
});

/// Provider returning sentences filtered by level, category, and active search query
final filteredSentencesProvider = Provider<List<Sentence>>((ref) {
  final all = ref.watch(allSentencesProvider);
  final filter = ref.watch(sentenceDifficultyFilterProvider);
  final category = ref.watch(sentenceCategoryFilterProvider);
  final query = ref.watch(sentenceSearchQueryProvider).trim().toLowerCase();

  return all.where((sentence) {
    // 1. Difficulty & Tab filtering
    if (filter == 'Favorites') {
      if (!sentence.isFavorite) return false;
    } else if (filter == 'Practiced') {
      if (!sentence.isPracticed) return false;
    } else if (filter != 'All') {
      if (sentence.difficulty.toLowerCase() != filter.toLowerCase()) {
        return false;
      }
    }

    // 2. Category filtering
    if (category != 'All') {
      if (sentence.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
    }

    // 3. Search query filtering
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
