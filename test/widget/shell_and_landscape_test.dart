import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skill_forge_app/core/theme/app_theme.dart';
import 'package:skill_forge_app/core/theme/theme_cubit.dart';
import 'package:skill_forge_app/presentation/curriculum/bloc/curriculum_bloc.dart';
import 'package:skill_forge_app/presentation/sandbox/bloc/sandbox_bloc.dart';
import 'package:skill_forge_app/presentation/flashcards/cubit/flashcard_sm2_cubit.dart';
import 'package:skill_forge_app/presentation/cohort/cubit/cohort_cubit.dart';
import 'package:skill_forge_app/presentation/ai_mentor/cubit/ai_socratic_mentor_cubit.dart';
import 'package:skill_forge_app/presentation/shell/adaptive_scaffold.dart';
import 'package:skill_forge_app/presentation/analytics/views/mastery_analytics_view.dart';
import 'package:skill_forge_app/data/repositories/curriculum_repository.dart';
import 'package:skill_forge_app/data/repositories/sandbox_repository.dart';
import 'package:skill_forge_app/data/repositories/flashcard_repository.dart';
import 'package:skill_forge_app/data/repositories/cohort_repository.dart';
import 'package:skill_forge_app/data/repositories/mentor_repository.dart';
import 'package:skill_forge_app/data/datasources/preferences_service.dart';
import 'package:skill_forge_app/data/models/track_model.dart';
import 'package:skill_forge_app/data/models/challenge_model.dart';
import 'package:skill_forge_app/data/models/flashcard_model.dart';
import 'package:skill_forge_app/data/models/cohort_and_mentor_models.dart';
import 'package:skill_forge_app/core/platform/sandbox_platform_bridge.dart';
import 'package:skill_forge_app/injection.dart';

class MockCurriculumRepo extends Mock implements CurriculumRepository {}

class MockSandboxRepo extends Mock implements SandboxRepository {}

class MockFlashcardRepo extends Mock implements FlashcardRepository {}

class MockCohortRepo extends Mock implements CohortRepository {}

class MockMentorRepo extends Mock implements MentorRepository {}

class MockPreferencesService extends Mock implements PreferencesService {}

