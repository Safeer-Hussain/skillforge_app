class FlashcardModel {
  final String id;
  final String trackId;
  final String topicTag;
  final String frontPrompt;
  final String backAnswer;
  final String codeExample;
  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final String lastReviewedAt;
  final String nextReviewAt;
  final String status; // 'New', 'Learning', 'Review', 'Mastered'

  const FlashcardModel({
    required this.id,
    required this.trackId,
    required this.topicTag,
    required this.frontPrompt,
    required this.backAnswer,
    required this.codeExample,
    required this.repetitions,
    required this.easeFactor,
    required this.intervalDays,
    required this.lastReviewedAt,
    required this.nextReviewAt,
    required this.status,
  });

  FlashcardModel copyWith({
    String? id,
    String? trackId,
    String? topicTag,
    String? frontPrompt,
    String? backAnswer,
    String? codeExample,
    int? repetitions,
    double? easeFactor,
    int? intervalDays,
    String? lastReviewedAt,
    String? nextReviewAt,
    String? status,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      topicTag: topicTag ?? this.topicTag,
      frontPrompt: frontPrompt ?? this.frontPrompt,
      backAnswer: backAnswer ?? this.backAnswer,
      codeExample: codeExample ?? this.codeExample,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackId': trackId,
      'topicTag': topicTag,
      'frontPrompt': frontPrompt,
      'backAnswer': backAnswer,
      'codeExample': codeExample,
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'intervalDays': intervalDays,
      'lastReviewedAt': lastReviewedAt,
      'nextReviewAt': nextReviewAt,
      'status': status,
    };
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] as String,
      trackId: map['trackId'] as String? ?? 'general',
      topicTag: map['topicTag'] as String? ?? 'Architecture',
      frontPrompt: map['frontPrompt'] as String,
      backAnswer: map['backAnswer'] as String,
      codeExample: map['codeExample'] as String? ?? '',
      repetitions: (map['repetitions'] as num? ?? 0).toInt(),
      easeFactor: (map['easeFactor'] as num? ?? 2.5).toDouble(),
      intervalDays: (map['intervalDays'] as num? ?? 0).toInt(),
      lastReviewedAt: map['lastReviewedAt'] as String? ?? '',
      nextReviewAt: map['nextReviewAt'] as String? ?? '',
      status: map['status'] as String? ?? 'New',
    );
  }
}
