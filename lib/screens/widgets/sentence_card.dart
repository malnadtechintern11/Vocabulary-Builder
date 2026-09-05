import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/services/tts_service.dart';
import '../../core/widgets/animated_favorite_button.dart';
import '../../core/widgets/audio_pronounce_button.dart';
import '../../features/sentences/providers/sentences_provider.dart';
import '../../models/sentence.dart';
import 'sentence_recording_dialog.dart';

/// Clean, learner-friendly card displaying an English sentence, meaning, and key vocabulary
class SentenceCard extends ConsumerWidget {
  final Sentence sentence;
  final VoidCallback? onPractice;

  const SentenceCard({
    super.key,
    required this.sentence,
    this.onPractice,
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final diffColor = _getDifficultyColor(sentence.difficulty);
    final currentlySpeakingId = ref.watch(ttsSpeakingSentenceIdProvider);
    final isSpeakingThis = currentlySpeakingId == sentence.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSpeakingThis
              ? AppColors.primary
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: isSpeakingThis ? 2.0 : 1.2,
        ),
        boxShadow: isSpeakingThis
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : (isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online Result Banner & Save Sentence Action if fetched online
            if (sentence.isOnline) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F2B2B)
                      : const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Online Sentence Result',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(savedSentencesProvider.notifier)
                            .saveSentence(sentence);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Saved "${sentence.text.length > 30 ? '${sentence.text.substring(0, 30)}...' : sentence.text}" to offline library!',
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmark_add_rounded, size: 14),
                      label: const Text('Save Sentence'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.primaryLight : AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Top Row: Difficulty Badge, Category Chip & Favorite
            Row(
              children: [
                // Difficulty Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: diffColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: diffColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        sentence.difficulty,
                        style: TextStyle(
                          color: diffColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Category Chip
                Expanded(
                  child: Text(
                    sentence.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),

                // Practiced / Completed Checkmark Button
                IconButton(
                  icon: Icon(
                    sentence.isPracticed
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: sentence.isPracticed
                        ? AppColors.success
                        : (isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight),
                    size: 22,
                  ),
                  tooltip: sentence.isPracticed
                      ? 'Practiced (tap to unmark)'
                      : 'Mark as Practiced',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    ref
                        .read(practicedSentenceIdsProvider.notifier)
                        .togglePracticed(sentence.id);
                  },
                ),

                // Animated Favorite Button with tactile bounce
                AnimatedFavoriteButton(
                  isFavorite: sentence.isFavorite,
                  itemName: sentence.text.length > 30 ? '${sentence.text.substring(0, 30)}...' : sentence.text,
                  tooltip: sentence.isFavorite ? 'Remove from saved' : 'Save sentence',
                  onToggle: () {
                    ref.read(favoriteSentenceIdsProvider.notifier).toggleFavorite(sentence.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // English Sentence Text
            SelectableText(
              sentence.text,
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.42,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            // English Meaning Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark.withValues(alpha: 0.6)
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderDark.withValues(alpha: 0.5)
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 15,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'English Meaning',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      AudioPronounceButton(
                        id: 'sentence_meaning_${sentence.id}',
                        text: sentence.meaning,
                        tooltip: 'Listen to English meaning',
                        iconSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sentence.meaning,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.35,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textPrimaryLight.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Kannada Meaning Box (ಕನ್ನಡ ಅರ್ಥ)
            if (sentence.kannadaMeaning.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF064E3B).withValues(alpha: 0.22)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.secondary.withValues(alpha: 0.4)
                        : const Color(0xFF86EFAC).withValues(alpha: 0.7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 15,
                          color: isDark
                              ? AppColors.secondaryLight
                              : AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ಕನ್ನಡ ಅರ್ಥ (Kannada Meaning)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: isDark
                                  ? AppColors.secondaryLight
                                  : AppColors.secondaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sentence.kannadaMeaning,
                      style: TextStyle(
                        fontSize: 14,
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


            // Important Vocabulary Words Section
            if (sentence.vocabularyWords.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Key Vocabulary',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: sentence.vocabularyWords.map((vocab) {
                  final vocabId = 'sentence_${sentence.id}_vocab_${vocab.word}';
                  return InkWell(
                    onTap: () {
                      ref.read(appTtsControllerProvider).toggleSpeak(
                            id: vocabId,
                            text: '${vocab.word}. ${vocab.meaning}',
                          );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryContainerDark.withValues(alpha: 0.45)
                            : AppColors.primaryContainerLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primaryLight.withValues(alpha: 0.25)
                              : AppColors.primaryLight.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${vocab.word}: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: vocab.meaning,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          AudioPronounceButton(
                            id: vocabId,
                            text: '${vocab.word}. ${vocab.meaning}',
                            tooltip: 'Pronounce "${vocab.word}"',
                            iconSize: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Action Buttons Row: Speaker (TTS), Copy, Practice
            Row(
              children: [
                // Speaker Button
                AudioPronounceTonalButton(
                  id: sentence.id,
                  text: sentence.text,
                  label: 'Listen',
                  playingLabel: 'Playing',
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                const SizedBox(width: 4),

                // Record Audio / Voice Pronunciation Button
                IconButton(
                  icon: const Icon(Icons.mic_rounded, size: 20),
                  tooltip: 'Record audio (Speak & Practice)',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  onPressed: () => SentenceRecordingDialog.show(context, sentence),
                ),
                const SizedBox(width: 4),

                // Copy Button
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'Copy sentence',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    final textToCopy = sentence.kannadaMeaning.isNotEmpty
                        ? '${sentence.text}\n(${sentence.kannadaMeaning})'
                        : sentence.text;
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sentence & meaning copied to clipboard!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Practice Button with auto-scaling to guarantee zero overflow
                if (onPractice != null)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: FilledButton.tonalIcon(
                        onPressed: onPractice,
                        icon: const Icon(Icons.school_rounded, size: 15),
                        label: const Text(
                          'Practice',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
