import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/services/analytics_service.dart';
import 'package:vocabulary_builder/core/services/notification_service.dart';
import 'package:vocabulary_builder/firebase_options.dart';

void main() {
  group('Firebase Services & Configuration Tests', () {
    test('DefaultFirebaseOptions contains correct Android configuration from google-services.json', () {
      final androidOptions = DefaultFirebaseOptions.android;
      expect(androidOptions.projectId, 'kalika-27e2e');
      expect(androidOptions.appId, '1:346682434600:android:220e3aa67f6774b9f3411d');
      expect(androidOptions.messagingSenderId, '346682434600');
      expect(androidOptions.storageBucket, 'kalika-27e2e.firebasestorage.app');
      expect(androidOptions.apiKey, isNotEmpty);
    });

    test('AnalyticsService singleton handles logging gracefully without throwing', () async {
      final analytics = AnalyticsService.instance;
      expect(analytics, isNotNull);

      // Verify custom events execute safely even in test/desktop environment
      await analytics.logEvent(name: 'test_event', parameters: {'param': 'value'});
      await analytics.logScreenView(screenName: 'TestScreen');
      await analytics.logWordLearned(word: 'resilient', difficulty: 'advanced', category: 'General');
      await analytics.logQuizCompleted(score: 9, totalQuestions: 10, quizType: 'smartMixed');
      await analytics.logSearch(searchTerm: 'wisdom');
      await analytics.logCustomWordAdded(word: 'harmony', category: 'Life');
    });

    test('NotificationService singleton initializes channel configuration constants', () {
      final notifications = NotificationService.instance;
      expect(notifications, isNotNull);
      expect(NotificationService.channelId, 'kalika_general_channel');
      expect(NotificationService.channelName, 'Kalika Notifications');
      expect(NotificationService.channelDescription, contains('vocabulary updates'));
    });

    test('NotificationService topic management handles calls safely', () async {
      final notifications = NotificationService.instance;
      await notifications.subscribeToTopic('test_topic');
      await notifications.unsubscribeFromTopic('test_topic');
    });
  });
}
