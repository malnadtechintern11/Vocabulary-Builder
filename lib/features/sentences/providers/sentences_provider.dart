import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../../../core/services/online_sentence_service.dart';
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

/// Persistence key for storing saved custom/online sentences
const String _kSavedCustomSentencesPrefsKey = 'saved_custom_sentences_json';

/// Provider managing custom user-saved sentences (stored in SQLite + SharedPreferences)
final savedSentencesProvider =
    StateNotifierProvider<SavedSentencesNotifier, List<Sentence>>((ref) {
  final notifier = SavedSentencesNotifier();
  notifier.loadSavedSentences();
  return notifier;
});

class SavedSentencesNotifier extends StateNotifier<List<Sentence>> {
  SavedSentencesNotifier() : super([]);

  Future<void> loadSavedSentences() async {
    try {
      final List<Sentence> list = [];

      // 1. Load from SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonStringList = prefs.getStringList(_kSavedCustomSentencesPrefsKey) ?? [];
        for (final str in jsonStringList) {
          try {
            final map = jsonDecode(str) as Map<String, dynamic>;
            list.add(Sentence.fromJson(map));
          } catch (_) {}
        }
      } catch (_) {}

      // 2. Query SQLite custom_sentences table
      try {
        final db = await AppDatabase.instance.database;
        final rows = await db.query(DatabaseTables.tableCustomSentences);
        for (final row in rows) {
          final id = row['id'] as String;
          if (!list.any((s) => s.id == id)) {
            final vocabJson = row['vocabulary_words'] as String? ?? '[]';
            final vocabList = (jsonDecode(vocabJson) as List<dynamic>? ?? [])
                .map((e) => SentenceWord.fromJson(e as Map<String, dynamic>))
                .toList();

            list.add(Sentence(
              id: id,
              text: row['text'] as String,
              meaning: row['meaning'] as String,
              kannadaMeaning: row['kannada_meaning'] as String? ?? '',
              vocabularyWords: vocabList,
              difficulty: row['difficulty'] as String? ?? 'Beginner',
              category: row['category'] as String? ?? 'General',
              isFavorite: (row['is_favorite'] as int? ?? 0) == 1,
              isPracticed: (row['is_practiced'] as int? ?? 0) == 1,
              isOnline: false,
            ));
          }
        }
      } catch (dbErr) {
        debugPrint('SQLite custom_sentences query error: $dbErr');
      }

      state = list;
    } catch (_) {}
  }

  Future<Sentence> saveSentence(Sentence sentence) async {
    final localSentence = sentence.copyWith(isOnline: false);
    // Remove if already exists with same ID or text
    final current = state
        .where((s) =>
            s.id != localSentence.id &&
            s.text.trim().toLowerCase() != localSentence.text.trim().toLowerCase())
        .toList();
    final next = [localSentence, ...current];
    state = next;

    // Persist to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStringList = next.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_kSavedCustomSentencesPrefsKey, jsonStringList);
    } catch (_) {}

    // Persist to SQLite
    try {
      final db = await AppDatabase.instance.database;
      await db.insert(
        DatabaseTables.tableCustomSentences,
        {
          'id': localSentence.id,
          'text': localSentence.text,
          'meaning': localSentence.meaning,
          'kannada_meaning': localSentence.kannadaMeaning,
          'vocabulary_words': jsonEncode(localSentence.vocabularyWords.map((v) => v.toJson()).toList()),
          'difficulty': localSentence.difficulty,
          'category': localSentence.category,
          'is_favorite': localSentence.isFavorite ? 1 : 0,
          'is_practiced': localSentence.isPracticed ? 1 : 0,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('SQLite insert custom sentence error: $e');
    }

    return localSentence;
  }

  Future<void> removeSentence(String sentenceId) async {
    final next = state.where((s) => s.id != sentenceId).toList();
    state = next;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStringList = next.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList(_kSavedCustomSentencesPrefsKey, jsonStringList);
    } catch (_) {}

    try {
      final db = await AppDatabase.instance.database;
      await db.delete(
        DatabaseTables.tableCustomSentences,
        where: 'id = ?',
        whereArgs: [sentenceId],
      );
    } catch (_) {}
  }

  bool isSentenceSaved(String sentenceText) {
    final clean = sentenceText.trim().toLowerCase();
    return state.any((s) => s.text.trim().toLowerCase() == clean);
  }
}

