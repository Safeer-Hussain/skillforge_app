import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skill_forge_app/data/models/daily_activity_model.dart';
import 'package:skill_forge_app/data/repositories/study_activity_repository.dart';
import 'package:skill_forge_app/presentation/heatmap/cubit/study_heatmap_cubit.dart';
import 'package:skill_forge_app/presentation/heatmap/cubit/study_heatmap_state.dart';

class MockStudyActivityRepository extends Mock
    implements StudyActivityRepository {}

void main() {
  late MockStudyActivityRepository mockRepository;
  late List<DailyActivityModel> sampleActivities;

  setUp(() {
    mockRepository = MockStudyActivityRepository();

    final baseDate = DateTime(2026, 11, 17);
    sampleActivities = List.generate(364, (index) {
      final date = baseDate.subtract(Duration(days: 363 - index));
      // Make the last 14 days active with varied intensities
      if (index >= 350) {
        return DailyActivityModel(
          date: date,
          completedLessons: 2,
          sandboxExecutions: 3,
          flashcardsReviewed: 5,
          xpEarned: 350,
        );
      } else if (index % 3 == 0) {
        return DailyActivityModel(
          date: date,
          completedLessons: 1,
          sandboxExecutions: 1,
          flashcardsReviewed: 1,
          xpEarned: 185,
        );
      }
      return DailyActivityModel(date: date);
    });

    when(
      () => mockRepository.get52WeeksActivity(
        referenceDate: any(named: 'referenceDate'),
      ),
    ).thenAnswer((_) async => sampleActivities);

    when(() => mockRepository.computeStats(any())).thenReturn({
      'currentStreak': 14,
      'longestStreak': 25,
      'totalContributions': 680,
      'activeDaysCount': 130,
      'totalLessons': 150,
      'totalSandboxRuns': 230,
      'totalFlashcards': 300,
      'totalXp': 24500,
      'activeDaysRatio': 130 / 364,
    });
  });

  group('DailyActivityModel & Intensity Logic Tests', () {
    test('Calculates total count and intensity levels correctly', () {
      final day0 = DailyActivityModel(
        date: DateTime(2026, 1, 1),
        completedLessons: 0,
        sandboxExecutions: 0,
        flashcardsReviewed: 0,
      );
      expect(day0.totalCount, 0);
      expect(day0.intensityLevel, 0);

      final day1 = DailyActivityModel(
        date: DateTime(2026, 1, 2),
        completedLessons: 1,
        sandboxExecutions: 1,
      );
      expect(day1.totalCount, 2);
      expect(day1.intensityLevel, 1);

      final day2 = DailyActivityModel(
        date: DateTime(2026, 1, 3),
        completedLessons: 2,
        sandboxExecutions: 1,
        flashcardsReviewed: 1,
      );
      expect(day2.totalCount, 4);
      expect(day2.intensityLevel, 2);

      final day3 = DailyActivityModel(
        date: DateTime(2026, 1, 4),
        completedLessons: 3,
        sandboxExecutions: 3,
        flashcardsReviewed: 2,
      );
      expect(day3.totalCount, 8);
      expect(day3.intensityLevel, 3);

      final day4 = DailyActivityModel(
        date: DateTime(2026, 1, 5),
        completedLessons: 4,
        sandboxExecutions: 4,
        flashcardsReviewed: 4,
      );
      expect(day4.totalCount, 12);
      expect(day4.intensityLevel, 4);
    });

    test('Serializes toMap and fromMap with dateKey parsing', () {
      final original = DailyActivityModel(
        date: DateTime(2026, 5, 20),
        completedLessons: 3,
        sandboxExecutions: 2,
        flashcardsReviewed: 4,
        xpEarned: 400,
      );

      final map = original.toMap();
      expect(map['date'], '2026-05-20');
      expect(map['completedLessons'], 3);
      expect(map['sandboxExecutions'], 2);
      expect(map['flashcardsReviewed'], 4);
      expect(map['xpEarned'], 400);

      final restored = DailyActivityModel.fromMap(map);
      expect(restored.date.year, 2026);
      expect(restored.date.month, 5);
      expect(restored.date.day, 20);
      expect(restored.completedLessons, 3);
      expect(restored.totalCount, 9);
      expect(restored.intensityLevel, 3);
    });
  });

  group('StudyHeatmapCubit State Machine Tests', () {
    test('Loads 52-week activity matrix and sets initial state', () async {
      final cubit = StudyHeatmapCubit(repository: mockRepository);
      await Future.delayed(Duration.zero);

      expect(cubit.state.isLoading, false);
      expect(cubit.state.activities.length, 364);
      expect(cubit.state.currentStreak, 14);
      expect(cubit.state.longestStreak, 25);
      expect(cubit.state.totalContributions, 680);
      expect(cubit.state.selectedDay, isNotNull);
      expect(cubit.state.filter, ActivityFilter.all);

      await cubit.close();
    });

    test(
      'Toggles activity filters and returns filtered intensity levels',
      () async {
        final cubit = StudyHeatmapCubit(repository: mockRepository);
        await Future.delayed(Duration.zero);

        final testDay = DailyActivityModel(
          date: DateTime(2026, 11, 17),
          completedLessons: 1,
          sandboxExecutions: 4,
          flashcardsReviewed: 10,
          xpEarned: 500,
        );

        // All filter
        cubit.setFilter(ActivityFilter.all);
        expect(cubit.state.getFilteredCount(testDay), 15);
        expect(cubit.state.getFilteredIntensity(testDay), 4);

        // Lessons filter
        cubit.setFilter(ActivityFilter.lessons);
        expect(cubit.state.getFilteredCount(testDay), 1);
        expect(cubit.state.getFilteredIntensity(testDay), 1);

        // Sandbox filter
        cubit.setFilter(ActivityFilter.sandbox);
        expect(cubit.state.getFilteredCount(testDay), 4);
        expect(cubit.state.getFilteredIntensity(testDay), 2);

        // Flashcards filter
        cubit.setFilter(ActivityFilter.flashcards);
        expect(cubit.state.getFilteredCount(testDay), 10);
        expect(cubit.state.getFilteredIntensity(testDay), 4);

        await cubit.close();
      },
    );

    test('Selects and clears specific day in state', () async {
      final cubit = StudyHeatmapCubit(repository: mockRepository);
      await Future.delayed(Duration.zero);

      final specificDay = sampleActivities[100];
      cubit.selectDay(specificDay);
      expect(cubit.state.selectedDay?.dateKey, specificDay.dateKey);

      cubit.selectDay(null);
      expect(cubit.state.selectedDay, isNull);

      await cubit.close();
    });

    test('Logs activity session and updates list immutably', () async {
      final updatedToday = sampleActivities.last.copyWith(
        completedLessons: 4,
        xpEarned: 550,
      );

      when(() => mockRepository.logActivity(type: 'lesson', count: 2, xp: 200))
          .thenAnswer((_) async => updatedToday);

      final cubit = StudyHeatmapCubit(repository: mockRepository);
      await Future.delayed(Duration.zero);

      await cubit.logActivity(type: 'lesson', count: 2, xp: 200);

      expect(cubit.state.selectedDay?.dateKey, updatedToday.dateKey);
      expect(cubit.state.selectedDay?.completedLessons, 4);

      verify(
        () => mockRepository.logActivity(type: 'lesson', count: 2, xp: 200),
      ).called(1);

      await cubit.close();
    });
  });
}
