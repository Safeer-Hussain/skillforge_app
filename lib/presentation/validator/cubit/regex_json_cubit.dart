import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/regex_tester_engine.dart';
import '../../../../core/utils/json_schema_validator_engine.dart';
import '../../../data/models/regex_json_template_model.dart';
import '../../../data/repositories/regex_json_repository.dart';
import 'regex_json_state.dart';

class RegexJsonCubit extends Cubit<RegexJsonState> {
  final RegexJsonRepository repository;

  RegexJsonCubit({required this.repository}) : super(const RegexJsonState()) {
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final templates = await repository.getTemplates();
      final defaultRegex = templates.firstWhere(
        (t) => t.type == 'regex',
        orElse: () => templates.first,
      );
      final defaultSchema = templates.firstWhere(
        (t) => t.type == 'json_schema',
        orElse: () => templates.last,
      );

      final regexResult = RegexTesterEngine.evaluate(
        pattern: defaultRegex.pattern,
        input: defaultRegex.sampleInput,
        caseInsensitive:
            defaultRegex.options['caseInsensitive'] as bool? ?? false,
        multiLine: defaultRegex.options['multiLine'] as bool? ?? false,
      );

      final jsonResult = JsonSchemaValidatorEngine.validate(
        schemaString: defaultSchema.pattern,
        jsonPayloadString: defaultSchema.sampleInput,
      );

      emit(
        state.copyWith(
          isLoading: false,
          templates: templates,
          selectedTemplate: defaultRegex,
          regexPattern: defaultRegex.pattern,
          regexInput: defaultRegex.sampleInput,
          caseInsensitive:
              defaultRegex.options['caseInsensitive'] as bool? ?? false,
          multiLine: defaultRegex.options['multiLine'] as bool? ?? false,
          regexResult: regexResult,
          jsonSchema: defaultSchema.pattern,
          jsonInput: defaultSchema.sampleInput,
          jsonResult: jsonResult,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load templates: $e',
        ),
      );
    }
  }

  void setMode(ValidatorMode mode) {
    emit(state.copyWith(mode: mode));
  }

  void updateRegexPattern(String pattern) {
    final result = RegexTesterEngine.evaluate(
      pattern: pattern,
      input: state.regexInput,
      caseInsensitive: state.caseInsensitive,
      multiLine: state.multiLine,
      dotAll: state.dotAll,
      unicode: state.unicode,
    );
    emit(state.copyWith(regexPattern: pattern, regexResult: result));
  }

  void updateRegexInput(String input) {
    final result = RegexTesterEngine.evaluate(
      pattern: state.regexPattern,
      input: input,
      caseInsensitive: state.caseInsensitive,
      multiLine: state.multiLine,
      dotAll: state.dotAll,
      unicode: state.unicode,
    );
    emit(state.copyWith(regexInput: input, regexResult: result));
  }

  void toggleFlag(String flag) {
    bool newCase = state.caseInsensitive;
    bool newMulti = state.multiLine;
    bool newDot = state.dotAll;
    bool newUni = state.unicode;

    if (flag == 'caseInsensitive') newCase = !newCase;
    if (flag == 'multiLine') newMulti = !newMulti;
    if (flag == 'dotAll') newDot = !newDot;
    if (flag == 'unicode') newUni = !newUni;

    final result = RegexTesterEngine.evaluate(
      pattern: state.regexPattern,
      input: state.regexInput,
      caseInsensitive: newCase,
      multiLine: newMulti,
      dotAll: newDot,
      unicode: newUni,
    );

    emit(
      state.copyWith(
        caseInsensitive: newCase,
        multiLine: newMulti,
        dotAll: newDot,
        unicode: newUni,
        regexResult: result,
      ),
    );
  }

  void updateJsonSchema(String schema) {
    final result = JsonSchemaValidatorEngine.validate(
      schemaString: schema,
      jsonPayloadString: state.jsonInput,
    );
    emit(state.copyWith(jsonSchema: schema, jsonResult: result));
  }

  void updateJsonInput(String input) {
    final result = JsonSchemaValidatorEngine.validate(
      schemaString: state.jsonSchema,
      jsonPayloadString: input,
    );
    emit(state.copyWith(jsonInput: input, jsonResult: result));
  }

  void formatJsonInput() {
    try {
      final decoded = jsonDecode(state.jsonInput);
      const encoder = JsonEncoder.withIndent('  ');
      final formatted = encoder.convert(decoded);
      updateJsonInput(formatted);
    } catch (_) {}
  }

  void formatJsonSchema() {
    try {
      final decoded = jsonDecode(state.jsonSchema);
      const encoder = JsonEncoder.withIndent('  ');
      final formatted = encoder.convert(decoded);
      updateJsonSchema(formatted);
    } catch (_) {}
  }

  void selectTemplate(RegexJsonTemplateModel template) {
    if (template.type == 'regex') {
      final result = RegexTesterEngine.evaluate(
        pattern: template.pattern,
        input: template.sampleInput,
        caseInsensitive: template.options['caseInsensitive'] as bool? ?? false,
        multiLine: template.options['multiLine'] as bool? ?? false,
        dotAll: template.options['dotAll'] as bool? ?? false,
        unicode: template.options['unicode'] as bool? ?? false,
      );

      emit(
        state.copyWith(
          mode: ValidatorMode.regex,
          selectedTemplate: template,
          regexPattern: template.pattern,
          regexInput: template.sampleInput,
          caseInsensitive:
              template.options['caseInsensitive'] as bool? ?? false,
          multiLine: template.options['multiLine'] as bool? ?? false,
          dotAll: template.options['dotAll'] as bool? ?? false,
          unicode: template.options['unicode'] as bool? ?? false,
          regexResult: result,
        ),
      );
    } else {
      final result = JsonSchemaValidatorEngine.validate(
        schemaString: template.pattern,
        jsonPayloadString: template.sampleInput,
      );

      emit(
        state.copyWith(
          mode: ValidatorMode.jsonSchema,
          selectedTemplate: template,
          jsonSchema: template.pattern,
          jsonInput: template.sampleInput,
          jsonResult: result,
        ),
      );
    }
  }

  void generateDartModel([String className = 'SkillForgeModel']) {
    final dartCode = JsonSchemaValidatorEngine.generateDartModel(
      className: className,
      schemaString: state.jsonSchema,
    );
    emit(state.copyWith(generatedDartModel: dartCode));
  }

  Future<void> saveCustomTemplate(String title) async {
    try {
      final isRegex = state.mode == ValidatorMode.regex;
      final template = RegexJsonTemplateModel(
        id: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        type: isRegex ? 'regex' : 'json_schema',
        pattern: isRegex ? state.regexPattern : state.jsonSchema,
        sampleInput: isRegex ? state.regexInput : state.jsonInput,
        options: isRegex
            ? {
                'caseInsensitive': state.caseInsensitive,
                'multiLine': state.multiLine,
                'dotAll': state.dotAll,
                'unicode': state.unicode,
              }
            : {},
        isPreset: false,
        createdAt: DateTime.now(),
      );

      await repository.saveTemplate(template);
      final updatedList = [template, ...state.templates];
      emit(state.copyWith(templates: updatedList, selectedTemplate: template));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to save custom template: $e'));
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await repository.deleteTemplate(id);
      final updatedList = state.templates.where((t) => t.id != id).toList();
      emit(
        state.copyWith(
          templates: updatedList,
          clearSelectedTemplate: state.selectedTemplate?.id == id,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete template: $e'));
    }
  }
}
