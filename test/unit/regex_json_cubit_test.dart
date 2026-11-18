import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skill_forge_app/core/utils/regex_tester_engine.dart';
import 'package:skill_forge_app/core/utils/json_schema_validator_engine.dart';
import 'package:skill_forge_app/data/models/regex_json_template_model.dart';
import 'package:skill_forge_app/data/repositories/regex_json_repository.dart';
import 'package:skill_forge_app/presentation/validator/cubit/regex_json_cubit.dart';
import 'package:skill_forge_app/presentation/validator/cubit/regex_json_state.dart';

class MockRegexJsonRepository extends Mock implements RegexJsonRepository {}

class FakeRegexJsonTemplateModel extends Fake
    implements RegexJsonTemplateModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRegexJsonTemplateModel());
  });

  late MockRegexJsonRepository mockRepository;
  late List<RegexJsonTemplateModel> sampleTemplates;

  setUp(() {
    mockRepository = MockRegexJsonRepository();

    sampleTemplates = [
      RegexJsonTemplateModel(
        id: 'tpl_semver',
        title: 'SemVer Regex',
        type: 'regex',
        pattern: r'^v?(\d+)\.(\d+)\.(\d+)$',
        sampleInput: 'v1.4.2',
        options: {'caseInsensitive': false, 'multiLine': false},
        isPreset: true,
        createdAt: DateTime(2026, 11, 18),
      ),
      RegexJsonTemplateModel(
        id: 'tpl_schema_telemetry',
        title: 'Telemetry Schema',
        type: 'json_schema',
        pattern: '''{
  "type": "object",
  "required": ["sessionId", "heapMb"],
  "properties": {
    "sessionId": { "type": "string" },
    "heapMb": { "type": "number", "minimum": 1.0 }
  }
}''',
        sampleInput: '{"sessionId": "sess_123", "heapMb": 45.0}',
        options: {},
        isPreset: true,
        createdAt: DateTime(2026, 11, 18),
      ),
    ];

    when(() => mockRepository.getTemplates())
        .thenAnswer((_) async => sampleTemplates);
    when(() => mockRepository.saveTemplate(any()))
        .thenAnswer((_) async => Future.value());
    when(() => mockRepository.deleteTemplate(any()))
        .thenAnswer((_) async => Future.value());
  });

  group('RegexTesterEngine Algorithm Tests', () {
    test('Accurately matches SemVer pattern and captures groups', () {
      final res = RegexTesterEngine.evaluate(
        pattern: r'^v?(\d+)\.(\d+)\.(\d+)$',
        input: 'v2.10.8',
      );

      expect(res.isPatternValid, true);
      expect(res.matches.length, 1);
      final match = res.matches.first;
      expect(match.matchedText, 'v2.10.8');
      expect(match.groups.length, 4); // Full match + 3 capture groups
      expect(match.groups[1].value, '2');
      expect(match.groups[2].value, '10');
      expect(match.groups[3].value, '8');
    });

    test('Gracefully captures FormatException on malformed regex syntax', () {
      final res = RegexTesterEngine.evaluate(
        pattern: r'(?P<invalid_unclosed',
        input: 'any sample',
      );

      expect(res.isPatternValid, false);
      expect(res.patternError, isNotNull);
      expect(res.matches.isEmpty, true);
    });

    test('Respects caseInsensitive flag correctly', () {
      final caseSensitiveRes = RegexTesterEngine.evaluate(
        pattern: r'^[a-z]+$',
        input: 'FLUTTER',
        caseInsensitive: false,
      );
      expect(caseSensitiveRes.matches.isEmpty, true);

      final caseInsensitiveRes = RegexTesterEngine.evaluate(
        pattern: r'^[a-z]+$',
        input: 'FLUTTER',
        caseInsensitive: true,
      );
      expect(caseInsensitiveRes.matches.length, 1);
    });
  });

  group('JsonSchemaValidatorEngine Algorithm Tests', () {
    test('Validates compliant JSON payload successfully', () {
      const schema = '''{
        "type": "object",
        "required": ["name", "version", "isOnline"],
        "properties": {
          "name": { "type": "string", "minLength": 2 },
          "version": { "type": "integer", "minimum": 1 },
          "isOnline": { "type": "boolean" }
        }
      }''';

      const validJson = '''{
        "name": "SkillForge Engine",
        "version": 3,
        "isOnline": true
      }''';

      final res = JsonSchemaValidatorEngine.validate(
        schemaString: schema,
        jsonPayloadString: validJson,
      );

      expect(res.isValid, true);
      expect(res.violations.isEmpty, true);
    });

    test('Identifies missing required keys and numeric violations', () {
      const schema = '''{
        "type": "object",
        "required": ["name", "score"],
        "properties": {
          "name": { "type": "string" },
          "score": { "type": "number", "minimum": 10.0 }
        }
      }''';

      const invalidJson = '''{
        "score": 5.0
      }''';

      final res = JsonSchemaValidatorEngine.validate(
        schemaString: schema,
        jsonPayloadString: invalidJson,
      );

      expect(res.isValid, false);
      expect(res.violations.length, 2);
      expect(
        res.violations.any(
          (v) => v.message.contains("Missing required property 'name'"),
        ),
        true,
      );
      expect(
        res.violations.any((v) => v.message.contains('is less than minimum')),
        true,
      );
    });

    test('Generates type-safe Dart model code with fromJson and toJson', () {
      const schema = '''{
        "type": "object",
        "required": ["id", "count"],
        "properties": {
          "id": { "type": "string" },
          "count": { "type": "integer" },
          "active": { "type": "boolean" }
        }
      }''';

      final dartCode = JsonSchemaValidatorEngine.generateDartModel(
        className: 'TelemetryPacket',
        schemaString: schema,
      );

      expect(dartCode.contains('class TelemetryPacket'), true);
      expect(dartCode.contains('final String id;'), true);
      expect(dartCode.contains('final int count;'), true);
      expect(dartCode.contains('final bool? active;'), true);
      expect(dartCode.contains('factory TelemetryPacket.fromJson'), true);
      expect(dartCode.contains('Map<String, dynamic> toJson()'), true);
    });
  });

  group('RegexJsonCubit State Machine Tests', () {
    test(
      'Initializes templates and evaluates default regex and schema',
      () async {
        final cubit = RegexJsonCubit(repository: mockRepository);
        await Future.delayed(Duration.zero);

        expect(cubit.state.isLoading, false);
        expect(cubit.state.templates.length, 2);
        expect(cubit.state.mode, ValidatorMode.regex);
        expect(cubit.state.regexPattern, r'^v?(\d+)\.(\d+)\.(\d+)$');
        expect(cubit.state.regexResult.matches.length, 1);
        expect(cubit.state.jsonResult.isValid, true);

        await cubit.close();
      },
    );

    test('Switches between Regex and JSON Schema modes', () async {
      final cubit = RegexJsonCubit(repository: mockRepository);
      await Future.delayed(Duration.zero);

      cubit.setMode(ValidatorMode.jsonSchema);
      expect(cubit.state.mode, ValidatorMode.jsonSchema);

      cubit.setMode(ValidatorMode.regex);
      expect(cubit.state.mode, ValidatorMode.regex);

      await cubit.close();
    });

    test('Updates regex and flags reactively', () async {
      final cubit = RegexJsonCubit(repository: mockRepository);
      await Future.delayed(Duration.zero);

      cubit.updateRegexPattern(r'^[a-z]+$');
      cubit.updateRegexInput('HELLO');
      expect(cubit.state.regexResult.matches.isEmpty, true);

      cubit.toggleFlag('caseInsensitive');
      expect(cubit.state.caseInsensitive, true);
      expect(cubit.state.regexResult.matches.length, 1);

      await cubit.close();
    });

    test('Selects template and updates evaluation state', () async {
      final cubit = RegexJsonCubit(repository: mockRepository);
      await Future.delayed(Duration.zero);

      final jsonTemplate = sampleTemplates[1];
      cubit.selectTemplate(jsonTemplate);

      expect(cubit.state.mode, ValidatorMode.jsonSchema);
      expect(cubit.state.selectedTemplate?.id, 'tpl_schema_telemetry');
      expect(cubit.state.jsonResult.isValid, true);

      await cubit.close();
    });

    test('Saves custom template and persists to repository', () async {
      final cubit = RegexJsonCubit(repository: mockRepository);
      await Future.delayed(Duration.zero);

      await cubit.saveCustomTemplate('My Custom Token Regex');

      expect(cubit.state.templates.length, 3);
      expect(cubit.state.templates.first.title, 'My Custom Token Regex');
      verify(() => mockRepository.saveTemplate(any())).called(1);

      await cubit.close();
    });
  });
}
