import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabulary_builder/core/widgets/empty_state_view.dart';
import 'package:vocabulary_builder/core/widgets/error_state_view.dart';
import 'package:vocabulary_builder/core/widgets/loading_view.dart';
import 'package:vocabulary_builder/features/words/presentation/widgets/word_card.dart';
import '../providers/favorites_provider.dart';

/// Screen displaying user's bookmarked / favorite words
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Words'),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'No Saved Words',
              description: 'Tap the heart icon on any word to save it here for quick study and revision.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoritesListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final word = favorites[index];
                return WordCard(key: ValueKey(word.id), word: word);
              },
            ),
          );
        },
        loading: () => const LoadingView(message: 'Loading saved words...'),
        error: (err, _) => ErrorStateView(
          message: err.toString(),
          onRetry: () => ref.invalidate(favoritesListProvider),
        ),
      ),
    );
  }
}
