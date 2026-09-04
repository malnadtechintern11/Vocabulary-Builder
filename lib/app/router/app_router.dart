import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/navigation/presentation/screens/main_shell_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/quiz/presentation/screens/active_quiz_screen.dart';
import '../../features/quiz/presentation/screens/quiz_result_screen.dart';
import '../../features/quiz/presentation/screens/quiz_setup_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/words/domain/entities/word.dart';
import '../../features/words/presentation/screens/add_word_screen.dart';
import '../../features/words/presentation/screens/word_detail_screen.dart';
import '../../features/words/presentation/screens/words_list_screen.dart';
import '../../features/ocr/presentation/screens/scan_text_screen.dart';
import '../../features/translation/presentation/screens/translation_screen.dart';
import '../../screens/english_sentences_screen.dart';
import '../../screens/sentence_practice_screen.dart';
import 'route_names.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');

/// Provider for GoRouter instance
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.words,
    debugLogDiagnostics: false,
    routes: [
      // Main Application Stateful Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Explore / Words
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.words,
                name: RouteNames.words,
                builder: (context, state) => const WordsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.wordDetail,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                      final extraWord = state.extra is Word ? state.extra as Word : null;
                      return WordDetailScreen(wordId: id, initialWord: extraWord);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Saved Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.favorites,
                name: RouteNames.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),

          // Branch 3: Practice & Quizzes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.quiz,
                name: RouteNames.quiz,
                builder: (context, state) => const QuizSetupScreen(),
                routes: [
                  GoRoute(
                    path: 'active',
                    name: RouteNames.quizActive,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const ActiveQuizScreen(),
                  ),
                  GoRoute(
                    path: 'result',
                    name: RouteNames.quizResult,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const QuizResultScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 4: Learning Progress & Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.progress,
                name: RouteNames.progress,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),

          // Branch 5: User Adding New Words (in the middle of Progress and Settings)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.addWord,
                name: RouteNames.addWord,
                builder: (context, state) => const AddWordScreen(),
              ),
            ],
          ),

          // Branch 6: Settings & Customization
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                name: RouteNames.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // English Sentences section with practice mode
      GoRoute(
        path: RoutePaths.sentences,
        name: RouteNames.sentences,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EnglishSentencesScreen(),
        routes: [
          GoRoute(
            path: 'practice',
            name: RouteNames.sentencesPractice,
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => const SentencePracticeScreen(),
          ),
        ],
      ),

      // Scan Text from Camera/Image (100% Offline On-Device OCR)
      GoRoute(
        path: RoutePaths.scanText,
        name: RouteNames.scanText,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScanTextScreen(),
      ),

      // Multi-Language Translation (Online - 10 Languages)
      GoRoute(
        path: RoutePaths.translation,
        name: RouteNames.translation,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final initialText = state.extra is String ? state.extra as String : null;
          return TranslationScreen(initialText: initialText);
        },
      ),
    ],
  );
});
