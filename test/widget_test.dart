import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/widgets/custom_badge.dart';
import 'package:vocabulary_builder/core/widgets/empty_state_view.dart';
import 'package:vocabulary_builder/features/settings/presentation/screens/settings_screen.dart';
import 'package:vocabulary_builder/features/words/presentation/screens/add_word_screen.dart';
import 'package:vocabulary_builder/features/words/presentation/widgets/difficulty_badge.dart';

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

    testWidgets('SettingsScreen renders Theme options and Vocabulary Info', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Vocabulary Library'), findsOneWidget);
      expect(find.text('1,350 Words'), findsOneWidget);
      expect(find.text('27 Topics (50+ each)'), findsOneWidget);
      expect(find.text('ಕನ್ನಡ ಅರ್ಥಗಳು ಸೇರಿಸಲಾಗಿದೆ'), findsOneWidget);
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
  });
}
