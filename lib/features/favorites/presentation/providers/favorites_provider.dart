import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabulary_builder/features/words/domain/entities/word.dart';
import 'package:vocabulary_builder/features/words/presentation/providers/words_provider.dart';

/// Provider for list of favorite words
final favoritesListProvider = FutureProvider.autoDispose<List<Word>>((ref) async {
  final getWordsUseCase = ref.watch(getWordsUseCaseProvider);
  return getWordsUseCase(onlyFavorites: true);
});
