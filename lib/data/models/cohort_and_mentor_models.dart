class StudyRoomModel {
  final String id;
  final String title;
  final String topic;
  final int participantsCount;
  final int pomodoroMinutes;
  final bool isActive;
  final String hostName;
  final bool userJoined;

  const StudyRoomModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.participantsCount,
    required this.pomodoroMinutes,
    required this.isActive,
    required this.hostName,
    this.userJoined = false,
  });

  StudyRoomModel copyWith({
    String? id,
    String? title,
    String? topic,
    int? participantsCount,
    int? pomodoroMinutes,
    bool? isActive,
    String? hostName,
    bool? userJoined,
  }) {
    return StudyRoomModel(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      participantsCount: participantsCount ?? this.participantsCount,
      pomodoroMinutes: pomodoroMinutes ?? this.pomodoroMinutes,
      isActive: isActive ?? this.isActive,
      hostName: hostName ?? this.hostName,
      userJoined: userJoined ?? this.userJoined,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'participantsCount': participantsCount,
      'pomodoroMinutes': pomodoroMinutes,
      'isActive': isActive ? 1 : 0,
      'hostName': hostName,
      'userJoined': userJoined ? 1 : 0,
    };
  }

  factory StudyRoomModel.fromMap(Map<String, dynamic> map) {
    return StudyRoomModel(
      id: map['id'] as String,
      title: map['title'] as String,
      topic: map['topic'] as String,
      participantsCount: (map['participantsCount'] as num? ?? 1).toInt(),
      pomodoroMinutes: (map['pomodoroMinutes'] as num? ?? 25).toInt(),
      isActive: (map['isActive'] as int? ?? 1) == 1,
      hostName: map['hostName'] as String? ?? 'Lead Architect',
      userJoined: (map['userJoined'] as int? ?? 0) == 1,
    );
  }
}

class CodeReviewModel {
  final String id;
  final String authorName;
  final String authorRole;
  final String title;
  final String codeSnippet;
  final String description;
  final int upvotesCount;
  final bool isUpvoted;
  final int commentsCount;
  final String createdAt;
  final String tags;

  const CodeReviewModel({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.title,
    required this.codeSnippet,
    required this.description,
    required this.upvotesCount,
    required this.isUpvoted,
    required this.commentsCount,
    required this.createdAt,
    required this.tags,
  });

  CodeReviewModel copyWith({
    String? id,
    String? authorName,
    String? authorRole,
    String? title,
    String? codeSnippet,
    String? description,
    int? upvotesCount,
    bool? isUpvoted,
    int? commentsCount,
    String? createdAt,
    String? tags,
  }) {
    return CodeReviewModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      title: title ?? this.title,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      description: description ?? this.description,
      upvotesCount: upvotesCount ?? this.upvotesCount,
      isUpvoted: isUpvoted ?? this.isUpvoted,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorName': authorName,
      'authorRole': authorRole,
      'title': title,
      'codeSnippet': codeSnippet,
      'description': description,
      'upvotesCount': upvotesCount,
      'isUpvoted': isUpvoted ? 1 : 0,
      'commentsCount': commentsCount,
      'createdAt': createdAt,
      'tags': tags,
    };
  }

  factory CodeReviewModel.fromMap(Map<String, dynamic> map) {
    return CodeReviewModel(
      id: map['id'] as String,
      authorName: map['authorName'] as String,
      authorRole: map['authorRole'] as String? ?? 'Senior Engineer',
      title: map['title'] as String,
      codeSnippet: map['codeSnippet'] as String,
      description: map['description'] as String,
      upvotesCount: (map['upvotesCount'] as num? ?? 0).toInt(),
      isUpvoted: (map['isUpvoted'] as int? ?? 0) == 1,
      commentsCount: (map['commentsCount'] as num? ?? 0).toInt(),
      createdAt: map['createdAt'] as String? ?? 'Just now',
      tags: map['tags'] as String? ?? 'Architecture',
    );
  }
}

class ReviewCommentModel {
  final String id;
  final String reviewId;
  final String authorName;
  final String authorRole;
  final String content;
  final String createdAt;

  const ReviewCommentModel({
    required this.id,
    required this.reviewId,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewId': reviewId,
      'authorName': authorName,
      'authorRole': authorRole,
      'content': content,
      'createdAt': createdAt,
    };
  }

  factory ReviewCommentModel.fromMap(Map<String, dynamic> map) {
    return ReviewCommentModel(
      id: map['id'] as String,
      reviewId: map['reviewId'] as String,
      authorName: map['authorName'] as String,
      authorRole: map['authorRole'] as String? ?? 'Software Engineer',
      content: map['content'] as String,
      createdAt: map['createdAt'] as String,
    );
  }
}

class LeaderboardEntryModel {
  final String id;
  final int rank;
  final String name;
  final String title;
  final int xp;
  final int streakDays;
  final bool isCurrentUser;

  const LeaderboardEntryModel({
    required this.id,
    required this.rank,
    required this.name,
    required this.title,
    required this.xp,
    required this.streakDays,
    this.isCurrentUser = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rank': rank,
      'name': name,
      'title': title,
      'xp': xp,
      'streakDays': streakDays,
      'isCurrentUser': isCurrentUser ? 1 : 0,
    };
  }

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntryModel(
      id: map['id'] as String,
      rank: (map['rank'] as num).toInt(),
      name: map['name'] as String,
      title: map['title'] as String,
      xp: (map['xp'] as num).toInt(),
      streakDays: (map['streakDays'] as num).toInt(),
      isCurrentUser: (map['isCurrentUser'] as int? ?? 0) == 1,
    );
  }
}

class MentorMessageModel {
  final String id;
  final String sender; // 'user' or 'mentor'
  final String content;
  final DateTime timestamp;
  final bool isStreaming;

  const MentorMessageModel({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
  });

  MentorMessageModel copyWith({
    String? id,
    String? sender,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
  }) {
    return MentorMessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
