import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skill_forge_app/presentation/flashcards/cubit/flashcard_sm2_cubit.dart';
import 'package:skill_forge_app/presentation/flashcards/cubit/flashcard_sm2_state.dart';
import 'package:skill_forge_app/data/repositories/flashcard_repository.dart';
import 'package:skill_forge_app/data/datasources/preferences_service.dart';
import 'package:skill_forge_app/data/models/flashcard_model.dart';
import 'package:skill_forge_app/core/utils/sm2_algorithm.dart';

class MockFlashcardRepository extends Mock implements FlashcardRepository {}

class MockPreferencesService extends Mock implements PreferencesService {}

void main() {
  late MockFlashcardRepository mockRepo;
  late MockPreferencesService mockPrefs;
  late FlashcardSm2Cubit cubit;

  final sampleCard = const FlashcardModel(
    id: 'fc_test',
    trackId: 'track_flutter',
    topicTag: 'Flutter Engine',
    frontPrompt: 'What does markNeedsPaint() do?',
    backAnswer: 'Schedules repaint without layout pass',
    codeExample: 'void test() {}',
    repetitions: 1,
    easeFactor: 2.5,
    intervalDays: 1,
    lastReviewedAt: '',
    nextReviewAt: '',
    status: 'Learning',
  );

  setUp(() {
    mockRepo = MockFlashcardRepository();
    mockPrefs = MockPreferencesService();
    when(() => mockRepo.preferencesService).thenReturn(mockPrefs);
    when(() => mockPrefs.userXp).thenReturn(1420);
    when(() => mockPrefs.addXp(any())).thenAnswer((_) async {});
    cubit = FlashcardSm2Cubit(repository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('FlashcardSm2Cubit & Algorithm Tests', () {
    test('Sm2Algorithm accurately handles Again grade (reset)', () {
      final res = Sm2Algorithm.calculateNextReview(
        grade: Sm2Algorithm.gradeAgain,
        repetitions: 3,
        previousEaseFactor: 2.5,
        previousIntervalDays: 6,
      );

      expect(res.repetitions, 0);
      expect(res.intervalDays, 1);
      expect(res.easeFactor, lessThan(2.5));
      expect(res.easeFactor, greaterThanOrEqualTo(1.3));
    });

    test('Sm2Algorithm accurately scales Good and Easy intervals', () {
      final goodRes = Sm2Algorithm.calculateNextReview(
        grade: Sm2Algorithm.gradeGood,
        repetitions: 1,
        previousEaseFactor: 2.5,
        previousIntervalDays: 1,
      );

      expect(goodRes.repetitions, 2);
      expect(goodRes.intervalDays, 6);

      final easyRes = Sm2Algorithm.calculateNextReview(
        grade: Sm2Algorithm.gradeEasy,
        repetitions: 2,
        previousEaseFactor: 2.5,
        previousIntervalDays: 6,
      );

      expect(easyRes.repetitions, 3);
      expect(easyRes.intervalDays, (6 * 2.6).round());
      expect(easyRes.easeFactor, 2.6);
    });

    test('flipCard toggles isFlipped state', () {
      expect(cubit.state.isFlipped, false);
      cubit.flipCard();
      expect(cubit.state.isFlipped, true);
      cubit.flipCard();
      expect(cubit.state.isFlipped, false);
    });

    test('rateCurrentCard updates card and advances deck index', () async {
      when(() => mockRepo.getFlashcards())
          .thenAnswer((_) async => [sampleCard]);
      when(
        () =>
            mockRepo.rateCard(card: sampleCard, grade: Sm2Algorithm.gradeGood),
      ).thenAnswer(
        (_) async => sampleCard.copyWith(repetitions: 2, intervalDays: 6),
      );

      await cubit.loadDeck();
      await cubit.rateCurrentCard(Sm2Algorithm.gradeGood);

      expect(cubit.state.reviewedCount, 1);
      expect(cubit.state.status, FlashcardDeckStatus.completed);
    });

    test(
      'createCustomCard validates non-empty fields and persists card',
      () async {
        final emptyResult = await cubit.createCustomCard(
          topicTag: '',
          frontPrompt: '',
          backAnswer: '',
          codeExample: '',
        );
        expect(emptyResult, false);

        when(
          () => mockRepo.createCard(
            topicTag: any(named: 'topicTag'),
            frontPrompt: any(named: 'frontPrompt'),
            backAnswer: any(named: 'backAnswer'),
            codeExample: any(named: 'codeExample'),
          ),
        ).thenAnswer((_) async => sampleCard);

        final validResult = await cubit.createCustomCard(
          topicTag: 'Flutter Engine',
          frontPrompt: 'Valid Prompt',
          backAnswer: 'Valid Answer',
          codeExample: 'Valid Code',
        );
        expect(validResult, true);
        expect(cubit.state.deck.length, 1);
      },
    );

    test(
      'Mock Certification Exam records answers and computes certificate hash',
      () {
        cubit.startExam();
        expect(cubit.state.examState.isExamActive, true);

        // Select answers for all 5 questions
        for (int i = 0; i < FlashcardSm2Cubit.sampleExamQuestions.length; i++) {
          final correctIdx =
              FlashcardSm2Cubit.sampleExamQuestions[i].correctOptionIndex;
          cubit.selectExamAnswer(i, correctIdx);
        }

        cubit.submitExam();

        expect(cubit.state.examState.isExamActive, false);
        expect(cubit.state.examState.isSubmitted, true);
        expect(cubit.state.examState.score, 5);
        expect(cubit.state.examState.isPassed, true);
        expect(
          cubit.state.examState.certificateHash,
          startsWith('SKILLFORGE-CERT-'),
        );
      },
    );
  });
}
