import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/translation_service.dart';
import '../../../../core/widgets/audio_pronounce_button.dart';
import '../../../words/presentation/widgets/difficulty_badge.dart';
import '../providers/ocr_provider.dart';

/// Screen implementing 3-step learning flow:
/// 1. Scan Text from Image/Camera
/// 2. Choose Target Language
/// 3. Change Text into Chosen Language with offline vocabulary matching
class ScanTextScreen extends ConsumerWidget {
  const ScanTextScreen({super.key});

  void _showWordUnderstandingSheet(BuildContext context, WidgetRef ref, String wordText) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final word = await ref.read(ocrNotifierProvider.notifier).findWord(wordText);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(22, 16, 22, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Word header & speaker button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      wordText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ),
                  AudioPronounceButton(
                    id: 'sheet_$wordText',
                    text: wordText,
                    iconSize: 22,
                  ),
                ],
              ),

              // Word Details if in local database
              if (word != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    DifficultyBadge(difficulty: word.difficulty),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        word.partOfSpeech.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Kannada Meaning Box
                if (word.kannadaMeaning.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.25)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFF86EFAC),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ಕನ್ನಡ ಅರ್ಥ (Kannada Meaning)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.secondaryLight : AppColors.secondaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.kannadaMeaning,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF14532D),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 10),
                Text(
                  word.meaning,
                  style: const TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                ),

                if (word.example.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Example: "${word.example}"',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'This word is not yet in your local dictionary. You can translate it to Kannada online or save it to your vocabulary.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Actions: Translate & Save
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(RoutePaths.translation, extra: wordText);
                      },
                      icon: const Icon(Icons.translate_rounded, size: 16),
                      label: const Text('Translate Word'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(RoutePaths.addWord, extra: wordText);
                      },
                      icon: const Icon(Icons.bookmark_add_rounded, size: 16),
                      label: const Text('Save Word'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrState = ref.watch(ocrNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLangName = TranslationService.getLanguageName(ocrState.selectedLanguageCode);
    final currentLangFlag = TranslationService.getLanguageFlag(ocrState.selectedLanguageCode);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.document_scanner_rounded,
                size: 20,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scan Text (OCR)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '100% Offline On-Device Recognition',
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
        actions: [
          if (ocrState.result != null || ocrState.imageFile != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Clear & Scan New Image',
              onPressed: () {
                ref.read(ocrNotifierProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Hero Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E1B4B).withValues(alpha: 0.95),
                        const Color(0xFF312E81).withValues(alpha: 0.7),
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
                    ? AppColors.primaryLight.withValues(alpha: 0.3)
                    : AppColors.primaryLight.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryLight.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Textbook & Image Scanner',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '1. Scan text  ➔  2. Choose language  ➔  3. Change into chosen language instantly.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Capture / Pick Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: ocrState.isProcessing
                      ? null
                      : () => ref.read(ocrNotifierProvider.notifier).pickAndRecognize(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_rounded, size: 20),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: ocrState.isProcessing
                      ? null
                      : () => ref.read(ocrNotifierProvider.notifier).pickAndRecognize(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 20),
                  label: const Text('Choose Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Image Preview (if image selected)
          if (ocrState.imageFile != null) ...[
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image_rounded, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Scanned Image Source',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      FilledButton.tonalIcon(
                        onPressed: ocrState.isProcessing
                            ? null
                            : () => ref.read(ocrNotifierProvider.notifier).cropCurrentImage(),
                        icon: const Icon(Icons.crop_rounded, size: 15),
                        label: const Text('Crop Image', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => ref.read(ocrNotifierProvider.notifier).clear(),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        tooltip: 'Remove',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.file(
                        File(ocrState.imageFile!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: ocrState.isProcessing
                          ? null
                          : () => ref.read(ocrNotifierProvider.notifier).cropCurrentImage(),
                      icon: const Icon(Icons.crop_rotate_rounded, size: 17),
                      label: const Text('Crop / Re-crop Image for Best Accuracy'),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Processing Loading Indicator
          if (ocrState.isProcessing) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Detecting Text On-Device...',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Running offline machine learning OCR model without internet.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Error / Empty Message
          if (ocrState.errorMessage != null && !ocrState.isProcessing) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.25)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ocrState.errorMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ==========================================
          // 3-STEP PIPELINE WHEN TEXT IS SCANNED
          // ==========================================
          if (ocrState.result != null && ocrState.result!.isNotEmpty) ...[
            // ----------------------------------------
            // STEP 1: SCANNED ENGLISH TEXT
            // ----------------------------------------
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Step 1 Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Step 1',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Scanned English Text',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${ocrState.result!.words.length} Words',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Detected Text Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: SelectableText(
                      ocrState.result!.rawText,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tool Actions: Listen & Copy
                  Row(
                    children: [
                      AudioPronounceTonalButton(
                        id: 'ocr_text_${ocrState.result!.rawText.hashCode}',
                        text: ocrState.result!.rawText,
                        label: 'Listen Aloud',
                        playingLabel: 'Speaking...',
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: 'Copy scanned text',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: ocrState.result!.rawText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Scanned text copied to clipboard!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          context.push(RoutePaths.addWord, extra: ocrState.result!.rawText);
                        },
                        icon: const Icon(Icons.bookmark_add_rounded, size: 17),
                        label: const Text('Save to Vocab', style: TextStyle(fontSize: 12.5)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ----------------------------------------
            // STEP 2: CHOOSE LANGUAGE
            // ----------------------------------------
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Step 2',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Choose Language to Translate Into',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap any language to instantly change the scanned text into that language:',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Language Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TranslationService.supportedLanguages.map((lang) {
                      final isSelected = lang.code == ocrState.selectedLanguageCode;
                      return ChoiceChip(
                        avatar: Text(lang.flag, style: const TextStyle(fontSize: 14)),
                        label: Text(
                          '${lang.name} (${lang.nativeName})',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0D9488), // Teal
                        backgroundColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(ocrNotifierProvider.notifier).setTargetLanguage(lang.code);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ----------------------------------------
            // STEP 3: CHANGED TEXT IN CHOSEN LANGUAGE
            // ----------------------------------------
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.4 : 0.3),
                  width: 1.5,
                ),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Step 3',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$currentLangFlag Changed into $currentLangName',
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (ocrState.isTranslating)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D9488)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Translated Text Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.22)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFF86EFAC),
                        width: 1.2,
                      ),
                    ),
                    child: ocrState.isTranslating
                        ? Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF059669)),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Translating text into $currentLangName...',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          )
                        : (ocrState.translatedText != null && ocrState.translatedText!.isNotEmpty)
                            ? SelectableText(
                                ocrState.translatedText!,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF14532D),
                                ),
                              )
                            : Text(
                                'Tap a language above to translate and view your text.',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                  ),

                  // Offline / Error Notification
                  if (ocrState.translationError != null && !ocrState.isTranslating) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF7F1D1D).withValues(alpha: 0.2)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ocrState.translationError!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(ocrNotifierProvider.notifier).translateCurrentText();
                            },
                            child: const Text('Retry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Action Buttons for Translated Text
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: (ocrState.translatedText != null && ocrState.translatedText!.isNotEmpty)
                            ? () {
                                Clipboard.setData(ClipboardData(text: ocrState.translatedText!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Translated $currentLangName text copied to clipboard!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy Translation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            RoutePaths.translation,
                            extra: ocrState.result!.rawText,
                          );
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('Full Translator'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------
            // STEP 4: OFFLINE MATCHED VOCABULARY WORDS
            // ----------------------------------------
            if (ocrState.matchedWords.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                  boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.library_books_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Dictionary Words in This Scan (${ocrState.matchedWords.length})',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...ocrState.matchedWords.map((word) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  word.word,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DifficultyBadge(difficulty: word.difficulty),
                                const Spacer(),
                                AudioPronounceButton(
                                  id: 'match_${word.id}',
                                  text: word.word,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                            if (word.kannadaMeaning.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ಕನ್ನಡ ಅರ್ಥ: ${word.kannadaMeaning}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              word.meaning,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: isDark ? AppColors.textPrimaryDark : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ----------------------------------------
            // ALL DETECTED WORDS (TAP TO LEARN)
            // ----------------------------------------
            if (ocrState.result!.words.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                  boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Tap Any Word to Understand & Learn:',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ocrState.result!.words.take(30).map((word) {
                        return ActionChip(
                          avatar: const Icon(Icons.info_outline_rounded, size: 15),
                          label: Text(word),
                          backgroundColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                          side: BorderSide(
                            color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                          onPressed: () {
                            _showWordUnderstandingSheet(context, ref, word);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
