import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'flashcard_sm2_state.dart';
import '../../../data/repositories/flashcard_repository.dart';
import '../../../data/models/flashcard_model.dart';

class FlashcardSm2Cubit extends Cubit<FlashcardSm2State> {
  final FlashcardRepository repository;
  Timer? _examTimer;

  static const List<ExamQuestion> sampleExamQuestions = [
    ExamQuestion(
      id: 'q1',
      question: 'Which method in RenderObject is called by the pipeline when relayout is required without size changes?',
      options: [
        'performResize()',
        'markNeedsPaint()',
        'layout() with parentUsesSize: false',
        'adoptChild()',
      ],
      correctOptionIndex: 2,
      explanation: 'When parentUsesSize is false, layout boundaries isolate child measurements from parent reflow.',
    ),
    ExamQuestion(
      id: 'q2',
      question: 'In Dart 3+ isolate architecture, what happens when TransferableTypedData is passed across ports?',
      options: [
        'A full deep copy of the byte array is duplicated on the heap',
        'Underlying memory pointers are transferred directly without deep copy',
        'Data is serialized into JSON strings',
        'An exception is thrown if bytes exceed 1MB',
      ],
      correctOptionIndex: 1,
      explanation: 'TransferableTypedData transfers ownership of unmanaged byte buffers directly between isolate memory spaces.',
    ),
    ExamQuestion(
      id: 'q3',
      question: 'What is the core Raft invariant that ensures no two leaders are elected for the same term?',
      options: [
        'Leader AppendEntries Heartbeat',
        'Election Safety (each peer votes for at most one candidate per term)',
        'Log Matching Property',
        'Leader Completeness',
      ],
      correctOptionIndex: 1,
      explanation: 'Election Safety guarantees at most one leader can be elected in a given term because a candidate needs majority votes.',
    ),
    ExamQuestion(
      id: 'q4',
      question: 'In Clean Architecture, which layer contains concrete database adapters and external API interceptors?',
      options: [
        'Domain Layer',
        'Application Layer',
        'Data (Infrastructure) Layer',
        'Presentation Layer',
      ],
      correctOptionIndex: 2,
      explanation: 'The Data layer implements repositories defined by Domain interfaces, interacting with low-level databases and network clients.',
    ),
    ExamQuestion(
      id: 'q5',
      question: 'Which vector search index type provides sub-millisecond query latency with logarithmic complexity at the cost of high RAM?',
      options: [
        'Flat Inverted File (IVF)',
        'Hierarchical Navigable Small World (HNSW)',
        'Locality Sensitive Hashing (LSH)',
        'Product Quantization (PQ)',
      ],
      correctOptionIndex: 1,
      explanation: 'HNSW constructs multi-layer proximity graphs offering O(log N) search times with high recall accuracy.',
    ),
  ];

  FlashcardSm2Cubit({required this.repository})
    : super(const FlashcardSm2State());

  Future<void> loadDeck() async {
    emit(state.copyWith(status: FlashcardDeckStatus.loading));
    try {
      final cards = await repository.getFlashcards();
      emit(
        state.copyWith(
          status: FlashcardDeckStatus.ready,
          deck: cards,
          currentIndex: 0,
          isFlipped: false,
          totalUserXp: repository.preferencesService.userXp,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FlashcardDeckStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void flipCard() {
    emit(state.copyWith(isFlipped: !state.isFlipped));
  }

  Future<void> rateCurrentCard(int grade) async {
    final current = state.currentCard;
    if (current == null) return;

    final updated = await repository.rateCard(card: current, grade: grade);

    final updatedDeck = List<FlashcardModel>.from(state.deck);
    updatedDeck[state.currentIndex] = updated;

    final nextIndex = state.currentIndex + 1;
    final isDone = nextIndex >= updatedDeck.length;

    emit(
      state.copyWith(
        deck: updatedDeck,
        currentIndex: isDone ? state.currentIndex : nextIndex,
        isFlipped: false,
        reviewedCount: state.reviewedCount + 1,
        status: isDone
            ? FlashcardDeckStatus.completed
            : FlashcardDeckStatus.ready,
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
  }

  void resetDeckProgress() {
    emit(
      state.copyWith(
        currentIndex: 0,
        isFlipped: false,
        reviewedCount: 0,
        status: FlashcardDeckStatus.ready,
      ),
    );
  }

  Future<bool> createCustomCard({
    required String topicTag,
    required String frontPrompt,
    required String backAnswer,
    required String codeExample,
  }) async {
    if (topicTag.trim().isEmpty ||
        frontPrompt.trim().isEmpty ||
        backAnswer.trim().isEmpty) {
      return false;
    }

    final newCard = await repository.createCard(
      topicTag: topicTag.trim(),
      frontPrompt: frontPrompt.trim(),
      backAnswer: backAnswer.trim(),
      codeExample: codeExample.trim(),
    );

    final updatedDeck = List<FlashcardModel>.from(state.deck)..add(newCard);
    emit(
      state.copyWith(
        deck: updatedDeck,
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
    return true;
  }

  // Certification Exam Handlers
  void startExam() {
    _examTimer?.cancel();
    emit(
      state.copyWith(
        examState: ExamState(
          isExamActive: true,
          remainingSeconds: 600,
          currentQuestionIndex: 0,
          selectedAnswers: {},
          isSubmitted: false,
          totalQuestions: sampleExamQuestions.length,
        ),
      ),
    );

    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.examState.remainingSeconds <= 1) {
        timer.cancel();
        submitExam();
      } else {
        emit(
          state.copyWith(
            examState: state.examState.copyWith(
              remainingSeconds: state.examState.remainingSeconds - 1,
            ),
          ),
        );
      }
    });
  }

  void selectExamAnswer(int questionIndex, int optionIndex) {
    final updated = Map<int, int>.from(state.examState.selectedAnswers);
    updated[questionIndex] = optionIndex;
    emit(
      state.copyWith(
        examState: state.examState.copyWith(selectedAnswers: updated),
      ),
    );
  }

  void setExamQuestionIndex(int index) {
    if (index >= 0 && index < sampleExamQuestions.length) {
      emit(
        state.copyWith(
          examState: state.examState.copyWith(currentQuestionIndex: index),
        ),
      );
    }
  }

  void submitExam() {
    _examTimer?.cancel();
    _examTimer = null;

    int correct = 0;
    for (int i = 0; i < sampleExamQuestions.length; i++) {
      if (state.examState.selectedAnswers[i] ==
          sampleExamQuestions[i].correctOptionIndex) {
        correct++;
      }
    }

    final percentage = (correct / sampleExamQuestions.length) * 100;
    final passed = percentage >= 80;

    final randomHex = List.generate(
      16,
      (_) => Random().nextInt(16).toRadixString(16),
    ).join();
    final certHash = 'SKILLFORGE-CERT-$randomHex'.toUpperCase();

    if (passed) {
      repository.preferencesService.addXp(500);
    }

    emit(
      state.copyWith(
        examState: state.examState.copyWith(
          isExamActive: false,
          isSubmitted: true,
          score: correct,
          isPassed: passed,
          certificateHash: certHash,
        ),
        totalUserXp: repository.preferencesService.userXp,
      ),
    );
  }

  @override
  Future<void> close() {
    _examTimer?.cancel();
    return super.close();
  }
}
