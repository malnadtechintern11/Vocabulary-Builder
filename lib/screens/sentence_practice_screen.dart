import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme/app_colors.dart';
import '../core/services/tts_service.dart';
import '../core/widgets/audio_pronounce_button.dart';
import '../core/widgets/empty_state_view.dart';
import '../features/sentences/providers/sentences_provider.dart';
import '../models/sentence.dart';
import 'widgets/sentence_recording_dialog.dart';

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

  void _nextSentence(Sentence current, int total) {
    if (total == 0) return;
    ref.read(practicedSentenceIdsProvider.notifier).markAsPracticed(current.id);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentence Practice'),
        actions: [
          IconButton(
            icon: Icon(
              currentSentence.isPracticed
                  ? Icons.check_circle_rounded
                  : Icons.check_circle_outline_rounded,
              color: currentSentence.isPracticed ? AppColors.success : null,
            ),
            tooltip: currentSentence.isPracticed
                ? 'Practiced (tap to unmark)'
                : 'Mark as Practiced',
            onPressed: () {
              ref
                  .read(practicedSentenceIdsProvider.notifier)
                  .togglePracticed(currentSentence.id);
            },
          ),
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
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
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
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: diffColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: diffColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              currentSentence.difficulty,
                              style: TextStyle(
                                color: diffColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            currentSentence.category,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
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
                          fontSize: 22.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.45,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pronunciation Audio & Speech Recording Row
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          AudioPronounceTonalButton(
                            id: currentSentence.id,
                            text: currentSentence.text,
                            label: 'Listen',
                            playingLabel: 'Playing...',
                            fontSize: 13,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => SentenceRecordingDialog.show(context, currentSentence),
                            icon: const Icon(Icons.mic_rounded, size: 16),
                            label: const Text(
                              'Record Speech',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
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
                              const SizedBox(height: 10),
                              // English Meaning
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.surfaceDark.withValues(alpha: 0.6)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'English Meaning',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? AppColors.primaryLight
                                                : AppColors.primary,
                                          ),
                                        ),
                                        AudioPronounceButton(
                                          id: 'practice_meaning_${currentSentence.id}',
                                          text: currentSentence.meaning,
                                          tooltip: 'Listen to English meaning',
                                          iconSize: 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      currentSentence.meaning,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.35,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (currentSentence.kannadaMeaning.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF064E3B).withValues(alpha: 0.25)
                                        : const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.secondary.withValues(alpha: 0.45)
                                          : const Color(0xFF86EFAC).withValues(alpha: 0.8),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.translate_rounded,
                                            size: 14,
                                            color: isDark
                                                ? AppColors.secondaryLight
                                                : AppColors.secondaryDark,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'ಕನ್ನಡ ಅರ್ಥ (Kannada Meaning)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                ? AppColors.secondaryLight
                                                : AppColors.secondaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentSentence.kannadaMeaning,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          height: 1.45,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : const Color(0xFF14532D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                          final vocabId = 'practice_${currentSentence.id}_vocab_${vocab.word}';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                ref.read(appTtsControllerProvider).toggleSpeak(
                                      id: vocabId,
                                      text: '${vocab.word}. ${vocab.meaning}',
                                    );
                              },
                              borderRadius: BorderRadius.circular(10),
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
                                    const SizedBox(width: 6),
                                    AudioPronounceButton(
                                      id: vocabId,
                                      text: '${vocab.word}. ${vocab.meaning}',
                                      tooltip: 'Pronounce "${vocab.word}"',
                                      iconSize: 16,
                                    ),
                                  ],
                                ),
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
                      onPressed: () => _nextSentence(currentSentence, sentences.length),
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
