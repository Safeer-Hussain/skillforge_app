import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skill_forge_app/presentation/ai_mentor/cubit/ai_socratic_mentor_cubit.dart';
import 'package:skill_forge_app/data/repositories/mentor_repository.dart';

class MockMentorRepository extends Mock implements MentorRepository {}

void main() {
  late MockMentorRepository mockRepo;
  late AiSocraticMentorCubit cubit;

  setUp(() {
    mockRepo = MockMentorRepository();
    cubit = AiSocraticMentorCubit(repository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('AiSocraticMentorCubit Tests', () {
    test('Initial state contains welcome message and isStreaming is false', () {
      expect(cubit.state.messages, isNotEmpty);
      expect(cubit.state.isStreaming, false);
      expect(cubit.state.isAnalyzingTelemetry, false);
    });

    test('sendUserMessage streams tokens and guarantees isStreaming is false in finally', () async {
      when(() => mockRepo.gatherLearnerTelemetry()).thenAnswer(
        (_) async => {
          'xp': 1420,
          'streak': 14,
          'weakTopics': ['Concurrency'],
          'retentionRate': 0.88,
        },
      );

      when(() => mockRepo.generateSocraticStream(any(), any())).thenAnswer(
        (_) => Stream.fromIterable([
          'Let ',
          'us ',
          'inspect ',
          'first ',
          'principles.',
        ]),
      );

      final future = cubit.sendUserMessage('Review My Sandbox Solution');
      await future;

      // Upon completion, isStreaming must strictly be false
      expect(cubit.state.isStreaming, false);
      expect(cubit.state.isAnalyzingTelemetry, false);
      expect(cubit.state.messages.length, greaterThan(1));
      expect(cubit.state.messages.last.sender, 'mentor');
      expect(
        cubit.state.messages.last.content,
        'Let us inspect first principles.',
      );
    });

    test('sendUserMessage handles repository exceptions and still resets isStreaming in finally', () async {
      when(() => mockRepo.gatherLearnerTelemetry())
          .thenThrow(Exception('Simulated SQLite telemetry failure'));

      final future = cubit.sendUserMessage('Quiz Me');
      await future;

      // Even if exception was thrown, isStreaming MUST reset to false in finally block
      expect(cubit.state.isStreaming, false);
      expect(cubit.state.isAnalyzingTelemetry, false);
      expect(
        cubit.state.errorMessage,
        contains('Simulated SQLite telemetry failure'),
      );
    });

    test('clearConversation resets session to pristine greeting state', () {
      cubit.clearConversation();
      expect(cubit.state.messages.length, 1);
      expect(cubit.state.isStreaming, false);
      expect(cubit.state.isAnalyzingTelemetry, false);
    });
  });
}
