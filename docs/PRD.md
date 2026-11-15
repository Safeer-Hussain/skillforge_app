# Product Requirements Document (PRD): SkillForge

## 1. Executive Summary
**SkillForge** is an Enterprise Technical Mastery & EdTech Platform, Interactive Live Code & Architecture Sandbox, Spaced-Repetition SM-2 Flashcard Engine, Native AST/Runtime Execution Bridge, and On-Device AI Socratic Engineering Mentor developed in Flutter. It is designed to prepare software engineers for Senior, Staff, and Principal Architecture roles through rigorous hands-on practice, cognitive reinforcement, and socratic evaluation.

---

## 2. Platform Architecture & Clean Architecture Boundaries

SkillForge adheres to Feature-First Clean Architecture combined with BLoC / Cubit state management:

```
lib/
├── core/
│   ├── constants/             # Global configurations, keys, socratic prompts
│   ├── network/               # Dio Client & Latency Simulation Interceptors
│   ├── platform/              # Native MethodChannel & EventChannel runtime bridge
│   ├── theme/                 # Obsidian IDE Dark & Crisp Academic Light schemes
│   └── utils/                 # SM-2 Algorithm, AST Complexity Analyzer, AppFeedback
├── data/
│   ├── datasources/           # SQLite LocalDatabase & SharedPreferences
│   ├── models/                # Immutable Data Transfer Objects (DTOs)
│   └── repositories/          # Concrete implementation of domain logic & cache
├── domain/                    # Abstract interfaces, domain contracts
├── presentation/              # Feature-first BLoCs, Cubits, and Adaptive Views
│   ├── curriculum/            # Track catalog, syllabus, and lesson studio
│   ├── sandbox/               # Live code editor, quick symbol toolbar, test runner
│   ├── flashcards/            # 3D SM-2 flashcard flip studio & certification exam
│   ├── cohort/                # Deep work rooms, peer reviews, leaderboard
│   ├── ai_mentor/             # On-device AI Socratic dialogue with AST context
│   ├── analytics/             # 14-day XP velocity & retention charts (fl_chart)
│   ├── shell/                 # AdaptiveScaffold (360dp landscape safe)
│   ├── splash/                # 1200ms branded pulse splash screen
│   └── widgets/               # Offline banner, code syntax view
└── injection.dart             # GetIt dependency injection registry
```

---

## 3. Core Modules & Functional Specifications

### Module 1: Engineering Career Tracks & Interactive Lesson Studio
- **Curriculum Catalog**: 18+ seeded tracks spanning 5 domains:
  - Mobile Architecture & Flutter Internals
  - Clean Architecture & SOLID Patterns
  - Distributed Systems & Backends
  - Applied LLM Architecture & AI Engineering
  - System Design & Scalability
- **Difficulties**: Associate, Senior, Staff/Principal.
- **Interactive Syllabus**: Module accordion with checkboxes that instantly recalculate track progress percentage and award XP to SQLite.
- **Lesson Studio**: Formatted architectural notes, time/space complexity badges (`O(1)`, `O(log n)`), 1-tap "Launch in Code Sandbox" action, and share progress credential sheet.

### Module 2: Interactive Live Code & Architecture Sandbox
- **Native Platform Channels**:
  - `MethodChannel('com.safeer.skillforge/sandbox_runtime')` executing Dart code snippets, running unit assertions, and measuring cyclomatic complexity.
  - `EventChannel('com.safeer.skillforge/focus_telemetry')` streaming memory, parse latency, and streak multipliers every 2 seconds.
- **Curated Challenges**:
  - Thread-Safe LRU Cache with O(1) Eviction
  - Stream Debouncer with Leading Instant Emission
  - Rate-Limiter Token Bucket with Atomic Refill
  - Binary Tree Level-Order (BFS) Traversal
- **Editor Features**: Quick-insert symbol bar (`{ }`, `( )`, `=>`, `async`, `await`, `;`), Reset Template, and "Run & Verify Tests" FAB (`heroTag: 'fab_sandbox_run_code'`).

### Module 3: Spaced-Repetition Flashcards (SM-2 Algorithm) & Certification Exam
- **SM-2 Deck Studio**:
  - 3D-style flip card animation (`AnimatedSwitcher` + `Transform`).
  - 4-Tier recall rating buttons:
    - `Again (<1m)`: Grade 1, resets repetitions to 0, intervals to 1.
    - `Hard (12h)`: Grade 2, slight interval adjustment.
    - `Good (2d)`: Grade 4, standard SM-2 progression.
    - `Easy (5d)`: Grade 5, ease factor boost and interval scaling.
  - Custom Flashcard Creator modal with strict form validation.
