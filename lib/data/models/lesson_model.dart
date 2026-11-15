class LessonModel {
  final String id;
  final String trackId;
  final String title;
  final String moduleTitle;
  final int durationMinutes;
  final String timeComplexity;
  final String spaceComplexity;
  final String contentNotes;
  final String codeSnippet;
  final bool isCompleted;
  final int xpReward;
  final String relatedChallengeId;

  const LessonModel({
    required this.id,
    required this.trackId,
    required this.title,
    required this.moduleTitle,
    required this.durationMinutes,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.contentNotes,
    required this.codeSnippet,
    required this.isCompleted,
    required this.xpReward,
    required this.relatedChallengeId,
  });

  LessonModel copyWith({
    String? id,
    String? trackId,
    String? title,
    String? moduleTitle,
    int? durationMinutes,
    String? timeComplexity,
    String? spaceComplexity,
    String? contentNotes,
    String? codeSnippet,
    bool? isCompleted,
    int? xpReward,
    String? relatedChallengeId,
  }) {
    return LessonModel(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      moduleTitle: moduleTitle ?? this.moduleTitle,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timeComplexity: timeComplexity ?? this.timeComplexity,
      spaceComplexity: spaceComplexity ?? this.spaceComplexity,
      contentNotes: contentNotes ?? this.contentNotes,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      isCompleted: isCompleted ?? this.isCompleted,
      xpReward: xpReward ?? this.xpReward,
      relatedChallengeId: relatedChallengeId ?? this.relatedChallengeId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackId': trackId,
      'title': title,
      'moduleTitle': moduleTitle,
      'durationMinutes': durationMinutes,
      'timeComplexity': timeComplexity,
      'spaceComplexity': spaceComplexity,
      'contentNotes': contentNotes,
      'codeSnippet': codeSnippet,
      'isCompleted': isCompleted ? 1 : 0,
      'xpReward': xpReward,
      'relatedChallengeId': relatedChallengeId,
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      title: map['title'] as String,
      moduleTitle: map['moduleTitle'] as String,
      durationMinutes: (map['durationMinutes'] as num? ?? 15).toInt(),
      timeComplexity: map['timeComplexity'] as String? ?? 'O(1)',
      spaceComplexity: map['spaceComplexity'] as String? ?? 'O(1)',
      contentNotes: map['contentNotes'] as String? ?? '',
      codeSnippet: map['codeSnippet'] as String? ?? '',
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      xpReward: (map['xpReward'] as num? ?? 50).toInt(),
      relatedChallengeId: map['relatedChallengeId'] as String? ?? '',
    );
  }
}
