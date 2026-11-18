import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skill_forge_app/core/theme/app_theme.dart';
import 'package:skill_forge_app/data/models/regex_json_template_model.dart';
import 'package:skill_forge_app/data/repositories/regex_json_repository.dart';
import 'package:skill_forge_app/presentation/sandbox/bloc/sandbox_bloc.dart';
import 'package:skill_forge_app/data/repositories/sandbox_repository.dart';
import 'package:skill_forge_app/presentation/validator/cubit/regex_json_cubit.dart';
import 'package:skill_forge_app/presentation/validator/views/regex_json_validator_view.dart';

class MockRegexJsonRepository extends Mock implements RegexJsonRepository {}

class MockSandboxRepository extends Mock implements SandboxRepository {}

class FakeRegexJsonTemplateModel extends Fake
    implements RegexJsonTemplateModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRegexJsonTemplateModel());
  });

  late MockRegexJsonRepository mockRepository;
  late MockSandboxRepository mockSandboxRepository;
  late List<RegexJsonTemplateModel> sampleTemplates;

  setUp(() {
    mockRepository = MockRegexJsonRepository();
    mockSandboxRepository = MockSandboxRepository();

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

    when(() => mockSandboxRepository.getChallenges())
        .thenAnswer((_) async => []);
  });

  Widget createTestWidget({
    ThemeMode themeMode = ThemeMode.dark,
    required Widget child,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SandboxBloc>(
          create: (_) => SandboxBloc(repository: mockSandboxRepository),
        ),
        BlocProvider<RegexJsonCubit>(
          create: (_) => RegexJsonCubit(repository: mockRepository),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeMode,
        home: child,
      ),
    );
  }

  group('RegexJsonValidatorView Widget Tests (Sprint 3)', () {
    testWidgets('Renders all primary visualizer elements in portrait', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegexJsonValidatorView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Regex & JSON Schema Studio'), findsOneWidget);
      expect(find.text('Regex Tester'), findsOneWidget);
      expect(find.text('JSON Schema'), findsOneWidget);
      expect(find.text('REGULAR EXPRESSION PATTERN'), findsOneWidget);
      expect(find.text('TEST INPUT STRING'), findsOneWidget);
      expect(find.text('MATCH CAPTURES & GROUPS'), findsOneWidget);

      // Unique hero tag verification
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      final fab = tester.widget<FloatingActionButton>(fabFinder);
      expect(fab.heroTag, 'fab_regex_json_validate');

      expect(tester.takeException(), isNull);
    });

    testWidgets('Toggles between Regex and JSON Schema modes', (tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegexJsonValidatorView()),
      );
      await tester.pumpAndSettle();

      // Tap JSON Schema mode
      await tester.tap(find.text('JSON Schema'));
      await tester.pumpAndSettle();

      expect(find.text('JSON SCHEMA DEFINITION (DRAFT-07)'), findsOneWidget);
      expect(find.text('TARGET JSON PAYLOAD'), findsOneWidget);
      expect(find.text('SCHEMA CONFORMANCE DIAGNOSTICS'), findsOneWidget);

      // Tap back to Regex
      await tester.tap(find.text('Regex Tester'));
      await tester.pumpAndSettle();

      expect(find.text('REGULAR EXPRESSION PATTERN'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Opens presets bottom sheet and loads template', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegexJsonValidatorView()),
      );
      await tester.pumpAndSettle();

      // Tap Preset icon button in AppBar
      await tester.tap(find.byIcon(Icons.bookmarks_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Curated Engineering Presets'), findsOneWidget);
      expect(find.text('SemVer Regex'), findsOneWidget);
      expect(find.text('Telemetry Schema'), findsOneWidget);

      // Tap Telemetry Schema
      await tester.tap(find.text('Telemetry Schema'));
      await tester.pumpAndSettle();

      expect(find.text('SCHEMA CONFORMANCE DIAGNOSTICS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Landscape 360dp height viewport safety test (800x360)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(child: const RegexJsonValidatorView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Regex & JSON Schema Studio'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
