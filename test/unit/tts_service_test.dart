import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/services/tts_service.dart';
import 'package:vocabulary_builder/core/widgets/audio_pronounce_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TtsService and ActiveTtsNotifier Tests', () {
    test('TtsService instance is singleton', () {
      final instance1 = TtsService.instance;
      final instance2 = TtsService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('ActiveTtsNotifier initial state is null', () {
      final notifier = ActiveTtsNotifier();
      expect(notifier.state, isNull);
    });

    test('ActiveTtsNotifier stop resets state to null', () async {
      final notifier = ActiveTtsNotifier();
      await notifier.stop();
      expect(notifier.state, isNull);
    });

    test('AppTtsController formats word IDs correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(appTtsControllerProvider);
      expect(controller, isNotNull);
      expect(container.read(activeTtsIdProvider), isNull);
    });
  });

  group('AudioPronounceButton Widget Tests', () {
    testWidgets('AudioPronounceButton renders speaker icon and tooltip', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AudioPronounceButton(
                id: 'test_word_1',
                text: 'Phenomenon',
                tooltip: 'Pronounce "Phenomenon"',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AudioPronounceButton), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.volume_down_rounded), findsOneWidget);
    });

    testWidgets('AudioPronounceTonalButton renders with label and icon', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: AudioPronounceTonalButton(
                id: 'test_sentence_1',
                text: 'Practice makes permanent.',
                label: 'Pronounce',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AudioPronounceTonalButton), findsOneWidget);
      expect(find.text('Pronounce'), findsOneWidget);
      expect(find.byIcon(Icons.volume_down_rounded), findsOneWidget);
    });
  });
}
