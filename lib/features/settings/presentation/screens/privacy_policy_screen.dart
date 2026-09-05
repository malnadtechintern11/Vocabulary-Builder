import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Dedicated full screen for Privacy Policy & Security commitments
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.privacy_tip_rounded,
                size: 20,
                color: Color(0xFF0D9488),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Privacy Policy',
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
              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shield_rounded,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                SizedBox(width: 5),
                Text(
                  '100% Secure',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Card
              _buildHeroCard(context, isDark: isDark),

              const SizedBox(height: 24),

              // Section Header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Our Privacy Commitments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Policy Section 1: Offline-First Data Storage
              _buildPolicySection(
                context,
                isDark: isDark,
                icon: Icons.storage_rounded,
                color: const Color(0xFF3B82F6),
                tag: 'Offline SQLite',
                title: '1. Offline-First Data Storage',
                description:
                    'All your vocabulary progress, custom words, favorites, learned status, streak records, and quiz scores are stored locally in your device SQLite database. We do not store or sync your learning history to any external server.',
                highlights: const [
                  'Your learning data resides strictly in your device private sandbox.',
                  'Fully functional 100% offline without requiring internet access.',
                  'No mandatory account sign-up, user IDs, or cloud profiling.',
                ],
              ),
              const SizedBox(height: 14),

              // Policy Section 2: Zero Tracking & No Analytics
              _buildPolicySection(
                context,
                isDark: isDark,
                icon: Icons.visibility_off_rounded,
                color: const Color(0xFF10B981),
                tag: 'Zero Telemetry',
                title: '2. Zero Data Tracking & No Analytics',
                description:
                    'Vocabulary Builder does not track your search history, personal information, location, or usage habits. There are no third-party trackers, telemetry libraries, or targeted advertising SDKs included.',
                highlights: const [
                  'No third-party advertising SDKs or tracking cookies.',
                  'Zero collection of user search queries or study habits.',
                  'We never sell, monetize, or broker personal learning data.',
                ],
              ),
              const SizedBox(height: 14),

              // Policy Section 3: On-Device Image & Camera Privacy
              _buildPolicySection(
                context,
                isDark: isDark,
                icon: Icons.camera_enhance_rounded,
                color: const Color(0xFF8B5CF6),
                tag: 'Local OCR ML',
                title: '3. On-Device Image & Camera Privacy',
                description:
                    'When using the photo or camera text scanner (OCR), image processing takes place 100% on your device using on-device machine learning models. Your captured photos and text are never uploaded, stored, or shared.',
                highlights: const [
                  'Optical character recognition runs entirely on your local chipset.',
                  'Captured camera frames are cleared from memory immediately.',
                  'No photos or extracted text are uploaded to cloud servers.',
                ],
              ),
              const SizedBox(height: 14),

              // Policy Section 4: Secure Online Dictionary & Translation
              _buildPolicySection(
                context,
                isDark: isDark,
                icon: Icons.public_rounded,
                color: const Color(0xFFF59E0B),
                tag: 'TLS Encrypted',
                title: '4. Secure Online Dictionary & Translation',
                description:
                    'When you search for a word not in the offline database or translate text, the app securely queries public dictionary and translation APIs solely to return definitions and Kannada translations. No user credentials or identifiers are transmitted.',
                highlights: const [
                  'Only the requested translation word or phrase is queried.',
                  'All remote requests use secure HTTPS encryption.',
                  'No device IDs, IP logs, or personal tokens are attached.',
                ],
              ),
              const SizedBox(height: 14),

              // Policy Section 5: Student & Family Safe
              _buildPolicySection(
                context,
                isDark: isDark,
                icon: Icons.child_care_rounded,
                color: const Color(0xFFEC4899),
                tag: 'Family Safe',
                title: '5. Student & Family Safe',
                description:
                    'This application is suitable for students and learners of all ages. It contains educational vocabulary content without disruptive ads or in-app purchases.',
                highlights: const [
                  'Designed for learners, school students, and language enthusiasts.',
                  'No paywalls, hidden in-app purchases, or subscription traps.',
                  'Clean educational interface free from intrusive pop-ups.',
                ],
              ),
              const SizedBox(height: 14),

              // Policy Section 6: Device Permissions Explained
              _buildPolicySection(
                context,
                isDark: isDark,
                icon: Icons.security_rounded,
                color: const Color(0xFF06B6D4),
                tag: 'Minimal Permissions',
                title: '6. Device Permissions Breakdown',
                description:
                    'Vocabulary Builder requests only essential permissions strictly needed to enable specific learning features:',
                highlights: const [
                  'Camera: Optional, requested only when scanning text with OCR.',
                  'Storage/Photos: Optional, requested only when picking an image.',
                  'Speech Engine: Uses your native device Text-to-Speech engine.',
                  'Internet: Used solely for online translations and dictionary lookup.',
                ],
              ),
              const SizedBox(height: 14),

              // Policy Section 7: User Control & Data Deletion
              _buildPolicySection(
                context,
                isDark: isDark,
                icon: Icons.tune_rounded,
                color: const Color(0xFF6366F1),
                tag: 'Full Control',
                title: '7. Total User Control & Data Deletion',
                description:
                    'You maintain complete control over your educational records at all times. You can delete custom words, clear your learning progress, or remove all cached data directly from the app settings or device application manager.',
                highlights: const [
                  'Instant reset of quizzes, bookmarks, and custom vocabulary.',
                  'Uninstalling the app permanently purges all SQLite databases.',
                  'Zero residual records kept on external servers.',
                ],
              ),
              const SizedBox(height: 22),

              // Version & Last Updated Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last updated: September 2026 • Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Vocabulary Builder • English & ಕನ್ನಡ Learning Hub',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1.2,
              ),
            ),
            boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: const Text(
                'I Understand',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, {required bool isDark}) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F2B2B),
                  const Color(0xFF131B2E),
                ]
              : [
                  const Color(0xFFECFDF5),
                  const Color(0xFFF0FDF4),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0D9488).withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.4,
        ),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Policy',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        fontSize: 22,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '100% Private, Offline-First & Transparent',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your vocabulary growth and learning journey are personal. Vocabulary Builder is engineered from the ground up to respect your privacy with zero external tracking, zero cloud data harvesting, and complete on-device security.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeaturePill(
                icon: Icons.wifi_off_rounded,
                label: 'Offline-First',
                isDark: isDark,
              ),
              _buildFeaturePill(
                icon: Icons.no_accounts_rounded,
                label: 'No Accounts',
                isDark: isDark,
              ),
              _buildFeaturePill(
                icon: Icons.lock_outline_rounded,
                label: 'Private SQLite',
                isDark: isDark,
              ),
              _buildFeaturePill(
                icon: Icons.favorite_rounded,
                label: 'No Ads',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFF0D9488),
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

  Widget _buildPolicySection(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required Color color,
    required String tag,
    required String title,
    required String description,
    required List<String> highlights,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.18 : 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.48,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.4) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: highlights
                  .map(
                    (point) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
