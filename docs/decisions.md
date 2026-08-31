# Architectural Decision Records (ADRs)

### ADR 1: Feature-First Clean Architecture
- **Decision:** Organize codebase by feature (`features/words`, `features/favorites`, `features/quiz`, `features/progress`) rather than purely by layer.
- **Rationale:** Keeps high-cohesion code together and simplifies maintenance as new vocabulary features are added.

### ADR 2: Riverpod for State Management
- **Decision:** Use `flutter_riverpod` with immutable state providers and `StateNotifier`.
- **Rationale:** Compile-time safety, seamless dependency injection, reactive invalidation, and decoupling of UI from business logic.

### ADR 3: SQLite with FFI Support
- **Decision:** Use `sqflite` with `sqflite_common_ffi` initialization for desktop/Windows compatibility.
- **Rationale:** Ensures offline SQL querying capabilities across mobile and desktop without external backend servers.

### ADR 4: GoRouter with Stateful Navigation Shell
- **Decision:** Use `GoRouter` with `StatefulShellRoute.indexedStack`.
- **Rationale:** Preserves scroll and search state when switching between bottom navigation tabs (Explore, Saved, Quiz, Progress).
