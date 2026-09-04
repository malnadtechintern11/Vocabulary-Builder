import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/words/domain/entities/word.dart';
import 'translation_service.dart';

/// Custom exception thrown when online dictionary lookup fails due to no internet connection
class WordNoInternetException implements Exception {
  final String message;
  const WordNoInternetException([
    this.message = 'This word is not available offline. Please connect to the internet to search for it.',
  ]);

  @override
  String toString() => message;
}

/// Custom exception thrown when a word is not found in online dictionaries
class WordNotFoundOnlineException implements Exception {
  final String word;
  final String message;
  const WordNotFoundOnlineException(
    this.word, [
    this.message = 'Word not found in online dictionary.',
  ]);

  @override
  String toString() => message;
}

/// Service to fetch rich word information from online dictionary and translation APIs
class OnlineDictionaryService {
  static OnlineDictionaryService? _instance;
  final http.Client _client;
  final TranslationService _translationService;

  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
  };

  OnlineDictionaryService._({
    http.Client? client,
    TranslationService? translationService,
  })  : _client = client ?? http.Client(),
        _translationService = translationService ?? TranslationService();

  factory OnlineDictionaryService({
    http.Client? client,
    TranslationService? translationService,
  }) {
    if (client != null || translationService != null) {
      return OnlineDictionaryService._(
        client: client,
        translationService: translationService,
      );
    }
    return _instance ??= OnlineDictionaryService._();
  }

  /// Search for a word online using Free Dictionary API + Datamuse + Translation API
  Future<Word> fetchWordDetails(String wordQuery) async {
    final cleanWord = wordQuery.trim();
    if (cleanWord.isEmpty) {
      throw const WordNotFoundOnlineException('', 'Please enter a word to search.');
    }

    try {
      // 1. Primary: Query Free Dictionary API
      try {
        final uri = Uri.parse(
          'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(cleanWord.toLowerCase())}',
        );

        final response = await _client.get(uri, headers: _headers).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is List && decoded.isNotEmpty) {
            final entry = decoded[0] as Map<String, dynamic>;
            return await _parseDictionaryEntry(cleanWord, entry);
          }
        }
      } on SocketException {
        throw const WordNoInternetException();
      } on http.ClientException {
        throw const WordNoInternetException();
      } catch (e) {
        if (e is WordNoInternetException) rethrow;
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('socket') || errStr.contains('network') || errStr.contains('host')) {
          throw const WordNoInternetException();
        }
        debugPrint('FreeDictionary API lookup failed for "$cleanWord", attempting secondary providers: $e');
      }

      // 2. Secondary: Datamuse API (Definitions, Tags, IPA Pronunciation)
      try {
        final datamuseUri = Uri.parse(
          'https://api.datamuse.com/words?sp=${Uri.encodeComponent(cleanWord.toLowerCase())}&md=dpfs&max=1',
        );
        final datamuseRes = await _client.get(datamuseUri, headers: _headers).timeout(const Duration(seconds: 8));
        if (datamuseRes.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(datamuseRes.bodyBytes));
          if (decoded is List && decoded.isNotEmpty) {
            final item = decoded[0] as Map<String, dynamic>;
            if (item['word'] != null) {
              return await _parseDatamuseEntry(cleanWord, item);
            }
          }
        }
      } on SocketException {
        throw const WordNoInternetException();
      } on http.ClientException {
        throw const WordNoInternetException();
      } catch (e) {
        if (e is WordNoInternetException) rethrow;
        debugPrint('Datamuse API fallback failed for "$cleanWord": $e');
      }

      // 3. Tertiary: Translation & Definition fallback
      return await _fallbackOnlineLookup(cleanWord);
    } on SocketException {
      throw const WordNoInternetException();
    } on http.ClientException {
      throw const WordNoInternetException();
    } on TimeoutException {
      throw const WordNoInternetException();
    } on HandshakeException {
      throw const WordNoInternetException();
    } catch (e) {
      if (e is WordNoInternetException || e is WordNotFoundOnlineException) {
        rethrow;
      }
      final errLower = e.toString().toLowerCase();
      if (errLower.contains('socket') ||
          errLower.contains('network') ||
          errLower.contains('connection') ||
          errLower.contains('host') ||
          errLower.contains('timeout')) {
        throw const WordNoInternetException();
      }
      debugPrint('OnlineDictionaryService error for "$cleanWord": $e');
      // If there's an unexpected parsing error, try fallback lookup
      try {
        return await _fallbackOnlineLookup(cleanWord);
      } catch (_) {
        throw WordNotFoundOnlineException(
          cleanWord,
          'Could not find definitions for "$cleanWord" online. Check spelling.',
        );
      }
    }
  }

  /// Parse structured dictionary entry from Free Dictionary API
  Future<Word> _parseDictionaryEntry(String originalWord, Map<String, dynamic> entry) async {
    final word = entry['word']?.toString() ?? originalWord;

    // Extract phonetic representation
    String phonetic = entry['phonetic']?.toString() ?? '';
    if (phonetic.isEmpty && entry['phonetics'] is List) {
      final phoneticsList = entry['phonetics'] as List<dynamic>;
      for (final p in phoneticsList) {
        if (p is Map<String, dynamic> && p['text'] != null && p['text'].toString().isNotEmpty) {
          phonetic = p['text'].toString();
          break;
        }
      }
    }

    String partOfSpeech = 'noun';
    String meaning = '';
    String example = '';
    final synonyms = <String>{};
    final antonyms = <String>{};

    if (entry['meanings'] is List) {
      final meaningsList = entry['meanings'] as List<dynamic>;
      for (final m in meaningsList) {
        if (m is Map<String, dynamic>) {
          final pos = m['partOfSpeech']?.toString() ?? '';
          if (partOfSpeech == 'noun' && pos.isNotEmpty) {
            partOfSpeech = pos.toLowerCase();
          }

          // Gather top-level synonyms and antonyms
          if (m['synonyms'] is List) {
            for (final s in m['synonyms']) {
              if (s != null && s.toString().trim().isNotEmpty) {
                synonyms.add(s.toString().trim());
              }
            }
          }
          if (m['antonyms'] is List) {
            for (final a in m['antonyms']) {
              if (a != null && a.toString().trim().isNotEmpty) {
                antonyms.add(a.toString().trim());
              }
            }
          }

          // Definitions
          if (m['definitions'] is List) {
            final defs = m['definitions'] as List<dynamic>;
            for (final d in defs) {
              if (d is Map<String, dynamic>) {
                if (meaning.isEmpty && d['definition'] != null) {
                  meaning = d['definition'].toString().trim();
                }
                if (example.isEmpty && d['example'] != null) {
                  example = d['example'].toString().trim();
                }
                if (d['synonyms'] is List) {
                  for (final s in d['synonyms']) {
                    if (s != null && s.toString().trim().isNotEmpty) {
                      synonyms.add(s.toString().trim());
                    }
                  }
                }
                if (d['antonyms'] is List) {
                  for (final a in d['antonyms']) {
                    if (a != null && a.toString().trim().isNotEmpty) {
                      antonyms.add(a.toString().trim());
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    if (meaning.isEmpty) {
      meaning = 'Expressing the concept or quality of $word.';
    }

    if (example.isEmpty) {
      example = 'The word "$word" is widely used in modern English.';
    }

    // Fetch Kannada translation
    String kannadaMeaning = '';
    try {
      final trResult = await _translationService.translate(
        text: word,
        targetLanguageCode: 'kn',
        sourceLanguageCode: 'en',
      );
      kannadaMeaning = trResult.translatedText;
    } catch (e) {
      debugPrint('Kannada translation failed for online word "$word": $e');
    }

    final formattedWord = word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : originalWord;

    return Word(
      id: 0,
      word: formattedWord,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech.isEmpty ? 'noun' : partOfSpeech,
      meaning: meaning,
      kannadaMeaning: kannadaMeaning,
      example: example,
      synonyms: synonyms.take(6).toList(),
      antonyms: antonyms.take(6).toList(),
      difficulty: 'intermediate',
      category: 'general',
      isFavorite: false,
      isLearned: false,
      isOnline: true,
    );
  }

  /// Parse dictionary entry from Datamuse API
  Future<Word> _parseDatamuseEntry(String originalWord, Map<String, dynamic> item) async {
    final word = item['word']?.toString() ?? originalWord;
    String phonetic = '';
    String partOfSpeech = 'noun';
    String meaning = '';

    if (item['tags'] is List) {
      final tags = (item['tags'] as List<dynamic>).map((t) => t.toString()).toList();
      for (final t in tags) {
        if (t.startsWith('ipa_pron:')) {
          phonetic = '/${t.replaceFirst('ipa_pron:', '')}/';
        } else if (t == 'n') {
          partOfSpeech = 'noun';
        } else if (t == 'v') {
          partOfSpeech = 'verb';
        } else if (t == 'adj') {
          partOfSpeech = 'adjective';
        } else if (t == 'adv') {
          partOfSpeech = 'adverb';
        }
      }
    }

    if (item['defs'] is List) {
      final defs = item['defs'] as List<dynamic>;
      if (defs.isNotEmpty) {
        final rawDef = defs.first.toString();
        final tabIndex = rawDef.indexOf('\t');
        if (tabIndex != -1 && tabIndex + 1 < rawDef.length) {
          meaning = rawDef.substring(tabIndex + 1).trim();
        } else {
          meaning = rawDef.trim();
        }
      }
    }

    if (meaning.isEmpty) {
      meaning = 'Definition for the English vocabulary term "$word".';
    }

    // Translate to Kannada
    String kannadaMeaning = '';
    try {
      final trResult = await _translationService.translate(
        text: word,
        targetLanguageCode: 'kn',
        sourceLanguageCode: 'en',
      );
      kannadaMeaning = trResult.translatedText;
    } catch (e) {
      debugPrint('Kannada translation for Datamuse "$word" failed: $e');
    }

    final formattedWord = word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1)
        : originalWord;

    return Word(
      id: 0,
      word: formattedWord,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      meaning: meaning,
      kannadaMeaning: kannadaMeaning,
      example: 'The term "$formattedWord" is frequently used in conversational English.',
      synonyms: const [],
      antonyms: const [],
      difficulty: 'intermediate',
      category: 'general',
      isFavorite: false,
      isLearned: false,
      isOnline: true,
    );
  }

  /// Fallback lookup when dictionary APIs do not contain the word:
  /// Uses Translation API to translate to Kannada and English definitions.
  Future<Word> _fallbackOnlineLookup(String word) async {
    try {
      final knTranslation = await _translationService.translate(
        text: word,
        targetLanguageCode: 'kn',
        sourceLanguageCode: 'en',
      );

      final enTranslation = await _translationService.translate(
        text: word,
        targetLanguageCode: 'en',
        sourceLanguageCode: 'auto',
      );

      final cleanKannada = knTranslation.translatedText.trim();
      final cleanEnglish = enTranslation.translatedText.trim();

      if (cleanKannada.isEmpty && cleanEnglish.isEmpty) {
        throw WordNotFoundOnlineException(
          word,
          'Word "$word" could not be translated or found online.',
        );
      }

      final formattedWord = word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1)
          : word;

      return Word(
        id: 0,
        word: formattedWord,
        phonetic: '',
        partOfSpeech: 'noun',
        meaning: cleanEnglish.isNotEmpty && cleanEnglish.toLowerCase() != word.toLowerCase()
            ? 'Refers to "$cleanEnglish"'
            : 'English vocabulary term "$formattedWord"',
        kannadaMeaning: cleanKannada,
        example: 'We learned the term "$formattedWord" in our vocabulary study.',
        synonyms: const [],
        antonyms: const [],
        difficulty: 'intermediate',
        category: 'general',
        isFavorite: false,
        isLearned: false,
        isOnline: true,
      );
    } catch (e) {
      if (e is WordNoInternetException) rethrow;
      throw WordNotFoundOnlineException(
        word,
        'Word "$word" could not be found online. Please check spelling.',
      );
    }
  }
}
