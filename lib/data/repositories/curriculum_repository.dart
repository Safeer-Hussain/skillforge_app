import '../datasources/local_database.dart';
import '../datasources/preferences_service.dart';
import '../models/track_model.dart';
import '../models/lesson_model.dart';

class CurriculumRepository {
  final AppDatabase database;
  final PreferencesService preferencesService;

  CurriculumRepository({
    required this.database,
    required this.preferencesService,
  });

  Future<List<TrackModel>> getTracks() async {
    return await database.getAllTracks();
  }

  Future<List<LessonModel>> getLessons(String trackId) async {
    return await database.getLessonsForTrack(trackId);
  }

  Future<TrackModel> toggleEnrollment(TrackModel track) async {
    final updated = track.copyWith(isEnrolled: !track.isEnrolled);
    await database.updateTrack(updated);
    return updated;
  }

  Future<TrackModel> toggleBookmark(TrackModel track) async {
    final updated = track.copyWith(isBookmarked: !track.isBookmarked);
    await database.updateTrack(updated);
    return updated;
  }

  Future<Map<String, dynamic>> completeLesson({
    required TrackModel track,
    required LessonModel lesson,
  }) async {
    final updatedLesson = lesson.copyWith(isCompleted: !lesson.isCompleted);
    await database.updateLesson(updatedLesson);

    final allLessons = await database.getLessonsForTrack(track.id);
    final completedCount = allLessons.where((l) => l.isCompleted).length;
    final totalCount = allLessons.isEmpty ? 1 : allLessons.length;
    final progress = completedCount / totalCount;

    final updatedTrack = track.copyWith(
      progressPercent: double.parse(progress.toStringAsFixed(2)),
      completedLessonsCount: completedCount,
    );
    await database.updateTrack(updatedTrack);

    if (updatedLesson.isCompleted) {
      await preferencesService.addXp(lesson.xpReward);
    }

    return {
      'track': updatedTrack,
      'lesson': updatedLesson,
      'lessons': allLessons,
      'awardedXp': updatedLesson.isCompleted ? lesson.xpReward : 0,
    };
  }
}
