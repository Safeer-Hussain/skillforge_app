import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skill_forge_app/presentation/sandbox/bloc/sandbox_bloc.dart';
import 'package:skill_forge_app/presentation/sandbox/bloc/sandbox_event.dart';
import 'package:skill_forge_app/presentation/sandbox/bloc/sandbox_state.dart';
import 'package:skill_forge_app/data/repositories/sandbox_repository.dart';
import 'package:skill_forge_app/data/datasources/preferences_service.dart';
import 'package:skill_forge_app/data/models/challenge_model.dart';
import 'package:skill_forge_app/core/platform/sandbox_platform_bridge.dart';

class MockSandboxRepository extends Mock implements SandboxRepository {}

class MockPreferencesService extends Mock implements PreferencesService {}

class FakeChallengeModel extends Fake implements ChallengeModel {}

void main() {
  late MockSandboxRepository mockRepo;
  late MockPreferencesService mockPrefs;
  late StreamController<FocusTelemetryPacket> telemetryController;
  late SandboxBloc bloc;

  final sampleChallenge = const ChallengeModel(
    id: 'challenge_test',
    title: 'Thread-Safe LRU Cache',
    difficulty: 'Senior',
    domain: 'Data Structures',
    description: 'Test LRU Cache challenge',
    starterCode: 'class LruCache {}',
    solutionCode: 'class LruCache { /* solution */ }',
    testCasesJson: '[]',
    cyclomaticTarget: 5,
    xpReward: 200,
    isCompleted: false,
  );

  setUpAll(() {
    registerFallbackValue(FakeChallengeModel());
  });

  setUp(() {
    mockRepo = MockSandboxRepository();
    mockPrefs = MockPreferencesService();
    telemetryController = StreamController<FocusTelemetryPacket>.broadcast();

    when(() => mockRepo.preferencesService).thenReturn(mockPrefs);
    when(() => mockPrefs.userXp).thenReturn(1420);
    when(() => mockPrefs.addXp(any())).thenAnswer((_) async {});
    when(() => mockRepo.telemetryStream)
        .thenAnswer((_) => telemetryController.stream);

    bloc = SandboxBloc(repository: mockRepo);
  });

  tearDown(() {
    telemetryController.close();
    bloc.close();
  });

  group('SandboxBloc Tests', () {
    test('Initial state is correct', () {
      expect(bloc.state.status, SandboxStatus.initial);
      expect(bloc.state.challenges, isEmpty);
    });

    test(
      'LoadChallengesEvent populates challenges and initial starter code',
      () async {
        when(() => mockRepo.getChallenges())
            .thenAnswer((_) async => [sampleChallenge]);

        final expectation = expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<SandboxState>((s) => s.status == SandboxStatus.loading),
            predicate<SandboxState>(
              (s) =>
                  s.status == SandboxStatus.ready &&
                  s.challenges.length == 1 &&
                  s.selectedChallenge?.id == 'challenge_test' &&
                  s.currentCode == 'class LruCache {}',
            ),
          ]),
        );

        bloc.add(const LoadChallengesEvent());
        await expectation;
      },
    );

    test('InsertSymbolEvent appends symbol to current code buffer', () async {
      when(() => mockRepo.getChallenges())
          .thenAnswer((_) async => [sampleChallenge]);
      bloc.add(const LoadChallengesEvent());
      await pumpEventQueue();

      bloc.add(const InsertSymbolEvent(' => '));
      await pumpEventQueue();

      expect(bloc.state.currentCode, 'class LruCache {} => ');
    });

    test('RunVerifyTestsEvent executes assertions, parses complexity, and updates XP', () async {
      when(() => mockRepo.getChallenges())
          .thenAnswer((_) async => [sampleChallenge]);
      when(
        () => mockRepo.runUnitTests(
          code: any(named: 'code'),
          challenge: any(named: 'challenge'),
        ),
      ).thenAnswer(
        (_) async => const TestSuiteResult(
          challengeId: 'challenge_test',
          success: true,
          totalCount: 4,
          passedCount: 4,
          assertions: [
            TestAssertionResult(
              name: 'Boundary Test',
              passed: true,
              latencyMs: 12,
            ),
            TestAssertionResult(
              name: 'Concurrency Test',
              passed: true,
              latencyMs: 14,
            ),
            TestAssertionResult(
              name: 'Eviction Order',
              passed: true,
              latencyMs: 18,
            ),
            TestAssertionResult(
              name: 'Zero Memory Leak',
              passed: true,
              latencyMs: 15,
            ),
          ],
          cyclomaticComplexity: 4,
          executionTimeMs: 25,
          heapMemoryMb: 14.5,
        ),
      );

      bloc.add(const LoadChallengesEvent());
      await pumpEventQueue();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<SandboxState>((s) => s.status == SandboxStatus.running),
          predicate<SandboxState>(
            (s) =>
                s.status == SandboxStatus.success &&
                s.testResult?.passedCount == 4 &&
                s.testResult?.cyclomaticComplexity == 4 &&
                s.selectedChallenge?.isCompleted == true,
          ),
        ]),
      );

      bloc.add(const RunVerifyTestsEvent());
      await expectation;
    });

    test('ExecuteSnippetEvent runs code snippet and updates console', () async {
      when(() => mockRepo.getChallenges())
          .thenAnswer((_) async => [sampleChallenge]);
      when(() => mockRepo.executeSnippet(any())).thenAnswer(
        (_) async => const SandboxExecutionResult(
          success: true,
          output: 'Snippet evaluated successfully',
          executionTimeMs: 20,
          heapMemoryMb: 14.2,
          cyclomaticComplexity: 2,
        ),
      );

      bloc.add(const LoadChallengesEvent());
      await pumpEventQueue();

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<SandboxState>((s) => s.status == SandboxStatus.running),
          predicate<SandboxState>(
            (s) =>
                s.status == SandboxStatus.ready &&
                s.executionResult?.output == 'Snippet evaluated successfully',
          ),
        ]),
      );

      bloc.add(const ExecuteSnippetEvent());
      await expectation;
    });
  });
}
