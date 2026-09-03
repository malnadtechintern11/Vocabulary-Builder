import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme/app_colors.dart';
import '../core/widgets/animated_progress_bar.dart';
import '../core/widgets/empty_state_view.dart';
import '../features/sentences/providers/sentences_provider.dart';
import 'sentence_practice_screen.dart';
import 'widgets/sentence_card.dart';

/// Screen displaying 600 curated English sentences with progress tracking, category filtering, search, and TTS
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
    final selectedCategory = ref.watch(sentenceCategoryFilterProvider);
    final categories = ref.watch(sentenceCategoriesListProvider);
    final stats = ref.watch(sentenceProgressStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('English Sentences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.school_rounded),
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
          // Progress & Practice Header Card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E1B4B).withValues(alpha: 0.9),
                        const Color(0xFF312E81).withValues(alpha: 0.6),
                      ]
                    : [
                        const Color(0xFFEEF2FF),
                        const Color(0xFFE0E7FF),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.35)
                    : AppColors.primaryLight.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Progress icon, title with stacked subtitle & Practice button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryLight.withValues(alpha: 0.25)
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.insights_rounded,
                        color:
                            isDark ? AppColors.primaryLight : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sentences Progress',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${stats.totalPracticed} of ${stats.totalSentences} mastered (${(stats.overallPercentage * 100).toStringAsFixed(0)}%)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const SentencePracticeScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.school_rounded, size: 15),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.primaryLight : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      label: const Text(
                        'Practice',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Overall Animated Progress Bar
                AnimatedProgressBar(
                  value: stats.overallPercentage,
                  height: 7,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                const SizedBox(height: 10),

                // Level Progress Breakdown Row - using Expanded for each level so it never overflows
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniLevelProgress(
                        label: 'Basic',
                        practiced: stats.beginnerPracticed,
                        total: stats.beginnerTotal,
                        color: AppColors.difficultyBeginner,
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildMiniLevelProgress(
                        label: 'Inter.',
                        practiced: stats.intermediatePracticed,
                        total: stats.intermediateTotal,
                        color: AppColors.difficultyIntermediate,
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _buildMiniLevelProgress(
                        label: 'Adv.',
                        practiced: stats.advancedPracticed,
                        total: stats.advancedTotal,
                        color: AppColors.difficultyAdvanced,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(sentenceSearchQueryProvider.notifier).state = val;
              },
              decoration: InputDecoration(
                hintText: 'Search 600+ sentences in English or ಕನ್ನಡ...',
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Level Filter Chips (Beginner, Intermediate, Advanced, Practiced, Saved)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All (${allSentences.length})',
                  filterValue: 'All',
                  isSelected: selectedFilter == 'All',
                  isDark: isDark,
                  accentColor:
                      isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Beginner (${stats.beginnerTotal})',
                  filterValue: 'Beginner',
                  isSelected: selectedFilter == 'Beginner',
                  isDark: isDark,
                  accentColor: AppColors.difficultyBeginner,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Intermediate (${stats.intermediateTotal})',
                  filterValue: 'Intermediate',
                  isSelected: selectedFilter == 'Intermediate',
                  isDark: isDark,
                  accentColor: AppColors.difficultyIntermediate,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Advanced (${stats.advancedTotal})',
                  filterValue: 'Advanced',
                  isSelected: selectedFilter == 'Advanced',
                  isDark: isDark,
                  accentColor: AppColors.difficultyAdvanced,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Practiced (${stats.totalPracticed})',
                  filterValue: 'Practiced',
                  isSelected: selectedFilter == 'Practiced',
                  isDark: isDark,
                  accentColor: AppColors.success,
                  icon: Icons.check_circle_rounded,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Saved (${stats.totalFavorites})',
                  filterValue: 'Favorites',
                  isSelected: selectedFilter == 'Favorites',
                  isDark: isDark,
                  accentColor: AppColors.favorite,
                  icon: Icons.favorite_rounded,
                ),
              ],
            ),
          ),

          // Category Filter Chips (Daily Conversation, Family, School, Work, etc.)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: categories.map((cat) {
                final isSel = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    showCheckmark: false,
                    backgroundColor: isDark
                        ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                        : const Color(0xFFF1F5F9),
                    selectedColor:
                        isDark ? AppColors.primaryLight : AppColors.primary,
                    side: BorderSide(
                      color: isSel
                          ? (isDark
                              ? AppColors.primaryLight
                              : AppColors.primary)
                          : (isDark
                              ? AppColors.borderDark
                              : const Color(0xFFCBD5E1)),
                      width: 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSel
                          ? Colors.white
                          : (isDark
                              ? const Color(0xFFF8FAFC)
                              : const Color(0xFF0F172A)),
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 11.5,
                    ),
                    onSelected: (_) {
                      ref
                          .read(sentenceCategoryFilterProvider.notifier)
                          .state = cat;
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 4),
          const Divider(height: 1),

          // Sentences List Content
          Expanded(
            child: filteredSentences.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No Sentences Found',
                    description:
                        'No sentences match your active level, category, or search filters.',
                    actionLabel: 'Reset Filters',
                    onActionPressed: () {
                      _searchController.clear();
                      ref.read(sentenceSearchQueryProvider.notifier).state = '';
                      ref
                          .read(sentenceDifficultyFilterProvider.notifier)
                          .state = 'All';
                      ref
                          .read(sentenceCategoryFilterProvider.notifier)
                          .state = 'All';
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    itemCount: filteredSentences.length,
                    itemBuilder: (context, index) {
                      final sentence = filteredSentences[index];
                      return SentenceCard(
                        key: ValueKey(sentence.id),
                        sentence: sentence,
                        onPractice: () {
                          final practiceIndex =
                              allSentences.indexOf(sentence);
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

  Widget _buildMiniLevelProgress({
    required String label,
    required int practiced,
    required int total,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$label: ',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Text(
          '$practiced/$total',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
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
              size: 14,
              color: isSelected ? Colors.white : accentColor,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      backgroundColor:
          isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      selectedColor: accentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
        fontSize: 12,
      ),
      onSelected: (_) {
        ref.read(sentenceDifficultyFilterProvider.notifier).state =
            filterValue;
      },
    );
  }
}
