import '../../../data/models/track_model.dart';
import '../../../data/models/lesson_model.dart';

enum CurriculumStatus { initial, loading, loaded, error }

class CurriculumState {
  final CurriculumStatus status;
  final List<TrackModel> allTracks;
  final List<TrackModel> filteredTracks;
  final TrackModel? selectedTrack;
  final List<LessonModel> currentLessons;
  final String selectedDomain;
  final String selectedDifficulty;
  final String selectedEnrollmentStatus;
  final String searchQuery;
  final String? errorMessage;
  final int totalUserXp;

  const CurriculumState({
    this.status = CurriculumStatus.initial,
    this.allTracks = const [],
    this.filteredTracks = const [],
    this.selectedTrack,
    this.currentLessons = const [],
    this.selectedDomain = 'All Domains',
    this.selectedDifficulty = 'All Levels',
    this.selectedEnrollmentStatus = 'All',
    this.searchQuery = '',
    this.errorMessage,
    this.totalUserXp = 1420,
  });

  CurriculumState copyWith({
    CurriculumStatus? status,
    List<TrackModel>? allTracks,
    List<TrackModel>? filteredTracks,
    TrackModel? selectedTrack,
    List<LessonModel>? currentLessons,
    String? selectedDomain,
    String? selectedDifficulty,
    String? selectedEnrollmentStatus,
    String? searchQuery,
    String? errorMessage,
    int? totalUserXp,
  }) {
    return CurriculumState(
      status: status ?? this.status,
      allTracks: allTracks ?? this.allTracks,
      filteredTracks: filteredTracks ?? this.filteredTracks,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      currentLessons: currentLessons ?? this.currentLessons,
      selectedDomain: selectedDomain ?? this.selectedDomain,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      selectedEnrollmentStatus:
          selectedEnrollmentStatus ?? this.selectedEnrollmentStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      totalUserXp: totalUserXp ?? this.totalUserXp,
    );
  }
}
