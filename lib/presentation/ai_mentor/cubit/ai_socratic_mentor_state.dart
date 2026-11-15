import '../../../data/models/cohort_and_mentor_models.dart';

class AiSocraticMentorState {
  final List<MentorMessageModel> messages;
  final bool isStreaming;
  final bool isAnalyzingTelemetry;
  final Map<String, dynamic> telemetry;
  final String? errorMessage;

  const AiSocraticMentorState({
    this.messages = const [],
    this.isStreaming = false,
    this.isAnalyzingTelemetry = false,
    this.telemetry = const {},
    this.errorMessage,
  });

  AiSocraticMentorState copyWith({
    List<MentorMessageModel>? messages,
    bool? isStreaming,
    bool? isAnalyzingTelemetry,
    Map<String, dynamic>? telemetry,
    String? errorMessage,
  }) {
    return AiSocraticMentorState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      isAnalyzingTelemetry: isAnalyzingTelemetry ?? this.isAnalyzingTelemetry,
      telemetry: telemetry ?? this.telemetry,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
