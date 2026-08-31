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
    final levels = [
      {'key': 'all', 'label': 'All Levels'},
      {'key': 'beginner', 'label': 'Beginner'},
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
              selectedColor: AppColors.primaryContainerLight,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryDark : null,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
