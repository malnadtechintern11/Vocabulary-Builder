import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabulary_builder/app/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.favorite.withValues(alpha: isDark ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 20,
                color: AppColors.favorite,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Saved Collection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Personal Revision Deck',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'No Saved Words Yet',
              description: 'Tap the heart icon on any vocabulary word to save it here for quick review and listening practice.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoritesListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: favorites.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.favorite.withValues(alpha: 0.12)
                          : const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.favorite.withValues(alpha: 0.3)
                            : const Color(0xFFFECDD3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bookmark_added_rounded,
                          size: 18,
                          color: AppColors.favorite,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${favorites.length} ${favorites.length == 1 ? 'word' : 'words'} saved for quick pronunciation & study practice',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF9F1239),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final word = favorites[index - 1];
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
