import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/services/sentence_pronunciation_service.dart';
import '../../core/services/speech_service.dart';
import '../../core/widgets/audio_pronounce_button.dart';
import '../../features/sentences/providers/sentences_provider.dart';
import '../../models/sentence.dart';

/// Modal bottom sheet for recording audio, practicing spoken English sentences,
/// and evaluating pronunciation accuracy with word-by-word feedback.
class SentenceRecordingDialog extends ConsumerStatefulWidget {
  final Sentence sentence;

  const SentenceRecordingDialog({
    super.key,
    required this.sentence,
  });

  static Future<void> show(BuildContext context, Sentence sentence) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SentenceRecordingDialog(sentence: sentence),
    );
  }

  @override
  ConsumerState<SentenceRecordingDialog> createState() =>
      _SentenceRecordingDialogState();
}

class _SentenceRecordingDialogState
    extends ConsumerState<SentenceRecordingDialog>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _liveTranscript = '';
  double _soundLevel = 0.0;
  SentencePronunciationResult? _evaluationResult;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (_isListening) {
      SpeechService.instance.stopListening();
    }
    super.dispose();
  }

  Future<void> _startRecording() async {
    _pulseController.repeat(reverse: true);
    setState(() {
      _liveTranscript = '';
      _soundLevel = 0.0;
      _evaluationResult = null;
      _isListening = true;
    });

    final success = await SpeechService.instance.startListening(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      onSoundLevelChange: (level) {
        if (!mounted) return;
        // Level typically varies between -10 to 10 dB or 0 to 100
        final normalized = level > 0 ? (level / 10).clamp(0.0, 1.0) : 0.0;
        setState(() {
          _soundLevel = normalized;
        });
      },
      onResult: (recognizedWords, isFinal) {
        if (!mounted) return;
        setState(() {
          _liveTranscript = recognizedWords;
        });

        // Only auto-stop if final result and has substantial speech recognized
        if (isFinal && recognizedWords.trim().isNotEmpty) {
          _stopRecording();
        }
      },
    );

    if (!success && mounted) {
      _pulseController.stop();
      _pulseController.reset();
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.mic_off_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Microphone permission or speech recognition is not available.'),
              ),
            ],
          ),
          backgroundColor: AppColors.incorrectRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    _pulseController.stop();
    _pulseController.reset();
    await SpeechService.instance.stopListening();
    if (!mounted) return;

    final eval = SentencePronunciationService.evaluate(
      targetSentence: widget.sentence.text,
      spokenTranscript: _liveTranscript,
    );

    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
      _evaluationResult = eval;
    });

    // Auto mark as practiced if accuracy >= 80%
    if (eval.accuracyScore >= 80) {
      ref
          .read(practicedSentenceIdsProvider.notifier)
          .markAsPracticed(widget.sentence.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            mediaQuery.viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.record_voice_over_rounded,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Voice Pronunciation Practice',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Target Sentence Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                      : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'READ AND SPEAK THIS SENTENCE:',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildSentenceTextWithLiveHighlights(isDark),
                    if (widget.sentence.kannadaMeaning.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.sentence.kannadaMeaning,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Audio reference listener
                    AudioPronounceTonalButton(
                      id: 'ref_${widget.sentence.id}',
                      text: widget.sentence.text,
                      label: 'Listen to Reference Audio',
                      playingLabel: 'Playing...',
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Recording / Feedback Section
              if (_evaluationResult != null)
                _buildEvaluationView(isDark)
              else
                _buildRecordingControls(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentenceTextWithLiveHighlights(bool isDark) {
    if (!_isListening || _liveTranscript.trim().isEmpty) {
      return Text(
        widget.sentence.text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          height: 1.4,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      );
    }

    final spokenLower = _liveTranscript.toLowerCase();
    final words = widget.sentence.text.split(RegExp(r'\s+'));

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: words.map((rawWord) {
        final clean = rawWord.toLowerCase().replaceAll(RegExp(r"[^\w']"), '');
        final isHeard = clean.isNotEmpty && spokenLower.contains(clean);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: isHeard
                ? (isDark
                    ? const Color(0xFF064E3B).withValues(alpha: 0.65)
                    : const Color(0xFFDCFCE7))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isHeard
                ? Border.all(
                    color: isDark ? const Color(0xFF10B981) : const Color(0xFF22C55E),
                    width: 1.2,
                  )
                : null,
          ),
          child: Text(
            rawWord,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isHeard
                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF15803D))
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecordingControls(bool isDark) {
    return Column(
      children: [
        // Live transcript or prompt container
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 85),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isListening
                ? (isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: _isListening
                ? Border.all(
                    color: (_soundLevel > 0.08 ? AppColors.correctGreen : AppColors.primary)
                        .withValues(alpha: 0.6),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isListening) ...[
                // Active Voice Activity Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: _soundLevel > 0.08
                            ? AppColors.correctGreen
                            : AppColors.incorrectRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_soundLevel > 0.08
                                    ? AppColors.correctGreen
                                    : AppColors.incorrectRed)
                                .withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _soundLevel > 0.08
                          ? 'Hearing your voice! Keep speaking...'
                          : 'Listening... Speak clearly into mic',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _soundLevel > 0.08
                            ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D))
                            : AppColors.incorrectRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Equalizer Sound Bars that react dynamically to voice volume
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(7, (i) {
                    final weights = [0.35, 0.65, 0.95, 1.25, 0.90, 0.60, 0.35];
                    final height = (8.0 + (_soundLevel * 32.0 * weights[i])).clamp(8.0, 44.0);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 5,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _soundLevel > 0.08
                              ? [const Color(0xFF10B981), const Color(0xFF059669)]
                              : [const Color(0xFFEF4444), const Color(0xFFF97316)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // Live transcript
                Text(
                  _liveTranscript.isNotEmpty
                      ? '"$_liveTranscript"'
                      : 'Say the words in the sentence...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontStyle: _liveTranscript.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ] else ...[
                Text(
                  'Tap the microphone button below and speak the English sentence aloud clearly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Big Mic Action Button with Sound-Level Dynamic Glow
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = _isListening
                ? 1.0 + (_pulseController.value * 0.06) + (_soundLevel * 0.08)
                : 1.0;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _isListening ? _stopRecording : _startRecording,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? (_soundLevel > 0.08
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFFEF4444), const Color(0xFFDC2626)])
                      : [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening
                            ? (_soundLevel > 0.08
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444))
                            : AppColors.primary)
                        .withValues(alpha: _isListening ? 0.45 : 0.3),
                    blurRadius: _isListening ? 20 : 10,
                    spreadRadius: _isListening ? 4 : 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isListening ? 'Tap to Stop & Evaluate' : 'Tap to Record Audio',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationView(bool isDark) {
    final eval = _evaluationResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Score & Feedback Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: eval.statusColor.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: eval.statusColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Circular Accuracy Score
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: eval.statusColor,
                ),
                child: Center(
                  child: Text(
                    '${eval.accuracyScore}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eval.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: eval.statusColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      eval.description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textPrimaryLight.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Word-by-word Breakdown
        Text(
          'WORD-BY-WORD PRONUNCIATION:',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: eval.words.map((w) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: w.isMatched
                    ? (isDark
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFFDCFCE7))
                    : (isDark
                        ? const Color(0xFF7F1D1D).withValues(alpha: 0.4)
                        : const Color(0xFFFEE2E2)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: w.isMatched
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.incorrectRed.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    w.isMatched
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 13,
                    color: w.isMatched
                        ? AppColors.success
                        : AppColors.incorrectRed,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    w.word,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: w.isMatched
                          ? (isDark ? Colors.white : const Color(0xFF166534))
                          : (isDark ? Colors.white : const Color(0xFF991B1B)),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        // What was heard
        if (eval.spokenText.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark.withValues(alpha: 0.4)
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hearing_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Recorded: "${eval.spokenText}"',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Action Buttons Row (Try Again & Done)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.done_rounded, size: 16),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
