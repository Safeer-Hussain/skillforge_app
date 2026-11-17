import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skill_forge_app/core/theme/app_theme.dart';
import 'package:skill_forge_app/data/models/daily_activity_model.dart';
import 'package:skill_forge_app/data/repositories/study_activity_repository.dart';
import 'package:skill_forge_app/presentation/heatmap/cubit/study_heatmap_cubit.dart';
import 'package:skill_forge_app/presentation/heatmap/views/study_heatmap_view.dart';

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
      if (index >= 350) {
        return DailyActivityModel(
          date: date,
          completedLessons: 2,
          sandboxExecutions: 3,
          flashcardsReviewed: 5,
          xpEarned: 350,
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
      'longestStreak': 30,
      'totalContributions': 540,
      'activeDaysCount': 120,
      'totalLessons': 100,
      'totalSandboxRuns': 190,
      'totalFlashcards': 250,
      'totalXp': 18500,
      'activeDaysRatio': 120 / 364,
    });
  });

  Widget createTestWidget({
    ThemeMode themeMode = ThemeMode.dark,
    required Widget child,
  }) {
    return BlocProvider<StudyHeatmapCubit>(
      create: (_) => StudyHeatmapCubit(repository: mockRepository),
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeMode,
        home: child,
      ),
    );
  }

  group('StudyHeatmapView Widget Tests (Sprint 2)', () {
    testWidgets('Renders all primary heatmap elements in portrait', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const StudyHeatmapView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Study Activity Heatmap'), findsOneWidget);
      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('Longest Streak'), findsOneWidget);
      expect(find.text('Contributions'), findsOneWidget);
      expect(find.text('Active Days'), findsOneWidget);

      expect(find.text('52-WEEK ACTIVITY CONTRIBUTION MATRIX'), findsOneWidget);
      expect(
        find.text('52-WEEK DOMAIN CONTRIBUTION BREAKDOWN'),
        findsOneWidget,
      );

      // Verify FAB with unique hero tag exists
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.heroTag, 'fab_heatmap_log_activity');

      // Verify no exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('Toggles filter choice chips seamlessly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const StudyHeatmapView()),
      );
      await tester.pumpAndSettle();

      // Find and tap "Lessons Completed" filter chip
      final lessonChip = find.text('Lessons Completed');
      expect(lessonChip, findsOneWidget);
      await tester.tap(lessonChip);
      await tester.pumpAndSettle();

      // Tap "Sandbox AST Runs"
      final sandboxChip = find.text('Sandbox AST Runs');
      expect(sandboxChip, findsOneWidget);
      await tester.tap(sandboxChip);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Opens modal bottom sheet to log session with form validation',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const StudyHeatmapView()),
        );
        await tester.pumpAndSettle();

        // Tap FAB
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.text('Log Study Session'), findsOneWidget);
        expect(find.text('Activity Category'), findsOneWidget);
        expect(find.text('Session Count'), findsOneWidget);
        expect(find.text('XP Reward Points'), findsOneWidget);
        expect(find.text('Commit Study Activity'), findsOneWidget);

        // Clear count field and submit to test validation
        final countField = find.widgetWithText(TextFormField, '1');
        await tester.enterText(countField, '');
        await tester.tap(find.text('Commit Study Activity'));
        await tester.pumpAndSettle();

        expect(find.text('Session count is required'), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Landscape 360dp height viewport safety test (800x360)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(child: const StudyHeatmapView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Study Activity Heatmap'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
