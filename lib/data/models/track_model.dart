class TrackModel {
  final String id;
  final String title;
  final String domain;
  final String difficulty;
  final String description;
  final String iconPath;
  final bool isEnrolled;
  final bool isBookmarked;
  final double progressPercent;
  final int totalXp;
  final int lessonsCount;
  final int completedLessonsCount;

  const TrackModel({
    required this.id,
    required this.title,
    required this.domain,
    required this.difficulty,
    required this.description,
    required this.iconPath,
    required this.isEnrolled,
    required this.isBookmarked,
    required this.progressPercent,
    required this.totalXp,
    required this.lessonsCount,
    required this.completedLessonsCount,
  });

  TrackModel copyWith({
    String? id,
    String? title,
    String? domain,
    String? difficulty,
    String? description,
    String? iconPath,
    bool? isEnrolled,
    bool? isBookmarked,
    double? progressPercent,
    int? totalXp,
    int? lessonsCount,
    int? completedLessonsCount,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      domain: domain ?? this.domain,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      progressPercent: progressPercent ?? this.progressPercent,
      totalXp: totalXp ?? this.totalXp,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      completedLessonsCount:
          completedLessonsCount ?? this.completedLessonsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'domain': domain,
      'difficulty': difficulty,
      'description': description,
      'iconPath': iconPath,
      'isEnrolled': isEnrolled ? 1 : 0,
      'isBookmarked': isBookmarked ? 1 : 0,
      'progressPercent': progressPercent,
      'totalXp': totalXp,
      'lessonsCount': lessonsCount,
      'completedLessonsCount': completedLessonsCount,
    };
  }

  factory TrackModel.fromMap(Map<String, dynamic> map) {
    return TrackModel(
      id: map['id'] as String,
      title: map['title'] as String,
      domain: map['domain'] as String,
      difficulty: map['difficulty'] as String,
      description: map['description'] as String,
      iconPath: map['iconPath'] as String,
      isEnrolled: (map['isEnrolled'] as int? ?? 0) == 1,
      isBookmarked: (map['isBookmarked'] as int? ?? 0) == 1,
      progressPercent: (map['progressPercent'] as num? ?? 0.0).toDouble(),
      totalXp: (map['totalXp'] as num? ?? 0).toInt(),
      lessonsCount: (map['lessonsCount'] as num? ?? 0).toInt(),
      completedLessonsCount: (map['completedLessonsCount'] as num? ?? 0)
          .toInt(),
    );
  }
}
