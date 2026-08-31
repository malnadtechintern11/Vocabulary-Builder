import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/quiz_question.dart';
import '../providers/quiz_controller.dart';

/// Screen allowing user to select quiz type, difficulty, and launch quiz session
class QuizSetupScreen extends ConsumerStatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  ConsumerState<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends ConsumerState<QuizSetupScreen> {
  QuizType _selectedType = QuizType.meaningMatch;
  String _selectedDifficulty = 'all';
  int _selectedCount = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statsAsync = ref.watch(quizStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    AppColors.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Test Your Knowledge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Challenge yourself with randomized questions generated directly from your local vocabulary library.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Quiz Type Section
            Text(
              '1. Select Quiz Mode',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _buildTypeOption(
              context,
              type: QuizType.meaningMatch,
              title: 'Definition Match',
              description: 'Select the correct definition for the target word.',
              icon: Icons.menu_book_rounded,
            ),
            _buildTypeOption(
              context,
              type: QuizType.synonymMatch,
              title: 'Synonym Finder',
              description: 'Identify the word with the closest meaning.',
              icon: Icons.compare_arrows_rounded,
            ),
            _buildTypeOption(
              context,
              type: QuizType.antonymMatch,
              title: 'Antonym Challenge',
              description: 'Pick the word with the opposite meaning.',
              icon: Icons.swap_horiz_rounded,
            ),
            _buildTypeOption(
              context,
              type: QuizType.fillInTheBlank,
              title: 'Fill in the Blank',
              description: 'Choose the missing word in the contextual example sentence.',
              icon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 24),

            // Select Difficulty
            Text(
              '2. Select Difficulty Level',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                {'key': 'all', 'label': 'All Levels'},
                {'key': 'beginner', 'label': 'Beginner'},
                {'key': 'intermediate', 'label': 'Intermediate'},
                {'key': 'advanced', 'label': 'Advanced'},
              ].map((lvl) {
                final isSel = _selectedDifficulty == lvl['key'];
                return ChoiceChip(
                  label: Text(lvl['label']!),
                  selected: isSel,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() => _selectedDifficulty = lvl['key']!);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Select Question Count
            Text(
              '3. Number of Questions',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [5, 10, 15, 20].map((count) {
                final isSel = _selectedCount == count;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ChoiceChip(
                    label: Text('$count Qs'),
                    selected: isSel,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() => _selectedCount = count);
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Start Quiz Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(quizControllerProvider.notifier).startQuiz(
                    type: _selectedType,
                    difficulty: _selectedDifficulty == 'all' ? null : _selectedDifficulty,
                    questionCount: _selectedCount,
                  );
                  if (context.mounted) {
                    context.push(RoutePaths.quizActive);
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: const Text(
                  'Start Quiz Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Past Quiz Summary Quick Peek
            statsAsync.when(
              data: (stats) {
                final total = stats['totalQuizzes'] as int? ?? 0;
                final avg = (stats['averageScore'] as num?)?.toDouble() ?? 0.0;
                if (total == 0) return const SizedBox.shrink();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Completed', '$total', isDark),
                        Container(width: 1, height: 36, color: isDark ? Colors.white10 : Colors.black12),
                        _buildStatItem('Average Score', '${avg.toStringAsFixed(0)}%', isDark),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    BuildContext context, {
    required QuizType type,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: isSelected
            ? (isDark ? AppColors.surfaceVariantDark : AppColors.primaryContainerLight)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _selectedType = type),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isSelected ? (isDark ? Colors.white : AppColors.primaryDark) : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
