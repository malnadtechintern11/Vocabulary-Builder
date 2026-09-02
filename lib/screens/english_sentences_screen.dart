import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme/app_colors.dart';
import '../core/widgets/empty_state_view.dart';
import '../features/sentences/providers/sentences_provider.dart';
import 'sentence_practice_screen.dart';
import 'widgets/sentence_card.dart';

/// Screen displaying curated English sentences with difficulty filtering, search, and TTS
class EnglishSentencesScreen extends ConsumerStatefulWidget {
  const EnglishSentencesScreen({super.key});

  @override
  ConsumerState<EnglishSentencesScreen> createState() =>
      _EnglishSentencesScreenState();
}

class _EnglishSentencesScreenState
    extends ConsumerState<EnglishSentencesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSentences = ref.watch(allSentencesProvider);
    final filteredSentences = ref.watch(filteredSentencesProvider);
    final selectedFilter = ref.watch(sentenceDifficultyFilterProvider);
    final favoriteIds = ref.watch(favoriteSentenceIdsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final beginnerCount =
        allSentences.where((s) => s.difficulty.toLowerCase() == 'beginner').length;
    final intermediateCount =
        allSentences.where((s) => s.difficulty.toLowerCase() == 'intermediate').length;
    final advancedCount =
        allSentences.where((s) => s.difficulty.toLowerCase() == 'advanced').length;
    final favoritesCount = favoriteIds.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('English Sentences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center_rounded),
            tooltip: 'Sentence Practice Mode',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SentencePracticeScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Practice Banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                    : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.3)
                    : AppColors.primaryLight.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.25)
                        : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practice Mode with Audio',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Listen, test your comprehension & tap "Next Sentence".',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SentencePracticeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.primaryLight : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Practice'),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(sentenceSearchQueryProvider.notifier).state = val;
              },
              decoration: InputDecoration(
                hintText: 'Search sentences, meanings, or words...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(sentenceSearchQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Difficulty & Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All (${allSentences.length})',
                  filterValue: 'All',
                  isSelected: selectedFilter == 'All',
                  isDark: isDark,
                  accentColor: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Beginner ($beginnerCount)',
                  filterValue: 'Beginner',
                  isSelected: selectedFilter == 'Beginner',
                  isDark: isDark,
                  accentColor: AppColors.difficultyBeginner,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Intermediate ($intermediateCount)',
                  filterValue: 'Intermediate',
                  isSelected: selectedFilter == 'Intermediate',
                  isDark: isDark,
                  accentColor: AppColors.difficultyIntermediate,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Advanced ($advancedCount)',
                  filterValue: 'Advanced',
                  isSelected: selectedFilter == 'Advanced',
                  isDark: isDark,
                  accentColor: AppColors.difficultyAdvanced,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Saved ($favoritesCount)',
                  filterValue: 'Favorites',
                  isSelected: selectedFilter == 'Favorites',
                  isDark: isDark,
                  accentColor: AppColors.favorite,
                  icon: Icons.favorite_rounded,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sentences List Content
          Expanded(
            child: filteredSentences.isEmpty
                ? (selectedFilter == 'Favorites'
                    ? EmptyStateView(
                        icon: Icons.favorite_border_rounded,
                        title: 'No Saved Sentences',
                        description:
                            'Tap the heart icon on any sentence to save it here for quick review.',
                        actionLabel: 'Browse All Sentences',
                        onActionPressed: () {
                          ref
                              .read(sentenceDifficultyFilterProvider.notifier)
                              .state = 'All';
                        },
                      )
                    : EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No Sentences Found',
                        description:
                            'No sentences match your current search or category filter.',
                        actionLabel: 'Clear Search',
                        onActionPressed: () {
                          _searchController.clear();
                          ref.read(sentenceSearchQueryProvider.notifier).state =
                              '';
                          ref
                              .read(sentenceDifficultyFilterProvider.notifier)
                              .state = 'All';
                        },
                      ))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: filteredSentences.length,
                    itemBuilder: (context, index) {
                      final sentence = filteredSentences[index];
                      return SentenceCard(
                        key: ValueKey(sentence.id),
                        sentence: sentence,
                        onPractice: () {
                          final practiceIndex = allSentences.indexOf(sentence);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SentencePracticeScreen(
                                initialIndex:
                                    practiceIndex >= 0 ? practiceIndex : 0,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String filterValue,
    required bool isSelected,
    required bool isDark,
    required Color accentColor,
    IconData? icon,
  }) {
    return ChoiceChip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : accentColor,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor:
          isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      selectedColor: accentColor,
      side: BorderSide(
        color: isSelected
            ? accentColor
            : (isDark ? AppColors.borderDark : AppColors.borderLight),
        width: 1,
      ),
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        fontSize: 12.5,
      ),
      onSelected: (_) {
        ref.read(sentenceDifficultyFilterProvider.notifier).state = filterValue;
      },
    );
  }
}