void main() {
  late MockCurriculumRepo mockCurriculum;
  late MockSandboxRepo mockSandbox;
  late MockFlashcardRepo mockFlashcards;
  late MockCohortRepo mockCohort;
  late MockMentorRepo mockMentor;
  late MockPreferencesService mockPrefs;
  late StreamController<FocusTelemetryPacket> telemetryStream;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({'skillforge_theme_mode': 'dark'});
  });

  setUp(() {
    mockCurriculum = MockCurriculumRepo();
    mockSandbox = MockSandboxRepo();
    mockFlashcards = MockFlashcardRepo();
    mockCohort = MockCohortRepo();
    mockMentor = MockMentorRepo();
    mockPrefs = MockPreferencesService();
    telemetryStream = StreamController<FocusTelemetryPacket>.broadcast();

    when(() => mockPrefs.userXp).thenReturn(1420);
    when(() => mockPrefs.streakDays).thenReturn(14);
    when(() => mockPrefs.simulatedLatencyEnabled).thenReturn(false);
    when(() => mockPrefs.forceHttp503Enabled).thenReturn(false);

    when(() => mockCurriculum.preferencesService).thenReturn(mockPrefs);
    when(() => mockCurriculum.getTracks()).thenAnswer(
      (_) async => [
        const TrackModel(
          id: 'track_1',
          title: 'Flutter Engine Pipeline',
          domain: 'Mobile Architecture',
          difficulty: 'Staff/Principal',
          description: 'RenderObjects & Impeller',
          iconPath: 'assets/images/track_flutter.png',
          isEnrolled: true,
          isBookmarked: false,
          progressPercent: 0.5,
          totalXp: 1800,
          lessonsCount: 4,
          completedLessonsCount: 2,
        ),
      ],
    );

    when(() => mockSandbox.preferencesService).thenReturn(mockPrefs);
    when(() => mockSandbox.telemetryStream)
        .thenAnswer((_) => telemetryStream.stream);
    when(() => mockSandbox.getChallenges()).thenAnswer(
      (_) async => [
        const ChallengeModel(
          id: 'ch_1',
          title: 'LRU Cache',
          difficulty: 'Senior',
          domain: 'Data Structures',
          description: 'Implement LRU Cache',
          starterCode: 'class LruCache {}',
          solutionCode: 'class LruCache {}',
          testCasesJson: '[]',
          cyclomaticTarget: 5,
          xpReward: 150,
        ),
      ],
    );

    when(() => mockFlashcards.preferencesService).thenReturn(mockPrefs);
    when(() => mockFlashcards.getFlashcards()).thenAnswer(
      (_) async => [
        const FlashcardModel(
          id: 'fc_1',
          trackId: 'track_1',
          topicTag: 'Engine',
          frontPrompt: 'What is markNeedsPaint()?',
          backAnswer: 'Repaints without layout',
          codeExample: '',
          repetitions: 1,
          easeFactor: 2.5,
          intervalDays: 1,
          lastReviewedAt: '',
          nextReviewAt: '',
          status: 'Learning',
        ),
      ],
    );

    when(() => mockCohort.preferencesService).thenReturn(mockPrefs);
    when(() => mockCohort.getStudyRooms()).thenAnswer(
      (_) async => [
        const StudyRoomModel(
          id: 'rm_1',
          title: 'Deep Focus Sprint',
          topic: 'Engine Internals',
          participantsCount: 4,
          pomodoroMinutes: 25,
          isActive: true,
          hostName: 'Lead Architect',
        ),
      ],
    );
    when(() => mockCohort.getCodeReviews()).thenAnswer((_) async => []);
    when(() => mockCohort.getLeaderboard()).thenAnswer((_) async => []);

    if (sl.isRegistered<PreferencesService>()) {
      sl.unregister<PreferencesService>();
    }
    sl.registerSingleton<PreferencesService>(mockPrefs);
  });

  tearDown(() {
    telemetryStream.close();
  });

  Widget createTestWidget({
    ThemeMode themeMode = ThemeMode.dark,
    required Widget child,
    required SharedPreferences prefs,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit(prefs: prefs)),
        BlocProvider<CurriculumBloc>(
          create: (_) => CurriculumBloc(repository: mockCurriculum),
        ),
        BlocProvider<SandboxBloc>(
          create: (_) => SandboxBloc(repository: mockSandbox),
        ),
        BlocProvider<FlashcardSm2Cubit>(
          create: (_) => FlashcardSm2Cubit(repository: mockFlashcards),
        ),
        BlocProvider<CohortCubit>(
          create: (_) => CohortCubit(repository: mockCohort),
        ),
        BlocProvider<AiSocraticMentorCubit>(
          create: (_) => AiSocraticMentorCubit(repository: mockMentor),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: mode,
            home: child,
          );
        },
      ),
    );
  }

  group('Shell & Landscape Widget Verification Tests', () {
    testWidgets('Zero duplicate Hero tags across the multi-tab shell', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        createTestWidget(prefs: prefs, child: const AdaptiveScaffold()),
      );
      await tester.pumpAndSettle();

      // Verify no duplicate Hero tag exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Zero RenderFlex overflow errors on an 800x360 landscape viewport',
      (tester) async {
        final prefs = await SharedPreferences.getInstance();

        // Set physical size to 800x360 landscape
        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          createTestWidget(prefs: prefs, child: const AdaptiveScaffold()),
        );
        await tester.pumpAndSettle();

        // Verify that NavigationRail renders and zero overflow errors occur
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Reset test physical size
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      },
    );

    testWidgets('Full-width chart rendering in MasteryAnalyticsView', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        createTestWidget(prefs: prefs, child: const MasteryAnalyticsView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('14-DAY XP VELOCITY & RETENTION CURVE'), findsOneWidget);
      expect(find.text('ARCHITECTURAL COMPETENCY MATRIX'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Instant Dark and Light theme switching parity', (
      tester,
    ) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        createTestWidget(prefs: prefs, child: const MasteryAnalyticsView()),
      );
      await tester.pumpAndSettle();

      // Find theme toggle button
      final toggleFinder = find.byTooltip(
        'Toggle Obsidian Dark / Crisp Light Mode',
      );
      expect(toggleFinder, findsOneWidget);

      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
