import '../datasources/local_database.dart';
import '../datasources/preferences_service.dart';
import '../models/challenge_model.dart';
import '../../core/platform/sandbox_platform_bridge.dart';

class SandboxRepository {
  final AppDatabase database;
  final PreferencesService preferencesService;
  final SandboxPlatformBridge platformBridge;

  SandboxRepository({
    required this.database,
    required this.preferencesService,
    required this.platformBridge,
  });

  Future<List<ChallengeModel>> getChallenges() async {
    return await database.getAllChallenges();
  }

  Future<SandboxExecutionResult> executeSnippet(String code) async {
    return await platformBridge.executeSnippet(code);
  }

  Future<TestSuiteResult> runUnitTests({
    required String code,
    required ChallengeModel challenge,
  }) async {
    final result = await platformBridge.runUnitTests(
      code: code,
      challengeId: challenge.id,
    );

    if (result.success && !challenge.isCompleted) {
      final updatedChallenge = challenge.copyWith(isCompleted: true);
      await database.updateChallenge(updatedChallenge);
      await preferencesService.addXp(challenge.xpReward);
    }

    return result;
  }

  Stream<FocusTelemetryPacket> get telemetryStream =>
      platformBridge.focusTelemetryStream;
}
