import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
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

  static File? _cachedLogoFile;

  /// Prepares the app logo image as an [XFile] from asset bundle
  static Future<XFile> _getLogoXFile() async {
    if (_cachedLogoFile != null && await _cachedLogoFile!.exists()) {
      return XFile(
        _cachedLogoFile!.path,
        mimeType: 'image/png',
        name: 'kalika_logo.png',
      );
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/kalika_logo.png');

    final byteData = await rootBundle.load(AppConstants.appLogoAssetPath);
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    await file.writeAsBytes(bytes, flush: true);
    _cachedLogoFile = file;

    return XFile(
      file.path,
      mimeType: 'image/png',
      name: 'kalika_logo.png',
    );
  }

  /// Shares app promotion message, app logo image, and direct Play Store link across apps
  static Future<void> shareApp(BuildContext context) async {
    Rect? sharePositionOrigin;
    try {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        sharePositionOrigin = box.localToGlobal(Offset.zero) & box.size;
      }
    } catch (_) {}

    try {
      final logoXFile = await _getLogoXFile();

      await SharePlus.instance.share(
        ShareParams(
          files: [logoXFile],
          text: shareMessage,
          subject: 'Learn English with Kalika (English & ಕನ್ನಡ)',
          title: 'Kalika',
          sharePositionOrigin: sharePositionOrigin,
        ),
      );
    } catch (_) {
      // Fallback 1: Share text without file if file sharing fails on any platform
      try {
        await SharePlus.instance.share(
          ShareParams(
            text: shareMessage,
            subject: 'Learn English with Kalika (English & ಕನ್ನಡ)',
            title: 'Kalika',
            sharePositionOrigin: sharePositionOrigin,
          ),
        );
      } catch (_) {
        // Fallback 2: Copy message and Play Store link directly to clipboard
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
}
