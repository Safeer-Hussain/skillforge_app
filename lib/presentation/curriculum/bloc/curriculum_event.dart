import '../../../data/models/track_model.dart';
import '../../../data/models/lesson_model.dart';

abstract class CurriculumEvent {
  const CurriculumEvent();
}

class LoadCurriculumEvent extends CurriculumEvent {
  const LoadCurriculumEvent();
}

class FilterCurriculumEvent extends CurriculumEvent {
  final String? domain;
  final String? difficulty;
  final String? enrollmentStatus; // 'All', 'Enrolled', 'Bookmarked'
  final String? searchQuery;

  const FilterCurriculumEvent({
    this.domain,
    this.difficulty,
    this.enrollmentStatus,
    this.searchQuery,
  });
}

class ToggleEnrollTrackEvent extends CurriculumEvent {
  final TrackModel track;
  const ToggleEnrollTrackEvent(this.track);
}

class ToggleBookmarkTrackEvent extends CurriculumEvent {
  final TrackModel track;
  const ToggleBookmarkTrackEvent(this.track);
}

class SelectTrackEvent extends CurriculumEvent {
  final TrackModel track;
  const SelectTrackEvent(this.track);
}

class ToggleCompleteLessonEvent extends CurriculumEvent {
  final TrackModel track;
  final LessonModel lesson;
  const ToggleCompleteLessonEvent({required this.track, required this.lesson});
}
