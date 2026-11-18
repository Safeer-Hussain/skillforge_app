import 'package:sqflite/sqflite.dart';

import '../datasources/local_database.dart';
import '../models/regex_json_template_model.dart';

class RegexJsonRepository {
  final AppDatabase database;

  RegexJsonRepository({required this.database});

  Future<Database> _getDb() async {
    final db = await database.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS regex_json_templates (
        id TEXT PRIMARY KEY,
        title TEXT,
        type TEXT,
        pattern TEXT,
        sampleInput TEXT,
        optionsJson TEXT,
        isPreset INTEGER,
        createdAt TEXT
      )
    ''');
    return db;
  }

  Future<List<RegexJsonTemplateModel>> getTemplates() async {
    final db = await _getDb();
    final results = await db.query(
      'regex_json_templates',
      orderBy: 'isPreset DESC, createdAt DESC',
    );

    if (results.isEmpty) {
      final seeded = _getCuratedPresets();
      final batch = db.batch();
      for (final t in seeded) {
        batch.insert(
          'regex_json_templates',
          t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      return seeded;
    }

    return results.map((r) => RegexJsonTemplateModel.fromMap(r)).toList();
  }

  Future<void> saveTemplate(RegexJsonTemplateModel template) async {
    final db = await _getDb();
    await db.insert(
      'regex_json_templates',
      template.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTemplate(String id) async {
    final db = await _getDb();
    await db.delete(
      'regex_json_templates',
      where: 'id = ? AND isPreset = 0',
      whereArgs: [id],
    );
  }

  List<RegexJsonTemplateModel> _getCuratedPresets() {
    final now = DateTime(2026, 11, 18);
    return [
      // Regex 1: Semantic Versioning 2.0.0
      RegexJsonTemplateModel(
        id: 'preset_regex_semver',
        title: 'Semantic Versioning 2.0.0 (SemVer)',
        type: 'regex',
        pattern: r'^v?(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
        sampleInput: 'v2.14.3-alpha.1+build.4820',
        options: {'caseInsensitive': false, 'multiLine': false},
        isPreset: true,
        createdAt: now,
      ),

      // Regex 2: JWT Bearer Token Header/Payload/Signature
      RegexJsonTemplateModel(
        id: 'preset_regex_jwt',
        title: 'JWT Bearer Compact Serialization',
        type: 'regex',
        pattern: r'^[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*$',
        sampleInput: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkFsaWNlIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
        options: {'caseInsensitive': false, 'multiLine': false},
        isPreset: true,
        createdAt: now,
      ),

      // Regex 3: RFC 5322 Email with Domain Captures
      RegexJsonTemplateModel(
        id: 'preset_regex_email',
        title: 'RFC 5322 Standard Email Address',
        type: 'regex',
        pattern: r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$',
        sampleInput: 'architect.safeer@skillforge.dev',
        options: {'caseInsensitive': true, 'multiLine': false},
        isPreset: true,
        createdAt: now,
      ),

      // Regex 4: ISO 8601 UTC Timestamp with Timezone Offset
      RegexJsonTemplateModel(
        id: 'preset_regex_iso_date',
        title: 'ISO 8601 UTC Extended Timestamp',
        type: 'regex',
        pattern: r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$',
        sampleInput: '2026-11-18T15:30:00.000Z',
        options: {'caseInsensitive': false, 'multiLine': false},
        isPreset: true,
        createdAt: now,
      ),

      // Regex 5: IPv4 & CIDR Subnet Notation
      RegexJsonTemplateModel(
        id: 'preset_regex_ipv4',
        title: 'IPv4 Address & CIDR Prefix',
        type: 'regex',
        pattern: r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(?:\/(3[0-2]|[12]?[0-9]))?$',
        sampleInput: '192.168.1.1/24',
        options: {'caseInsensitive': false, 'multiLine': false},
        isPreset: true,
        createdAt: now,
      ),

      // JSON Schema 1: AI Socratic Engineering Mentor Response
      RegexJsonTemplateModel(
        id: 'preset_schema_ai_mentor',
        title: 'AI Socratic Mentor Structured Response Schema',
        type: 'json_schema',
        pattern: '''{
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["mentorName", "architecturalFocus", "confidenceScore", "socraticInquiry", "suggestedFix"],
  "properties": {
    "mentorName": { "type": "string", "minLength": 3 },
    "architecturalFocus": { "type": "string" },
    "confidenceScore": { "type": "number", "minimum": 0.0, "maximum": 1.0 },
    "socraticInquiry": { "type": "string", "minLength": 10 },
    "suggestedFix": { "type": "string" },
    "references": {
      "type": "array",
      "items": { "type": "string" }
    }
  }
}''',
        sampleInput: '''{
  "mentorName": "Dr. Turing (Staff Mobile Architect)",
  "architecturalFocus": "Impeller Raster Shaders & DisplayList Caching",
  "confidenceScore": 0.98,
  "socraticInquiry": "Why does wrapping frequently repainted child widgets in RepaintBoundary isolate dirty frame marks?",
  "suggestedFix": "Wrap the AnimatedPulse widget inside a RepaintBoundary to stop root layer invalidation.",
  "references": ["Flutter Engine RenderObject Pipeline", "Skia vs Impeller SPIR-V Passes"]
}''',
        options: {},
        isPreset: true,
        createdAt: now,
      ),

      // JSON Schema 2: Native Focus Telemetry Packet Specification
      RegexJsonTemplateModel(
        id: 'preset_schema_telemetry',
        title: 'Native Focus Telemetry Packet Specification',
        type: 'json_schema',
        pattern: '''{
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["sessionId", "focusSeconds", "sandboxHeapMemoryMb", "astParseLatencyMs", "isImpellerActive"],
  "properties": {
    "sessionId": { "type": "string", "pattern": "^[0-9a-fA-F-]{36}\$" },
    "focusSeconds": { "type": "integer", "minimum": 0 },
    "sandboxHeapMemoryMb": { "type": "number", "minimum": 1.0, "maximum": 512.0 },
    "astParseLatencyMs": { "type": "integer", "minimum": 0, "maximum": 5000 },
    "isImpellerActive": { "type": "boolean" },
    "activeTags": {
      "type": "array",
      "items": { "type": "string" }
    }
  }
}''',
        sampleInput: '''{
  "sessionId": "e82b3a19-48fe-4b16-89d7-83d8e5b8d2fa",
  "focusSeconds": 1540,
  "sandboxHeapMemoryMb": 42.5,
  "astParseLatencyMs": 18,
  "isImpellerActive": true,
  "activeTags": ["BLoC", "Clean Architecture", "SM-2"]
}''',
        options: {},
        isPreset: true,
        createdAt: now,
      ),

      // JSON Schema 3: Microservice Event Sourcing CloudEvent
      RegexJsonTemplateModel(
        id: 'preset_schema_cloudevent',
        title: 'CloudEvents v1.0 Distributed Envelope Specification',
        type: 'json_schema',
        pattern: '''{
  "\$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["specversion", "id", "source", "type", "data"],
  "properties": {
    "specversion": { "type": "string", "enum": ["1.0"] },
    "id": { "type": "string", "minLength": 1 },
    "source": { "type": "string" },
    "type": { "type": "string" },
    "time": { "type": "string" },
    "datacontenttype": { "type": "string" },
    "data": { "type": "object" }
  }
}''',
        sampleInput: '''{
  "specversion": "1.0",
  "id": "evt_7720914820",
  "source": "/skillforge/sandbox/isolate_executor",
  "type": "com.skillforge.sandbox.code_evaluated",
  "time": "2026-11-18T15:45:00Z",
  "datacontenttype": "application/json",
  "data": {
    "challengeId": "challenge_lru_cache",
    "testsPassed": 4,
    "xpAwarded": 200
  }
}''',
        options: {},
        isPreset: true,
        createdAt: now,
      ),
    ];
  }
}
