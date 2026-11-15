class Sm2Result {
  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final DateTime nextReviewDate;

  const Sm2Result({
    required this.repetitions,
    required this.easeFactor,
    required this.intervalDays,
    required this.nextReviewDate,
  });
}

class Sm2Algorithm {
  // 4-Tier recall grade mapping
  // Again: grade 1 (Reset interval, repeat in <1m / 10m)
  // Hard:  grade 2 (Small interval bump, slight EF reduction)
  // Good:  grade 4 (Standard SM-2 spacing)
  // Easy:  grade 5 (Maximum spacing, EF increase)
  static const int gradeAgain = 1;
  static const int gradeHard = 2;
  static const int gradeGood = 4;
  static const int gradeEasy = 5;

  static Sm2Result calculateNextReview({
    required int grade,
    required int repetitions,
    required double previousEaseFactor,
    required int previousIntervalDays,
    DateTime? fromDate,
  }) {
    final now = fromDate ?? DateTime.now();

    // SM-2 Ease Factor calculation
    // EF' = EF + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02))
    final efDelta = 0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02);
    var newEaseFactor = previousEaseFactor + efDelta;
    if (newEaseFactor < 1.3) {
      newEaseFactor = 1.3;
    }

    int newRepetitions;
    int newIntervalDays;

    if (grade >= 3) {
      if (repetitions == 0) {
        newIntervalDays = 1;
      } else if (repetitions == 1) {
        newIntervalDays = 6;
      } else {
        newIntervalDays = (previousIntervalDays * newEaseFactor).round();
      }
      newRepetitions = repetitions + 1;
    } else {
      newRepetitions = 0;
      newIntervalDays = 1;
    }

    // For gradeAgain, next review is immediate/same day
    final nextReviewDate = grade == gradeAgain
        ? now.add(const Duration(minutes: 10))
        : now.add(Duration(days: newIntervalDays));

    return Sm2Result(
      repetitions: newRepetitions,
      easeFactor: double.parse(newEaseFactor.toStringAsFixed(2)),
      intervalDays: newIntervalDays,
      nextReviewDate: nextReviewDate,
    );
  }
}