- **Certification Exam**:
  - 10-minute live countdown timer.
  - Question navigator pills.
  - Automated scoring and verified digital certificate generation (benchmark: >= 80%).

### Module 4: Live Cohort Study Rooms, Peer Code Reviews & Leaderboard
- **Study Rooms**: Active deep-work rooms with integrated Pomodoro focus timer synced to telemetry.
- **Peer Code Reviews**: Interactive RFC feed with reactive upvoting, comment threads, share bottom sheet, and "+ Post Architecture Question" modal.
- **Weekly Leaderboard**: Global XP leaderboard highlighting the user's current ranking and streak.

### Module 5: On-Device AI Socratic Engineering Mentor & Analytics
- **AI Socratic Mentor**: Reads live SQLite learner statistics (completed lessons, weak flashcards, sandbox failures) to formulate probing first-principles questions.
- **Guaranteed Cleanup**: Asynchronous token streaming wrapped in `try ... finally` guaranteeing `isStreaming: false`.
- **Mastery Analytics**: Full-width edge-to-edge `fl_chart` 14-day velocity chart, competency radar, and Recruiter Debug Drawer.

---

## 4. SQLite Data Schema

### Table: `tracks`
- `id` (TEXT PRIMARY KEY)
- `title` (TEXT)
- `domain` (TEXT)
- `difficulty` (TEXT)
- `description` (TEXT)
- `iconPath` (TEXT)
- `isEnrolled` (INTEGER)
- `isBookmarked` (INTEGER)
- `progressPercent` (REAL)
- `totalXp` (INTEGER)
- `lessonsCount` (INTEGER)
- `completedLessonsCount` (INTEGER)

### Table: `lessons`
- `id` (TEXT PRIMARY KEY)
- `trackId` (TEXT, FOREIGN KEY)
- `title` (TEXT)
- `moduleTitle` (TEXT)
- `durationMinutes` (INTEGER)
- `timeComplexity` (TEXT)
- `spaceComplexity` (TEXT)
- `contentNotes` (TEXT)
- `codeSnippet` (TEXT)
- `isCompleted` (INTEGER)
- `xpReward` (INTEGER)
- `relatedChallengeId` (TEXT)

### Table: `challenges`
- `id` (TEXT PRIMARY KEY)
- `title` (TEXT)
- `difficulty` (TEXT)
- `domain` (TEXT)
- `description` (TEXT)
- `starterCode` (TEXT)
- `solutionCode` (TEXT)
- `testCasesJson` (TEXT)
- `cyclomaticTarget` (INTEGER)
- `xpReward` (INTEGER)
- `isCompleted` (INTEGER)

### Table: `flashcards`
- `id` (TEXT PRIMARY KEY)
- `trackId` (TEXT)
- `topicTag` (TEXT)
- `frontPrompt` (TEXT)
- `backAnswer` (TEXT)
- `codeExample` (TEXT)
- `repetitions` (INTEGER)
- `easeFactor` (REAL)
- `intervalDays` (INTEGER)
- `lastReviewedAt` (TEXT)
- `nextReviewAt` (TEXT)
- `status` (TEXT)

### Table: `study_rooms`
- `id` (TEXT PRIMARY KEY)
- `title` (TEXT)
- `topic` (TEXT)
- `participantsCount` (INTEGER)
- `pomodoroMinutes` (INTEGER)
- `isActive` (INTEGER)
- `hostName` (TEXT)
- `userJoined` (INTEGER)

### Table: `code_reviews`
- `id` (TEXT PRIMARY KEY)
- `authorName` (TEXT)
- `authorRole` (TEXT)
- `title` (TEXT)
- `codeSnippet` (TEXT)
- `description` (TEXT)
- `upvotesCount` (INTEGER)
- `isUpvoted` (INTEGER)
- `commentsCount` (INTEGER)
- `createdAt` (TEXT)
- `tags` (TEXT)

---

## 5. Non-Functional Requirements & Security
- **Anti-AI Code Hygiene**: Strict prohibition of emojis in code, logs, and commit messages. Material Symbols only.
- **Landscape Viewport Safety**: 360dp height safe with compact `NavigationRail` and `mainAxisExtent: 145` on grid cards.
- **Impeller Safety**: Impeller Vulkan disabled on Android to prevent crashes on Mali/MediaTek chips.
- **Zero Hardcoded Colors**: 100% theme parity via `ColorScheme` tokens.
