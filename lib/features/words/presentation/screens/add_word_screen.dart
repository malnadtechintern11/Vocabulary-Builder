import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/success_celebration_dialog.dart';
import '../../domain/entities/word.dart';
import '../providers/words_provider.dart';

/// Screen allowing users to add their own custom vocabulary words
class AddWordScreen extends ConsumerStatefulWidget {
  const AddWordScreen({super.key});

  @override
  ConsumerState<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends ConsumerState<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _wordController = TextEditingController();
  final _phoneticController = TextEditingController();
  final _meaningController = TextEditingController();
  final _kannadaMeaningController = TextEditingController();
  final _exampleController = TextEditingController();
  final _synonymsController = TextEditingController();
  final _antonymsController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String _selectedPartOfSpeech = 'noun';
  String _selectedDifficulty = 'basic';
  String _selectedCategory = 'General';
  bool _isCustomCategory = false;
  bool _isSubmitting = false;

  final List<String> _partsOfSpeech = [
    'noun',
    'verb',
    'adjective',
    'adverb',
    'pronoun',
    'preposition',
    'conjunction',
    'interjection',
  ];

  final List<String> _topics = [
    'Actions', 'Animals', 'Arts', 'Body', 'Communication', 'Creativity',
    'Daily', 'Education', 'Emotions', 'Food', 'General', 'Geography',
    'Health', 'Life', 'Mind', 'Nature', 'Personality', 'Place',
    'Relationships', 'Science', 'Skills', 'Social', 'Society', 'Sports',
    'Time', 'Travel', 'Values', 'Custom Topic...'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final extra = GoRouterState.of(context).extra;
        if (extra is Map<String, dynamic>) {
          if (extra['word'] != null && _wordController.text.isEmpty) {
            _wordController.text = extra['word'].toString();
          }
          if (extra['meaning'] != null && _meaningController.text.isEmpty) {
            _meaningController.text = extra['meaning'].toString();
          }
          if (extra['kannadaMeaning'] != null && _kannadaMeaningController.text.isEmpty) {
            _kannadaMeaningController.text = extra['kannadaMeaning'].toString();
          }
          if (extra['example'] != null && _exampleController.text.isEmpty) {
            _exampleController.text = extra['example'].toString();
          }
        } else if (extra is String && extra.trim().isNotEmpty && _wordController.text.isEmpty) {
          final text = extra.trim();
          if (text.contains(' ') || text.length > 30) {
            _exampleController.text = text;
          } else {
            _wordController.text = text;
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _phoneticController.dispose();
    _meaningController.dispose();
    _kannadaMeaningController.dispose();
    _exampleController.dispose();
    _synonymsController.dispose();
    _antonymsController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _submitWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final finalCategory = _isCustomCategory && _customCategoryController.text.trim().isNotEmpty
        ? _customCategoryController.text.trim().toLowerCase()
        : _selectedCategory.toLowerCase();

    final synonyms = _synonymsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final antonyms = _antonymsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final newWord = Word(
      id: 0,
      word: _wordController.text.trim(),
      phonetic: _phoneticController.text.trim(),
      partOfSpeech: _selectedPartOfSpeech,
      meaning: _meaningController.text.trim(),
      kannadaMeaning: _kannadaMeaningController.text.trim(),
      example: _exampleController.text.trim(),
      synonyms: synonyms,
      antonyms: antonyms,
      difficulty: _selectedDifficulty.toLowerCase(),
      category: finalCategory,
      isFavorite: false,
      isLearned: false,
    );

    final result = await ref.read(wordControllerProvider.notifier).addWord(newWord);

    setState(() => _isSubmitting = false);

    if (result != null && mounted) {
      _resetForm();
      SuccessCelebrationDialog.show(
        context: context,
        title: 'Word Added Successfully!',
        message: '"${result.word}" is now permanently saved to your offline vocabulary library.',
        scoreText: '+1 New Word',
        primaryButtonLabel: 'View Word',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          context.push('${RoutePaths.words}/${result.id}');
        },
        secondaryButtonLabel: 'Add Another',
        onSecondaryPressed: () => Navigator.of(context).pop(),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to add word. Please check if it already exists.'),
          backgroundColor: AppColors.incorrectRed,
        ),
      );
    }
  }

