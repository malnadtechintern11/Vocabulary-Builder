import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/learning_analytics_service.dart';

/// Aesthetic 7-day weekly activity bar chart displaying study frequency & goal completions
class WeeklyActivityChart extends StatelessWidget {
  final List<DailyActivityItem> activities;

  const WeeklyActivityChart({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxWords = activities.map((a) => a.wordsLearned).fold(0, math.max);
    final chartCeiling = math.max(maxWords, 10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      size: 20,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '7-Day Learning Activity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Activity Bars Row
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activities.map((act) {
                final heightFactor = (act.wordsLearned / chartCeiling).clamp(0.08, 1.0);
                final hasActivity = act.wordsLearned > 0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (act.isGoalAchieved)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                      )
                    else
                      const SizedBox(height: 18),

                    // Animated Bar Pill
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: heightFactor),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, _) {
                        return Container(
                          width: 22,
                          height: 64 * val,
                          decoration: BoxDecoration(
                            gradient: act.isToday
                                ? LinearGradient(
                                    colors: [
                                      isDark ? AppColors.primaryLight : AppColors.primary,
                                      const Color(0xFF818CF8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )
                                : (hasActivity
                                    ? LinearGradient(
                                        colors: [
                                          AppColors.success,
                                          const Color(0xFF34D399),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    : null),
                            color: !hasActivity
                                ? (isDark ? Colors.white12 : const Color(0xFFE2E8F0))
                                : null,
                            borderRadius: BorderRadius.circular(11),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Day Name Label
                    Text(
                      act.dayName,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: act.isToday ? FontWeight.w900 : FontWeight.w600,
                        color: act.isToday
                            ? (isDark ? AppColors.primaryLight : AppColors.primary)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                    Text(
                      '${act.wordsLearned}w',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: hasActivity
                            ? (isDark ? Colors.white70 : Colors.black87)
                            : (isDark ? Colors.white24 : Colors.black26),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
