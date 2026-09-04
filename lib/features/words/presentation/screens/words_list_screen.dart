import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/online_dictionary_service.dart';
import '../../../../core/widgets/animated_progress_bar.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../progress/presentation/providers/learning_streak_provider.dart';
import '../../../quiz/presentation/providers/quiz_controller.dart';
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
    final searchQuery = ref.watch(wordSearchQueryProvider);

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
            Expanded(
              child: Column(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'English & ಕನ್ನಡ Learning Hub',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(wordsListProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // Search and Filters Area
            SliverToBoxAdapter(
              child: Padding(
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
                                          Flexible(
                                            child: Text(
                                              'English Sentences',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.2,
                                                color: isDark
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors.primaryDark,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 10),

                    // Multi-Language Translation Banner (with Integrated Camera & Image OCR)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          onTap: () => context.push(RoutePaths.translation),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF14293D), const Color(0xFF0F3B57)]
                                    : [const Color(0xFFF0FDF4), const Color(0xFFE0F2FE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.secondaryLight.withValues(alpha: 0.35)
                                    : AppColors.secondary.withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.secondaryLight.withValues(alpha: 0.25)
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
                                  child: const Icon(
                                    Icons.g_translate_rounded,
                                    color: AppColors.secondary,
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
                                          Flexible(
                                            child: Text(
                                              'Multi-Language Translation',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.2,
                                                color: isDark
                                                    ? AppColors.textPrimaryDark
                                                    : const Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              '10 Languages',
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
                                        'Type or scan photos to translate into Kannada, Hindi & more',
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
                                  color: isDark ? AppColors.secondaryLight : AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Daily Learning Goal & Streak Strip
                    _buildGoalAndStreakStrip(context, ref, isDark),
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
            ),
            const SliverToBoxAdapter(
              child: Divider(height: 1),
            ),
            // Results & Quick Context Strip
            SliverToBoxAdapter(
              child: wordsAsync.maybeWhen(
                data: (words) => words.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 2),
                        child: Row(
                          children: [
                            if (words.length == 1 && words.first.isOnline)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.25 : 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF0D9488).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.public_rounded, size: 13, color: Color(0xFF0D9488)),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Online Dictionary Result',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
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
            ),
            // Word List Content
            ...wordsAsync.when(
              data: (words) {
                if (words.isEmpty) {
                  final isSearching = searchQuery.trim().isNotEmpty;
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: isSearching ? Icons.travel_explore_rounded : Icons.search_off_rounded,
                        title: isSearching ? 'No Online or Offline Words Found' : 'No Words Found',
                        description: isSearching
                            ? 'We could not find definitions for "${searchQuery.trim()}" in the local library or online dictionary. Check spelling and try again.'
                            : 'Try adjusting your search query or filter tags to discover more words.',
                        actionLabel: isSearching ? 'Clear Search' : 'Clear Filters',
                        onActionPressed: () {
                          ref.read(wordSearchQueryProvider.notifier).state = '';
                          ref.read(selectedDifficultyFilterProvider.notifier).state = 'all';
                          ref.read(selectedCategoryFilterProvider.notifier).state = 'all';
                        },
                      ),
                    ),
                  ];
                }

                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    sliver: SliverList.builder(
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        final word = words[index];
                        return WordCard(key: ValueKey('${word.id}_${word.word}'), word: word);
                      },
                    ),
                  ),
                ];
              },
              loading: () {
                final isSearching = searchQuery.trim().isNotEmpty;
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: LoadingView(
                      message: isSearching
                          ? 'Searching online dictionary for "${searchQuery.trim()}"...'
                          : 'Loading vocabulary...',
                    ),
                  ),
                ];
              },
              error: (err, _) {
                final isNoInternet = err is WordNoInternetException ||
                    err.toString().toLowerCase().contains('offline') ||
                    err.toString().toLowerCase().contains('internet') ||
                    err.toString().toLowerCase().contains('socket') ||
                    err.toString().toLowerCase().contains('network');

                if (isNoInternet) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.incorrectRed.withValues(alpha: isDark ? 0.2 : 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 40,
                                  color: AppColors.incorrectRed,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Word Not Available Offline',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'This word is not available offline. Please connect to the internet to search for it.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () => ref.invalidate(wordsListProvider),
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Retry Search'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                }

                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorStateView(
                      message: err.toString(),
                      onRetry: () => ref.invalidate(wordsListProvider),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalAndStreakStrip(BuildContext context, WidgetRef ref, bool isDark) {
    final streakAsync = ref.watch(streakInfoProvider);
    final goalTargetAsync = ref.watch(dailyGoalTargetProvider);
    final todayWordsAsync = ref.watch(todayWordsLearnedProvider);

    final streak = streakAsync.value?.currentStreak ?? 0;
    final target = goalTargetAsync.value ?? 10;
    final todayWords = todayWordsAsync.value ?? 0;
    final progressVal = target > 0 ? (todayWords / target).clamp(0.0, 1.0) : 0.0;
    final isGoalMet = todayWords >= target;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Row(
        children: [
          // Streak Badge
          InkWell(
            onTap: () => context.go(RoutePaths.progress),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 4),
                  Text(
                    '$streak ${streak == 1 ? 'Day' : 'Days'}',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Daily Goal Progress (Opens interactive goal sheet)
          Expanded(
            child: InkWell(
              onTap: () => _showDailyGoalSheet(context, ref),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isGoalMet ? Icons.check_circle_rounded : Icons.track_changes_rounded,
                          size: 15,
                          color: isGoalMet ? AppColors.success : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isGoalMet ? 'Goal Completed!' : 'Daily Goal: $todayWords/$target',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isGoalMet ? AppColors.success : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isGoalMet ? AppColors.success : AppColors.primary).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(progressVal * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isGoalMet ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDailyGoalSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final target = ref.read(dailyGoalTargetProvider).value ?? 10;
    final todayWords = ref.read(todayWordsLearnedProvider).value ?? 0;
    final streak = ref.read(streakInfoProvider).value?.currentStreak ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final currentTarget = ref.watch(dailyGoalTargetProvider).value ?? target;
            final currentToday = ref.watch(todayWordsLearnedProvider).value ?? todayWords;
            final currentProgress = currentTarget > 0 ? (currentToday / currentTarget).clamp(0.0, 1.0) : 0.0;
            final currentGoalMet = currentToday >= currentTarget;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.track_changes_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Daily Learning Goal',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFEF4444)),
                            const SizedBox(width: 4),
                            Text(
                              '$streak Days',
                              style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AnimatedProgressBar(
                    value: currentProgress,
                    height: 10,
                    color: currentGoalMet ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$currentToday of $currentTarget words learned today',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${(currentProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: currentGoalMet ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Set Your Daily Target:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [5, 10, 20, 30].map((count) {
                      final isSel = currentTarget == count;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            onTap: () async {
                              await ref.read(learningAnalyticsServiceProvider).setDailyGoalTarget(count);
                              ref.invalidate(dailyGoalTargetProvider);
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                                    : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel
                                      ? (isDark ? AppColors.primaryLight : AppColors.primary)
                                      : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                                ),
                              ),
                              child: Text(
                                '$count Words',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSel
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'To learn words: Tap any word in Explore and press "Mark as Mastered".',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.go(RoutePaths.progress);
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 18),
                      label: const Text('View Full Progress & Achievements'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
