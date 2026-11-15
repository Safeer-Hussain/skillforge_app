import '../datasources/local_database.dart';
import '../datasources/preferences_service.dart';
import '../models/cohort_and_mentor_models.dart';

class CohortRepository {
  final AppDatabase database;
  final PreferencesService preferencesService;

  CohortRepository({required this.database, required this.preferencesService});

  Future<List<StudyRoomModel>> getStudyRooms() async {
    return await database.getStudyRooms();
  }

  Future<StudyRoomModel> toggleJoinRoom(StudyRoomModel room) async {
    final willJoin = !room.userJoined;
    final updated = room.copyWith(
      userJoined: willJoin,
      participantsCount: room.participantsCount + (willJoin ? 1 : -1),
    );
    await database.updateStudyRoom(updated);
    if (willJoin) {
      await preferencesService.addXp(20);
    }
    return updated;
  }

  Future<StudyRoomModel> hostRoom({
    required String title,
    required String topic,
    required int pomodoroMinutes,
  }) async {
    final room = StudyRoomModel(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      topic: topic,
      participantsCount: 1,
      pomodoroMinutes: pomodoroMinutes,
      isActive: true,
      hostName: 'Safeer Hussain',
      userJoined: true,
    );
    await database.insertStudyRoom(room);
    await preferencesService.addXp(50);
    return room;
  }

  Future<List<CodeReviewModel>> getCodeReviews() async {
    return await database.getCodeReviews();
  }

  Future<CodeReviewModel> toggleUpvoteReview(CodeReviewModel review) async {
    final willUpvote = !review.isUpvoted;
    final updated = review.copyWith(
      isUpvoted: willUpvote,
      upvotesCount: review.upvotesCount + (willUpvote ? 1 : -1),
    );
    await database.updateCodeReview(updated);
    if (willUpvote) {
      await preferencesService.addXp(10);
    }
    return updated;
  }

  Future<CodeReviewModel> postReviewQuestion({
    required String title,
    required String description,
    required String codeSnippet,
    required String tags,
  }) async {
    final review = CodeReviewModel(
      id: 'cr_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Safeer Hussain',
      authorRole: 'Principal Architect',
      title: title,
      codeSnippet: codeSnippet,
      description: description,
      upvotesCount: 1,
      isUpvoted: true,
      commentsCount: 0,
      createdAt: 'Just now',
      tags: tags,
    );
    await database.insertCodeReview(review);
    await preferencesService.addXp(40);
    return review;
  }

  Future<List<ReviewCommentModel>> getComments(String reviewId) async {
    return await database.getCommentsForReview(reviewId);
  }

  Future<ReviewCommentModel> addComment({
    required String reviewId,
    required String content,
  }) async {
    final comment = ReviewCommentModel(
      id: 'rc_${DateTime.now().millisecondsSinceEpoch}',
      reviewId: reviewId,
      authorName: 'Safeer Hussain',
      authorRole: 'Principal Architect',
      content: content,
      createdAt: 'Just now',
    );
    await database.insertComment(comment);
    await preferencesService.addXp(15);
    return comment;
  }

  Future<List<LeaderboardEntryModel>> getLeaderboard() async {
    return await database.getLeaderboard();
  }
}
