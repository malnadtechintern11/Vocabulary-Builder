import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('"${result.word}" added to your vocabulary!'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'View Word',
            textColor: Colors.white,
            onPressed: () {
              context.push('${RoutePaths.words}/${result.id}');
            },
          ),
        ),
      );

      _resetForm();
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? AppColors.primaryLight : AppColors.primary,
                      isDark ? AppColors.primaryDark : AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
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
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add your own words with Kannada translations & examples.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 1. English Word
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

              const SizedBox(height: 18),

              // 2. Part of Speech
              Text(
                'Part of Speech',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedPartOfSpeech,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                items: _partsOfSpeech.map((pos) {
                  return DropdownMenuItem(
                    value: pos,
                    child: Text(
                      pos[0].toUpperCase() + pos.substring(1),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPartOfSpeech = val);
                  }
                },
              ),

              const SizedBox(height: 18),

              // 3. Phonetic (Optional)
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

              const SizedBox(height: 18),

              // 4. English Meaning
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

              const SizedBox(height: 18),

              // 5. Kannada Meaning
              Text(
                'ಕನ್ನಡ ಅರ್ಥ (Kannada Meaning) *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _kannadaMeaningController,
                decoration: InputDecoration(
                  hintText: 'ಉದಾ: ಕಷ್ಟಗಳನ್ನು ಎದುರಿಸಿ ಚೇತರಿಸಿಕೊಳ್ಳುವ / ದೃಢವಾದ',
                  prefixIcon: Icon(
                    Icons.translate_rounded,
                    color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                      width: 1.5,
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

              const SizedBox(height: 18),

              // 6. Example Sentence
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

              const SizedBox(height: 18),

              // 7. Difficulty Level
              Text(
                'Difficulty Level',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  {'key': 'basic', 'label': 'Basic'},
                  {'key': 'intermediate', 'label': 'Intermediate'},
                  {'key': 'advanced', 'label': 'Advanced'},
                ].map((lvl) {
                  final isSel = _selectedDifficulty == lvl['key'];
                  return ChoiceChip(
                    label: Text(lvl['label']!),
                    selected: isSel,
                    showCheckmark: false,
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
                      setState(() => _selectedDifficulty = lvl['key']!);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // 8. Topic / Category Selector
              Text(
                'Topic / Category',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                items: _topics.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t, overflow: TextOverflow.ellipsis),
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

              const SizedBox(height: 18),

              // 9. Synonyms (Optional)
              Text(
                'Synonyms (optional)',
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _synonymsController,
                decoration: const InputDecoration(
                  hintText: 'e.g. tough, flexible, robust',
                  prefixIcon: Icon(Icons.compare_arrows_rounded),
                ),
              ),

              const SizedBox(height: 18),

              // 10. Antonyms (Optional)
              Text(
                'Antonyms (optional)',
                style: theme.textTheme.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _antonymsController,
                decoration: const InputDecoration(
                  hintText: 'e.g. fragile, weak, delicate',
                  prefixIcon: Icon(Icons.swap_horiz_rounded),
                ),
              ),

              const SizedBox(height: 32),

              // 9. Save Word Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitWord,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add_task_rounded, size: 22),
                  label: Text(
                    _isSubmitting ? 'Saving Word...' : 'Add Word to Vocabulary',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
