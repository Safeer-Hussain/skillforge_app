class DailyActivityModel {
  final DateTime date;
  final int completedLessons;
  final int sandboxExecutions;
  final int flashcardsReviewed;
  final int xpEarned;

  const DailyActivityModel({
    required this.date,
    this.completedLessons = 0,
    this.sandboxExecutions = 0,
    this.flashcardsReviewed = 0,
    this.xpEarned = 0,
  });

  String get dateKey =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  int get totalCount =>
      completedLessons + sandboxExecutions + flashcardsReviewed;

  int get intensityLevel {
    final count = totalCount;
    if (count == 0) return 0;
    if (count <= 2) return 1;
    if (count <= 5) return 2;
    if (count <= 9) return 3;
    return 4;
  }

  DailyActivityModel copyWith({
    DateTime? date,
    int? completedLessons,
    int? sandboxExecutions,
    int? flashcardsReviewed,
    int? xpEarned,
  }) {
    return DailyActivityModel(
      date: date ?? this.date,
      completedLessons: completedLessons ?? this.completedLessons,
      sandboxExecutions: sandboxExecutions ?? this.sandboxExecutions,
      flashcardsReviewed: flashcardsReviewed ?? this.flashcardsReviewed,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': dateKey,
      'completedLessons': completedLessons,
      'sandboxExecutions': sandboxExecutions,
      'flashcardsReviewed': flashcardsReviewed,
      'xpEarned': xpEarned,
    };
  }

  factory DailyActivityModel.fromMap(Map<String, dynamic> map) {
    final dateStr = map['date'] as String;
    final parts = dateStr.split('-');
    final parsedDate = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    return DailyActivityModel(
      date: parsedDate,
      completedLessons: (map['completedLessons'] as num?)?.toInt() ?? 0,
      sandboxExecutions: (map['sandboxExecutions'] as num?)?.toInt() ?? 0,
      flashcardsReviewed: (map['flashcardsReviewed'] as num?)?.toInt() ?? 0,
      xpEarned: (map['xpEarned'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyActivityModel &&
          runtimeType == other.runtimeType &&
          dateKey == other.dateKey &&
          completedLessons == other.completedLessons &&
          sandboxExecutions == other.sandboxExecutions &&
          flashcardsReviewed == other.flashcardsReviewed &&
          xpEarned == other.xpEarned;

  @override
  int get hashCode =>
      dateKey.hashCode ^
      completedLessons.hashCode ^
      sandboxExecutions.hashCode ^
      flashcardsReviewed.hashCode ^
      xpEarned.hashCode;
}
