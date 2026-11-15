import 'package:flutter_bloc/flutter_bloc.dart';

import 'curriculum_event.dart';
import 'curriculum_state.dart';
import '../../../data/repositories/curriculum_repository.dart';
import '../../../data/models/track_model.dart';

class CurriculumBloc extends Bloc<CurriculumEvent, CurriculumState> {
  final CurriculumRepository repository;

  CurriculumBloc({required this.repository}) : super(const CurriculumState()) {
    on<LoadCurriculumEvent>(_onLoadCurriculum);
    on<FilterCurriculumEvent>(_onFilterCurriculum);
    on<ToggleEnrollTrackEvent>(_onToggleEnrollTrack);
    on<ToggleBookmarkTrackEvent>(_onToggleBookmarkTrack);
    on<SelectTrackEvent>(_onSelectTrack);
    on<ToggleCompleteLessonEvent>(_onToggleCompleteLesson);
  }

  Future<void> _onLoadCurriculum(
    LoadCurriculumEvent event,
    Emitter<CurriculumState> emit,
  ) async {
    emit(state.copyWith(status: CurriculumStatus.loading));
    try {
      final tracks = await repository.getTracks();
      final filtered = _applyFilters(
        tracks: tracks,
        domain: state.selectedDomain,
        difficulty: state.selectedDifficulty,
        enrollment: state.selectedEnrollmentStatus,
        query: state.searchQuery,
      );

      emit(
        state.copyWith(
          status: CurriculumStatus.loaded,
          allTracks: tracks,
          filteredTracks: filtered,
          totalUserXp: repository.preferencesService.userXp,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CurriculumStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onFilterCurriculum(
    FilterCurriculumEvent event,
    Emitter<CurriculumState> emit,
  ) {
    final domain = event.domain ?? state.selectedDomain;
    final difficulty = event.difficulty ?? state.selectedDifficulty;
    final enrollment = event.enrollmentStatus ?? state.selectedEnrollmentStatus;
    final query = event.searchQuery ?? state.searchQuery;

    final filtered = _applyFilters(
      tracks: state.allTracks,
      domain: domain,
      difficulty: difficulty,
      enrollment: enrollment,
      query: query,
    );

    emit(
      state.copyWith(
        selectedDomain: domain,
        selectedDifficulty: difficulty,
        selectedEnrollmentStatus: enrollment,
        searchQuery: query,
        filteredTracks: filtered,
      ),
    );
  }

  Future<void> _onToggleEnrollTrack(
    ToggleEnrollTrackEvent event,
    Emitter<CurriculumState> emit,
  ) async {
    final updated = await repository.toggleEnrollment(event.track);
    final all = state.allTracks
        .map((t) => t.id == updated.id ? updated : t)
        .toList();
    final filtered = _applyFilters(
      tracks: all,
      domain: state.selectedDomain,
      difficulty: state.selectedDifficulty,
      enrollment: state.selectedEnrollmentStatus,
      query: state.searchQuery,
    );

    emit(
      state.copyWith(
        allTracks: all,
        filteredTracks: filtered,
        selectedTrack: state.selectedTrack?.id == updated.id
            ? updated
            : state.selectedTrack,
      ),
    );
  }

  Future<void> _onToggleBookmarkTrack(
    ToggleBookmarkTrackEvent event,
    Emitter<CurriculumState> emit,
  ) async {
    final updated = await repository.toggleBookmark(event.track);
    final all = state.allTracks
        .map((t) => t.id == updated.id ? updated : t)
        .toList();
    final filtered = _applyFilters(
      tracks: all,
      domain: state.selectedDomain,
      difficulty: state.selectedDifficulty,
      enrollment: state.selectedEnrollmentStatus,
      query: state.searchQuery,
    );

    emit(
      state.copyWith(
        allTracks: all,
        filteredTracks: filtered,
        selectedTrack: state.selectedTrack?.id == updated.id
            ? updated
            : state.selectedTrack,
      ),
    );
  }

  Future<void> _onSelectTrack(
    SelectTrackEvent event,
    Emitter<CurriculumState> emit,
  ) async {
    emit(state.copyWith(selectedTrack: event.track));
    final lessons = await repository.getLessons(event.track.id);
    emit(state.copyWith(currentLessons: lessons));
  }

  Future<void> _onToggleCompleteLesson(
    ToggleCompleteLessonEvent event,
    Emitter<CurriculumState> emit,
  ) async {
    final result = await repository.completeLesson(
      track: event.track,
      lesson: event.lesson,
    );

    final updatedTrack = result['track'] as TrackModel;
    final all = state.allTracks
        .map((t) => t.id == updatedTrack.id ? updatedTrack : t)
        .toList();
    final lessons = await repository.getLessons(updatedTrack.id);

    final filtered = _applyFilters(
      tracks: all,
      domain: state.selectedDomain,
      difficulty: state.selectedDifficulty,
      enrollment: state.selectedEnrollmentStatus,
      query: state.searchQuery,
    );

    emit(
      state.copyWith(
        allTracks: all,
        filteredTracks: filtered,
        selectedTrack: updatedTrack,
        currentLessons: lessons,
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
  }

  List<TrackModel> _applyFilters({
    required List<TrackModel> tracks,
    required String domain,
    required String difficulty,
    required String enrollment,
    required String query,
  }) {
    return tracks.where((track) {
      // Domain filter
      if (domain != 'All Domains' && track.domain != domain) {
        return false;
      }
      // Difficulty filter
      if (difficulty != 'All Levels' && track.difficulty != difficulty) {
        return false;
      }
      // Enrollment filter
      if (enrollment == 'Enrolled' && !track.isEnrolled) {
        return false;
      }
      if (enrollment == 'Bookmarked' && !track.isBookmarked) {
        return false;
      }
      // Search query
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchesTitle = track.title.toLowerCase().contains(q);
        final matchesDesc = track.description.toLowerCase().contains(q);
        final matchesDomain = track.domain.toLowerCase().contains(q);
        if (!matchesTitle && !matchesDesc && !matchesDomain) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
