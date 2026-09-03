import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Language definition model for translation
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  String get displayName => '$name ($nativeName)';
}

/// Result of a translation operation
class TranslationResult {
  final String sourceText;
  final String translatedText;
  final String targetLanguageCode;
  final String sourceLanguageCode;

  const TranslationResult({
    required this.sourceText,
    required this.translatedText,
    required this.targetLanguageCode,
    this.sourceLanguageCode = 'auto',
  });
}

/// Custom exception thrown when translation fails due to lack of internet
class TranslationNoInternetException implements Exception {
  final String message;
  const TranslationNoInternetException([this.message = 'Internet connection is required for translation']);

  @override
  String toString() => message;
}

/// Online translation service for multi-language learning
class TranslationService {
  static TranslationService? _instance;
  final http.Client _client;

  TranslationService._({http.Client? client}) : _client = client ?? http.Client();

  factory TranslationService({http.Client? client}) {
    if (client != null) {
      return TranslationService._(client: client);
    }
    return _instance ??= TranslationService._();
  }

  /// The 10 supported learning languages
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    AppLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', flag: '🇮🇳'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇮🇳'),
    AppLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳'),
    AppLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳'),
  ];

  /// Find language by code
  static AppLanguage getLanguage(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => supportedLanguages.first,
    );
  }

  /// Convenience helper to get language name
  static String getLanguageName(String code) => getLanguage(code).name;

  /// Convenience helper to get language flag emoji
  static String getLanguageFlag(String code) => getLanguage(code).flag;

  /// Translate text online into the target language
  Future<TranslationResult> translate({
    required String text,
    required String targetLanguageCode,
    String sourceLanguageCode = 'auto',
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return TranslationResult(
        sourceText: '',
        translatedText: '',
        targetLanguageCode: targetLanguageCode,
        sourceLanguageCode: sourceLanguageCode,
      );
    }

    try {
      // Primary: Google Translate public API
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLanguageCode&tl=$targetLanguageCode&dt=t&q=${Uri.encodeComponent(trimmedText)}',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final segments = decoded[0] as List<dynamic>;
          final buffer = StringBuffer();
          for (final seg in segments) {
            if (seg is List && seg.isNotEmpty && seg[0] != null) {
              buffer.write(seg[0].toString());
            }
          }
          final translated = buffer.toString().trim();
          if (translated.isNotEmpty) {
            return TranslationResult(
              sourceText: trimmedText,
              translatedText: translated,
              targetLanguageCode: targetLanguageCode,
              sourceLanguageCode: sourceLanguageCode,
            );
          }
        }
      }

      // Fallback: MyMemory API
      final fallbackUri = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(trimmedText)}&langpair=$sourceLanguageCode|$targetLanguageCode',
      );
      final fallbackResponse = await _client.get(fallbackUri).timeout(const Duration(seconds: 10));
      if (fallbackResponse.statusCode == 200) {
        final fallbackData = jsonDecode(utf8.decode(fallbackResponse.bodyBytes));
        final resData = fallbackData['responseData'];
        if (resData != null && resData['translatedText'] != null) {
          final translated = resData['translatedText'].toString().trim();
          if (translated.isNotEmpty) {
            return TranslationResult(
              sourceText: trimmedText,
              translatedText: translated,
              targetLanguageCode: targetLanguageCode,
              sourceLanguageCode: sourceLanguageCode,
            );
          }
        }
      }

      throw Exception('Could not parse translation result');
    } on SocketException {
      throw const TranslationNoInternetException('Internet connection is required for translation');
    } on http.ClientException {
      throw const TranslationNoInternetException('Internet connection is required for translation');
    } on TimeoutException {
      throw const TranslationNoInternetException('Internet connection is required for translation');
    } on HandshakeException {
      throw const TranslationNoInternetException('Internet connection is required for translation');
    } catch (e) {
      if (e is TranslationNoInternetException) rethrow;
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') ||
          errorStr.contains('network') ||
          errorStr.contains('connection') ||
          errorStr.contains('host')) {
        throw const TranslationNoInternetException('Internet connection is required for translation');
      }
      throw Exception('Translation error: ${e.toString()}');
    }
  }
}
