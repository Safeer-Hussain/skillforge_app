import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/track_model.dart';
import '../models/lesson_model.dart';
import '../models/challenge_model.dart';
import '../models/flashcard_model.dart';
import '../models/cohort_and_mentor_models.dart';

class AppDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  // Allow injecting custom Database (e.g. for unit/widget tests)
  static void setMockDatabase(Database db) {
    _database = db;
  }

  Future<Database> initDb({String dbName = 'skillforge_mastery.db'}) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE tracks (
        id TEXT PRIMARY KEY,
        title TEXT,
        domain TEXT,
        difficulty TEXT,
        description TEXT,
        iconPath TEXT,
        isEnrolled INTEGER,
        isBookmarked INTEGER,
        progressPercent REAL,
        totalXp INTEGER,
        lessonsCount INTEGER,
        completedLessonsCount INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE lessons (
        id TEXT PRIMARY KEY,
        trackId TEXT,
        title TEXT,
        moduleTitle TEXT,
        durationMinutes INTEGER,
        timeComplexity TEXT,
        spaceComplexity TEXT,
        contentNotes TEXT,
        codeSnippet TEXT,
        isCompleted INTEGER,
        xpReward INTEGER,
        relatedChallengeId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE challenges (
        id TEXT PRIMARY KEY,
        title TEXT,
        difficulty TEXT,
        domain TEXT,
        description TEXT,
        starterCode TEXT,
        solutionCode TEXT,
        testCasesJson TEXT,
        cyclomaticTarget INTEGER,
        xpReward INTEGER,
        isCompleted INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        trackId TEXT,
        topicTag TEXT,
        frontPrompt TEXT,
        backAnswer TEXT,
        codeExample TEXT,
        repetitions INTEGER,
        easeFactor REAL,
        intervalDays INTEGER,
        lastReviewedAt TEXT,
        nextReviewAt TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE study_rooms (
        id TEXT PRIMARY KEY,
        title TEXT,
        topic TEXT,
        participantsCount INTEGER,
        pomodoroMinutes INTEGER,
        isActive INTEGER,
        hostName TEXT,
        userJoined INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE code_reviews (
        id TEXT PRIMARY KEY,
        authorName TEXT,
        authorRole TEXT,
        title TEXT,
        codeSnippet TEXT,
        description TEXT,
        upvotesCount INTEGER,
        isUpvoted INTEGER,
        commentsCount INTEGER,
        createdAt TEXT,
        tags TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE review_comments (
        id TEXT PRIMARY KEY,
        reviewId TEXT,
        authorName TEXT,
        authorRole TEXT,
        content TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE leaderboard (
        id TEXT PRIMARY KEY,
        rank INTEGER,
        name TEXT,
        title TEXT,
        xp INTEGER,
        streakDays INTEGER,
        isCurrentUser INTEGER
      )
    ''');
  }

  Future<void> _seedInitialData(Database db) async {
    // 18+ Seeded Career Tracks across 5 Domains & 3 Difficulties
    final tracks = [
      // Mobile Architecture & Flutter Internals
      const TrackModel(
        id: 'track_flutter_internals',
        title: 'Flutter Engine & RenderObject Pipeline Internals',
        domain: 'Mobile Architecture',
        difficulty: 'Staff/Principal',
        description: 'Deep dive into Element trees, RenderObjects, Impeller shading passes, raster threads, and dirty node marking.',
        iconPath: 'assets/images/track_flutter.png',
        isEnrolled: true,
        isBookmarked: true,
        progressPercent: 0.65,
        totalXp: 1800,
        lessonsCount: 6,
        completedLessonsCount: 4,
      ),
      const TrackModel(
        id: 'track_flutter_concurrency',
        title: 'Dart Isolate Concurrency & Shared Memory Offloading',
        domain: 'Mobile Architecture',
        difficulty: 'Senior',
        description: 'Architecting zero-jank background computation with Isolate.run, SendPort pools, and TransferableTypedData.',
        iconPath: 'assets/images/track_flutter.png',
        isEnrolled: true,
        isBookmarked: false,
        progressPercent: 0.40,
        totalXp: 1400,
        lessonsCount: 5,
        completedLessonsCount: 2,
      ),
      const TrackModel(
        id: 'track_flutter_state',
        title: 'Reactive State Machines: BLoC vs Riverpod Under Load',
        domain: 'Mobile Architecture',
        difficulty: 'Senior',
        description: 'Comparative telemetry, stream backpressure, test isolation, and state machine transitions in large enterprise apps.',
        iconPath: 'assets/images/track_flutter.png',
        isEnrolled: false,
        isBookmarked: true,
        progressPercent: 0.0,
        totalXp: 1200,
        lessonsCount: 5,
        completedLessonsCount: 0,
      ),
      const TrackModel(
        id: 'track_flutter_associate',
        title: 'Modern Flutter Essentials & Widget Lifecycle',
        domain: 'Mobile Architecture',
        difficulty: 'Associate',
        description: 'MasterBuildContext, InheritedWidget mechanics, key reconciliation, and declarative UI composition.',
        iconPath: 'assets/images/track_flutter.png',
        isEnrolled: false,
        isBookmarked: false,
        progressPercent: 0.0,
        totalXp: 800,
        lessonsCount: 4,
        completedLessonsCount: 0,
      ),

      // Clean Architecture & SOLID
      const TrackModel(
        id: 'track_clean_arch',
        title: 'Feature-First Clean Architecture & Domain Boundaries',
        domain: 'Clean Architecture',
        difficulty: 'Senior',
        description: 'Decoupling domain business rules from external frameworks, dependency inversion with GetIt, and pure use cases.',
        iconPath: 'assets/images/track_flutter.png',
        isEnrolled: true,
        isBookmarked: true,
        progressPercent: 0.50,
        totalXp: 1500,
        lessonsCount: 6,
        completedLessonsCount: 3,
      ),
      const TrackModel(
        id: 'track_solid_patterns',
        title: 'SOLID Principles & GoF Design Patterns in Dart',
        domain: 'Clean Architecture',
        difficulty: 'Associate',
        description: 'Pragmatic application of Factory, Strategy, Observer, Decorator, and Adapter patterns in mobile applications.',
        iconPath: 'assets/images/track_flutter.png',
        isEnrolled: false,
        isBookmarked: false,
        progressPercent: 0.0,
        totalXp: 950,
        lessonsCount: 5,
        completedLessonsCount: 0,
      ),
      const TrackModel(
        id: 'track_hexagonal_arch',
        title: 'Hexagonal Architecture & Ports-and-Adapters',
        domain: 'Clean Architecture',
        difficulty: 'Staff/Principal',
        description: 'Designing enterprise software cores invariant to UI frameworks, database engines, or transport protocols.',
        iconPath: 'assets/images/track_flutter.png',
        isEnrolled: false,
        isBookmarked: true,
        progressPercent: 0.0,
        totalXp: 1600,
        lessonsCount: 5,
        completedLessonsCount: 0,
      ),

      // Distributed Systems & Backends
      const TrackModel(
        id: 'track_distributed_consensus',
        title: 'Raft, Paxos & Distributed Consensus Protocols',
        domain: 'Distributed Systems',
        difficulty: 'Staff/Principal',
        description: 'Leader election, log replication, safety invariants, split-brain mitigation, and Byzantine fault tolerance.',
        iconPath: 'assets/images/track_distributed.png',
        isEnrolled: true,
        isBookmarked: true,
        progressPercent: 0.25,
        totalXp: 2100,
        lessonsCount: 6,
        completedLessonsCount: 1,
      ),
      const TrackModel(
        id: 'track_event_driven_backends',
        title: 'Event-Driven Microservices & Kafka Log Compaction',
        domain: 'Distributed Systems',
        difficulty: 'Senior',
        description: 'Outbox patterns, idempotency keys, consumer groups, partition rebalancing, and dead-letter queue architectures.',
        iconPath: 'assets/images/track_distributed.png',
        isEnrolled: false,
        isBookmarked: false,
        progressPercent: 0.0,
        totalXp: 1650,
        lessonsCount: 5,
        completedLessonsCount: 0,
      ),
      const TrackModel(
        id: 'track_grpc_microservices',
        title: 'High-Performance gRPC & Protocol Buffers in Dart/Go',
        domain: 'Distributed Systems',
        difficulty: 'Associate',
        description: 'Bi-directional streaming, binary serialization efficiency, code generation pipelines, and load balancing.',
        iconPath: 'assets/images/track_distributed.png',
        isEnrolled: false,
        isBookmarked: false,
        progressPercent: 0.0,
        totalXp: 1100,
        lessonsCount: 4,
        completedLessonsCount: 0,
      ),
      const TrackModel(
        id: 'track_database_internals',
        title: 'LSM-Trees, B+ Trees & Storage Engine Internals',
        domain: 'Distributed Systems',
        difficulty: 'Staff/Principal',
        description: 'Write-ahead logs (WAL), memtables, SSTables, bloom filters, write amplification, and ACID durability guarantees.',
        iconPath: 'assets/images/track_distributed.png',
        isEnrolled: false,
        isBookmarked: true,
        progressPercent: 0.0,
        totalXp: 2200,
        lessonsCount: 5,
        completedLessonsCount: 0,
      ),

      // Applied LLM Architecture & AI Engineering
      const TrackModel(
        id: 'track_rag_architecture',
        title: 'Production RAG: Vector Indexing & Hybrid Search',
        domain: 'AI Engineering',
        difficulty: 'Senior',
        description: 'HNSW indexing, cross-encoder reranking, semantic chunking strategies, and hallucination reduction guards.',
        iconPath: 'assets/images/track_ai.png',
        isEnrolled: true,
        isBookmarked: true,
        progressPercent: 0.80,
        totalXp: 1950,
        lessonsCount: 5,
        completedLessonsCount: 4,
      ),
      const TrackModel(
        id: 'track_ondevice_ai',
        title: 'On-Device LLM Inference & Quantization (GGUF/NPU)',
        domain: 'AI Engineering',
        difficulty: 'Staff/Principal',
        description: 'Running 4-bit quantized transformer weights on mobile NPUs with LiteRT/ExecuTorch and memory-mapped tensors.',
        iconPath: 'assets/images/track_ai.png',
        isEnrolled: false,
        isBookmarked: true,
        progressPercent: 0.0,
        totalXp: 2400,
        lessonsCount: 6,
        completedLessonsCount: 0,
      ),
      const TrackModel(
        id: 'track_agentic_workflows',
        title: 'Autonomous Agent Loops & Tool-Calling Graphs',
        domain: 'AI Engineering',
        difficulty: 'Senior',
        description: 'ReAct reasoning traces, cyclic graph workflows, state checkpoints, and multi-agent consensus validation.',
        iconPath: 'assets/images/track_ai.png',
        isEnrolled: false,
        isBookmarked: false,
        progressPercent: 0.0,
        totalXp: 1750,
        lessonsCount: 5,
        completedLessonsCount: 0,
      ),
      const TrackModel(
        id: 'track_prompt_engineering',
        title: 'Structured Outputs, Few-Shot & Socratic Prompting',
        domain: 'AI Engineering',
        difficulty: 'Associate',
        description: 'JSON Schema constrained decoding, chain-of-thought elicitation, and automated benchmark evaluations.',
        iconPath: 'assets/images/track_ai.png',
        isEnrolled: false,
        isBookmarked: false,
        progressPercent: 0.0,
        totalXp: 900,
        lessonsCount: 4,
        completedLessonsCount: 0,
      ),

      // System Design & Scalability
      const TrackModel(
        id: 'track_system_design_scaling',
        title: 'Scalable System Design: Millions of Concurrent Users',
        domain: 'System Design',
        difficulty: 'Staff/Principal',
        description: 'Consistent hashing, distributed caching tiers (Redis/Memcached), database sharding, and CDN edge delivery.',
        iconPath: 'assets/images/track_system_design.png',
        isEnrolled: true,
        isBookmarked: false,
        progressPercent: 0.50,
        totalXp: 2300,
        lessonsCount: 6,
        completedLessonsCount: 3,
      ),
      const TrackModel(
        id: 'track_rate_limiting',
        title: 'Distributed Rate Limiting & Token Bucket Algorithms',
        domain: 'System Design',
        difficulty: 'Senior',
        description: 'Sliding window logs, leaky bucket vs token bucket, Redis Lua atomic scripts, and gracefully handling DDoS spikes.',
        iconPath: 'assets/images/track_system_design.png',
        isEnrolled: false,
        isBookmarked: true,
        progressPercent: 0.0,
        totalXp: 1450,
        lessonsCount: 5,
        completedLessonsCount: 0,
      ),
      const TrackModel(
        id: 'track_capacity_planning',
        title: 'Back-of-the-Envelope Capacity & QPS Calculations',
        domain: 'System Design',
        difficulty: 'Associate',
        description: 'Storage projections, bandwidth sizing, IOPS constraints, latency SLA planning, and availability nines math.',
        iconPath: 'assets/images/track_system_design.png',
        isEnrolled: false,
        isBookmarked: false,
        progressPercent: 0.0,
        totalXp: 1050,
        lessonsCount: 4,
        completedLessonsCount: 0,
      ),
    ];

    for (final track in tracks) {
      await db.insert('tracks', track.toMap());
    }

    // Seed Lessons for Flutter Internals
    final lessons = [
      const LessonModel(
        id: 'lesson_render_tree',
        trackId: 'track_flutter_internals',
        title: 'The Three Trees: Widget, Element & RenderObject',
        moduleTitle: 'Module 1: Rendering Pipeline',
        durationMinutes: 20,
        timeComplexity: 'O(1)',
        spaceComplexity: 'O(n)',
        contentNotes: 'Flutter avoids rebuilding full native views by maintaining three parallel hierarchies: immutable Widget descriptions, persistent Element nodes acting as lifecycle managers, and RenderObjects holding paint boundaries and layout constraints.',
        codeSnippet: '''class OptimizedRenderBox extends RenderBox {
  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    final paint = Paint()..color = const Color(0xFF10B981);
    canvas.drawRect(offset & size, paint);
  }
}''',
        isCompleted: true,
        xpReward: 100,
        relatedChallengeId: 'challenge_lru_cache',
      ),
      const LessonModel(
        id: 'lesson_pipeline_owner',
        trackId: 'track_flutter_internals',
        title: 'PipelineOwner & The 60/120 FPS Frame Lifecycle',
        moduleTitle: 'Module 1: Rendering Pipeline',
        durationMinutes: 25,
        timeComplexity: 'O(n)',
        spaceComplexity: 'O(1)',
        contentNotes: 'PipelineOwner coordinates flushLayout, flushCompositingBits, flushPaint, and flushSemantics. Relayout boundaries prune subtrees that need not be remeasured during dynamic animation ticks.',
        codeSnippet: '''void flushLayout() {
  while (_nodesNeedingLayout.isNotEmpty) {
    final node = _nodesNeedingLayout.removeFirst();
    if (node._needsLayout && node.owner == this) {
      node._layoutWithoutResize();
    }
  }
}''',
        isCompleted: true,
        xpReward: 120,
        relatedChallengeId: 'challenge_lru_cache',
      ),
      const LessonModel(
        id: 'lesson_impeller_raster',
        trackId: 'track_flutter_internals',
        title: 'Impeller Architecture vs Skia Shader Warmup',
        moduleTitle: 'Module 2: Graphics & Shaders',
        durationMinutes: 18,
        timeComplexity: 'O(1)',
        spaceComplexity: 'O(1)',
        contentNotes: 'Impeller compiles shaders ahead-of-time (AOT) to Vulkan and Metal shading language SPIR-V representations, eliminating runtime compilation hitches that plagued mobile graphic pipelines.',
        codeSnippet: '''// Shaders pre-compiled AOT via impeller-c
layout(location = 0) in vec4 position;
layout(location = 1) in vec4 color;
layout(location = 0) out vec4 vColor;

void main() {
    gl_Position = position;
    vColor = color;
}''',
        isCompleted: true,
        xpReward: 110,
        relatedChallengeId: 'challenge_stream_debouncer',
      ),
      const LessonModel(
        id: 'lesson_repaint_boundary',
        trackId: 'track_flutter_internals',
        title: 'RepaintBoundaries & DisplayList Layer Caching',
        moduleTitle: 'Module 2: Graphics & Shaders',
        durationMinutes: 22,
        timeComplexity: 'O(1)',
        spaceComplexity: 'O(k)',
        contentNotes: 'Wrapping frequently animating subtrees in RepaintBoundary creates an isolated DisplayList texture layer, preventing sibling widgets from repainting during scrolling or pulse animations.',
        codeSnippet: '''Widget buildOptimizedTile(BuildContext context) {
  return const RepaintBoundary(
    child: AnimatedPulseBeacon(),
  );
}''',
        isCompleted: true,
        xpReward: 90,
        relatedChallengeId: 'challenge_stream_debouncer',
      ),
      const LessonModel(
        id: 'lesson_dirty_marking',
        trackId: 'track_flutter_internals',
        title: 'BuildOwner, markNeedsBuild & VSYNC Scheduling',
        moduleTitle: 'Module 3: Scheduling & Microtasks',
        durationMinutes: 30,
        timeComplexity: 'O(log n)',
        spaceComplexity: 'O(n)',
        contentNotes: 'When setState() is triggered, Element.markNeedsBuild() adds the element to the BuildOwner dirty list. The engine waits for the next VSYNC callback before executing the build phase.',
        codeSnippet: '''void markNeedsBuild() {
  if (!_dirty) {
    _dirty = true;
    owner!.scheduleBuildFor(this);
  }
}''',
        isCompleted: false,
        xpReward: 150,
        relatedChallengeId: 'challenge_token_bucket',
      ),
      const LessonModel(
        id: 'lesson_layer_trees',
        trackId: 'track_flutter_internals',
        title: 'Engine Layer Trees & Platform View Composition',
        moduleTitle: 'Module 3: Scheduling & Microtasks',
        durationMinutes: 28,
        timeComplexity: 'O(n)',
        spaceComplexity: 'O(n)',
        contentNotes: 'Understanding texture layer compositing, Virtual Display vs Hybrid Composition, and memory overhead of hardware overlay buffers in complex enterprise mobile applications.',
        codeSnippet: '''final SceneBuilder builder = SceneBuilder();
builder.pushOffset(0, 0);
builder.addPicture(Offset.zero, picture);
final Scene scene = builder.build();
window.render(scene);''',
        isCompleted: false,
        xpReward: 160,
        relatedChallengeId: 'challenge_tree_traversal',
      ),
    ];

    for (final lesson in lessons) {
      await db.insert('lessons', lesson.toMap());
    }

    // Seed Curated Coding & Architecture Challenges
    final challenges = [
      const ChallengeModel(
        id: 'challenge_lru_cache',
        title: 'Thread-Safe LRU Cache with O(1) Eviction',
        difficulty: 'Senior',
        domain: 'Data Structures',
        description: 'Implement a Least Recently Used (LRU) Cache supporting get(K key) and put(K key, V value) operations in strictly O(1) time complexity utilizing a Doubly Linked List and Hash Map.',
        starterCode: '''class LruCache<K, V> {
  final int capacity;
  final Map<K, _Node<K, V>> _cache = {};
  _Node<K, V>? _head;
  _Node<K, V>? _tail;

  LruCache(this.capacity);

  V? get(K key) {
    // Implement O(1) lookup and move to head
    if (!_cache.containsKey(key)) return null;
    final node = _cache[key]!;
    _moveToHead(node);
    return node.value;
  }

  void put(K key, V value) {
    // Implement O(1) insertion, update, and capacity eviction
    if (_cache.containsKey(key)) {
      final node = _cache[key]!;
      node.value = value;
      _moveToHead(node);
      return;
    }
    if (_cache.length >= capacity) {
      _removeTail();
    }
    final newNode = _Node(key, value);
    _cache[key] = newNode;
    _addToHead(newNode);
  }

  void _moveToHead(_Node<K, V> node) {
    _removeNode(node);
    _addToHead(node);
  }

  void _addToHead(_Node<K, V> node) {
    node.next = _head;
    node.prev = null;
    if (_head != null) _head!.prev = node;
    _head = node;
    _tail ??= node;
  }

  void _removeNode(_Node<K, V> node) {
    if (node.prev != null) node.prev!.next = node.next;
    else _head = node.next;
    if (node.next != null) node.next!.prev = node.prev;
    else _tail = node.prev;
  }

  void _removeTail() {
    if (_tail == null) return;
    _cache.remove(_tail!.key);
    _removeNode(_tail!);
  }
}

class _Node<K, V> {
  final K key;
  V value;
  _Node<K, V>? prev;
  _Node<K, V>? next;
  _Node(this.key, this.value);
}''',
        solutionCode: '// Full O(1) LRU solution included in template',
        testCasesJson: '''[
          {"name": "Boundary Capacity Eviction", "expected": true, "actual": true},
          {"name": "O(1) Head Refresh on Access", "expected": true, "actual": true},
          {"name": "Concurrency Mutex Guard", "expected": true, "actual": true},
          {"name": "Zero Memory Leaks on Teardown", "expected": true, "actual": true}
        ]''',
        cyclomaticTarget: 6,
        xpReward: 200,
        isCompleted: true,
      ),
      const ChallengeModel(
        id: 'challenge_stream_debouncer',
        title: 'Optimize Riverpod/BLoC Stream Debouncer',
        difficulty: 'Staff/Principal',
        domain: 'Reactive Programming',
        description: 'Build a memory-safe stream transformer that debounces high-frequency search keystrokes while guaranteeing immediate emission on leading events when required.',
        starterCode: '''import 'dart:async';

StreamTransformer<T, T> debounce<T>(Duration duration, {bool leading = false}) {
  Timer? timer;
  bool hasEmittedLeading = false;

  return StreamTransformer<T, T>.fromHandlers(
    handleData: (data, sink) {
      if (leading && !hasEmittedLeading) {
        sink.add(data);
        hasEmittedLeading = true;
      }
      timer?.cancel();
      timer = Timer(duration, () {
        if (!leading || hasEmittedLeading) {
          sink.add(data);
        }
        hasEmittedLeading = false;
      });
    },
    handleDone: (sink) {
      timer?.cancel();
      sink.close();
    },
  );
}''',
        solutionCode: '// Full Debounce stream transformer',
        testCasesJson: '''[
          {"name": "Trailing Burst Suppression", "expected": true, "actual": true},
          {"name": "Leading Instant Emission", "expected": true, "actual": true},
          {"name": "Timer Cancellation on Stream Close", "expected": true, "actual": true},
          {"name": "Zero CPU Spikes Under 10kHz Keystrokes", "expected": true, "actual": true}
        ]''',
        cyclomaticTarget: 5,
        xpReward: 220,
        isCompleted: false,
      ),
      const ChallengeModel(
        id: 'challenge_token_bucket',
        title: 'Rate-Limiter Token Bucket with Atomic Refill',
        difficulty: 'Senior',
        domain: 'System Design',
        description: 'Implement an atomic token bucket rate-limiter calculating dynamic tokens based on elapsed nanoseconds without periodic background timer drift.',
        starterCode: '''class TokenBucket {
  final double capacity;
  final double refillRatePerSecond;
  double _tokens;
  DateTime _lastRefill;

  TokenBucket({
    required this.capacity,
    required this.refillRatePerSecond,
  })  : _tokens = capacity,
        _lastRefill = DateTime.now();

  bool allowRequest(double tokensRequired) {
    _refill();
    if (_tokens >= tokensRequired) {
      _tokens -= tokensRequired;
      return true;
    }
    return false;
  }

  void _refill() {
    final now = DateTime.now();
    final elapsedSec = now.difference(_lastRefill).inMicroseconds / 1000000.0;
    _tokens = (_tokens + elapsedSec * refillRatePerSecond).clamp(0.0, capacity);
    _lastRefill = now;
  }
}''',
        solutionCode: '// Full atomic token bucket',
        testCasesJson: '''[
          {"name": "Burst Limit Enforcement", "expected": true, "actual": true},
          {"name": "Atomic Mathematical Refill", "expected": true, "actual": true},
          {"name": "Zero Timer Drift Over 24h", "expected": true, "actual": true},
          {"name": "Thread-Safe Reservation Invariant", "expected": true, "actual": true}
        ]''',
        cyclomaticTarget: 4,
        xpReward: 180,
        isCompleted: false,
      ),
      const ChallengeModel(
        id: 'challenge_tree_traversal',
        title: 'Binary Tree Level-Order (BFS) with Memory Bounds',
        difficulty: 'Senior',
        domain: 'Algorithms',
        description: 'Perform level-order traversal of a binary tree returning a list of values per level while strictly bounding queue memory footprint.',
        starterCode: '''import 'dart:collection';

class TreeNode {
  final int val;
  TreeNode? left;
  TreeNode? right;
  TreeNode(this.val, [this.left, this.right]);
}

List<List<int>> levelOrder(TreeNode? root) {
  if (root == null) return [];
  final result = <List<int>>[];
  final queue = Queue<TreeNode>()..add(root);

  while (queue.isNotEmpty) {
    final levelSize = queue.length;
    final currentLevel = <int>[];

    for (int i = 0; i < levelSize; i++) {
      final node = queue.removeFirst();
      currentLevel.add(node.val);
      if (node.left != null) queue.add(node.left!);
      if (node.right != null) queue.add(node.right!);
    }
    result.add(currentLevel);
  }

  return result;
}''',
        solutionCode: '// Full BFS traversal',
        testCasesJson: '''[
          {"name": "Empty Tree Boundary", "expected": true, "actual": true},
          {"name": "Multi-Level Hierarchy Order", "expected": true, "actual": true},
          {"name": "Unbalanced Skewed Tree Invariant", "expected": true, "actual": true},
          {"name": "Queue Memory Reclamation", "expected": true, "actual": true}
        ]''',
        cyclomaticTarget: 5,
        xpReward: 160,
        isCompleted: false,
      ),
    ];

    for (final ch in challenges) {
      await db.insert('challenges', ch.toMap());
    }

    // Seed Spaced-Repetition SM-2 Flashcards
    final flashcards = [
      const FlashcardModel(
        id: 'fc_1',
        trackId: 'track_flutter_internals',
        topicTag: 'Flutter Engine',
        frontPrompt: 'What is the exact distinction between markNeedsLayout() and markNeedsPaint() in RenderObject?',
        backAnswer: 'markNeedsLayout() flags the render object and bubbles up to its relayout boundary, scheduling a measurement pass. markNeedsPaint() does NOT re-measure sizes; it only schedules a repaint pass onto an existing or new DisplayList layer.',
        codeExample: '''// Paint pass avoids layout recalculation
void markNeedsPaint() {
  if (_needsPaint) return;
  _needsPaint = true;
  if (isRepaintBoundary) {
    owner?._nodesNeedingPaint.add(this);
  } else {
    parent?.markNeedsPaint();
  }
}''',
        repetitions: 3,
        easeFactor: 2.6,
        intervalDays: 6,
        lastReviewedAt: '2026-11-14T10:00:00Z',
        nextReviewAt: '2026-11-20T10:00:00Z',
        status: 'Review',
      ),
      const FlashcardModel(
        id: 'fc_2',
        trackId: 'track_flutter_concurrency',
        topicTag: 'Dart Concurrency',
        frontPrompt: 'How does Isolate.run() optimize memory transfer compared to legacy Isolate.spawn()?',
        backAnswer: 'Isolate.run() returns an exit message by passing pointers directly across isolate memory boundaries when possible, avoiding the deep copy serialization overhead of standard Port messages for primitive transferable buffers.',
        codeExample: '''final processed = await Isolate.run(() {
  return heavyAstTransform(rawSourceBytes);
});''',
        repetitions: 2,
        easeFactor: 2.5,
        intervalDays: 3,
        lastReviewedAt: '2026-11-13T12:00:00Z',
        nextReviewAt: '2026-11-16T12:00:00Z',
        status: 'Learning',
      ),
      const FlashcardModel(
        id: 'fc_3',
        trackId: 'track_distributed_consensus',
        topicTag: 'Distributed Systems',
        frontPrompt: 'Under what conditions does a Raft candidate fail to win an election even with majority votes?',
        backAnswer: 'In Raft, a candidate cannot win if its log is not at least as up-to-date as the majority’s logs (comparing last term, then last log index). This Log Completeness guarantee prevents committed entries from being overwritten.',
        codeExample: '''bool isLogUpToDate(int lastTerm, int lastIndex) {
  if (candidateLastTerm != myLastTerm) {
    return candidateLastTerm > myLastTerm;
  }
  return candidateLastIndex >= myLastIndex;
}''',
        repetitions: 1,
        easeFactor: 2.36,
        intervalDays: 1,
        lastReviewedAt: '2026-11-14T08:00:00Z',
        nextReviewAt: '2026-11-15T08:00:00Z',
        status: 'Learning',
      ),
      const FlashcardModel(
        id: 'fc_4',
        trackId: 'track_clean_arch',
        topicTag: 'Clean Architecture',
        frontPrompt: 'Why must Domain Entities never import packages from the Data or Presentation layer?',
        backAnswer: 'The Dependency Inversion Principle dictates high-level business rules must not depend on low-level implementation details. When domain code depends only on pure language primitives, external UI frameworks or databases can be swapped with zero enterprise regression.',
        codeExample: '''// Domain Entity: Pure Dart
class AuthSession {
  final String userId;
  final DateTime expiresAt;
  AuthSession(this.userId, this.expiresAt);
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}''',
        repetitions: 4,
        easeFactor: 2.7,
        intervalDays: 12,
        lastReviewedAt: '2026-11-10T14:00:00Z',
        nextReviewAt: '2026-11-22T14:00:00Z',
        status: 'Mastered',
      ),
      const FlashcardModel(
        id: 'fc_5',
        trackId: 'track_rag_architecture',
        topicTag: 'AI Architecture',
        frontPrompt: 'What is the primary trade-off between HNSW and IVF-PQ vector indexing in production?',
        backAnswer: 'HNSW (Hierarchical Navigable Small World) offers superior recall (>95%) and sub-millisecond query latency at the expense of high RAM consumption. IVF-PQ compresses vectors into quantized centroids, lowering memory footprint 80% while incurring modest recall loss.',
        codeExample: '''// HNSW graph traversal: O(log N)
final neighbors = hnswIndex.search(queryVector, k: 10, efSearch: 64);''',
        repetitions: 0,
        easeFactor: 2.5,
        intervalDays: 0,
        lastReviewedAt: '',
        nextReviewAt: '2026-11-15T19:00:00Z',
        status: 'New',
      ),
    ];

    for (final fc in flashcards) {
      await db.insert('flashcards', fc.toMap());
    }

    // Seed Cohort Study Rooms
    final rooms = [
      const StudyRoomModel(
        id: 'room_1',
        title: 'Deep Focus: Flutter Impeller & Engine Internals',
        topic: 'Graphics Pipeline & Shaders',
        participantsCount: 8,
        pomodoroMinutes: 50,
        isActive: true,
        hostName: 'Staff Mobile Architect',
        userJoined: false,
      ),
      const StudyRoomModel(
        id: 'room_2',
        title: 'Silent Sprint: Distributed Mutex & Raft Consensus',
        topic: 'Distributed Systems',
        participantsCount: 14,
        pomodoroMinutes: 25,
        isActive: true,
        hostName: 'Principal Backend Lead',
        userJoined: false,
      ),
      const StudyRoomModel(
        id: 'room_3',
        title: 'Architecture Review: On-Device LLM & LiteRT Graphs',
        topic: 'AI Architecture',
        participantsCount: 6,
        pomodoroMinutes: 45,
        isActive: true,
        hostName: 'Senior AI Engineer',
        userJoined: false,
      ),
    ];

    for (final room in rooms) {
      await db.insert('study_rooms', room.toMap());
    }

    // Seed Peer Code Reviews
    final reviews = [
      const CodeReviewModel(
        id: 'cr_1',
        authorName: 'Marcus Vance',
        authorRole: 'Senior Staff Engineer',
        title: 'RFC: Non-blocking Ring Buffer for Sensor Telemetry in Dart',
        codeSnippet: '''class RingBuffer<T> {
  final List<T?> _buffer;
  int _head = 0;
  int _tail = 0;
  RingBuffer(int capacity) : _buffer = List.filled(capacity, null);
  
  bool push(T item) {
    if ((_tail + 1) % _buffer.length == _head) return false;
    _buffer[_tail] = item;
    _tail = (_tail + 1) % _buffer.length;
    return true;
  }
}''',
        description: 'Reviewing cache line alignment and concurrency semantics when shared between UI isolate and telemetry worker.',
        upvotesCount: 24,
        isUpvoted: false,
        commentsCount: 3,
        createdAt: '2 hours ago',
        tags: 'Performance, Concurrency',
      ),
      const CodeReviewModel(
        id: 'cr_2',
        authorName: 'Elena Rostova',
        authorRole: 'Mobile Architect',
        title: 'Eliminating RenderFlex Overflows in Nested Multi-Pane Slates',
        codeSnippet: '''LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxHeight < 400) {
      return NavigationRail(minWidth: 56, ...);
    }
    return BottomNavigationBar(...);
  },
)''',
        description: 'Safeguarding landscape viewports on ultra-wide devices with dynamic intrinsic rail wrappers.',
        upvotesCount: 42,
        isUpvoted: true,
        commentsCount: 7,
        createdAt: '5 hours ago',
        tags: 'Flutter, Architecture',
      ),
    ];

    for (final cr in reviews) {
      await db.insert('code_reviews', cr.toMap());
    }

    // Seed Review Comments
    final comments = [
      const ReviewCommentModel(
        id: 'rc_1',
        reviewId: 'cr_1',
        authorName: 'Alex Mercer',
        authorRole: 'Systems Lead',
        content: 'Consider adding atomic compare-and-swap (CAS) pointers if this buffer is mutated without isolate port locks.',
        createdAt: '1 hour ago',
      ),
      const ReviewCommentModel(
        id: 'rc_2',
        reviewId: 'cr_1',
        authorName: 'Sophia Lin',
        authorRole: 'Staff Mobile Engineer',
        content: 'Benchmark with 100,000 packets per second showed zero GC pauses with this pre-allocated array strategy.',
        createdAt: '30 mins ago',
      ),
    ];

    for (final cm in comments) {
      await db.insert('review_comments', cm.toMap());
    }

    // Seed Leaderboard
    final leaderboard = [
      const LeaderboardEntryModel(
        id: 'lb_1',
        rank: 1,
        name: 'Devin K. (Staff Architect)',
        title: 'Systems & Runtime Lead',
        xp: 4850,
        streakDays: 42,
      ),
      const LeaderboardEntryModel(
        id: 'lb_2',
        rank: 2,
        name: 'Elena Rostova',
        title: 'Principal Mobile Engineer',
        xp: 4200,
        streakDays: 31,
      ),
      const LeaderboardEntryModel(
        id: 'lb_3',
        rank: 3,
        name: 'Safeer Hussain',
        title: 'Principal Architect (You)',
        xp: 3650,
        streakDays: 14,
        isCurrentUser: true,
      ),
      const LeaderboardEntryModel(
        id: 'lb_4',
        rank: 4,
        name: 'Tariq Al-Mansoor',
        title: 'Senior Distributed Lead',
        xp: 3200,
        streakDays: 19,
      ),
      const LeaderboardEntryModel(
        id: 'lb_5',
        rank: 5,
        name: 'Chloe Zhang',
        title: 'AI Systems Researcher',
        xp: 2980,
        streakDays: 12,
      ),
    ];

    for (final lb in leaderboard) {
      await db.insert('leaderboard', lb.toMap());
    }
  }

  // Database Access Queries
  Future<List<TrackModel>> getAllTracks() async {
    final db = await database;
    final maps = await db.query('tracks', orderBy: 'title ASC');
    return maps.map((m) => TrackModel.fromMap(m)).toList();
  }

  Future<void> updateTrack(TrackModel track) async {
    final db = await database;
    await db.update(
      'tracks',
      track.toMap(),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  Future<List<LessonModel>> getLessonsForTrack(String trackId) async {
    final db = await database;
    final maps = await db.query(
      'lessons',
      where: 'trackId = ?',
      whereArgs: [trackId],
    );
    return maps.map((m) => LessonModel.fromMap(m)).toList();
  }

  Future<void> updateLesson(LessonModel lesson) async {
    final db = await database;
    await db.update(
      'lessons',
      lesson.toMap(),
      where: 'id = ?',
      whereArgs: [lesson.id],
    );
  }

  Future<List<ChallengeModel>> getAllChallenges() async {
    final db = await database;
    final maps = await db.query('challenges', orderBy: 'id ASC');
    return maps.map((m) => ChallengeModel.fromMap(m)).toList();
  }

  Future<void> updateChallenge(ChallengeModel challenge) async {
    final db = await database;
    await db.update(
      'challenges',
      challenge.toMap(),
      where: 'id = ?',
      whereArgs: [challenge.id],
    );
  }

  Future<List<FlashcardModel>> getAllFlashcards() async {
    final db = await database;
    final maps = await db.query('flashcards', orderBy: 'topicTag ASC');
    return maps.map((m) => FlashcardModel.fromMap(m)).toList();
  }

  Future<void> insertFlashcard(FlashcardModel card) async {
    final db = await database;
    await db.insert('flashcards', card.toMap());
  }

  Future<void> updateFlashcard(FlashcardModel card) async {
    final db = await database;
    await db.update(
      'flashcards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<List<StudyRoomModel>> getStudyRooms() async {
    final db = await database;
    final maps = await db.query(
      'study_rooms',
      orderBy: 'participantsCount DESC',
    );
    return maps.map((m) => StudyRoomModel.fromMap(m)).toList();
  }

  Future<void> updateStudyRoom(StudyRoomModel room) async {
    final db = await database;
    await db.update(
      'study_rooms',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<void> insertStudyRoom(StudyRoomModel room) async {
    final db = await database;
    await db.insert('study_rooms', room.toMap());
  }

  Future<List<CodeReviewModel>> getCodeReviews() async {
    final db = await database;
    final maps = await db.query('code_reviews', orderBy: 'upvotesCount DESC');
    return maps.map((m) => CodeReviewModel.fromMap(m)).toList();
  }

  Future<void> updateCodeReview(CodeReviewModel review) async {
    final db = await database;
    await db.update(
      'code_reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  Future<void> insertCodeReview(CodeReviewModel review) async {
    final db = await database;
    await db.insert('code_reviews', review.toMap());
  }

  Future<List<ReviewCommentModel>> getCommentsForReview(String reviewId) async {
    final db = await database;
    final maps = await db.query(
      'review_comments',
      where: 'reviewId = ?',
      whereArgs: [reviewId],
    );
    return maps.map((m) => ReviewCommentModel.fromMap(m)).toList();
  }

  Future<void> insertComment(ReviewCommentModel comment) async {
    final db = await database;
    await db.insert('review_comments', comment.toMap());
  }

  Future<List<LeaderboardEntryModel>> getLeaderboard() async {
    final db = await database;
    final maps = await db.query('leaderboard', orderBy: 'rank ASC');
    return maps.map((m) => LeaderboardEntryModel.fromMap(m)).toList();
  }
}
