import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/theme_controller.dart';
import 'privacy_policy_screen.dart';

/// Settings screen allowing customization of ThemeMode (Light, Dark, System), App Sharing, Privacy Policy, and app configurations
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String _shareMessage = '''
🌟 Vocabulary Builder - English & ಕನ್ನಡ Learning Hub
Boost your vocabulary with 1,350+ words, Kannada meanings, offline quizzes, 600+ sentences, and photo OCR translation!
Download and master English vocabulary effortlessly today!''';

  void _shareApp(BuildContext context) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: _shareMessage,
          subject: 'Learn English with Vocabulary Builder (English & ಕನ್ನಡ)',
        ),
      );
    } catch (_) {
      // Fallback: Copy to clipboard if system share sheet encounters an issue
      await Clipboard.setData(const ClipboardData(text: _shareMessage));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App share message copied to clipboard!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
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
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Section 1: Appearance & Theme
          _buildSectionHeader(
            context,
            icon: Icons.palette_rounded,
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

          const SizedBox(height: 26),

          // Section 2: Share & Community (Attractive Action Banner)
          _buildSectionHeader(
            context,
            icon: Icons.share_rounded,
            title: 'Share & Community',
            subtitle: 'Spread the love of English & Kannada learning',
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF311B92), const Color(0xFF1E1B4B)]
                    : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: isDark ? 0.35 : 0.25),
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
                              'Share Vocabulary Builder with friends & family to learn together!',
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

          // Section 4: Vocabulary Library Info
          _buildSectionHeader(
            context,
            icon: Icons.library_books_rounded,
            title: 'Vocabulary Library',
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
                  title: 'Total Vocabulary',
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

          // Section 5: About App
          _buildSectionHeader(
            context,
            icon: Icons.info_rounded,
            title: 'About',
            subtitle: 'Application details, features & architecture',
          ),
          const SizedBox(height: 12),

          // 1. Hero Brand Card
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            isDark ? AppColors.primaryLight : AppColors.primary,
                            AppColors.primaryDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppColors.primaryLight : AppColors.primary)
                                .withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 30,
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
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppConstants.appTagline,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Vocabulary Builder is an educational suite created to help students, competitive examination candidates, and language enthusiasts master English. It combines offline vocabulary acquisition, bilingual Kannada meanings, audio pronunciations, contextual sentences, camera OCR text recognition, and smart spaced revision quizzes in an ad-free, 100% private environment.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildAboutTag(label: 'Offline-First', icon: Icons.wifi_off_rounded, isDark: isDark),
                    _buildAboutTag(label: 'Bilingual Kannada', icon: Icons.translate_rounded, isDark: isDark),
                    _buildAboutTag(label: 'Audio Pronunciation', icon: Icons.volume_up_rounded, isDark: isDark),
                    _buildAboutTag(label: 'On-Device OCR', icon: Icons.camera_enhance_rounded, isDark: isDark),
                    _buildAboutTag(label: 'Adaptive Quizzes', icon: Icons.quiz_rounded, isDark: isDark),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Feature Highlights Card
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.featured_play_list_rounded,
                      size: 20,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Core Learning Capabilities',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _buildAboutFeatureItem(
                  context: context,
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF3B82F6),
                  title: 'Comprehensive Word Catalog',
                  description:
                      '1,350+ essential words across 27 thematic domains including Academic, Business, Science, Technology, Medical, Everyday Conversation, and Exam Prep.',
                  isDark: isDark,
                ),
                const Divider(height: 16),
                _buildAboutFeatureItem(
                  context: context,
                  icon: Icons.format_quote_rounded,
                  color: const Color(0xFF10B981),
                  title: '600+ Real-World Sentences',
                  description:
                      'Structured into Beginner, Intermediate, and Advanced tiers with contextual Kannada meanings, word highlight tags, and interactive practice mode.',
                  isDark: isDark,
                ),
                const Divider(height: 16),
                _buildAboutFeatureItem(
                  context: context,
                  icon: Icons.record_voice_over_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: 'Native Audio Pronunciations',
                  description:
                      'Built-in speech synthesis engine provides crystal-clear standard English pronunciation for all vocabulary entries and full example sentences.',
                  isDark: isDark,
                ),
                const Divider(height: 16),
                _buildAboutFeatureItem(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFFF59E0B),
                  title: 'Camera & Photo OCR Scanner',
                  description:
                      'Scan printed text directly from textbooks, newspapers, or handwritten notes using on-device machine learning with instant word lookup.',
                  isDark: isDark,
                ),
                const Divider(height: 16),
                _buildAboutFeatureItem(
                  context: context,
                  icon: Icons.g_translate_rounded,
                  color: const Color(0xFF06B6D4),
                  title: '10-Language Multi-Translator',
                  description:
                      'On-demand multilingual translation supporting Kannada, Hindi, Telugu, Tamil, Malayalam, Spanish, French, German, Japanese, and English.',
                  isDark: isDark,
                ),
                const Divider(height: 16),
                _buildAboutFeatureItem(
                  context: context,
                  icon: Icons.psychology_rounded,
                  color: const Color(0xFFEC4899),
                  title: 'Smart Spaced-Revision Quizzes',
                  description:
                      'Adaptive quiz engine with multiple-choice, Kannada-to-English prompts, cloze sentence completions, and targeted weak-word reinforcement.',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Technical Specifications Card
          Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.memory_rounded,
                      size: 20,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Technical Specifications',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _buildAboutSpecRow(
                  context: context,
                  label: 'Framework',
                  value: 'Flutter & Dart',
                  isDark: isDark,
                ),
                _buildAboutSpecRow(
                  context: context,
                  label: 'Architecture',
                  value: 'Clean Architecture',
                  isDark: isDark,
                ),
                _buildAboutSpecRow(
                  context: context,
                  label: 'State Management',
                  value: 'Flutter Riverpod',
                  isDark: isDark,
                ),
                _buildAboutSpecRow(
                  context: context,
                  label: 'Database Engine',
                  value: 'SQLite (Schema v6)',
                  isDark: isDark,
                ),
                _buildAboutSpecRow(
                  context: context,
                  label: 'Machine Learning',
                  value: 'Google ML Kit OCR',
                  isDark: isDark,
                ),
                _buildAboutSpecRow(
                  context: context,
                  label: 'Text-to-Speech',
                  value: 'System Speech Engine',
                  isDark: isDark,
                ),
                _buildAboutSpecRow(
                  context: context,
                  label: 'Version & Build',
                  value: 'v1.0.0 (Build 100)',
                  isDark: isDark,
                ),
                _buildAboutSpecRow(
                  context: context,
                  label: 'Target Audience',
                  value: 'Students & Aspirants',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Mission & Educational Commitment Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF1E1B4B),
                        const Color(0xFF131B2E),
                      ]
                    : [
                        const Color(0xFFEEF2FF),
                        const Color(0xFFF8FAFC),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF4338CA) : const Color(0xFFC7D2FE),
                width: 1.2,
              ),
              boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3730A3) : const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Educational Mission',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1E1B4B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Created to empower students, competitive exam aspirants (IELTS, TOEFL, GRE, UPSC, KPSC), and self-learners. Our mission is to make quality vocabulary acquisition completely free, distraction-free, and accessible anytime without internet or paywalls.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.48,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 14),
                // Licenses Button
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showLicensePage(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: 'v1.0.0',
                        applicationLegalese: '© 2026 Vocabulary Builder\nOffline-First English Learning Hub',
                      );
                    },
                    icon: const Icon(Icons.policy_rounded, size: 18),
                    label: const Text(
                      'Open Source Licenses',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                      side: BorderSide(
                        color: isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 15,
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

  Widget _buildAboutTag({
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.7) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? AppColors.primaryLight : AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutFeatureItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSpecRow({
    required BuildContext context,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
