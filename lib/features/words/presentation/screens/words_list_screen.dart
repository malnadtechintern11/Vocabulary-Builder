import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../providers/words_provider.dart';
import '../widgets/difficulty_filter_chips.dart';
import '../widgets/word_card.dart';
import '../widgets/word_search_bar.dart';

/// Main explore and search vocabulary list screen
class WordsListScreen extends ConsumerWidget {
  const WordsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go(RoutePaths.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters Area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WordSearchBar(),
                const SizedBox(height: 12),
                const DifficultyFilterChips(),
                const SizedBox(height: 8),
                // Category Filter Dropdown / Row
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox.shrink();
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Topics'),
                            selected: selectedCategory == 'all',
                            showCheckmark: false,
                            backgroundColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                            selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                            side: BorderSide(
                              color: selectedCategory == 'all'
                                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                                  : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                              width: 1,
                            ),
                            labelStyle: TextStyle(
                              color: selectedCategory == 'all'
                                  ? Colors.white
                                  : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                              fontWeight: selectedCategory == 'all' ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 13,
                            ),
                            onSelected: (_) {
                              ref.read(selectedCategoryFilterProvider.notifier).state = 'all';
                            },
                          ),
                          const SizedBox(width: 6),
                          ...categories.map((cat) {
                            final isSel = selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(cat[0].toUpperCase() + cat.substring(1)),
                                selected: isSel,
                                showCheckmark: false,
                                backgroundColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                                selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                                side: BorderSide(
                                  color: isSel
                                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                                      : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                                  width: 1,
                                ),
                                labelStyle: TextStyle(
                                  color: isSel
                                      ? Colors.white
                                      : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                  fontSize: 13,
                                ),
                                onSelected: (_) {
                                  ref.read(selectedCategoryFilterProvider.notifier).state = cat;
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Word List Content
          Expanded(
            child: wordsAsync.when(
              data: (words) {
                if (words.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No Words Found',
                    description: 'Try adjusting your search query or filter tags to discover more words.',
                    actionLabel: 'Clear Filters',
                    onActionPressed: () {
                      ref.read(wordSearchQueryProvider.notifier).state = '';
                      ref.read(selectedDifficultyFilterProvider.notifier).state = 'all';
                      ref.read(selectedCategoryFilterProvider.notifier).state = 'all';
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(wordsListProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final word = words[index];
                      return WordCard(key: ValueKey(word.id), word: word);
                    },
                  ),
                );
              },
              loading: () => const LoadingView(message: 'Loading vocabulary...'),
              error: (err, _) => ErrorStateView(
                message: err.toString(),
                onRetry: () => ref.invalidate(wordsListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
