# Changelog

All notable changes to the SkillForge platform are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1+2] - 2026-11-18

### Added
- **Custom Regex & JSON Schema Live Tester (Sprint 3)**:
  - Integrated validator studio in Code Sandbox testing regex match captures, group tokens, and performance metrics (µs).
  - Flags support: Case Insensitive (`i`), Multi-line (`m`), DotAll (`s`), and Unicode (`u`).
  - JSON Schema Validator (draft-07 specification) supporting types, required keys, numeric bounds, string length/regex patterns, and array items.
  - Interactive Dart Data Model code generator with type-safe `fromJson` and `toJson` serialization.
  - Direct Code Sandbox injection bridge copying regex validators and test runners into the active code buffer.
  - SQLite persistence for custom user templates via `regex_json_templates` table.
  - Curated engineering preset library: SemVer 2.0.0, JWT Bearer Token, RFC 5322 Email, ISO 8601 Timestamp, IPv4/CIDR, AI Mentor Structured Response Schema, and Native Telemetry Packet Schema.
- Automated Release Workflow:
  - Added `.github/workflows/release.yml` for automated GitHub Actions APK builds (`flutter build apk --release`) and GitHub Release artifact attachments.

### Changed
- Incremented platform version to `1.0.1+2`.

---

## [1.0.0+1] - 2026-11-17

### Added
- **Big-O Time & Space Complexity Visualizer (Sprint 1)**:
  - Interactive canvas rendering asymptotic execution curves for O(1), O(log n), O(n), O(n log n), and O(2^n).
- **52-Week GitHub Contribution Streak & Study Heatmap Grid (Sprint 2)**:
  - 52-week activity contribution matrix displaying daily completed lessons, sandbox executions, and SM-2 flashcard reviews with 4 levels of emerald intensity.
- Initial enterprise architecture with Clean Architecture, SQLite local database, Impeller protection, and BLoC state management.
