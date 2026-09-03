import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/learning_analytics_service.dart';
import '../../../../core/widgets/animated_progress_bar.dart';

/// Interactive view displaying achievements and badges with locked/unlocked statuses & progress
class AchievementsView extends StatefulWidget {
  final List<AchievementBadge> badges;

  const AchievementsView({super.key, required this.badges});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  int _selectedFilter = 0; // 0: All, 1: Unlocked, 2: Locked

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final unlockedCount = widget.badges.where((b) => b.isUnlocked).length;
    final lockedCount = widget.badges.length - unlockedCount;

    final displayedBadges = widget.badges.where((b) {
      if (_selectedFilter == 1) return b.isUnlocked;
      if (_selectedFilter == 2) return !b.isUnlocked;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips Row
        Row(
          children: [
            _buildFilterTab('All (${widget.badges.length})', 0, isDark),
            const SizedBox(width: 8),
            _buildFilterTab('Unlocked ($unlockedCount)', 1, isDark),
            const SizedBox(width: 8),
            _buildFilterTab('Locked ($lockedCount)', 2, isDark),
          ],
        ),
        const SizedBox(height: 16),

        // Badges List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedBadges.length,
          itemBuilder: (context, index) {
            final badge = displayedBadges[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: badge.isUnlocked
                      ? badge.color.withValues(alpha: isDark ? 0.4 : 0.3)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1.2,
                ),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
              ),
              child: Row(
                children: [
                  // Badge Avatar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: badge.isUnlocked
                          ? LinearGradient(
                              colors: [badge.color, badge.color.withValues(alpha: 0.75)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: !badge.isUnlocked
                          ? (isDark ? Colors.white10 : const Color(0xFFE2E8F0))
                          : null,
                      shape: BoxShape.circle,
                      boxShadow: badge.isUnlocked
                          ? [
                              BoxShadow(
                                color: badge.color.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      badge.isUnlocked ? badge.icon : Icons.lock_outline_rounded,
                      size: 26,
                      color: badge.isUnlocked ? Colors.white : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Badge Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              badge.title,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: badge.isUnlocked
                                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                                    : (isDark ? Colors.white54 : Colors.black54),
                              ),
                            ),
                            if (badge.isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                                    SizedBox(width: 4),
                                    Text(
                                      'Unlocked',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Progress Bar for Locked Badges
                        if (!badge.isUnlocked) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              Text(
                                '${badge.currentValue} / ${badge.targetValue}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AnimatedProgressBar(
                            value: badge.progress,
                            height: 6,
                            color: badge.color,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label, int index, bool isDark) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                : (isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}
