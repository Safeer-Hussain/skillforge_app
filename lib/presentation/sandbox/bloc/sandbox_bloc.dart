import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'sandbox_event.dart';
import 'sandbox_state.dart';
import '../../../data/repositories/sandbox_repository.dart';
import '../../../core/platform/sandbox_platform_bridge.dart';

class SandboxBloc extends Bloc<SandboxEvent, SandboxState> {
  final SandboxRepository repository;
  StreamSubscription<FocusTelemetryPacket>? _telemetrySubscription;

  SandboxBloc({required this.repository}) : super(const SandboxState()) {
    on<LoadChallengesEvent>(_onLoadChallenges);
    on<SelectChallengeEvent>(_onSelectChallenge);
    on<UpdateCodeEvent>(_onUpdateCode);
    on<InsertSymbolEvent>(_onInsertSymbol);
    on<ResetTemplateEvent>(_onResetTemplate);
    on<RunVerifyTestsEvent>(_onRunVerifyTests);
    on<ExecuteSnippetEvent>(_onExecuteSnippet);
    on<TelemetryReceivedEvent>(_onTelemetryReceived);

    _listenToTelemetry();
  }

  void _listenToTelemetry() {
    _telemetrySubscription?.cancel();
    _telemetrySubscription = repository.telemetryStream.listen((packet) {
      if (!isClosed) {
        add(TelemetryReceivedEvent(packet));
      }
    });
  }

  void _onTelemetryReceived(
    TelemetryReceivedEvent event,
    Emitter<SandboxState> emit,
  ) {
    if (event.packet is FocusTelemetryPacket) {
      emit(state.copyWith(telemetry: event.packet as FocusTelemetryPacket));
    }
  }

  Future<void> _onLoadChallenges(
    LoadChallengesEvent event,
    Emitter<SandboxState> emit,
  ) async {
    emit(state.copyWith(status: SandboxStatus.loading));
    try {
      final challenges = await repository.getChallenges();
      final initialChallenge = challenges.isNotEmpty ? challenges.first : null;
      emit(
        state.copyWith(
          status: SandboxStatus.ready,
          challenges: challenges,
          selectedChallenge: initialChallenge,
          currentCode: initialChallenge?.starterCode ?? '',
          totalUserXp: repository.preferencesService.userXp,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SandboxStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSelectChallenge(
    SelectChallengeEvent event,
    Emitter<SandboxState> emit,
  ) {
    emit(
      state.copyWith(
        selectedChallenge: event.challenge,
        currentCode: event.challenge.starterCode,
        testResult: null,
        consoleOutput:
            'Selected challenge: ${event.challenge.title}\nComplexity target: <= ${event.challenge.cyclomaticTarget}\nPress "Run & Verify Tests" to execute.',
      ),
    );
  }

  void _onUpdateCode(UpdateCodeEvent event, Emitter<SandboxState> emit) {
    emit(state.copyWith(currentCode: event.code));
  }

  void _onInsertSymbol(InsertSymbolEvent event, Emitter<SandboxState> emit) {
    emit(state.copyWith(currentCode: '${state.currentCode}${event.symbol}'));
  }

  void _onResetTemplate(ResetTemplateEvent event, Emitter<SandboxState> emit) {
    if (state.selectedChallenge != null) {
      emit(
        state.copyWith(
          currentCode: state.selectedChallenge!.starterCode,
          consoleOutput: 'Template reset to original starter scaffold.',
          testResult: null,
        ),
      );
    }
  }

  Future<void> _onRunVerifyTests(
    RunVerifyTestsEvent event,
    Emitter<SandboxState> emit,
  ) async {
    final challenge = state.selectedChallenge;
    if (challenge == null) return;

    emit(
      state.copyWith(
        status: SandboxStatus.running,
        consoleOutput: 'Compiling AST & executing unit assertions via Sandbox Runtime Bridge...',
      ),
    );

    try {
      final result = await repository.runUnitTests(
        code: state.currentCode,
        challenge: challenge,
      );

      final passedCount = result.passedCount;
      final totalCount = result.totalCount;
      final statusString = result.success
          ? 'ALL TESTS PASSED'
          : 'SOME TESTS FAILED';

      final outputBuffer = StringBuffer();
      outputBuffer.writeln('=== $statusString ($passedCount/$totalCount) ===');
      outputBuffer.writeln('Execution Latency: ${result.executionTimeMs} ms');
      outputBuffer.writeln('Memory Footprint: ${result.heapMemoryMb} MB');
      outputBuffer.writeln(
        'Cyclomatic Complexity: ${result.cyclomaticComplexity}',
      );
      outputBuffer.writeln(
        'Target Invariant: <= ${challenge.cyclomaticTarget}',
      );
      outputBuffer.writeln('');
      for (final a in result.assertions) {
        final icon = a.passed ? '[PASS]' : '[FAIL]';
        outputBuffer.writeln('$icon ${a.name} (${a.latencyMs} ms)');
      }

      if (result.success) {
        outputBuffer.writeln(
          '\nAwarded +${challenge.xpReward} XP for architectural mastery.',
        );
      }

      final updatedChallenges = state.challenges.map((c) {
        if (c.id == challenge.id && result.success) {
          return c.copyWith(isCompleted: true);
        }
        return c;
      }).toList();

      emit(
        state.copyWith(
          status: result.success ? SandboxStatus.success : SandboxStatus.failed,
          testResult: result,
          challenges: updatedChallenges,
          selectedChallenge: result.success
              ? challenge.copyWith(isCompleted: true)
              : challenge,
          consoleOutput: outputBuffer.toString(),
          totalUserXp: repository.preferencesService.userXp,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SandboxStatus.failed,
          errorMessage: e.toString(),
          consoleOutput: 'Error executing test suite: $e',
        ),
      );
    }
  }

  Future<void> _onExecuteSnippet(
    ExecuteSnippetEvent event,
    Emitter<SandboxState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SandboxStatus.running,
        consoleOutput: 'Running snippet in native isolate...',
      ),
    );

    try {
      final res = await repository.executeSnippet(state.currentCode);
      emit(
        state.copyWith(
          status: SandboxStatus.ready,
          executionResult: res,
          consoleOutput:
              '=== ISOLATE OUTPUT ===\n${res.output}\n\nExecution Time: ${res.executionTimeMs} ms | Heap: ${res.heapMemoryMb} MB | Cyclomatic: ${res.cyclomaticComplexity}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SandboxStatus.failed,
          errorMessage: e.toString(),
          consoleOutput: 'Execution error: $e',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _telemetrySubscription?.cancel();
    return super.close();
  }
}
