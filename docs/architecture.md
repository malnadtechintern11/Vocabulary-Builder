# Architecture Documentation

## Overview
**Vocabulary Builder** is built using **Feature-First Clean Architecture** with **Riverpod** for reactive state management, **GoRouter** for declarative navigation, and **SQLite (sqflite / sqflite_common_ffi)** for offline data persistence.

```
UI (Screens / Widgets)
       ↓
State Notifiers / Riverpod Providers
       ↓
Domain Use Cases
       ↓
Domain Repository Interfaces
       ↓
Data Repository Implementations
       ↓
Local Data Sources (SQLite / JSON Seed Loader)
```

## Layers
1. **Domain Layer (`lib/features/*/domain/`):**
   - **Entities:** Pure Dart models representing business concepts (`Word`, `QuizQuestion`, `QuizResult`). Completely decoupled from UI and framework code.
   - **Repository Interfaces:** Abstract contracts (`WordRepository`, `QuizRepository`).
   - **Use Cases:** Encapsulated business operations (`GetWordsUseCase`, `GenerateQuizUseCase`, `ToggleFavoriteUseCase`, `SaveQuizResultUseCase`, etc.).

2. **Data Layer (`lib/features/*/data/`):**
   - **Models:** SQLite and JSON serializable models (`WordModel`, `QuizResultModel`).
   - **Data Sources:** Local database access objects (`WordLocalDataSource`, `QuizLocalDataSource`).
   - **Repository Implementations:** Implementations of domain repository interfaces connecting data sources to the domain.

3. **Presentation Layer (`lib/features/*/presentation/`):**
   - **Providers & Controllers:** State management via Riverpod (`wordsListProvider`, `wordControllerProvider`, `quizControllerProvider`, `progressMetricsProvider`).
   - **Screens:** Full pages (`WordsListScreen`, `WordDetailScreen`, `FavoritesScreen`, `QuizSetupScreen`, `ActiveQuizScreen`, `QuizResultScreen`, `ProgressScreen`).
   - **Widgets:** Reusable, testable UI components (`WordCard`, `QuizOptionCard`, `DifficultyBadge`, `WordSearchBar`, etc.).

4. **App & Core Layer (`lib/app/`, `lib/core/`):**
   - **Router:** `GoRouter` with `StatefulShellRoute` for bottom navigation bar preservation.
   - **Theme:** Curated Material 3 Light and Dark palettes.
   - **Database:** Singleton `AppDatabase` with desktop FFI support, migration readiness, and seed population.
