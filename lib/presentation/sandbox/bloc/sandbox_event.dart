import '../../../data/models/challenge_model.dart';

abstract class SandboxEvent {
  const SandboxEvent();
}

class LoadChallengesEvent extends SandboxEvent {
  const LoadChallengesEvent();
}

class SelectChallengeEvent extends SandboxEvent {
  final ChallengeModel challenge;
  const SelectChallengeEvent(this.challenge);
}

class UpdateCodeEvent extends SandboxEvent {
  final String code;
  const UpdateCodeEvent(this.code);
}

class InsertSymbolEvent extends SandboxEvent {
  final String symbol;
  const InsertSymbolEvent(this.symbol);
}

class ResetTemplateEvent extends SandboxEvent {
  const ResetTemplateEvent();
}

class RunVerifyTestsEvent extends SandboxEvent {
  const RunVerifyTestsEvent();
}

class ExecuteSnippetEvent extends SandboxEvent {
  const ExecuteSnippetEvent();
}

class TelemetryReceivedEvent extends SandboxEvent {
  final dynamic packet;
  const TelemetryReceivedEvent(this.packet);
}
