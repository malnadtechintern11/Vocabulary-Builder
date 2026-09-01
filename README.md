# Vocabulary Builder 📚

A production-quality, offline-first Flutter application designed to help learners and students master English vocabulary, discover word meanings, explore synonyms/antonyms, take interactive quizzes, and track learning progress.

---

## 🌟 Core Features

- **📖 Rich Vocabulary Library:** Explore curated English words with definitions, phonetic transcriptions, parts of speech, and contextual example sentences.
- **🔍 Real-Time Search & Filters:** Search by word or meaning, and filter by CEFR difficulty (Beginner, Intermediate, Advanced) and topics.
- **⭐ Saved Words / Favorites:** Bookmark words with one tap to build your custom study list.
- **🎯 Dynamic Quiz Engine:** Practice with multiple quiz types:
  - *Definition Match*
  - *Synonym Finder*
  - *Antonym Challenge*
  - *Fill in the Blank*
- **📊 Progress & Analytics Dashboard:** Monitor words mastered, quiz accuracy, total questions answered, and past quiz attempts.
- **⚡ 100% Offline & Local:** Bundled with rich seed vocabulary and backed by SQLite (`sqflite`).

---

## 🏗 Architecture & Engineering Standards

Built strictly following the **Flutter Production Architecture Standard**:
- **Clean Architecture:** Domain, Data, and Presentation layer separation with Repository Pattern and Use Cases.
- **State Management:** Riverpod 2 (`flutter_riverpod`) for reactive, testable state.
- **Navigation:** `go_router` with `StatefulShellRoute` preserving navigation states.
- **Design System:** Material 3 with tailored Light & themes, Google Fonts typography, and smooth micro-interactions.

```
lib/
├── app/                  # App initialization, routing, and theme
├── core/                 # Database, errors, constants, shared widgets
└── features/
    ├── words/            # Word library, search, details, mastery
    ├── favorites/        # Saved bookmarks
    ├── quiz/             # Question generator, active quiz, results
    ├── progress/         # Learning statistics and quiz history
    └── navigation/       # Shell navigation bar
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.13+ / Dart 3.0+)

### Running the App
```bash
# Get dependencies
flutter pub get

# Run on your target platform (Android, iOS, Windows, macOS, Linux, Web)
flutter run
```

### Running Tests
```bash
# Run unit & widget tests
flutter test

# Run static analysis
flutter analyze
```
