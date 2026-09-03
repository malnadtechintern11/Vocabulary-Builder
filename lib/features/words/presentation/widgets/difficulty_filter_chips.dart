import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/words_provider.dart';

/// Difficulty level selector chips with level indicators and pill styling
class DifficultyFilterChips extends ConsumerWidget {
  const DifficultyFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDifficultyFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final levels = [
      {'key': 'all', 'label': 'All Levels', 'color': isDark ? AppColors.primaryLight : AppColors.primary},
      {'key': 'basic', 'label': 'Basic', 'color': AppColors.difficultyBeginner},
      {'key': 'intermediate', 'label': 'Intermediate', 'color': AppColors.difficultyIntermediate},
      {'key': 'advanced', 'label': 'Advanced', 'color': AppColors.difficultyAdvanced},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: levels.map((lvl) {
          final isSelected = selected == lvl['key'];
          final dotColor = lvl['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              avatar: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white : dotColor,
                ),
              ),
              label: Text(lvl['label'] as String),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                fontSize: 12.5,
              ),
              onSelected: (_) {
                ref.read(selectedDifficultyFilterProvider.notifier).state = lvl['key'] as String;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
