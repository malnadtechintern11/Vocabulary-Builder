import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/word_local_data_source.dart';
import '../../data/repositories/word_repository_impl.dart';
import '../../domain/entities/word.dart';
import '../../domain/repositories/word_repository.dart';
import '../../domain/usecases/add_word_usecase.dart';
import '../../domain/usecases/get_word_by_id_usecase.dart';
import '../../domain/usecases/get_word_statistics_usecase.dart';
import '../../domain/usecases/get_words_usecase.dart';
import '../../domain/usecases/search_words_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../../domain/usecases/toggle_learned_usecase.dart';

// --- Dependency Injection Providers ---

final wordLocalDataSourceProvider = Provider<WordLocalDataSource>((ref) {
  return WordLocalDataSourceImpl();
});

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  final dataSource = ref.watch(wordLocalDataSourceProvider);
  return WordRepositoryImpl(localDataSource: dataSource);
});

final addWordUseCaseProvider = Provider<AddWordUseCase>((ref) {
  return AddWordUseCase(ref.watch(wordRepositoryProvider));
});

final getWordsUseCaseProvider = Provider<GetWordsUseCase>((ref) {
  return GetWordsUseCase(ref.watch(wordRepositoryProvider));
});

final getWordByIdUseCaseProvider = Provider<GetWordByIdUseCase>((ref) {
  return GetWordByIdUseCase(ref.watch(wordRepositoryProvider));
});

final searchWordsUseCaseProvider = Provider<SearchWordsUseCase>((ref) {
  return SearchWordsUseCase(ref.watch(wordRepositoryProvider));
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(ref.watch(wordRepositoryProvider));
});

final toggleLearnedUseCaseProvider = Provider<ToggleLearnedUseCase>((ref) {
  return ToggleLearnedUseCase(ref.watch(wordRepositoryProvider));
});

final getWordStatisticsUseCaseProvider = Provider<GetWordStatisticsUseCase>((ref) {
  return GetWordStatisticsUseCase(ref.watch(wordRepositoryProvider));
});

// --- Filter State Providers ---

final wordSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedDifficultyFilterProvider = StateProvider<String>((ref) => 'all');
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'all');

// --- Words List Provider ---

final wordsListProvider = FutureProvider.autoDispose<List<Word>>((ref) async {
  final searchQuery = ref.watch(wordSearchQueryProvider);
  final difficulty = ref.watch(selectedDifficultyFilterProvider);
  final category = ref.watch(selectedCategoryFilterProvider);

  if (searchQuery.trim().isNotEmpty) {
    final searchUseCase = ref.watch(searchWordsUseCaseProvider);
    final results = await searchUseCase(searchQuery);
    final cleanQuery = searchQuery.trim().toLowerCase();

    final filtered = results.where((w) {
      if (difficulty != 'all' && w.difficulty.toLowerCase() != difficulty.toLowerCase()) {
        return false;
      }
      if (category != 'all' && w.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    // Priority rank: exact word match (1st), prefix match (2nd), contains in word (3rd), others
    filtered.sort((a, b) {
      final aWord = a.word.toLowerCase();
      final bWord = b.word.toLowerCase();

      final aExact = aWord == cleanQuery ? 0 : 1;
      final bExact = bWord == cleanQuery ? 0 : 1;
      if (aExact != bExact) return aExact.compareTo(bExact);

      final aStarts = aWord.startsWith(cleanQuery) ? 0 : 1;
      final bStarts = bWord.startsWith(cleanQuery) ? 0 : 1;
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);

      final aContains = aWord.contains(cleanQuery) ? 0 : 1;
      final bContains = bWord.contains(cleanQuery) ? 0 : 1;
      if (aContains != bContains) return aContains.compareTo(bContains);

      return aWord.compareTo(bWord);
    });

    return filtered;
  }

  final getWordsUseCase = ref.watch(getWordsUseCaseProvider);
  return getWordsUseCase(
    difficulty: difficulty == 'all' ? null : difficulty,
    category: category == 'all' ? null : category,
  );
});

// --- Categories Provider ---

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(wordRepositoryProvider);
  return repository.getCategories();
});

// --- Word Detail Provider ---

final wordDetailProvider = FutureProvider.family<Word, int>((ref, wordId) async {
  final getWordById = ref.watch(getWordByIdUseCaseProvider);
  return getWordById(wordId);
});

// --- Word Controller for Mutable Actions ---

class WordController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  WordController(this._ref) : super(const AsyncValue.data(null));

  Future<void> toggleFavorite(Word word) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(toggleFavoriteUseCaseProvider);
      await useCase(word.id, !word.isFavorite);
      // Invalidate related providers to refresh UI reactively
      _ref.invalidate(wordsListProvider);
      _ref.invalidate(wordDetailProvider(word.id));
      _ref.invalidate(getWordStatisticsUseCaseProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Word?> addWord(Word word) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(addWordUseCaseProvider);
      final created = await useCase(word);
      _ref.invalidate(wordsListProvider);
      _ref.invalidate(categoriesProvider);
      _ref.invalidate(getWordStatisticsUseCaseProvider);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> toggleLearned(Word word) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(toggleLearnedUseCaseProvider);
      await useCase(word.id, !word.isLearned);
      _ref.invalidate(wordsListProvider);
      _ref.invalidate(wordDetailProvider(word.id));
      _ref.invalidate(getWordStatisticsUseCaseProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final wordControllerProvider = StateNotifierProvider<WordController, AsyncValue<void>>((ref) {
  return WordController(ref);
});
