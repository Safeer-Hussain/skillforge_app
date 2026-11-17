import '../../../data/models/daily_activity_model.dart';

enum ActivityFilter {
  all('All Activities'),
  lessons('Lessons Completed'),
  sandbox('Sandbox AST Runs'),
  flashcards('SM-2 Flashcards');

  final String label;
  const ActivityFilter(this.label);
}

class StudyHeatmapState {
  final bool isLoading;
  final List<DailyActivityModel> activities;
  final DailyActivityModel? selectedDay;
  final ActivityFilter filter;
  final int currentStreak;
  final int longestStreak;
  final int totalContributions;
  final int activeDaysCount;
  final int totalLessons;
  final int totalSandboxRuns;
  final int totalFlashcards;
  final int totalXp;
  final double activeDaysRatio;
  final String? errorMessage;

  const StudyHeatmapState({
    this.isLoading = false,
    this.activities = const [],
    this.selectedDay,
    this.filter = ActivityFilter.all,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalContributions = 0,
    this.activeDaysCount = 0,
    this.totalLessons = 0,
    this.totalSandboxRuns = 0,
    this.totalFlashcards = 0,
    this.totalXp = 0,
    this.activeDaysRatio = 0.0,
    this.errorMessage,
  });

  /// Returns the activity count for a specific day based on the active filter
  int getFilteredCount(DailyActivityModel day) {
    switch (filter) {
      case ActivityFilter.all:
        return day.totalCount;
      case ActivityFilter.lessons:
        return day.completedLessons;
      case ActivityFilter.sandbox:
        return day.sandboxExecutions;
      case ActivityFilter.flashcards:
        return day.flashcardsReviewed;
    }
  }

  /// Calculates intensity level (0 to 4) according to the active filter
  int getFilteredIntensity(DailyActivityModel day) {
    final count = getFilteredCount(day);
    if (count == 0) return 0;
    if (count <= 2) return 1;
    if (count <= 5) return 2;
    if (count <= 9) return 3;
    return 4;
  }

  StudyHeatmapState copyWith({
    bool? isLoading,
    List<DailyActivityModel>? activities,
    DailyActivityModel? selectedDay,
    bool clearSelectedDay = false,
    ActivityFilter? filter,
    int? currentStreak,
    int? longestStreak,
    int? totalContributions,
    int? activeDaysCount,
    int? totalLessons,
    int? totalSandboxRuns,
    int? totalFlashcards,
    int? totalXp,
    double? activeDaysRatio,
    String? errorMessage,
  }) {
    return StudyHeatmapState(
      isLoading: isLoading ?? this.isLoading,
      activities: activities ?? this.activities,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      filter: filter ?? this.filter,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalContributions: totalContributions ?? this.totalContributions,
      activeDaysCount: activeDaysCount ?? this.activeDaysCount,
      totalLessons: totalLessons ?? this.totalLessons,
      totalSandboxRuns: totalSandboxRuns ?? this.totalSandboxRuns,
      totalFlashcards: totalFlashcards ?? this.totalFlashcards,
      totalXp: totalXp ?? this.totalXp,
      activeDaysRatio: activeDaysRatio ?? this.activeDaysRatio,
      errorMessage: errorMessage,
    );
  }
}
