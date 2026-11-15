# SkillForge Engineering Directives & Gemini Context

## Project Identity
- **Name**: SkillForge
- **GitHub Owner**: Safeer-Hussain
- **Repository**: https://github.com/Safeer-Hussain/skillforge
- **Core Technology**: Flutter (Dart 3+), BLoC / Cubit, SQLite (`sqflite`), GetIt, `fl_chart`, Native Android (Kotlin) & iOS (Swift) Platform Channels.

## Architectural Mandates
1. **Clean Architecture + BLoC**:
   - `core/`: Themes, platform channels, network interceptors, SM-2 math, AST analyzers, feedback alerts.
   - `data/`: Local SQLite database, models, SharedPreferences, repository implementations.
   - `domain/`: Pure entities and contracts.
   - `presentation/`: Feature-first BLoCs/Cubits and adaptive views.
2. **Quality Gates**:
   - Always run `dart run tool/sprint_gate.dart` before commits.
   - In CI: `flutter analyze --no-fatal-infos` and `flutter test --coverage`.
3. **Autonomous Daily Sprints**:
   - Follow the 6-phase protocol documented in `rules.md` and `docs/AUTONOMOUS_BACKLOG.md`.