  void _resetForm() {
    _wordController.clear();
    _phoneticController.clear();
    _meaningController.clear();
    _kannadaMeaningController.clear();
    _exampleController.clear();
    _synonymsController.clear();
    _antonymsController.clear();
    _customCategoryController.clear();
    setState(() {
      _selectedPartOfSpeech = 'noun';
      _selectedDifficulty = 'basic';
      _selectedCategory = 'General';
      _isCustomCategory = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Word'),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_rounded),
            tooltip: 'Scan Textbook / Image (Offline OCR)',
            onPressed: () => context.push(RoutePaths.scanText),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear Form',
            onPressed: _resetForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? AppColors.primaryLight : AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Custom Vocabulary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add your own words with Kannada translations & examples.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: Word & Grammar Card
              Container(
                padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.text_fields_rounded,
                            size: 16,
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Word & Grammar',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'English Word *',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _wordController,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Resilient',
                                  prefixIcon: Icon(Icons.title_rounded),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter a word';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Part of Speech',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedPartOfSpeech,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                                items: _partsOfSpeech.map((pos) {
                                  return DropdownMenuItem(
                                    value: pos,
                                    child: Text(
                                      pos[0].toUpperCase() + pos.substring(1),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedPartOfSpeech = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pronunciation / Phonetic (Optional)',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneticController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. /rɪˈzɪl.jənt/',
                        prefixIcon: Icon(Icons.record_voice_over_outlined),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 2: Meanings & Kannada Translation Card
              Container(
                padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.translate_rounded,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Meanings & Translation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'English Meaning / Definition *',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _meaningController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Able to withstand or recover quickly from difficult conditions.',
                        prefixIcon: Icon(Icons.menu_book_rounded),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter the English meaning';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Kannada Meaning highlighted box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.15)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFF86EFAC),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.g_translate_rounded,
                                size: 17,
                                color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ಕನ್ನಡ ಅರ್ಥ (Kannada Meaning) *',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _kannadaMeaningController,
                            decoration: InputDecoration(
                              hintText: 'ಉದಾ: ಕಷ್ಟಗಳನ್ನು ಎದುರಿಸಿ ಚೇತರಿಸಿಕೊಳ್ಳುವ / ದೃಢವಾದ',
                              filled: true,
                              fillColor: isDark ? Colors.black26 : Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF059669).withValues(alpha: 0.5) : const Color(0xFF86EFAC),
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter Kannada meaning (ಕನ್ನಡ ಅರ್ಥ)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 3: Context, Category & Difficulty Card
              Container(
                padding: const EdgeInsets.all(18),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.format_quote_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Context & Learning Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Contextual Example Sentence',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _exampleController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g. She remained resilient despite facing numerous setbacks.',
                        prefixIcon: Icon(Icons.format_quote_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Difficulty Level',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'key': 'basic', 'label': 'Basic', 'color': AppColors.difficultyBeginner},
                        {'key': 'intermediate', 'label': 'Intermediate', 'color': AppColors.difficultyIntermediate},
                        {'key': 'advanced', 'label': 'Advanced', 'color': AppColors.difficultyAdvanced},
                      ].map((lvl) {
                        final isSel = _selectedDifficulty == lvl['key'];
                        final dotColor = lvl['color'] as Color;
                        return ChoiceChip(
                          avatar: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSel ? Colors.white : dotColor,
                            ),
                          ),
                          label: Text(lvl['label'] as String),
                          selected: isSel,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                          selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
                          side: BorderSide(
                            color: isSel
                                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                                : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                            width: 1.2,
                          ),
                          labelStyle: TextStyle(
                            color: isSel
                                ? Colors.white
                                : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedDifficulty = lvl['key'] as String);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Topic / Category',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_rounded),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      items: _topics.map((t) {
                        return DropdownMenuItem(
                          value: t,
                          child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCategory = val;
                            _isCustomCategory = val == 'Custom Topic...';
                          });
                        }
                      },
                    ),
                    if (_isCustomCategory) ...[
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _customCategoryController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Enter custom topic name (e.g. Technology)',
                          prefixIcon: Icon(Icons.edit_rounded),
                        ),
                        validator: (val) {
                          if (_isCustomCategory && (val == null || val.trim().isEmpty)) {
                            return 'Please enter the custom topic';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Synonyms (optional)',
                                style: theme.textTheme.titleSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _synonymsController,
                                decoration: const InputDecoration(
                                  hintText: 'tough, flexible',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Antonyms (optional)',
                                style: theme.textTheme.titleSmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _antonymsController,
                                decoration: const InputDecoration(
                                  hintText: 'fragile, weak',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Save Word Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitWord,
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add_task_rounded, size: 22),
                  label: Text(
                    _isSubmitting ? 'Saving Word...' : 'Add Word to Vocabulary',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
