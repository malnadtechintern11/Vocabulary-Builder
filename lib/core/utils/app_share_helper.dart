import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';

/// Centralized utility for sharing the Kalika application
class AppShareHelper {
  AppShareHelper._();

  /// Google Play Store link and promotional message
  static const String shareLink = AppConstants.playStoreWebUrl;
  static const String shareMessage = '''
🌟 Kalika - English & ಕನ್ನಡ Learning Hub
Boost your vocabulary with 1,350+ curated words, Kannada meanings, offline quizzes, 600+ sentences & camera OCR translation!

📲 Download on Google Play Store:
${AppConstants.playStoreWebUrl}''';

  /// Shares app promotion message and direct Play Store link across apps
  static Future<void> shareApp(BuildContext context) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareMessage,
          subject: 'Learn English with Kalika (English & ಕನ್ನಡ)',
          title: 'Kalika',
        ),
      );
    } catch (_) {
      // Fallback: Copy message and Play Store link directly to clipboard
      await Clipboard.setData(
        const ClipboardData(text: shareMessage),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('App details and Play Store link copied to clipboard!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
