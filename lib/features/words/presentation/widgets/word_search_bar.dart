import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/speech_service.dart';
import '../providers/words_provider.dart';

/// Interactive Search bar with voice recognition (microphone) and clear buttons
class WordSearchBar extends ConsumerStatefulWidget {
  const WordSearchBar({super.key});

  @override
  ConsumerState<WordSearchBar> createState() => _WordSearchBarState();
}

class _WordSearchBarState extends ConsumerState<WordSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(wordSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceSearch() async {
    final isListening = ref.read(voiceListeningProvider);

    if (isListening) {
      await SpeechService.instance.stopListening();
      ref.read(voiceListeningProvider.notifier).setListening(false);
      return;
    }

    final success = await SpeechService.instance.startListening(
      onResult: (recognizedWords, isFinal) {
        if (recognizedWords.trim().isEmpty) return;

        // Clean trailing punctuation from speech recognizer
        final cleanWords = recognizedWords
            .trim()
            .replaceAll(RegExp(r'[\.\,\?\!\;]+$'), '')
            .trim();

        setState(() {
          _controller.text = cleanWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: cleanWords.length),
          );
        });

        ref.read(wordSearchQueryProvider.notifier).state = cleanWords;

        if (isFinal) {
          SpeechService.instance.stopListening();
          ref.read(voiceListeningProvider.notifier).setListening(false);
        }
      },
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.mic_off_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Microphone permission or speech recognition is not available.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.incorrectRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(wordSearchQueryProvider);
    final isListening = ref.watch(voiceListeningProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Sync external query changes with controller
    if (_controller.text != query) {
      _controller.value = _controller.value.copyWith(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: (val) {
            ref.read(wordSearchQueryProvider.notifier).state = val;
          },
          decoration: InputDecoration(
            hintText: isListening
                ? 'Listening... Speak a word now'
                : 'Search words, meanings, or topics...',
            hintStyle: TextStyle(
              color: isListening
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : null,
              fontStyle: isListening ? FontStyle.italic : FontStyle.normal,
            ),
            prefixIcon: isListening
                ? Icon(
                    Icons.graphic_eq_rounded,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  )
                : const Icon(Icons.search_rounded),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Clear search',
                    onPressed: () {
                      _controller.clear();
                      ref.read(wordSearchQueryProvider.notifier).state = '';
                    },
                  ),
                // Microphone button
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      key: ValueKey<bool>(isListening),
                      color: isListening
                          ? (isDark ? AppColors.primaryLight : AppColors.primary)
                          : (isDark ? Colors.white70 : Colors.black54),
                      size: 22,
                    ),
                  ),
                  tooltip: isListening
                      ? 'Listening... Tap to stop'
                      : 'Voice search (Speak a word)',
                  onPressed: _toggleVoiceSearch,
                ),
              ],
            ),
          ),
        ),
        if (isListening)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Listening... Say any word to search',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
