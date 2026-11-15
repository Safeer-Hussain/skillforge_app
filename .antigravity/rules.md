# SkillForge Autonomous Engineering Engine Rules

## The Mandatory 6-Phase Autonomous Sprint Protocol
Whenever the user commands `"run daily sprint"`, `"daily sprint"`, or similar, the AI Assistant MUST autonomously execute the following 6 phases in strict sequential order without skipping or pausing:

### Phase 1: Pre-Flight Check
1. Verify git working directory is clean: `git status --porcelain`.
2. Ensure `origin` points to the authenticated repository URL: `git remote -v`.
3. Read `docs/AUTONOMOUS_BACKLOG.md` and select the earliest uncompleted `[ ]` sprint task.

### Phase 2: Architecture & Implementation
1. Adhere strictly to Feature-First Clean Architecture + BLoC/Cubit + GetIt.
2. Comply with all Safety Invariants:
   - ZERO hardcoded colors: Dynamic resolution via `Theme.of(context).colorScheme`.
   - ZERO emojis anywhere in code, UI strings, debug logs, or commit messages.
   - Unique hero tag on any `FloatingActionButton`.
   - Landscape 360dp safety: Compact `NavigationRail` wrapped in `SingleChildScrollView` + `IntrinsicHeight`, `mainAxisExtent: 145` on grids, full-width edge-to-edge charts (`width: double.infinity`, `reservedSize: 0`).
   - No double viewInsets in chat views (`Scaffold(resizeToAvoidBottomInset: true)`).
   - Form validation with inline red `errorText`.
   - Stream cleanup wrapped in `try ... finally` guaranteeing `isStreaming: false`.

### Phase 3: Automated Testing & Verification
1. Add accompanying automated unit/widget tests for the new sprint functionality.
2. Run `dart format lib test tool`.
3. Run `tool/sprint_gate.dart` (enforcing pub get, format, analyzer with `--no-fatal-infos`, and tests).
4. Verify all tests pass with 0 errors.

### Phase 4: Backlog Transition
1. In `docs/AUTONOMOUS_BACKLOG.md`, mark the sprint item as completed (`[x]`).

### Phase 5: Conventional Commit & Push
1. Stage all changes: `git add .`
2. Commit with a strict conventional commit message:
   `git commit -m "feat(sprint-N): <concise summary of sprint feature>"`
3. Push to `origin main`:
   `git push origin main`

### Phase 6: Post-Push Verification
1. Verify that local `main` is completely in sync with remote:
   `git log origin/main..HEAD`
   (Output MUST be completely empty, proving zero unpushed commits).
2. Report sprint completion summary to user.
