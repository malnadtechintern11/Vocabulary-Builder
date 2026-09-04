import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/translation_service.dart';
import '../../../../core/services/tts_service.dart';
import '../../../ocr/presentation/providers/ocr_provider.dart';
import '../providers/translation_provider.dart';

/// Online Multi-Language Translation screen supporting 10 Indian & English languages with photo scanning
class TranslationScreen extends ConsumerStatefulWidget {
  final String? initialText;

  const TranslationScreen({super.key, this.initialText});

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  late final TextEditingController _inputController;
  XFile? _scannedImageFile;
  bool _isScanning = false;
  String? _scanErrorMessage;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.initialText ?? '');

    // If initial text is passed (e.g. from OCR scanner or external navigation), prefill and translate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialText != null && widget.initialText!.trim().isNotEmpty) {
        ref.read(translationNotifierProvider.notifier).setInputText(widget.initialText!);
        ref.read(translationNotifierProvider.notifier).translate(textOverride: widget.initialText);
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScanText(ImageSource source) async {
    setState(() {
      _isScanning = true;
      _scanErrorMessage = null;
    });

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final xFile = await ocrService.pickImage(source: source);
      if (xFile == null) {
        if (mounted) setState(() => _isScanning = false);
        return;
      }

      String finalPath = xFile.path;
      final cropped = await ocrService.cropImage(xFile.path);
      if (cropped != null && cropped.isNotEmpty) {
        finalPath = cropped;
      }

      final ocrResult = await ocrService.recognizeText(finalPath);
      final rawText = ocrResult.rawText.trim();

      if (!mounted) return;

      if (rawText.isEmpty) {
        setState(() {
          _scannedImageFile = XFile(finalPath);
          _isScanning = false;
          _scanErrorMessage = 'No readable text detected in this image. Try capturing clearer text or typing below.';
        });
        return;
      }

      _inputController.text = rawText;
      ref.read(translationNotifierProvider.notifier).setInputText(rawText);

      setState(() {
        _scannedImageFile = XFile(finalPath);
        _isScanning = false;
        _scanErrorMessage = null;
      });

      // Automatically translate the scanned text into target language
      await ref.read(translationNotifierProvider.notifier).translate(textOverride: rawText);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanErrorMessage = 'Scan error: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _cropScannedImage() async {
    if (_scannedImageFile == null) return;
    setState(() {
      _isScanning = true;
      _scanErrorMessage = null;
    });

    try {
      final ocrService = ref.read(ocrServiceProvider);
      final cropped = await ocrService.cropImage(_scannedImageFile!.path);
      if (cropped != null && cropped.isNotEmpty && cropped != _scannedImageFile!.path) {
        final ocrResult = await ocrService.recognizeText(cropped);
        final rawText = ocrResult.rawText.trim();

        if (!mounted) return;

        if (rawText.isNotEmpty) {
          _inputController.text = rawText;
          ref.read(translationNotifierProvider.notifier).setInputText(rawText);
          await ref.read(translationNotifierProvider.notifier).translate(textOverride: rawText);
        }

        setState(() {
          _scannedImageFile = XFile(cropped);
          _isScanning = false;
          _scanErrorMessage = rawText.isEmpty ? 'No readable text found in cropped area.' : null;
        });
      } else {
        if (mounted) setState(() => _isScanning = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanErrorMessage = 'Crop error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(translationNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedTargetLang = TranslationService.getLanguage(translationState.targetLanguageCode);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: isDark ? 0.25 : 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.g_translate_rounded,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Multi-Language Translation',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '10 Indian & English Languages (Online)',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // Offline Internet Connection Error Banner
          if (translationState.isOfflineError) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF7F1D1D).withValues(alpha: 0.3)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFFDC2626) : const Color(0xFFF87171),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: AppColors.error,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connection Required',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Internet connection is required for translation',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF7F1D1D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'All other Vocabulary Builder features (Words, Sentences, Quizzes, Progress) continue to work 100% offline.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(translationNotifierProvider.notifier).translate();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry Translation'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Take Photo & Choose Image OCR Scanner Card (Placed above Language Selector)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.document_scanner_rounded,
                        size: 16,
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Scan Text from Image / Camera',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'OCR Auto-Fill',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? null : () => _pickAndScanText(ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_rounded, size: 18),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isScanning ? null : () => _pickAndScanText(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: const Text('Choose Image'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),

                // Scanned Image Preview Thumbnail
                if (_scannedImageFile != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child: Image.file(
                              File(_scannedImageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Image Scanned',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Text extracted & auto-filled below',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: _isScanning ? null : _cropScannedImage,
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          child: const Text('Re-crop', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Remove Image',
                          onPressed: () {
                            setState(() {
                              _scannedImageFile = null;
                              _scanErrorMessage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                // Scanning Progress Indicator
                if (_isScanning) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Scanning and extracting text from image...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],

                // Scanning Error Message
                if (_scanErrorMessage != null && !_isScanning) ...[
                  const SizedBox(height: 10),
                  Text(
                    _scanErrorMessage!,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Language Selector Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            child: Row(
              children: [
                // Source Language
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Translate From',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Auto Detect',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),

                // Arrow indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),

                // Target Language Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Translate To',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      PopupMenuButton<String>(
                        initialValue: translationState.targetLanguageCode,
                        onSelected: (code) {
                          ref.read(translationNotifierProvider.notifier).setTargetLanguage(code);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder: (context) {
                          return TranslationService.supportedLanguages.map((lang) {
                            return PopupMenuItem<String>(
                              value: lang.code,
                              child: Row(
                                children: [
                                  Text(lang.flag, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      lang.displayName,
                                      style: TextStyle(
                                        fontWeight: lang.code == translationState.targetLanguageCode
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                        color: lang.code == translationState.targetLanguageCode
                                            ? AppColors.primary
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (lang.code == translationState.targetLanguageCode)
                                    const Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(selectedTargetLang.flag, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                selectedTargetLang.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Target Language Horizontal Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TranslationService.supportedLanguages.map((lang) {
                final isSelected = lang.code == translationState.targetLanguageCode;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    avatar: Text(lang.flag, style: const TextStyle(fontSize: 13)),
                    label: Text(lang.name),
                    selected: isSelected,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    backgroundColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                    selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                    side: BorderSide(
                      color: isSelected
                          ? (isDark ? AppColors.primaryLight : AppColors.primary)
                          : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                      width: 1.2,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      ref.read(translationNotifierProvider.notifier).setTargetLanguage(lang.code);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Text Input Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Input English Text or Sentence',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (_inputController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        tooltip: 'Clear input',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          _inputController.clear();
                          ref.read(translationNotifierProvider.notifier).clear();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _inputController,
                  maxLines: 4,
                  minLines: 2,
                  onChanged: (val) {
                    ref.read(translationNotifierProvider.notifier).setInputText(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Type a word, phrase, or sentence to translate...',
                    fillColor: isDark ? Colors.black26 : const Color(0xFFF8FAFC),
                    filled: true,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${_inputController.text.length} characters',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data?.text != null && data!.text!.isNotEmpty) {
                          _inputController.text = data.text!;
                          ref.read(translationNotifierProvider.notifier).setInputText(data.text!);
                        }
                      },
                      icon: const Icon(Icons.content_paste_rounded, size: 15),
                      label: const Text('Paste', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Translate Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: translationState.isLoading
                  ? null
                  : () {
                      ref.read(translationNotifierProvider.notifier).translate(
                            textOverride: _inputController.text,
                          );
                    },
              icon: translationState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.translate_rounded, size: 20),
              label: Text(
                translationState.isLoading
                    ? 'Translating Online...'
                    : 'Translate to ${selectedTargetLang.name}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Translation Result Card
          if (translationState.result != null && translationState.result!.translatedText.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF059669).withValues(alpha: 0.5) : const Color(0xFF86EFAC),
                  width: 1.5,
                ),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Result Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Translation Result (${selectedTargetLang.nativeName})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedTargetLang.flag,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Translated Text Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.18)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF059669).withValues(alpha: 0.3)
                            : const Color(0xFFBBF7D0),
                      ),
                    ),
                    child: SelectableText(
                      translationState.result!.translatedText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF14532D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Actions Row: Copy, Pronounce (if English), Add to Vocabulary
                  Row(
                    children: [
                      // Pronounce if English or Latin
                      if (translationState.targetLanguageCode == 'en') ...[
                        FilledButton.tonalIcon(
                          onPressed: () {
                            ref.read(appTtsControllerProvider).toggleSpeak(
                                  id: 'translation_${translationState.result!.translatedText.hashCode}',
                                  text: translationState.result!.translatedText,
                                );
                          },
                          icon: const Icon(Icons.volume_up_rounded, size: 16),
                          label: const Text('Listen'),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Copy Button
                      IconButton.outlined(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: 'Copy translation',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: translationState.result!.translatedText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Translation copied to clipboard!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),

                      const Spacer(),

                      // Save / Add to Vocabulary Button
                      FilledButton.icon(
                        onPressed: () {
                          // Navigate to AddWordScreen with word and translation prefilled
                          context.push(
                            RoutePaths.addWord,
                            extra: {
                              'word': translationState.result!.sourceText,
                              'kannadaMeaning': translationState.targetLanguageCode == 'kn'
                                  ? translationState.result!.translatedText
                                  : '',
                              'meaning': translationState.result!.translatedText,
                            },
                          );
                        },
                        icon: const Icon(Icons.bookmark_add_rounded, size: 16),
                        label: const Text('Save to Vocabulary'),
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
