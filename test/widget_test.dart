import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/widgets/custom_badge.dart';
import 'package:vocabulary_builder/core/widgets/empty_state_view.dart';
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
  });
}
