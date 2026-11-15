import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'cohort_state.dart';
import '../../../data/repositories/cohort_repository.dart';
import '../../../data/models/cohort_and_mentor_models.dart';

class CohortCubit extends Cubit<CohortState> {
  final CohortRepository repository;
  Timer? _pomodoroTimer;

  CohortCubit({required this.repository}) : super(const CohortState());

  Future<void> loadCohortData() async {
    emit(state.copyWith(status: CohortStatus.loading));
    try {
      final rooms = await repository.getStudyRooms();
      final reviews = await repository.getCodeReviews();
      final leaderboard = await repository.getLeaderboard();

      emit(
        state.copyWith(
          status: CohortStatus.loaded,
          studyRooms: rooms,
          codeReviews: reviews,
          leaderboard: leaderboard,
          totalUserXp: repository.preferencesService.userXp,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CohortStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> toggleJoinRoom(StudyRoomModel room) async {
    final updated = await repository.toggleJoinRoom(room);
    final allRooms = state.studyRooms
        .map((r) => r.id == updated.id ? updated : r)
        .toList();

    if (updated.userJoined) {
      // Start Pomodoro timer for this room
      startPomodoro(updated);
    } else if (state.activePomodoroRoom?.id == updated.id) {
      stopPomodoro();
    }

    emit(
      state.copyWith(
        studyRooms: allRooms,
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
  }

  void startPomodoro(StudyRoomModel room) {
    _pomodoroTimer?.cancel();
    emit(
      state.copyWith(
        activePomodoroRoom: room,
        pomodoroRemainingSeconds: room.pomodoroMinutes * 60,
        isPomodoroRunning: true,
      ),
    );

    _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.pomodoroRemainingSeconds <= 1) {
        timer.cancel();
        emit(
          state.copyWith(isPomodoroRunning: false, pomodoroRemainingSeconds: 0),
        );
      } else {
        emit(
          state.copyWith(
            pomodoroRemainingSeconds: state.pomodoroRemainingSeconds - 1,
          ),
        );
      }
    });
  }

  void stopPomodoro() {
    _pomodoroTimer?.cancel();
    _pomodoroTimer = null;
    emit(state.copyWith(isPomodoroRunning: false, activePomodoroRoom: null));
  }

  Future<bool> hostNewRoom({
    required String title,
    required String topic,
    required int pomodoroMinutes,
  }) async {
    if (title.trim().isEmpty || topic.trim().isEmpty) return false;

    final room = await repository.hostRoom(
      title: title.trim(),
      topic: topic.trim(),
      pomodoroMinutes: pomodoroMinutes,
    );

    final all = List<StudyRoomModel>.from(state.studyRooms)..insert(0, room);
    startPomodoro(room);

    emit(
      state.copyWith(
        studyRooms: all,
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
    return true;
  }

  Future<void> toggleUpvoteReview(CodeReviewModel review) async {
    final updated = await repository.toggleUpvoteReview(review);
    final all = state.codeReviews
        .map((r) => r.id == updated.id ? updated : r)
        .toList();

    emit(
      state.copyWith(
        codeReviews: all,
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
  }

  Future<bool> postArchitectureQuestion({
    required String title,
    required String description,
    required String codeSnippet,
    required String tags,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) return false;

    final review = await repository.postReviewQuestion(
      title: title.trim(),
      description: description.trim(),
      codeSnippet: codeSnippet.trim().isEmpty
          ? '// No snippet provided'
          : codeSnippet.trim(),
      tags: tags.trim().isEmpty ? 'Architecture' : tags.trim(),
    );

    final all = List<CodeReviewModel>.from(state.codeReviews)
      ..insert(0, review);
    emit(
      state.copyWith(
        codeReviews: all,
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
    return true;
  }

  Future<List<ReviewCommentModel>> loadComments(String reviewId) async {
    return await repository.getComments(reviewId);
  }

  Future<void> addComment({
    required String reviewId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;
    await repository.addComment(reviewId: reviewId, content: content.trim());

    final updatedReviews = state.codeReviews.map((r) {
      if (r.id == reviewId) {
        return r.copyWith(commentsCount: r.commentsCount + 1);
      }
      return r;
    }).toList();

    emit(
      state.copyWith(
        codeReviews: updatedReviews,
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
  }

  @override
  Future<void> close() {
    _pomodoroTimer?.cancel();
    return super.close();
  }
}
