import '../../../../core/utils/regex_tester_engine.dart';
import '../../../data/models/json_validation_result.dart';
import '../../../data/models/regex_json_template_model.dart';

enum ValidatorMode {
  regex('Regex Pattern Tester'),
  jsonSchema('JSON Schema Validator');

  final String label;
  const ValidatorMode(this.label);
}

class RegexJsonState {
  final bool isLoading;
  final ValidatorMode mode;
  final List<RegexJsonTemplateModel> templates;
  final RegexJsonTemplateModel? selectedTemplate;

  // Regex State
  final String regexPattern;
  final String regexInput;
  final bool caseInsensitive;
  final bool multiLine;
  final bool dotAll;
  final bool unicode;
  final RegexExecutionResult regexResult;

  // JSON Schema State
  final String jsonSchema;
  final String jsonInput;
  final JsonValidationResult jsonResult;
  final String? generatedDartModel;

  final String? errorMessage;

  const RegexJsonState({
    this.isLoading = false,
    this.mode = ValidatorMode.regex,
    this.templates = const [],
    this.selectedTemplate,
    this.regexPattern = '',
    this.regexInput = '',
    this.caseInsensitive = false,
    this.multiLine = false,
    this.dotAll = false,
    this.unicode = false,
    this.regexResult = const RegexExecutionResult(
      isPatternValid: true,
      matches: [],
      executionTimeMicros: 0,
    ),
    this.jsonSchema = '',
    this.jsonInput = '',
    this.jsonResult = const JsonValidationResult(isValid: true, violations: []),
    this.generatedDartModel,
    this.errorMessage,
  });

  RegexJsonState copyWith({
    bool? isLoading,
    ValidatorMode? mode,
    List<RegexJsonTemplateModel>? templates,
    RegexJsonTemplateModel? selectedTemplate,
    bool clearSelectedTemplate = false,
    String? regexPattern,
    String? regexInput,
    bool? caseInsensitive,
    bool? multiLine,
    bool? dotAll,
    bool? unicode,
    RegexExecutionResult? regexResult,
    String? jsonSchema,
    String? jsonInput,
    JsonValidationResult? jsonResult,
    String? generatedDartModel,
    String? errorMessage,
  }) {
    return RegexJsonState(
      isLoading: isLoading ?? this.isLoading,
      mode: mode ?? this.mode,
      templates: templates ?? this.templates,
      selectedTemplate: clearSelectedTemplate
          ? null
          : (selectedTemplate ?? this.selectedTemplate),
      regexPattern: regexPattern ?? this.regexPattern,
      regexInput: regexInput ?? this.regexInput,
      caseInsensitive: caseInsensitive ?? this.caseInsensitive,
      multiLine: multiLine ?? this.multiLine,
      dotAll: dotAll ?? this.dotAll,
      unicode: unicode ?? this.unicode,
      regexResult: regexResult ?? this.regexResult,
      jsonSchema: jsonSchema ?? this.jsonSchema,
      jsonInput: jsonInput ?? this.jsonInput,
      jsonResult: jsonResult ?? this.jsonResult,
      generatedDartModel: generatedDartModel ?? this.generatedDartModel,
      errorMessage: errorMessage,
    );
  }
}
