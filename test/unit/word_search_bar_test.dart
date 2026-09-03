import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/services/speech_service.dart';
import 'package:vocabulary_builder/features/words/presentation/providers/words_provider.dart';
import 'package:vocabulary_builder/features/words/presentation/widgets/word_search_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WordSearchBar and Voice Search Tests', () {
    testWidgets('WordSearchBar renders search field and microphone button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WordSearchBar(),
            ),
          ),
        ),
      );

      // Verify TextField and icons exist
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      expect(find.byTooltip('Voice search (Speak a word)'), findsOneWidget);
    });

    testWidgets('WordSearchBar shows clear button and mic button when text is entered', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            wordSearchQueryProvider.overrideWith((ref) => 'abundant'),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WordSearchBar(),
            ),
          ),
        ),
      );

      // Verify both clear icon and mic icon are present
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      // Verify field text is cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('WordSearchBar reflects listening state visually', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: WordSearchBar(),
            ),
          ),
        ),
      );

      // Initially idle
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

      // Set listening to true
      container.read(voiceListeningProvider.notifier).setListening(true);
      await tester.pump();

      // Should show active mic icon and listening banner
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.text('Listening... Say any word to search'), findsOneWidget);
      expect(find.byTooltip('Listening... Tap to stop'), findsOneWidget);
    });
  });
}
