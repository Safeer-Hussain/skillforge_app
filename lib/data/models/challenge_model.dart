class ChallengeModel {
  final String id;
  final String title;
  final String difficulty;
  final String domain;
  final String description;
  final String starterCode;
  final String solutionCode;
  final String testCasesJson;
  final int cyclomaticTarget;
  final int xpReward;
  final bool isCompleted;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.domain,
    required this.description,
    required this.starterCode,
    required this.solutionCode,
    required this.testCasesJson,
    required this.cyclomaticTarget,
    required this.xpReward,
    this.isCompleted = false,
  });

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? difficulty,
    String? domain,
    String? description,
    String? starterCode,
    String? solutionCode,
    String? testCasesJson,
    int? cyclomaticTarget,
    int? xpReward,
    bool? isCompleted,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
      domain: domain ?? this.domain,
      description: description ?? this.description,
      starterCode: starterCode ?? this.starterCode,
      solutionCode: solutionCode ?? this.solutionCode,
      testCasesJson: testCasesJson ?? this.testCasesJson,
      cyclomaticTarget: cyclomaticTarget ?? this.cyclomaticTarget,
      xpReward: xpReward ?? this.xpReward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'difficulty': difficulty,
      'domain': domain,
      'description': description,
      'starterCode': starterCode,
      'solutionCode': solutionCode,
      'testCasesJson': testCasesJson,
      'cyclomaticTarget': cyclomaticTarget,
      'xpReward': xpReward,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory ChallengeModel.fromMap(Map<String, dynamic> map) {
    return ChallengeModel(
      id: map['id'] as String,
      title: map['title'] as String,
      difficulty: map['difficulty'] as String,
      domain: map['domain'] as String,
      description: map['description'] as String,
      starterCode: map['starterCode'] as String,
      solutionCode: map['solutionCode'] as String,
      testCasesJson: map['testCasesJson'] as String? ?? '[]',
      cyclomaticTarget: (map['cyclomaticTarget'] as num? ?? 8).toInt(),
      xpReward: (map['xpReward'] as num? ?? 100).toInt(),
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
    );
  }
}
