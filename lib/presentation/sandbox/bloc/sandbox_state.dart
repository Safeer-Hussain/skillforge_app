import '../../../data/models/challenge_model.dart';
import '../../../core/platform/sandbox_platform_bridge.dart';

enum SandboxStatus { initial, loading, ready, running, success, failed }

class SandboxState {
  final SandboxStatus status;
  final List<ChallengeModel> challenges;
  final ChallengeModel? selectedChallenge;
  final String currentCode;
  final TestSuiteResult? testResult;
  final SandboxExecutionResult? executionResult;
  final FocusTelemetryPacket? telemetry;
  final String consoleOutput;
  final String? errorMessage;
  final int totalUserXp;

  const SandboxState({
    this.status = SandboxStatus.initial,
    this.challenges = const [],
    this.selectedChallenge,
    this.currentCode = '',
    this.testResult,
    this.executionResult,
    this.telemetry,
    this.consoleOutput = 'SkillForge AST Sandbox ready. Select a challenge or write Dart code to verify.',
    this.errorMessage,
    this.totalUserXp = 1420,
  });

  SandboxState copyWith({
    SandboxStatus? status,
    List<ChallengeModel>? challenges,
    ChallengeModel? selectedChallenge,
    String? currentCode,
    TestSuiteResult? testResult,
    SandboxExecutionResult? executionResult,
    FocusTelemetryPacket? telemetry,
    String? consoleOutput,
    String? errorMessage,
    int? totalUserXp,
  }) {
    return SandboxState(
      status: status ?? this.status,
      challenges: challenges ?? this.challenges,
      selectedChallenge: selectedChallenge ?? this.selectedChallenge,
      currentCode: currentCode ?? this.currentCode,
      testResult: testResult ?? this.testResult,
      executionResult: executionResult ?? this.executionResult,
      telemetry: telemetry ?? this.telemetry,
      consoleOutput: consoleOutput ?? this.consoleOutput,
      errorMessage: errorMessage ?? this.errorMessage,
      totalUserXp: totalUserXp ?? this.totalUserXp,
    );
  }
}
