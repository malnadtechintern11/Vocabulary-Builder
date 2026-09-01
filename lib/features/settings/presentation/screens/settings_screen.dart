import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/theme_controller.dart';

/// Settings screen allowing customization of ThemeMode (Light, Dark, System) and app configurations
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: Appearance & Theme
          _buildSectionHeader(
            context,
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Choose how Vocabulary Builder looks on your device',
          ),
          const SizedBox(height: 12),

          _buildThemeCard(
            context: context,
            title: 'System Default',
            subtitle: 'Automatically match device system theme settings',
            icon: Icons.brightness_auto_rounded,
            isSelected: currentThemeMode == ThemeMode.system,
            isDark: isDark,
            onTap: () {
              ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.system);
            },
          ),
          const SizedBox(height: 10),

          _buildThemeCard(
            context: context,
            title: 'Light Mode',
            subtitle: 'Crisp, bright design with high contrast',
            icon: Icons.light_mode_rounded,
            isSelected: currentThemeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () {
              ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.light);
            },
          ),
          const SizedBox(height: 10),

          _buildThemeCard(
            context: context,
            title: 'Dark Mode',
            subtitle: 'Sleek dark design comfortable for low-light reading',
            icon: Icons.dark_mode_rounded,
            isSelected: currentThemeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () {
              ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
            },
          ),

          const SizedBox(height: 28),

          // Section 2: Vocabulary Library Info
          _buildSectionHeader(
            context,
            icon: Icons.library_books_outlined,
            title: 'Vocabulary Library',
            subtitle: 'Embedded offline dictionary & learning tools',
          ),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    icon: Icons.auto_stories_rounded,
                    title: 'Total Vocabulary',
                    value: '1,350 Words',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    context,
                    icon: Icons.category_rounded,
                    title: 'Topics / Categories',
                    value: '27 Topics (50+ each)',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    context,
                    icon: Icons.stairs_rounded,
                    title: 'Difficulty Levels',
                    value: 'Basic, Intermediate, Advanced',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    context,
                    icon: Icons.translate_rounded,
                    title: 'Kannada Meanings',
                    value: 'ಕನ್ನಡ ಅರ್ಥಗಳು ಸೇರಿಸಲಾಗಿದೆ',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    context,
                    icon: Icons.wifi_off_rounded,
                    title: 'Storage & Access',
                    value: '100% Offline SQLite',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Section 3: About App
          _buildSectionHeader(
            context,
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'Application details & version',
          ),
          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppConstants.appTagline,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'v1.0.0',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final borderColor = isSelected
        ? primaryColor
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (primaryColor.withValues(alpha: isDark ? 0.15 : 0.08))
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.2)
                    : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? primaryColor
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
