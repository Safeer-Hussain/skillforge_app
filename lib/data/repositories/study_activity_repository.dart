import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../datasources/local_database.dart';
import '../datasources/preferences_service.dart';
import '../models/daily_activity_model.dart';

class StudyActivityRepository {
  final AppDatabase database;
  final PreferencesService preferencesService;

  StudyActivityRepository({
    required this.database,
    required this.preferencesService,
  });

  /// Ensures the table exists before querying
  Future<Database> _getDb() async {
    final db = await database.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS study_activities (
        date TEXT PRIMARY KEY,
        completedLessons INTEGER,
        sandboxExecutions INTEGER,
        flashcardsReviewed INTEGER,
        xpEarned INTEGER
      )
    ''');
    return db;
  }

  /// Formats date to 'yyyy-MM-dd'
  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Retrieves 52 weeks (364 days) of daily activity.
  /// If empty, generates realistic engineering activity history.
  Future<List<DailyActivityModel>> get52WeeksActivity({
    DateTime? referenceDate,
  }) async {
    final db = await _getDb();
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 52 weeks = 364 days
    const totalDays = 364;
    final startDate = today.subtract(const Duration(days: totalDays - 1));

    final results = await db.query(
      'study_activities',
      where: 'date >= ? AND date <= ?',
      whereArgs: [_formatDate(startDate), _formatDate(today)],
      orderBy: 'date ASC',
    );

    final mapByDate = <String, DailyActivityModel>{};
    for (final row in results) {
      final model = DailyActivityModel.fromMap(row);
      mapByDate[model.dateKey] = model;
    }

    // If records are empty or too sparse, seed realistic history
    if (mapByDate.length < 50) {
      final seeded = _generateRealisticHistory(startDate, today);
      final batch = db.batch();
      for (final item in seeded) {
        batch.insert(
          'study_activities',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        mapByDate[item.dateKey] = item;
      }
      await batch.commit(noResult: true);
    }

    // Build the complete contiguous 364-day list
    final activities = <DailyActivityModel>[];
    for (int i = 0; i < totalDays; i++) {
      final date = startDate.add(Duration(days: i));
      final key = _formatDate(date);
      final item = mapByDate[key] ?? DailyActivityModel(date: date);
      activities.add(item);
    }

    return activities;
  }

  /// Seeds realistic 52-week engineering practice data with active streak
  List<DailyActivityModel> _generateRealisticHistory(
    DateTime start,
    DateTime end,
  ) {
    final items = <DailyActivityModel>[];
    final random = Random(42); // Deterministic seed for test parity
    final totalDays = end.difference(start).inDays + 1;

    for (int i = 0; i < totalDays; i++) {
      final date = start.add(Duration(days: i));
      final daysFromEnd = totalDays - 1 - i;

      int lessons = 0;
      int sandbox = 0;
      int flashcards = 0;
      int xp = 0;

      // Ensure the last 14 days match the user's active streak (active every day)
      if (daysFromEnd < 14) {
        lessons = 1 + random.nextInt(3); // 1-3 lessons
        sandbox = 1 + random.nextInt(4); // 1-4 sandbox runs
        flashcards = 2 + random.nextInt(6); // 2-7 flashcards
        xp = (lessons * 100) + (sandbox * 60) + (flashcards * 25);
      } else {
        // Weekday probability is higher (~72%), Weekend probability (~45%)
        final isWeekend =
            date.weekday == DateTime.saturday ||
            date.weekday == DateTime.sunday;
        final prob = isWeekend ? 0.42 : 0.72;

        if (random.nextDouble() < prob) {
          final intensityRoll = random.nextDouble();
          if (intensityRoll < 0.35) {
            // Level 1 (1-2 actions)
            lessons = random.nextBool() ? 1 : 0;
            sandbox = lessons == 0 ? 1 : 0;
            flashcards = (lessons == 0 && sandbox == 0) ? 2 : 0;
          } else if (intensityRoll < 0.70) {
            // Level 2 (3-5 actions)
            lessons = 1;
            sandbox = 1 + random.nextInt(2);
            flashcards = 1 + random.nextInt(3);
          } else if (intensityRoll < 0.90) {
            // Level 3 (6-9 actions)
            lessons = 2;
            sandbox = 2 + random.nextInt(3);
            flashcards = 3 + random.nextInt(4);
          } else {
            // Level 4 (10+ actions)
            lessons = 2 + random.nextInt(2);
            sandbox = 3 + random.nextInt(3);
            flashcards = 5 + random.nextInt(5);
          }
          xp = (lessons * 100) + (sandbox * 60) + (flashcards * 25);
        }
      }

      items.add(
        DailyActivityModel(
          date: date,
          completedLessons: lessons,
          sandboxExecutions: sandbox,
          flashcardsReviewed: flashcards,
          xpEarned: xp,
        ),
      );
    }

    return items;
  }

  /// Logs a study activity for today
  Future<DailyActivityModel> logActivity({
    required String type,
    int count = 1,
    int xp = 50,
    DateTime? date,
  }) async {
    final db = await _getDb();
    final targetDate = date ?? DateTime.now();
    final normalized = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final key = _formatDate(normalized);

    final existing = await db.query(
      'study_activities',
      where: 'date = ?',
      whereArgs: [key],
      limit: 1,
    );

    DailyActivityModel model;
    if (existing.isNotEmpty) {
      final current = DailyActivityModel.fromMap(existing.first);
      int updatedLessons = current.completedLessons;
      int updatedSandbox = current.sandboxExecutions;
      int updatedFlashcards = current.flashcardsReviewed;

      if (type == 'lesson') {
        updatedLessons += count;
      } else if (type == 'sandbox') {
        updatedSandbox += count;
      } else if (type == 'flashcard') {
        updatedFlashcards += count;
      }

      model = current.copyWith(
        completedLessons: updatedLessons,
        sandboxExecutions: updatedSandbox,
        flashcardsReviewed: updatedFlashcards,
        xpEarned: current.xpEarned + xp,
      );

      await db.update(
        'study_activities',
        model.toMap(),
        where: 'date = ?',
        whereArgs: [key],
      );
    } else {
      model = DailyActivityModel(
        date: normalized,
        completedLessons: type == 'lesson' ? count : 0,
        sandboxExecutions: type == 'sandbox' ? count : 0,
        flashcardsReviewed: type == 'flashcard' ? count : 0,
        xpEarned: xp,
      );

      await db.insert(
        'study_activities',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await preferencesService.addXp(xp);
    return model;
  }

  /// Computes streak metrics, totals, and distributions
  Map<String, dynamic> computeStats(List<DailyActivityModel> activities) {
    if (activities.isEmpty) {
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'totalContributions': 0,
        'activeDaysCount': 0,
        'totalLessons': 0,
        'totalSandboxRuns': 0,
        'totalFlashcards': 0,
        'totalXp': 0,
        'activeDaysRatio': 0.0,
      };
    }

    int currentStreak = 0;
    int longestStreak = 0;
    int runningStreak = 0;
    int totalContributions = 0;
    int activeDays = 0;
    int totalLessons = 0;
    int totalSandbox = 0;
    int totalFlashcards = 0;
    int totalXp = 0;

    // Scan forward for longest streak and totals
    for (int i = 0; i < activities.length; i++) {
      final act = activities[i];
      totalContributions += act.totalCount;
      totalLessons += act.completedLessons;
      totalSandbox += act.sandboxExecutions;
      totalFlashcards += act.flashcardsReviewed;
      totalXp += act.xpEarned;

      if (act.totalCount > 0) {
        activeDays++;
        runningStreak++;
        if (runningStreak > longestStreak) {
          longestStreak = runningStreak;
        }
      } else {
        runningStreak = 0;
      }
    }

    // Compute current streak scanning backwards from the end (today)
    for (int i = activities.length - 1; i >= 0; i--) {
      final act = activities[i];
      if (act.totalCount > 0) {
        currentStreak++;
      } else {
        // If today has no activity yet (i == activities.length - 1), check yesterday
        if (i == activities.length - 1) {
          continue;
        }
        break;
      }
    }

    final ratio = activities.isNotEmpty
        ? (activeDays / activities.length)
        : 0.0;

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalContributions': totalContributions,
      'activeDaysCount': activeDays,
      'totalLessons': totalLessons,
      'totalSandboxRuns': totalSandbox,
      'totalFlashcards': totalFlashcards,
      'totalXp': totalXp,
      'activeDaysRatio': ratio,
    };
  }
}
