class JsonSchemaViolation {
  final String path;
  final String message;
  final String? expectedType;
  final String? actualType;

  const JsonSchemaViolation({
    required this.path,
    required this.message,
    this.expectedType,
    this.actualType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonSchemaViolation &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          message == other.message;

  @override
  int get hashCode => path.hashCode ^ message.hashCode;
}

class JsonValidationResult {
  final bool isValid;
  final List<JsonSchemaViolation> violations;
  final dynamic parsedJson;
  final int parseLatencyMicros;

  const JsonValidationResult({
    required this.isValid,
    required this.violations,
    this.parsedJson,
    this.parseLatencyMicros = 0,
  });

  factory JsonValidationResult.valid({
    dynamic parsedJson,
    int parseLatencyMicros = 0,
  }) {
    return JsonValidationResult(
      isValid: true,
      violations: const [],
      parsedJson: parsedJson,
      parseLatencyMicros: parseLatencyMicros,
    );
  }

  factory JsonValidationResult.invalid(
    List<JsonSchemaViolation> violations, {
    dynamic parsedJson,
    int parseLatencyMicros = 0,
  }) {
    return JsonValidationResult(
      isValid: false,
      violations: violations,
      parsedJson: parsedJson,
      parseLatencyMicros: parseLatencyMicros,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonValidationResult &&
          runtimeType == other.runtimeType &&
          isValid == other.isValid &&
          violations.length == other.violations.length;

  @override
  int get hashCode => isValid.hashCode ^ violations.length.hashCode;
}
