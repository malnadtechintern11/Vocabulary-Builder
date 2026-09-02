import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme/app_colors.dart';
import '../core/widgets/empty_state_view.dart';
import '../features/sentences/providers/sentences_provider.dart';
import '../models/sentence.dart';

/// Interactive sentence practice mode with flashcard view, TTS, and "Next Sentence" progression
class SentencePracticeScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const SentencePracticeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<SentencePracticeScreen> createState() =>
      _SentencePracticeScreenState();
}

class _SentencePracticeScreenState
    extends ConsumerState<SentencePracticeScreen> {
  late int _currentIndex;
  bool _showMeaning = true;
  String _selectedDifficulty = 'All';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  List<Sentence> _getPracticeSentences(List<Sentence> all) {
    if (_selectedDifficulty == 'All') return all;
    return all
        .where((s) =>
            s.difficulty.toLowerCase() == _selectedDifficulty.toLowerCase())
        .toList();
  }

  void _nextSentence(int total) {
    if (total == 0) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % total;
    });
  }

  void _previousSentence(int total) {
    if (total == 0) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + total) % total;
    });
  }

  void _randomSentence(int total) {
    if (total <= 1) return;
    final random = Random();
    int next;
    do {
      next = random.nextInt(total);
    } while (next == _currentIndex);
    setState(() {
      _currentIndex = next;
    });
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.difficultyBeginner;
      case 'intermediate':
        return AppColors.difficultyIntermediate;
      case 'advanced':
        return AppColors.difficultyAdvanced;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSentences = ref.watch(allSentencesProvider);
    final sentences = _getPracticeSentences(allSentences);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (sentences.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sentence Practice')),
        body: EmptyStateView(
          icon: Icons.sentiment_dissatisfied_rounded,
          title: 'No Sentences Available',
          description: 'Try selecting a different level filter.',
          actionLabel: 'Reset to All',
          onActionPressed: () {
            setState(() {
              _selectedDifficulty = 'All';
              _currentIndex = 0;
            });
          },
        ),
      );
    }

    if (_currentIndex >= sentences.length) {
      _currentIndex = 0;
    }

    final currentSentence = sentences[_currentIndex];
    final diffColor = _getDifficultyColor(currentSentence.difficulty);
    final currentlySpeakingId = ref.watch(ttsSpeakingSentenceIdProvider);
    final isSpeaking = currentlySpeakingId == currentSentence.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentence Practice'),
        actions: [
          IconButton(
            icon: Icon(
              currentSentence.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: currentSentence.isFavorite ? AppColors.favorite : null,
            ),
            tooltip: currentSentence.isFavorite
                ? 'Remove from saved'
                : 'Save sentence',
            onPressed: () {
              ref
                  .read(favoriteSentenceIdsProvider.notifier)
                  .toggleFavorite(currentSentence.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Difficulty Selector Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Beginner',
                    'Intermediate',
                    'Advanced',
                  ].map((level) {
                    final isSel = _selectedDifficulty == level;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(level),
                        selected: isSel,
                        showCheckmark: false,
                        selectedColor: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        backgroundColor: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                        labelStyle: TextStyle(
                          color: isSel
                              ? Colors.white
                              : (isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight),
                          fontWeight:
                              isSel ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedDifficulty = level;
                            _currentIndex = 0;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Progress Bar & Counter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Practice Progress',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${_currentIndex + 1} of ${sentences.length}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / sentences.length,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Main Practice Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge and Category Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: diffColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: diffColor.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              currentSentence.difficulty,
                              style: TextStyle(
                                color: diffColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            currentSentence.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Large Sentence Text
                      SelectableText(
                        currentSentence.text,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Speaker Pronunciation Button
                      FilledButton.icon(
                        onPressed: () {
                          ref
                              .read(ttsControllerProvider)
                              .speakSentence(currentSentence);
                        },
                        icon: Icon(
                          isSpeaking
                              ? Icons.volume_up_rounded
                              : Icons.volume_down_rounded,
                          size: 20,
                        ),
                        label: Text(
                          isSpeaking ? 'Playing...' : 'Listen Pronunciation',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: isSpeaking
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.primaryContainerLight),
                          foregroundColor: isSpeaking
                              ? Colors.white
                              : (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Meaning Reveal / Toggle Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                              : AppColors.surfaceVariantLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline_rounded,
                                      size: 18,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Simple Meaning',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.primaryLight
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showMeaning = !_showMeaning;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: Text(
                                    _showMeaning ? 'Hide' : 'Reveal',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            if (_showMeaning) ...[
                              const SizedBox(height: 8),
                              Text(
                                currentSentence.meaning,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.4,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 6),
                              Text(
                                'Tap "Reveal" to check if you understood the meaning correctly.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Important Vocabulary Words
                      if (currentSentence.vocabularyWords.isNotEmpty) ...[
                        Text(
                          'Important Vocabulary Words',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...currentSentence.vocabularyWords.map((vocab) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surfaceVariantDark
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vocab.word,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      vocab.meaning,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation Controls with Prominent "Next Sentence" Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Previous Button
                  OutlinedButton.icon(
                    onPressed: () => _previousSentence(sentences.length),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Random / Shuffle Button
                  IconButton.outlined(
                    onPressed: () => _randomSentence(sentences.length),
                    icon: const Icon(Icons.shuffle_rounded, size: 19),
                    tooltip: 'Random sentence',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Big "Next Sentence" Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _nextSentence(sentences.length),
                      icon: const Text(
                        'Next Sentence',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      label: const Icon(Icons.arrow_forward_rounded, size: 20),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
