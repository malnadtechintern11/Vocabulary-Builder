import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/words_provider.dart';

/// Difficulty level selector chips
class DifficultyFilterChips extends ConsumerWidget {
  const DifficultyFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDifficultyFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final levels = [
      {'key': 'all', 'label': 'All Levels'},
      {'key': 'basic', 'label': 'Basic'},
      {'key': 'intermediate', 'label': 'Intermediate'},
      {'key': 'advanced', 'label': 'Advanced'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: levels.map((lvl) {
          final isSelected = selected == lvl['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(lvl['label']!),
              backgroundColor: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
              selectedColor: isDark ? AppColors.primaryLight : AppColors.primary,
              side: BorderSide(
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A)),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
              onSelected: (_) {
                ref.read(selectedDifficultyFilterProvider.notifier).state = lvl['key']!;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
