import 'dart:async';

import '../datasources/local_database.dart';
import '../datasources/preferences_service.dart';

class MentorRepository {
  final AppDatabase database;
  final PreferencesService preferencesService;

  MentorRepository({required this.database, required this.preferencesService});

  Future<Map<String, dynamic>> gatherLearnerTelemetry() async {
    final tracks = await database.getAllTracks();
    final flashcards = await database.getAllFlashcards();
    final challenges = await database.getAllChallenges();

    final completedLessons = tracks.fold<int>(
      0,
      (sum, t) => sum + t.completedLessonsCount,
    );
    final completedChallenges = challenges.where((c) => c.isCompleted).length;
    final weakCards = flashcards
        .where((f) => f.status == 'Learning' || f.repetitions < 2)
        .toList();
    final weakTopics = weakCards.map((f) => f.topicTag).toSet().toList();

    return {
      'xp': preferencesService.userXp,
      'streak': preferencesService.streakDays,
      'completedLessons': completedLessons,
      'completedChallenges': completedChallenges,
      'weakTopics': weakTopics.isEmpty
          ? ['Dart Concurrency', 'Distributed Systems']
          : weakTopics,
      'retentionRate': flashcards.isEmpty
          ? 0.85
          : (flashcards.where((f) => f.status == 'Mastered').length /
                flashcards.length),
    };
  }

  Stream<String> generateSocraticStream(
    String userPrompt,
    Map<String, dynamic> telemetry,
  ) async* {
    final weakTopics =
        (telemetry['weakTopics'] as List<dynamic>?)?.join(', ') ??
        'Concurrency';
    final xp = telemetry['xp'] ?? 1400;

    final retentionNum = (telemetry['retentionRate'] as num? ?? 0.85) * 100;
    final retentionPercent = retentionNum.toInt();

    String responseText = '';
    if (userPrompt.contains('Review My Sandbox Solution')) {
      responseText =
          'Let us inspect your sandbox solution through first principles.\n\n'
          '1. In your LRU Cache / Debouncer implementation, what happens to memory allocations when 10,000 requests arrive concurrently?\n'
          '2. Notice your linked list updates: are pointer assignments executed inside a mutex or isolate boundary, or could a race condition cause dangling references?\n\n'
          'Consider: If we replace the linked list with a fixed-size ring buffer of unboxed integers, what is the impact on L1 CPU cache lines vs heap pointer chasing? How would you verify that using your telemetry bridge?';
    } else if (userPrompt.contains('Quiz Me')) {
      responseText =
          'Here is your Senior Flutter Architecture scenario:\n\n'
          'Suppose your team builds a real-time order book streaming 200 price updates per second into a Flutter desktop and mobile dashboard. During rapid bursts, frame rates drop from 120 FPS to 44 FPS.\n\n'
          'Diagnostic questions:\n'
          'A) Which phase of the pipeline is saturating: BuildOwner dirty marking, PipelineOwner flushLayout, or the GPU Raster thread?\n'
          'B) How would you utilize RepaintBoundary and CustomPainter with raw DisplayLists to eliminate widget rebuild overhead?\n'
          'C) Where would you place your StreamController buffer: on the main UI isolate or behind an Isolate.run worker with TransferableTypedData?';
    } else if (userPrompt.contains('Audit My Weakest Flashcard Topics')) {
      responseText =
          'Based on your live SM-2 spaced repetition telemetry:\n\n'
          'Your active retention rate is $retentionPercent%. Your weakest recall intervals are currently centered on: $weakTopics.\n\n'
          'Key knowledge gap detected:\n'
          '- Raft Log Completeness & Candidate election criteria.\n'
          '- RenderObject relayout boundaries vs repaint boundaries.\n\n'
          'Socratic Check: In Raft, why is having a higher term not always sufficient for a candidate to claim leadership? What second condition must its log satisfy?';
    } else if (userPrompt.contains('7-Day Staff Engineer Study Plan')) {
      responseText =
          'Here is your adaptive 7-Day Staff Engineering roadmap targeting your current velocity ($xp XP):\n\n'
          'Day 1-2: Flutter Engine Deep Internals (PipelineOwner, RenderObject layout constraints, Impeller SPIR-V shader passes)\n'
          'Day 3: Dart Isolate Shared Memory, TransferableTypedData & Native MethodChannel backpressure\n'
          'Day 4-5: Distributed Consensus Protocols (Raft leader election, Paxos invariants, WAL storage)\n'
          'Day 6: Production Vector Indexing (HNSW graphs vs IVF-PQ quantization)\n'
          'Day 7: Full Architectural Certification Mock Exam & System Design Review\n\n'
          'Which topic shall we tackle first today?';
    } else {
      responseText =
          'Analyzing your query through the lens of enterprise technical mastery.\n\n'
          'When evaluating "$userPrompt", consider the system constraints: What are the latency SLAs, memory bounds, and failure modes under peak concurrent load?\n\n'
          'What is your initial hypothesis for solving this, and what trade-offs between throughput and consistency are you willing to accept?';
    }

    // Token-by-token streaming
    final words = responseText.split(' ');
    for (int i = 0; i < words.length; i++) {
      yield words[i] + (i < words.length - 1 ? ' ' : '');
      await Future.delayed(const Duration(milliseconds: 25));
    }
  }
}
