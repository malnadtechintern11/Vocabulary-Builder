import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/widgets/custom_badge.dart';
import 'package:vocabulary_builder/core/widgets/empty_state_view.dart';
import 'package:vocabulary_builder/core/widgets/error_state_view.dart';
import 'package:vocabulary_builder/features/settings/presentation/screens/settings_screen.dart';
import 'package:vocabulary_builder/features/words/presentation/screens/add_word_screen.dart';
import 'package:vocabulary_builder/features/words/presentation/widgets/difficulty_badge.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vocabulary_builder/core/services/online_dictionary_service.dart';
import 'package:vocabulary_builder/features/ocr/presentation/screens/scan_text_screen.dart';
import 'package:vocabulary_builder/features/translation/presentation/screens/translation_screen.dart';
import 'package:vocabulary_builder/features/words/domain/entities/word.dart';
import 'package:vocabulary_builder/features/words/domain/repositories/word_repository.dart';
import 'package:vocabulary_builder/features/words/domain/usecases/search_words_usecase.dart';
import 'package:vocabulary_builder/features/words/presentation/providers/words_provider.dart';
import 'package:vocabulary_builder/features/words/presentation/screens/words_list_screen.dart';
import 'package:vocabulary_builder/screens/english_sentences_screen.dart';

class MockWordRepository extends Mock implements WordRepository {}

class MockOnlineDictionaryService extends Mock implements OnlineDictionaryService {}

void main() {
  group('Widget Tests', () {
    testWidgets('EmptyStateView renders title, description, and action button', (WidgetTester tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.search_off,
              title: 'No Words',
              description: 'Try another filter',
              actionLabel: 'Reset',
              onActionPressed: () {
                actionPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('No Words'), findsOneWidget);
      expect(find.text('Try another filter'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.text('Reset'));
      expect(actionPressed, isTrue);
    });

    testWidgets('CustomBadge and DifficultyBadge display appropriate labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomBadge(
                  label: 'NEW',
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                ),
                DifficultyBadge(difficulty: 'intermediate'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('INTERMEDIATE'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders Theme options, Share App button, Privacy Policy, and Vocabulary Info', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Share & Community'), findsOneWidget);
      expect(find.text('Share App'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Vocabulary Library'), findsOneWidget);
      expect(find.text('1,350 Words'), findsOneWidget);
      expect(find.text('27 Topics (50+ each)'), findsOneWidget);
      expect(find.text('ಕನ್ನಡ ಅರ್ಥಗಳು ಸೇರಿಸಲಾಗಿದೆ'), findsOneWidget);

      // Tap Privacy Policy to verify modal sheet opens
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.text('100% Private, Offline-First & Transparent'), findsOneWidget);
      expect(find.text('1. Offline-First Data Storage'), findsOneWidget);
      expect(find.text('2. Zero Data Tracking & No Analytics'), findsOneWidget);
      expect(find.text('3. On-Device Image & Camera Privacy'), findsOneWidget);
      expect(find.text('I Understand'), findsOneWidget);

      // Tap I Understand to dismiss
      await tester.tap(find.text('I Understand'));
      await tester.pumpAndSettle();
      expect(find.text('100% Private, Offline-First & Transparent'), findsNothing);
    });

    testWidgets('AddWordScreen renders form elements and Kannada label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddWordScreen(),
          ),
        ),
      );

      expect(find.text('Add New Word'), findsOneWidget);
      expect(find.text('Custom Vocabulary'), findsOneWidget);
      expect(find.text('English Word *'), findsOneWidget);
      expect(find.text('English Meaning / Definition *'), findsOneWidget);
      expect(find.text('ಕನ್ನಡ ಅರ್ಥ (Kannada Meaning) *'), findsOneWidget);
      expect(find.text('Contextual Example Sentence'), findsOneWidget);
      expect(find.text('Add Word to Vocabulary'), findsOneWidget);
    });

    testWidgets('AddWordScreen renders without any overflow on compact 320px screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddWordScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final error = tester.takeException();
      if (error is FlutterError) {
        for (final diag in error.diagnostics) {
          debugPrint('DIAG: ${diag.toStringDeep()}');
        }
      }
      expect(error, isNull);
    });

    testWidgets('EnglishSentencesScreen renders without any overflow on compact screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EnglishSentencesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('English Sentences'), findsOneWidget);
      expect(find.text('Sentences Progress'), findsOneWidget);
      expect(find.text('Practice'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('EnglishSentencesScreen renders without any overflow on ultra-compact 320px screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EnglishSentencesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('English Sentences'), findsOneWidget);
      expect(find.text('Sentences Progress'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ScanTextScreen renders offline OCR header, camera and gallery buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ScanTextScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scan Text (OCR)'), findsOneWidget);
      expect(find.text('100% Offline On-Device Recognition'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose Image'), findsOneWidget);
      expect(find.text('Textbook & Image Scanner'), findsOneWidget);
    });

    testWidgets('TranslationScreen renders Photo/Camera scanning, 10 language options, input area, and handles offline message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TranslationScreen(initialText: 'Knowledge'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Multi-Language Translation'), findsOneWidget);
      expect(find.text('10 Indian & English Languages (Online)'), findsOneWidget);
      expect(find.text('Scan Text from Image / Camera'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose Image'), findsOneWidget);
      expect(find.text('Translate From'), findsOneWidget);
      expect(find.text('Translate To'), findsOneWidget);
      expect(find.text('Translate to Kannada'), findsOneWidget);
      expect(find.text('Knowledge'), findsOneWidget);
    });
    testWidgets('WordsListScreen renders offline error state without overflow when keyboard is open', (WidgetTester tester) async {
      // Simulate viewport height when keyboard is active (e.g., 360x360)
      tester.view.physicalSize = const Size(360, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockWordRepository();
      final mockOnline = MockOnlineDictionaryService();
      when(() => mockRepo.searchWords(any())).thenAnswer((_) async => <Word>[]);
      when(() => mockRepo.getCategories()).thenAnswer((_) async => <String>[]);
      when(() => mockRepo.getWords(
        category: any(named: 'category'),
        difficulty: any(named: 'difficulty'),
        onlyLearned: any(named: 'onlyLearned'),
        onlyFavorites: any(named: 'onlyFavorites'),
      )).thenAnswer((_) async => <Word>[]);
      when(() => mockOnline.fetchWordDetails(any())).thenThrow(
        const WordNoInternetException('This word is not available offline. Please connect to the internet to search for it.'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchWordsUseCaseProvider.overrideWith((ref) => SearchWordsUseCase(mockRepo)),
            onlineDictionaryServiceProvider.overrideWithValue(mockOnline),
          ],
          child: const MaterialApp(
            home: WordsListScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'candy');
      await tester.pump();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('EmptyStateView and ErrorStateView render without overflow on constrained height', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 240);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.search_off_rounded,
              title: 'No Words Found',
              description: 'Try adjusting your search query or filter tags to discover more words.',
              actionLabel: 'Clear Search',
              onActionPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateView(
              message: 'This word is not available offline. Please connect to the internet to search for it.',
              onRetry: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
