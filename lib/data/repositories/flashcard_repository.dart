import '../datasources/local_database.dart';
import '../datasources/preferences_service.dart';
import '../models/flashcard_model.dart';
import '../../core/utils/sm2_algorithm.dart';

class FlashcardRepository {
  final AppDatabase database;
  final PreferencesService preferencesService;

  FlashcardRepository({
    required this.database,
    required this.preferencesService,
  });

  Future<List<FlashcardModel>> getFlashcards() async {
    return await database.getAllFlashcards();
  }

  Future<FlashcardModel> rateCard({
    required FlashcardModel card,
    required int grade,
  }) async {
    final sm2 = Sm2Algorithm.calculateNextReview(
      grade: grade,
      repetitions: card.repetitions,
      previousEaseFactor: card.easeFactor,
      previousIntervalDays: card.intervalDays,
    );

    final status = sm2.repetitions >= 4
        ? 'Mastered'
        : sm2.repetitions > 0
        ? 'Review'
        : 'Learning';

    final updated = card.copyWith(
      repetitions: sm2.repetitions,
      easeFactor: sm2.easeFactor,
      intervalDays: sm2.intervalDays,
      lastReviewedAt: DateTime.now().toIso8601String(),
      nextReviewAt: sm2.nextReviewDate.toIso8601String(),
      status: status,
    );

    await database.updateFlashcard(updated);
    await preferencesService.addXp(15);
    return updated;
  }

  Future<FlashcardModel> createCard({
    required String topicTag,
    required String frontPrompt,
    required String backAnswer,
    required String codeExample,
  }) async {
    final newCard = FlashcardModel(
      id: 'fc_${DateTime.now().millisecondsSinceEpoch}',
      trackId: 'custom',
      topicTag: topicTag,
      frontPrompt: frontPrompt,
      backAnswer: backAnswer,
      codeExample: codeExample,
      repetitions: 0,
      easeFactor: 2.5,
      intervalDays: 0,
      lastReviewedAt: '',
      nextReviewAt: DateTime.now().toIso8601String(),
      status: 'New',
    );

    await database.insertFlashcard(newCard);
    await preferencesService.addXp(25);
    return newCard;
  }
}
