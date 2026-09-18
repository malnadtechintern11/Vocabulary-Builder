import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_share_button.dart';

/// Dedicated full screen displaying application information, architecture,
/// core capabilities, technical specifications, mission, and open source licenses.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1.5,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              tooltip: 'Back to Settings',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.info_rounded,
                size: 20,
                color: primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'About Kalika',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.3,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primary.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: primary,
                ),
                const SizedBox(width: 5),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          const AppShareButton(),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
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
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          AppConstants.appLogoAssetPath,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                        ),
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
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Kalika is an educational suite created to help students, competitive examination candidates, and language enthusiasts master English. It combines offline vocabulary acquisition, bilingual Kannada meanings, audio pronunciations, contextual sentences, camera OCR text recognition, and smart spaced revision quizzes in an ad-free, 100% private environment.',
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
                      color: primary,
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
                      color: primary,
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
                        applicationIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              AppConstants.appLogoAssetPath,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        applicationLegalese: '© 2026 Kalika\nOffline-First English Learning Hub',
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
                      foregroundColor: primary,
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
