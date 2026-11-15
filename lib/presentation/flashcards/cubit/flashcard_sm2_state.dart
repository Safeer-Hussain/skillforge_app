import '../../../data/models/flashcard_model.dart';

enum FlashcardDeckStatus { initial, loading, ready, completed, error }

class ExamQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const ExamQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

class ExamState {
  final bool isExamActive;
  final int remainingSeconds;
  final int currentQuestionIndex;
  final Map<int, int> selectedAnswers; // questionIndex -> optionIndex
  final bool isSubmitted;
  final int score;
  final int totalQuestions;
  final bool isPassed;
  final String certificateHash;

  const ExamState({
    this.isExamActive = false,
    this.remainingSeconds = 600, // 10 minutes
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.isSubmitted = false,
    this.score = 0,
    this.totalQuestions = 5,
    this.isPassed = false,
    this.certificateHash = '',
  });

  ExamState copyWith({
    bool? isExamActive,
    int? remainingSeconds,
    int? currentQuestionIndex,
    Map<int, int>? selectedAnswers,
    bool? isSubmitted,
    int? score,
    int? totalQuestions,
    bool? isPassed,
    String? certificateHash,
  }) {
    return ExamState(
      isExamActive: isExamActive ?? this.isExamActive,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isPassed: isPassed ?? this.isPassed,
      certificateHash: certificateHash ?? this.certificateHash,
    );
  }
}

class FlashcardSm2State {
  final FlashcardDeckStatus status;
  final List<FlashcardModel> deck;
  final int currentIndex;
  final bool isFlipped;
  final int reviewedCount;
  final String? errorMessage;
  final ExamState examState;
  final int totalUserXp;

  const FlashcardSm2State({
    this.status = FlashcardDeckStatus.initial,
    this.deck = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.reviewedCount = 0,
    this.errorMessage,
    this.examState = const ExamState(),
    this.totalUserXp = 1420,
  });

  FlashcardModel? get currentCard {
    if (deck.isEmpty || currentIndex >= deck.length) return null;
    return deck[currentIndex];
  }

  FlashcardSm2State copyWith({
    FlashcardDeckStatus? status,
    List<FlashcardModel>? deck,
    int? currentIndex,
    bool? isFlipped,
    int? reviewedCount,
    String? errorMessage,
    ExamState? examState,
    int? totalUserXp,
  }) {
    return FlashcardSm2State(
      status: status ?? this.status,
      deck: deck ?? this.deck,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      reviewedCount: reviewedCount ?? this.reviewedCount,
      errorMessage: errorMessage ?? this.errorMessage,
      examState: examState ?? this.examState,
      totalUserXp: totalUserXp ?? this.totalUserXp,
    );
  }
}
