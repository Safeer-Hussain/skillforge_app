import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/daily_activity_model.dart';
import '../../../data/repositories/study_activity_repository.dart';
import 'study_heatmap_state.dart';

class StudyHeatmapCubit extends Cubit<StudyHeatmapState> {
  final StudyActivityRepository repository;

  StudyHeatmapCubit({required this.repository})
    : super(const StudyHeatmapState()) {
    loadActivityMatrix();
  }

  Future<void> loadActivityMatrix({DateTime? referenceDate}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final activities = await repository.get52WeeksActivity(
        referenceDate: referenceDate,
      );
      final stats = repository.computeStats(activities);

      // Default select the last day (today) if available
      final todayModel = activities.isNotEmpty ? activities.last : null;

      emit(
        state.copyWith(
          isLoading: false,
          activities: activities,
          selectedDay: todayModel,
          currentStreak: stats['currentStreak'] as int,
          longestStreak: stats['longestStreak'] as int,
          totalContributions: stats['totalContributions'] as int,
          activeDaysCount: stats['activeDaysCount'] as int,
          totalLessons: stats['totalLessons'] as int,
          totalSandboxRuns: stats['totalSandboxRuns'] as int,
          totalFlashcards: stats['totalFlashcards'] as int,
          totalXp: stats['totalXp'] as int,
          activeDaysRatio: stats['activeDaysRatio'] as double,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load study activity matrix: $e',
        ),
      );
    }
  }

  void setFilter(ActivityFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  void selectDay(DailyActivityModel? day) {
    emit(state.copyWith(selectedDay: day, clearSelectedDay: day == null));
  }

  Future<void> logActivity({
    required String type,
    int count = 1,
    int xp = 50,
  }) async {
    try {
      final updatedModel = await repository.logActivity(
        type: type,
        count: count,
        xp: xp,
      );

      // Update in existing list immutably
      final updatedList = state.activities.map((item) {
        if (item.dateKey == updatedModel.dateKey) {
          return updatedModel;
        }
        return item;
      }).toList();

      final stats = repository.computeStats(updatedList);

      emit(
        state.copyWith(
          activities: updatedList,
          selectedDay: updatedModel,
          currentStreak: stats['currentStreak'] as int,
          longestStreak: stats['longestStreak'] as int,
          totalContributions: stats['totalContributions'] as int,
          activeDaysCount: stats['activeDaysCount'] as int,
          totalLessons: stats['totalLessons'] as int,
          totalSandboxRuns: stats['totalSandboxRuns'] as int,
          totalFlashcards: stats['totalFlashcards'] as int,
          totalXp: stats['totalXp'] as int,
          activeDaysRatio: stats['activeDaysRatio'] as double,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to log activity session: $e'));
    }
  }
}
