import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/navigation/presentation/screens/main_shell_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/quiz/presentation/screens/active_quiz_screen.dart';
import '../../features/quiz/presentation/screens/quiz_result_screen.dart';
import '../../features/quiz/presentation/screens/quiz_setup_screen.dart';
import '../../features/words/presentation/screens/word_detail_screen.dart';
import '../../features/words/presentation/screens/words_list_screen.dart';
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
                      return WordDetailScreen(wordId: id);
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
        ],
      ),
    ],
  );
});