/// Provider returning all sentences (built-in 600 + user saved custom sentences) enriched with user favorite and practiced status
final allSentencesProvider = Provider<List<Sentence>>((ref) {
  final favoriteIds = ref.watch(favoriteSentenceIdsProvider);
  final practicedIds = ref.watch(practicedSentenceIdsProvider);
  final savedCustomSentences = ref.watch(savedSentencesProvider);

  // Combine user-saved sentences + built-in 600 sentences
  final combined = <Sentence>[
    ...savedCustomSentences,
    ...SentencesData.sentences,
  ];

  return combined.map((s) {
    return s.copyWith(
      isFavorite: favoriteIds.contains(s.id),
      isPracticed: practicedIds.contains(s.id),
      isOnline: false,
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

/// Online Sentence Service provider
final onlineSentenceServiceProvider = Provider<OnlineSentenceService>((ref) {
  return OnlineSentenceService();
});

/// Async provider for sentences, automatically fetching from online API when local data has no matches
final filteredSentencesAsyncProvider = FutureProvider<List<Sentence>>((ref) async {
  final all = ref.watch(allSentencesProvider);
  final filter = ref.watch(sentenceDifficultyFilterProvider);
  final category = ref.watch(sentenceCategoryFilterProvider);
  final query = ref.watch(sentenceSearchQueryProvider).trim().toLowerCase();

  // 1. Filter local sentences first
  final localFiltered = all.where((sentence) {
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
    final inKannada = sentence.kannadaMeaning.toLowerCase().contains(query);
    final inCategory = sentence.category.toLowerCase().contains(query);
    final inVocab = sentence.vocabularyWords.any((v) =>
        v.word.toLowerCase().contains(query) ||
        v.meaning.toLowerCase().contains(query));

    return inText || inMeaning || inKannada || inCategory || inVocab;
  }).toList();

  // If local results are found or search query is empty, return local data immediately (100% offline)
  if (localFiltered.isNotEmpty || query.isEmpty) {
    return localFiltered;
  }

  // 2. If NO local sentences match and search query is not empty, automatically fetch online
  final onlineService = ref.watch(onlineSentenceServiceProvider);
  try {
    final onlineSentence = await onlineService.fetchSentenceDetails(query);
    return [onlineSentence];
  } on SentenceNotFoundOnlineException {
    return [];
  } on SentenceNoInternetException {
    rethrow;
  } catch (e) {
    final errStr = e.toString().toLowerCase();
    if (errStr.contains('socket') ||
        errStr.contains('network') ||
        errStr.contains('offline') ||
        errStr.contains('connection') ||
        errStr.contains('host')) {
      throw const SentenceNoInternetException();
    }
    throw SentenceNotFoundOnlineException(query, e.toString());
  }
});

/// Synchronous backward-compatible filteredSentencesProvider
final filteredSentencesProvider = Provider<List<Sentence>>((ref) {
  return ref.watch(filteredSentencesAsyncProvider).maybeWhen(
        data: (list) => list,
        orElse: () => [],
      );
});

/// Current sentence index in Practice Mode
final sentencePracticeIndexProvider = StateProvider<int>((ref) => 0);

/// Currently playing TTS sentence ID provider linked to global active TTS ID
final ttsSpeakingSentenceIdProvider = Provider<String?>((ref) {
  return ref.watch(activeTtsIdProvider);
});

/// Controller for TTS operations connected to Riverpod
final ttsControllerProvider = Provider<TtsController>((ref) {
  return TtsController(ref);
});

class TtsController {
  final Ref ref;

  TtsController(this.ref);

  Future<void> speakSentence(Sentence sentence) async {
    await ref.read(appTtsControllerProvider).toggleSpeak(
          id: sentence.id,
          text: sentence.text,
        );
  }

  Future<void> stop() async {
    await ref.read(appTtsControllerProvider).stop();
  }
}
