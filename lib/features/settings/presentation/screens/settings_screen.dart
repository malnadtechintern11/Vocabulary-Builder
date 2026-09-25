import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_share_helper.dart';
import '../../../../core/widgets/app_share_button.dart';
import '../providers/theme_controller.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';

/// Settings screen allowing customization of ThemeMode (Light, Dark, System), App Sharing, Privacy Policy, and app configurations
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Play Store link and text shared with other apps and users
  static const String shareLink = AppShareHelper.shareLink;
  static const String shareMessage = AppShareHelper.shareMessage;

  void _shareApp(BuildContext context) {
    AppShareHelper.shareApp(context);
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _openAbout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 21,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Theme, Share & Privacy',
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
        actions: const [
          AppShareButton(),
          SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Section 1: Appearance & Theme
          _buildSectionHeader(
            context,
            icon: Icons.palette_rounded,
            title: 'Appearance',
            subtitle: 'Choose how Kalika looks on your device',
          ),
          const SizedBox(height: 12),

          _buildThemeCard(
            context: context,
            title: 'Light Mode',
            badgeText: 'System Default',
            subtitle: 'Crisp, bright design with high contrast (Default)',
            icon: Icons.light_mode_rounded,
            isSelected: currentThemeMode == ThemeMode.light || currentThemeMode == ThemeMode.system,
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

          const SizedBox(height: 26),

          // Section 2: Rate Us & Support
          _buildSectionHeader(
            context,
            icon: Icons.star_rounded,
            title: 'Rate Us',
            subtitle: 'Love learning? Rate us 5 stars on Google Play Store',
          ),
          const SizedBox(height: 12),

          const _RateUsCard(),

          const SizedBox(height: 26),

          // Section 3: Share & Community (Attractive Action Banner)
          _buildSectionHeader(
            context,
            icon: Icons.share_rounded,
            title: 'Share & Community',
            subtitle: 'Spread the love of English & Kannada learning',
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.heroGradientDark : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => _shareApp(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Share App',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.auto_awesome_rounded, color: Color(0xFFFDE047), size: 16),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Share Kalika with friends & family to learn together!',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Share',
                              style: TextStyle(
                                color: Color(0xFF4F46E5),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Color(0xFF4F46E5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Section 3: Privacy & Security
          _buildSectionHeader(
            context,
            icon: Icons.security_rounded,
            title: 'Privacy & Security',
            subtitle: 'Your data, privacy standards & commitments',
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            child: Material(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
              ),
              child: InkWell(
                onTap: () => _openPrivacyPolicy(context),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.privacy_tip_rounded,
                          color: Color(0xFF0D9488),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '• 100% Offline',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0D9488),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Learn how your data and offline privacy are safeguarded',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Section 4: Kalika Library Info
          _buildSectionHeader(
            context,
            icon: Icons.library_books_rounded,
            title: 'Kalika Library',
            subtitle: 'Embedded offline dictionary & learning tools',
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.auto_stories_rounded,
                  title: 'Total Kalika Words',
                  value: '1,350 Words',
                ),
                const Divider(height: 22),
                _buildInfoRow(
                  context,
                  icon: Icons.category_rounded,
                  title: 'Topics / Categories',
                  value: '27 Topics (50+ each)',
                ),
                const Divider(height: 22),
                _buildInfoRow(
                  context,
                  icon: Icons.stairs_rounded,
                  title: 'Difficulty Levels',
                  value: 'Basic, Intermediate, Advanced',
                ),
                const Divider(height: 22),
                _buildInfoRow(
                  context,
                  icon: Icons.translate_rounded,
                  title: 'Kannada Meanings',
                  value: 'ಕನ್ನಡ ಅರ್ಥಗಳು ಸೇರಿಸಲಾಗಿದೆ',
                ),
                const Divider(height: 22),
                _buildInfoRow(
                  context,
                  icon: Icons.wifi_off_rounded,
                  title: 'Storage & Access',
                  value: '100% Offline SQLite',
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // Section 5: About App (Dedicated Screen)
          _buildSectionHeader(
            context,
            icon: Icons.info_rounded,
            title: 'About',
            subtitle: 'Application details, features & architecture',
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            child: Material(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
              ),
              child: InkWell(
                onTap: () => _openAbout(context),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: isDark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'About App',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'v1.0.0',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Specifications, capabilities, mission & open source licenses',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Footer note
          Center(
            child: Column(
              children: [
                Text(
                  'Made with ❤️ for English & Kannada learners',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 • Build 100 • Production Release',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textTertiaryDark.withValues(alpha: 0.7) : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),
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
    final primary = isDark ? AppColors.primaryLight : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
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
    String? badgeText,
  }) {
    final theme = Theme.of(context);
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final borderColor = isSelected
        ? primaryColor
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Material(
        color: isSelected
            ? (primaryColor.withValues(alpha: isDark ? 0.15 : 0.08))
            : (isDark ? AppColors.surfaceDark : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor,
            width: isSelected ? 2.0 : 1.2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.2)
                        : (isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(12),
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 15,
                                color: isSelected
                                    ? primaryColor
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: (isSelected ? primaryColor : (isDark ? AppColors.primaryLight : AppColors.primary))
                                    .withValues(alpha: isDark ? 0.22 : 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (isSelected ? primaryColor : (isDark ? AppColors.primaryLight : AppColors.primary))
                                      .withValues(alpha: 0.35),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w500,
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
    final primary = isDark ? AppColors.primaryLight : AppColors.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

/// Interactive 5-star rating card connecting directly to the Google Play Store
class _RateUsCard extends StatefulWidget {
  const _RateUsCard();

  @override
  State<_RateUsCard> createState() => _RateUsCardState();
}

class _RateUsCardState extends State<_RateUsCard> {
  int _selectedRating = 0;

  // Vibrant gold color for filled rating stars
  static const Color _goldColor = Color(0xFFFFB800);

  Future<void> _handleRating(int rating) async {
    setState(() {
      _selectedRating = rating;
    });

    HapticFeedback.lightImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star_rounded, color: _goldColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Opening Google Play Store for your $rating-star rating...',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    await _openPlayStore(context);
  }

  Future<void> _openPlayStore(BuildContext context) async {
    final marketUri = Uri.parse(AppConstants.playStoreMarketUrl);
    final webUri = Uri.parse(AppConstants.playStoreWebUrl);

    try {
      // 1. Attempt to open native Google Play Store app
      final launchedMarket = await launchUrl(
        marketUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launchedMarket) {
        // 2. Fallback to web browser with Play Store URL
        final launchedWeb = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launchedWeb && context.mounted) {
          _showFallbackCopySnackBar(context);
        }
      }
    } catch (_) {
      try {
        // Fallback if market:// scheme is unsupported on this device
        final launchedWeb = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launchedWeb && context.mounted) {
          _showFallbackCopySnackBar(context);
        }
      } catch (_) {
        if (context.mounted) {
          _showFallbackCopySnackBar(context);
        }
      }
    }
  }

  void _showFallbackCopySnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Could not open Google Play Store directly.'),
        action: SnackBarAction(
          label: 'Copy Link',
          onPressed: () {
            Clipboard.setData(const ClipboardData(text: AppConstants.playStoreWebUrl));
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getRatingFeedbackText(int rating) {
    switch (rating) {
      case 5:
        return '5 Stars • Loved it! Best Kalika app!';
      case 4:
        return '4 Stars • Great learning experience!';
      case 3:
        return '3 Stars • Good, your review helps us improve!';
      case 2:
        return '2 Stars • Help us improve with your feedback!';
      case 1:
        return '1 Star • Tell us what to fix on Play Store!';
      default:
        return 'Tap a star to rate on Google Play Store';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_goldColor, Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _goldColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate Kalika',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enjoying our app? Tap any star to review on Play Store!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Interactive 5-Star Row (blank initially, filled with gold on tap)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                final isFilled = starNumber <= _selectedRating;

                return InkWell(
                  onTap: () => _handleRating(starNumber),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                    child: AnimatedScale(
                      scale: isFilled ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isFilled
                            ? _goldColor
                            : (isDark ? AppColors.blueGrey : const Color(0xFF94A3B8)),
                        size: 38,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 10),

          // Dynamic Rating Feedback Text
          Text(
            _getRatingFeedbackText(_selectedRating),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _selectedRating > 0
                  ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),

          const SizedBox(height: 14),

          // Direct Button: "Rate on Google Play Store"
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _handleRating(_selectedRating > 0 ? _selectedRating : 5),
              icon: const Icon(Icons.rate_review_rounded, size: 18),
              label: const Text(
                'Rate on Google Play Store',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
