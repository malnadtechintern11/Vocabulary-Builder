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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 21,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Vocabulary Builder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'English & ಕನ್ನಡ Learning Hub',
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
      body: Column(
        children: [
          // Search and Filters Area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English Sentences Home Card Banner
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: () => context.push(RoutePaths.sentences),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                                : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? AppColors.primaryLight.withValues(alpha: 0.35)
                                : AppColors.primaryLight.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primaryLight.withValues(alpha: 0.25)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.record_voice_over_rounded,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'English Sentences',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.primaryDark,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '600+ Sentences',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Beginner, Intermediate & Advanced with audio',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
          // Results & Quick Context Strip
          wordsAsync.maybeWhen(
            data: (words) => words.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
                    child: Row(
                      children: [
                        Text(
                          '${words.length} ${words.length == 1 ? 'Word' : 'Words'} Listed',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Spacer(),
                        if (selectedCategory != 'all')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              selectedCategory[0].toUpperCase() + selectedCategory.substring(1),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
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
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
