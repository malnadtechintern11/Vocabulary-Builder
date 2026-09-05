import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/sentence.dart';
import 'translation_service.dart';

/// Exception thrown when online sentence lookup fails due to no internet connection
class SentenceNoInternetException implements Exception {
  final String message;
  const SentenceNoInternetException([
    this.message = 'This sentence is not available offline. Please connect to the internet to search for it.',
  ]);

  @override
  String toString() => message;
}

/// Exception thrown when a sentence could not be parsed or found online
class SentenceNotFoundOnlineException implements Exception {
  final String sentence;
  final String message;
  const SentenceNotFoundOnlineException(
    this.sentence, [
    this.message = 'Sentence information could not be retrieved online.',
  ]);

  @override
  String toString() => '$message (Query: "$sentence")';
}

/// Service to fetch rich English sentence details online:
/// - Accurate Kannada translations via TranslationService
/// - Meaning and contextual explanation
/// - Useful vocabulary word breakdowns with definitions
/// - Inferred difficulty level and category
class OnlineSentenceService {
  static OnlineSentenceService? _instance;
  final http.Client _client;
  final TranslationService _translationService;

  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
  };

  OnlineSentenceService._({
    http.Client? client,
    TranslationService? translationService,
  })  : _client = client ?? http.Client(),
        _translationService = translationService ?? TranslationService();

  factory OnlineSentenceService({
    http.Client? client,
    TranslationService? translationService,
  }) {
    if (client != null || translationService != null) {
      return OnlineSentenceService._(
        client: client,
        translationService: translationService,
      );
    }
    return _instance ??= OnlineSentenceService._();
  }

  /// Stopwords to filter out when extracting key vocabulary from an English sentence
  static const Set<String> _stopwords = {
    'a', 'about', 'above', 'after', 'again', 'against', 'all', 'am', 'an', 'and',
    'any', 'are', 'aren\'t', 'as', 'at', 'be', 'because', 'been', 'before', 'being',
    'below', 'between', 'both', 'but', 'by', 'can', 'can\'t', 'cannot', 'could',
    'couldn\'t', 'did', 'didn\'t', 'do', 'does', 'doesn\'t', 'doing', 'don\'t',
    'down', 'during', 'each', 'few', 'for', 'from', 'further', 'had', 'hadn\'t',
    'has', 'hasn\'t', 'have', 'haven\'t', 'having', 'he', 'he\'d', 'he\'ll', 'he\'s',
    'her', 'here', 'here\'s', 'hers', 'herself', 'him', 'himself', 'his', 'how',
    'how\'s', 'i', 'i\'d', 'i\'ll', 'i\'m', 'i\'ve', 'if', 'in', 'into', 'is',
    'isn\'t', 'it', 'it\'s', 'its', 'itself', 'just', 'let\'s', 'me', 'more',
    'most', 'mustn\'t', 'my', 'myself', 'no', 'nor', 'not', 'of', 'off', 'on',
    'once', 'only', 'or', 'other', 'ought', 'our', 'ours', 'ourselves', 'out',
    'over', 'own', 'same', 'shan\'t', 'she', 'she\'d', 'she\'ll', 'she\'s', 'should',
    'shouldn\'t', 'so', 'some', 'such', 'than', 'that', 'that\'s', 'the', 'their',
    'theirs', 'them', 'themselves', 'then', 'there', 'there\'s', 'these', 'they',
    'they\'d', 'they\'ll', 'they\'re', 'they\'ve', 'this', 'those', 'through', 'to',
    'too', 'under', 'until', 'up', 'very', 'was', 'wasn\'t', 'we', 'we\'d', 'we\'ll',
    'we\'re', 'we\'ve', 'were', 'weren\'t', 'what', 'what\'s', 'when', 'when\'s',
    'where', 'where\'s', 'which', 'while', 'who', 'who\'s', 'whom', 'why', 'why\'s',
    'with', 'won\'t', 'would', 'wouldn\'t', 'you', 'you\'d', 'you\'ll', 'you\'re',
    'you\'ve', 'your', 'yours', 'yourself', 'yourselves'
  };

  /// Fetch sentence information from online translation and dictionary APIs
  Future<Sentence> fetchSentenceDetails(String rawQuery) async {
    final cleanQuery = rawQuery.trim();
    if (cleanQuery.isEmpty) {
      throw const SentenceNotFoundOnlineException('', 'Please enter a sentence to search.');
    }

    // Capitalize first character and format
    final formattedSentence = cleanQuery.length > 1
        ? '${cleanQuery[0].toUpperCase()}${cleanQuery.substring(1)}'
        : cleanQuery.toUpperCase();

    // 1. Fetch Kannada Translation
    String kannadaMeaning = '';
    try {
      final translationRes = await _translationService.translate(
        text: formattedSentence,
        targetLanguageCode: 'kn',
        sourceLanguageCode: 'en',
      );
      kannadaMeaning = translationRes.translatedText.trim();
    } on TranslationNoInternetException {
      throw const SentenceNoInternetException();
    } on SocketException {
      throw const SentenceNoInternetException();
    } on http.ClientException {
      throw const SentenceNoInternetException();
    } on TimeoutException {
      throw const SentenceNoInternetException();
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socket') ||
          errStr.contains('network') ||
          errStr.contains('offline') ||
          errStr.contains('connection') ||
          errStr.contains('host')) {
        throw const SentenceNoInternetException();
      }
      debugPrint('Translation error for sentence "$formattedSentence": $e');
    }

    // 2. Extract Key Vocabulary Words from Sentence
    final keyWords = _extractKeyWords(formattedSentence);
    final List<SentenceWord> vocabularyWords = [];

    // Fetch definitions for key words (limit to 3 words to ensure quick response)
    for (final word in keyWords.take(3)) {
      final wordMeaning = await _fetchWordMeaning(word);
      if (wordMeaning.isNotEmpty) {
        vocabularyWords.add(SentenceWord(
          word: word[0].toUpperCase() + word.substring(1),
          meaning: wordMeaning,
        ));
      }
    }

    // 3. Formulate English Meaning
    final englishMeaning = _generateEnglishMeaning(formattedSentence, vocabularyWords);

    // 4. Infer Category and Difficulty
    final category = _inferCategory(formattedSentence);
    final difficulty = _inferDifficulty(formattedSentence, vocabularyWords);

    final uniqueId = 'online_${formattedSentence.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}';

    return Sentence(
      id: uniqueId,
      text: formattedSentence,
      meaning: englishMeaning,
      kannadaMeaning: kannadaMeaning,
      vocabularyWords: vocabularyWords,
      difficulty: difficulty,
      category: category,
      isFavorite: false,
      isPracticed: false,
      isOnline: true,
    );
  }

  /// Extracts meaningful content words from an English sentence
  List<String> _extractKeyWords(String sentence) {
    final cleanWords = sentence
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3 && !_stopwords.contains(w))
        .toList();

    // Sort by length descending to prioritize rich/informative words
    cleanWords.sort((a, b) => b.length.compareTo(a.length));

    // Remove duplicates while preserving order
    final seen = <String>{};
    final unique = <String>[];
    for (final w in cleanWords) {
      if (seen.add(w)) {
        unique.add(w);
      }
    }
    return unique;
  }

  /// Looks up a short, concise definition for a vocabulary word
  Future<String> _fetchWordMeaning(String word) async {
    try {
      // Primary: Datamuse API (fast, lightweight, concise definition)
      final datamuseUri = Uri.parse(
        'https://api.datamuse.com/words?sp=${Uri.encodeComponent(word)}&md=d&max=1',
      );
      final response = await _client.get(datamuseUri, headers: _headers).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded[0] as Map<String, dynamic>;
          final defs = first['defs'] as List<dynamic>?;
          if (defs != null && defs.isNotEmpty) {
            final rawDef = defs[0].toString();
            final tabIdx = rawDef.indexOf('\t');
            if (tabIdx != -1 && tabIdx < rawDef.length - 1) {
              final cleaned = rawDef.substring(tabIdx + 1).trim();
              if (cleaned.isNotEmpty) {
                return cleaned[0].toUpperCase() + cleaned.substring(1);
              }
            }
          }
        }
      }
    } catch (_) {
      // Fallback: Free Dictionary API
      try {
        final dictUri = Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(word)}',
        );
        final dictRes = await _client.get(dictUri, headers: _headers).timeout(const Duration(seconds: 4));
        if (dictRes.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(dictRes.bodyBytes));
          if (decoded is List && decoded.isNotEmpty) {
            final meanings = decoded[0]['meanings'] as List<dynamic>?;
            if (meanings != null && meanings.isNotEmpty) {
              final definitions = meanings[0]['definitions'] as List<dynamic>?;
              if (definitions != null && definitions.isNotEmpty) {
                final def = definitions[0]['definition']?.toString();
                if (def != null && def.trim().isNotEmpty) {
                  return def.trim();
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    // Default contextual description if API definition is unavailable
    return 'Key concept or action featured in this sentence';
  }

  /// Formulates a helpful English meaning / paraphrase
  String _generateEnglishMeaning(String sentence, List<SentenceWord> vocab) {
    // If sentence ends with a question mark
    if (sentence.trim().endsWith('?')) {
      return 'Inquires about: ${sentence.replaceAll('?', '').trim().toLowerCase()}.';
    }

    // If key vocabulary is identified, synthesize a clear explanatory meaning
    if (vocab.length >= 2) {
      return 'Expresses an idea involving ${vocab[0].word.toLowerCase()} (${vocab[0].meaning.toLowerCase()}) and ${vocab[1].word.toLowerCase()}.';
    } else if (vocab.isNotEmpty) {
      return 'Highlights the concept of ${vocab[0].word.toLowerCase()}: ${vocab[0].meaning.toLowerCase()}.';
    }

    return 'Expresses that ${sentence.trim().toLowerCase()}.';
  }

  /// Determines semantic category based on sentence words
  String _inferCategory(String sentence) {
    final lower = sentence.toLowerCase();

    if (lower.contains(RegExp(r'\b(computer|software|data|digital|internet|app|code|algorithm|cloud|tech|device|screen)\b'))) {
      return 'Technology';
    }
    if (lower.contains(RegExp(r'\b(work|job|office|career|meeting|business|client|project|manager|salary|interview|colleague)\b'))) {
      return 'Work';
    }
    if (lower.contains(RegExp(r'\b(school|college|university|student|teacher|study|exam|class|lesson|degree|homework|learn)\b'))) {
      return 'School';
    }
    if (lower.contains(RegExp(r'\b(travel|trip|flight|airport|ticket|hotel|journey|tour|vacation|destination|visit|train)\b'))) {
      return 'Travel';
    }
    if (lower.contains(RegExp(r'\b(food|eat|restaurant|cook|dinner|breakfast|lunch|coffee|tea|recipe|meal|dish|taste)\b'))) {
      return 'Food';
    }
    if (lower.contains(RegExp(r'\b(family|mother|father|parents|brother|sister|son|daughter|children|home|kid)\b'))) {
      return 'Family';
    }
    if (lower.contains(RegExp(r'\b(health|doctor|hospital|medicine|exercise|fitness|diet|illness|pain|sleep|healthy)\b'))) {
      return 'Health';
    }
    if (lower.contains(RegExp(r'\b(weather|rain|sun|sunny|storm|cloud|cold|hot|summer|winter|wind|temperature)\b'))) {
      return 'Weather';
    }
    if (lower.contains(RegExp(r'\b(shop|buy|store|market|price|discount|cost|money|purchase|cash|sale)\b'))) {
      return 'Shopping';
    }
    if (lower.contains(RegExp(r'\b(music|game|sport|play|hobby|art|paint|read|dance|guitar|book)\b'))) {
      return 'Hobbies';
    }

    return 'Everyday English';
  }

  /// Infers sentence difficulty based on length and vocabulary complexity
  String _inferDifficulty(String sentence, List<SentenceWord> vocab) {
    final words = sentence.split(RegExp(r'\s+'));
    final wordCount = words.length;

    // Advanced: long sentence or rich polysyllabic words
    final hasLongWords = words.any((w) => w.length >= 10);
    if (wordCount >= 14 || hasLongWords) {
      return 'Advanced';
    }

    // Intermediate: moderate length
    if (wordCount >= 8) {
      return 'Intermediate';
    }

    // Beginner: short and straightforward
    return 'Beginner';
  }
}
