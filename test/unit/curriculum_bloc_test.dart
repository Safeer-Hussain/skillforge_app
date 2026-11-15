import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skill_forge_app/presentation/curriculum/bloc/curriculum_bloc.dart';
import 'package:skill_forge_app/presentation/curriculum/bloc/curriculum_event.dart';
import 'package:skill_forge_app/presentation/curriculum/bloc/curriculum_state.dart';
import 'package:skill_forge_app/data/repositories/curriculum_repository.dart';
import 'package:skill_forge_app/data/datasources/preferences_service.dart';
import 'package:skill_forge_app/data/models/track_model.dart';
import 'package:skill_forge_app/data/models/lesson_model.dart';

class MockCurriculumRepository extends Mock implements CurriculumRepository {}

class MockPreferencesService extends Mock implements PreferencesService {}

void main() {
  late MockCurriculumRepository mockRepo;
  late MockPreferencesService mockPrefs;
  late CurriculumBloc bloc;

  final sampleTrack = const TrackModel(
    id: 'track_test',
    title: 'Flutter Engine Internals',
    domain: 'Mobile Architecture',
    difficulty: 'Senior',
    description: 'Test track description',
    iconPath: 'assets/images/track_flutter.png',
    isEnrolled: false,
    isBookmarked: false,
    progressPercent: 0.0,
    totalXp: 1200,
    lessonsCount: 4,
    completedLessonsCount: 0,
  );

  final sampleLesson = const LessonModel(
    id: 'lesson_test',
    trackId: 'track_test',
    title: 'PipelineOwner Flush',
    moduleTitle: 'Module 1',
    durationMinutes: 15,
    timeComplexity: 'O(1)',
    spaceComplexity: 'O(1)',
    contentNotes: 'Notes',
    codeSnippet: 'void test() {}',
    isCompleted: false,
    xpReward: 100,
    relatedChallengeId: 'challenge_1',
  );

  setUp(() {
    mockRepo = MockCurriculumRepository();
    mockPrefs = MockPreferencesService();
    when(() => mockRepo.preferencesService).thenReturn(mockPrefs);
    when(() => mockPrefs.userXp).thenReturn(1420);
    bloc = CurriculumBloc(repository: mockRepo);
  });

  tearDown(() {
    bloc.close();
  });

  group('CurriculumBloc Tests', () {
    test('Initial state is correct', () {
      expect(bloc.state.status, CurriculumStatus.initial);
      expect(bloc.state.allTracks, isEmpty);
    });

    test(
      'LoadCurriculumEvent loads tracks and applies default filters',
      () async {
        when(() => mockRepo.getTracks()).thenAnswer((_) async => [sampleTrack]);

        bloc.add(const LoadCurriculumEvent());

        await expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<CurriculumState>(
              (s) => s.status == CurriculumStatus.loading,
            ),
            predicate<CurriculumState>(
              (s) =>
                  s.status == CurriculumStatus.loaded &&
                  s.allTracks.length == 1 &&
                  s.filteredTracks.length == 1,
            ),
          ]),
        );
      },
    );

    test('ToggleEnrollTrackEvent updates track enrollment', () async {
      final enrolledTrack = sampleTrack.copyWith(isEnrolled: true);
      when(() => mockRepo.getTracks()).thenAnswer((_) async => [sampleTrack]);
      when(() => mockRepo.toggleEnrollment(sampleTrack))
          .thenAnswer((_) async => enrolledTrack);

      bloc.add(const LoadCurriculumEvent());
      await pumpEventQueue();

      bloc.add(ToggleEnrollTrackEvent(sampleTrack));

      await expectLater(
        bloc.stream,
        emits(
          predicate<CurriculumState>(
            (s) =>
                s.allTracks.first.isEnrolled == true &&
                s.filteredTracks.first.isEnrolled == true,
          ),
        ),
      );
    });

    test(
      'ToggleCompleteLessonEvent calculates progress and awards XP',
      () async {
        final completedLesson = sampleLesson.copyWith(isCompleted: true);
        final updatedTrack = sampleTrack.copyWith(
          completedLessonsCount: 1,
          progressPercent: 0.25,
        );

        when(() => mockRepo.getTracks()).thenAnswer((_) async => [sampleTrack]);
        when(
          () =>
              mockRepo.completeLesson(track: sampleTrack, lesson: sampleLesson),
        ).thenAnswer(
          (_) async => {
            'track': updatedTrack,
            'lesson': completedLesson,
            'awardedXp': 100,
          },
        );
        when(() => mockRepo.getLessons(sampleTrack.id))
            .thenAnswer((_) async => [completedLesson]);
        when(() => mockPrefs.userXp).thenReturn(1520);

        bloc.add(const LoadCurriculumEvent());
        await pumpEventQueue();

        bloc.add(
          ToggleCompleteLessonEvent(track: sampleTrack, lesson: sampleLesson),
        );

        await expectLater(
          bloc.stream,
          emits(
            predicate<CurriculumState>(
              (s) =>
                  s.selectedTrack?.completedLessonsCount == 1 &&
                  s.selectedTrack?.progressPercent == 0.25 &&
                  s.totalUserXp == 1520,
            ),
          ),
        );
      },
    );

    test(
      'FilterCurriculumEvent filters tracks by domain and difficulty',
      () async {
        final aiTrack = sampleTrack.copyWith(
          id: 'track_ai',
          title: 'Production RAG',
          domain: 'AI Engineering',
          difficulty: 'Associate',
        );

        when(() => mockRepo.getTracks())
            .thenAnswer((_) async => [sampleTrack, aiTrack]);
        bloc.add(const LoadCurriculumEvent());
        await pumpEventQueue();

        bloc.add(const FilterCurriculumEvent(domain: 'AI Engineering'));
        await pumpEventQueue();

        expect(bloc.state.filteredTracks.length, 1);
        expect(bloc.state.filteredTracks.first.domain, 'AI Engineering');
      },
    );
  });
}
