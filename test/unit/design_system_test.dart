import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocabulary_builder/core/widgets/animated_favorite_button.dart';
import 'package:vocabulary_builder/core/widgets/animated_progress_bar.dart';
import 'package:vocabulary_builder/core/widgets/success_celebration_dialog.dart';

void main() {
  group('Design System & Animation Widget Tests', () {
    testWidgets('AnimatedFavoriteButton toggles and fires callback on tap', (WidgetTester tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedFavoriteButton(
              isFavorite: false,
              itemName: 'ephemeral',
              onToggle: () {
                toggled = true;
              },
            ),
          ),
        ),
      );

      // Verify outline heart icon initially
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(AnimatedFavoriteButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(toggled, isTrue);
      // SnackBar shows with item name
      expect(find.text('Saved "ephemeral" to collection'), findsOneWidget);
    });

    testWidgets('AnimatedProgressBar renders smoothly with percentage text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedProgressBar(
              value: 0.75,
              height: 10,
              showPercentageText: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('SuccessCelebrationDialog renders title, score text, and triggers callbacks', (WidgetTester tester) async {
      bool primaryPressed = false;
      bool secondaryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  SuccessCelebrationDialog.show(
                    context: context,
                    title: 'Level Complete!',
                    message: 'Great mastery demonstrated.',
                    scoreText: '100% Score',
                    primaryButtonLabel: 'Continue',
                    onPrimaryPressed: () => primaryPressed = true,
                    secondaryButtonLabel: 'Review',
                    onSecondaryPressed: () => secondaryPressed = true,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Level Complete!'), findsOneWidget);
      expect(find.text('Great mastery demonstrated.'), findsOneWidget);
      expect(find.text('100% Score'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      expect(primaryPressed, isTrue);

      await tester.tap(find.text('Review'));
      expect(secondaryPressed, isTrue);
    });
  });
}
