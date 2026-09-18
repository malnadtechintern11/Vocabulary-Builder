import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized service for Google Firebase Analytics in Kalika
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;
  bool _isInitialized = false;

  /// Returns the GoRouter / Navigator observer for automatic screen view tracking
  FirebaseAnalyticsObserver? get observer => _observer;

  /// Initializes Firebase Analytics and configures data collection
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      debugPrint('ℹ️ Firebase Analytics is not supported on Windows/Linux desktop.');
      return;
    }

    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      await _analytics!.setAnalyticsCollectionEnabled(true);
      _isInitialized = true;
      debugPrint('✅ AnalyticsService successfully initialized.');
    } catch (e) {
      debugPrint('⚠️ AnalyticsService initialization skipped or failed: $e');
    }
  }

  /// Logs a custom event to Firebase Analytics
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      if (_analytics == null) return;
      await _analytics!.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('📊 [Analytics Event]: $name $parameters');
    } catch (e) {
      debugPrint('Error logging analytics event $name: $e');
    }
  }

  /// Logs a screen view transition
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      if (_analytics == null) return;
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('📊 [Analytics Screen]: $screenName');
    } catch (e) {
      debugPrint('Error logging screen view $screenName: $e');
    }
  }

  /// Logs when a user marks a word as mastered/learned
  Future<void> logWordLearned({
    required String word,
    required String difficulty,
    required String category,
  }) async {
    await logEvent(
      name: 'word_mastered',
      parameters: {
        'word': word,
        'difficulty': difficulty,
        'category': category,
      },
    );
  }

  /// Logs completion of a quiz session
  Future<void> logQuizCompleted({
    required int score,
    required int totalQuestions,
    required String quizType,
  }) async {
    await logEvent(
      name: 'quiz_completed',
      parameters: {
        'score': score,
        'total_questions': totalQuestions,
        'quiz_type': quizType,
        'accuracy_percentage': totalQuestions > 0 ? (score / totalQuestions * 100).round() : 0,
      },
    );
  }

  /// Logs search query executed by the user
  Future<void> logSearch({required String searchTerm}) async {
    if (searchTerm.trim().isEmpty) return;
    try {
      if (_analytics == null) return;
      await _analytics!.logSearch(searchTerm: searchTerm.trim());
    } catch (e) {
      debugPrint('Error logging search term: $e');
    }
  }

  /// Logs when a custom word is added by the user
  Future<void> logCustomWordAdded({
    required String word,
    required String category,
  }) async {
    await logEvent(
      name: 'custom_word_added',
      parameters: {
        'word': word,
        'category': category,
      },
    );
  }
}
