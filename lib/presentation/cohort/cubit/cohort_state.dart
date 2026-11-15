import '../../../data/models/cohort_and_mentor_models.dart';

enum CohortStatus { initial, loading, loaded, error }

class CohortState {
  final CohortStatus status;
  final List<StudyRoomModel> studyRooms;
  final List<CodeReviewModel> codeReviews;
  final List<LeaderboardEntryModel> leaderboard;
  final StudyRoomModel? activePomodoroRoom;
  final int pomodoroRemainingSeconds;
  final bool isPomodoroRunning;
  final String? errorMessage;
  final int totalUserXp;

  const CohortState({
    this.status = CohortStatus.initial,
    this.studyRooms = const [],
    this.codeReviews = const [],
    this.leaderboard = const [],
    this.activePomodoroRoom,
    this.pomodoroRemainingSeconds = 1500, // 25 min default
    this.isPomodoroRunning = false,
    this.errorMessage,
    this.totalUserXp = 1420,
  });

  CohortState copyWith({
    CohortStatus? status,
    List<StudyRoomModel>? studyRooms,
    List<CodeReviewModel>? codeReviews,
    List<LeaderboardEntryModel>? leaderboard,
    StudyRoomModel? activePomodoroRoom,
    int? pomodoroRemainingSeconds,
    bool? isPomodoroRunning,
    String? errorMessage,
    int? totalUserXp,
  }) {
    return CohortState(
      status: status ?? this.status,
      studyRooms: studyRooms ?? this.studyRooms,
      codeReviews: codeReviews ?? this.codeReviews,
      leaderboard: leaderboard ?? this.leaderboard,
      activePomodoroRoom: activePomodoroRoom ?? this.activePomodoroRoom,
      pomodoroRemainingSeconds:
          pomodoroRemainingSeconds ?? this.pomodoroRemainingSeconds,
      isPomodoroRunning: isPomodoroRunning ?? this.isPomodoroRunning,
      errorMessage: errorMessage ?? this.errorMessage,
      totalUserXp: totalUserXp ?? this.totalUserXp,
    );
  }
}
