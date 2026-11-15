import 'package:flutter_bloc/flutter_bloc.dart';

import 'ai_socratic_mentor_state.dart';
import '../../../data/repositories/mentor_repository.dart';
import '../../../data/models/cohort_and_mentor_models.dart';

class AiSocraticMentorCubit extends Cubit<AiSocraticMentorState> {
  final MentorRepository repository;

  AiSocraticMentorCubit({required this.repository})
    : super(
        AiSocraticMentorState(
          messages: [
            MentorMessageModel(
              id: 'welcome',
              sender: 'mentor',
              content:
                  'Greetings. I am your SkillForge Socratic Engineering Mentor.\n\n'
                  'I continuously observe your local SQLite curriculum graph, code sandbox AST diagnostics, and SM-2 flashcard recall latency to guide your journey to Principal Architect.\n\n'
                  'Select a prompt shortcut below or paste an architecture dilemma to begin.',
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );

  Future<void> sendUserMessage(String prompt) async {
    if (prompt.trim().isEmpty || state.isStreaming) return;

    final userMsg = MentorMessageModel(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      content: prompt.trim(),
      timestamp: DateTime.now(),
    );

    final updatedWithUser = List<MentorMessageModel>.from(state.messages)
      ..add(userMsg);
    emit(
      state.copyWith(
        messages: updatedWithUser,
        isStreaming: true,
        isAnalyzingTelemetry: true,
      ),
    );

    try {
      final telemetry = await repository.gatherLearnerTelemetry();
      emit(state.copyWith(telemetry: telemetry, isAnalyzingTelemetry: false));

      final mentorMsgId = 'msg_mentor_${DateTime.now().millisecondsSinceEpoch}';
      var mentorMsg = MentorMessageModel(
        id: mentorMsgId,
        sender: 'mentor',
        content: '',
        timestamp: DateTime.now(),
        isStreaming: true,
      );

      final currentMsgs = List<MentorMessageModel>.from(state.messages)
        ..add(mentorMsg);
      emit(state.copyWith(messages: currentMsgs));

      final buffer = StringBuffer();
      await for (final token in repository.generateSocraticStream(
        prompt,
        telemetry,
      )) {
        buffer.write(token);
        mentorMsg = mentorMsg.copyWith(content: buffer.toString());

        final streamedList = state.messages
            .map((m) => m.id == mentorMsgId ? mentorMsg : m)
            .toList();
        emit(state.copyWith(messages: streamedList));
      }

      // Mark message streaming complete
      final finalizedList = state.messages.map((m) {
        if (m.id == mentorMsgId) {
          return m.copyWith(isStreaming: false);
        }
        return m;
      }).toList();

      emit(state.copyWith(messages: finalizedList));
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), isAnalyzingTelemetry: false),
      );
    } finally {
      // Guaranteed stream cleanup: isStreaming must strictly reset to false
      emit(state.copyWith(isStreaming: false, isAnalyzingTelemetry: false));
    }
  }

  void clearConversation() {
    emit(
      AiSocraticMentorState(
        messages: [
          MentorMessageModel(
            id: 'welcome_reset',
            sender: 'mentor',
            content: 'Session reset. Socratic workspace initialized for fresh architectural inquiry.',
            timestamp: DateTime.now(),
          ),
        ],
        isStreaming: false,
        isAnalyzingTelemetry: false,
        telemetry: state.telemetry,
      ),
    );
  }
}
