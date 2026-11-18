import 'dart:convert';

import '../../data/models/json_validation_result.dart';

class JsonSchemaValidatorEngine {
  /// Validates a JSON string against a JSON Schema string.
  static JsonValidationResult validate({
    required String schemaString,
    required String jsonPayloadString,
  }) {
    if (schemaString.trim().isEmpty) {
      return JsonValidationResult.valid();
    }

    final stopwatch = Stopwatch()..start();

    // Parse Schema
    Map<String, dynamic> schema;
    try {
      final decodedSchema = jsonDecode(schemaString);
      if (decodedSchema is! Map<String, dynamic>) {
        return JsonValidationResult.invalid([
          const JsonSchemaViolation(
            path: r'$schema',
            message: 'JSON Schema root must be a valid JSON Object.',
          ),
        ]);
      }
      schema = decodedSchema;
    } on FormatException catch (e) {
      return JsonValidationResult.invalid([
        JsonSchemaViolation(
          path: r'$schema',
          message: 'Malformed JSON Schema syntax: ${e.message}',
        ),
      ]);
    }

    // Parse JSON Payload
    dynamic payload;
    try {
      payload = jsonDecode(jsonPayloadString);
    } on FormatException catch (e) {
      return JsonValidationResult.invalid([
        JsonSchemaViolation(
          path: 'root',
          message: 'Malformed JSON payload syntax: ${e.message}',
        ),
      ]);
    }

    final violations = <JsonSchemaViolation>[];
    _validateNode(
      path: 'root',
      value: payload,
      schema: schema,
      violations: violations,
    );

    stopwatch.stop();

    if (violations.isEmpty) {
      return JsonValidationResult.valid(
        parsedJson: payload,
        parseLatencyMicros: stopwatch.elapsedMicroseconds,
      );
    } else {
      return JsonValidationResult.invalid(
        violations,
        parsedJson: payload,
        parseLatencyMicros: stopwatch.elapsedMicroseconds,
      );
    }
  }

  static void _validateNode({
    required String path,
    required dynamic value,
    required Map<String, dynamic> schema,
    required List<JsonSchemaViolation> violations,
  }) {
    // 1. Check type
    if (schema.containsKey('type')) {
      final expectedType = schema['type'] as String;
      final actualType = _getJsonType(value);

      if (!_isTypeMatch(expectedType, actualType, value)) {
        violations.add(
          JsonSchemaViolation(
            path: path,
            message:
                "Expected type '$expectedType' but received '$actualType'.",
            expectedType: expectedType,
            actualType: actualType,
          ),
        );
        return; // Stop further deep validation on mismatched type
      }
    }

    // 2. Check enum
    if (schema.containsKey('enum')) {
      final allowed = schema['enum'] as List<dynamic>;
      if (!allowed.contains(value)) {
        violations.add(
          JsonSchemaViolation(
            path: path,
            message: 'Value must be one of: ${allowed.join(", ")}.',
          ),
        );
      }
    }

    // 3. Object validation (properties, required)
    if (value is Map<String, dynamic>) {
      // Required keys
      if (schema.containsKey('required')) {
        final requiredKeys = (schema['required'] as List<dynamic>)
            .cast<String>();
        for (final reqKey in requiredKeys) {
          if (!value.containsKey(reqKey)) {
            violations.add(
              JsonSchemaViolation(
                path: '$path.$reqKey',
                message: "Missing required property '$reqKey'.",
              ),
            );
          }
        }
      }

      // Property schemas
      if (schema.containsKey('properties')) {
        final properties = schema['properties'] as Map<String, dynamic>;
        for (final entry in properties.entries) {
          final propName = entry.key;
          final propSchema = entry.value as Map<String, dynamic>;
          if (value.containsKey(propName)) {
            _validateNode(
              path: '$path.$propName',
              value: value[propName],
              schema: propSchema,
              violations: violations,
            );
          }
        }
      }
    }

    // 4. Array validation
    if (value is List<dynamic>) {
      if (schema.containsKey('items')) {
        final itemSchema = schema['items'] as Map<String, dynamic>;
        for (int i = 0; i < value.length; i++) {
          _validateNode(
            path: '$path[$i]',
            value: value[i],
            schema: itemSchema,
            violations: violations,
          );
        }
      }
    }

    // 5. String validation (minLength, maxLength, pattern)
    if (value is String) {
      if (schema.containsKey('minLength')) {
        final minLen = schema['minLength'] as int;
        if (value.length < minLen) {
          violations.add(
            JsonSchemaViolation(
              path: path,
              message:
                  'String length (${value.length}) is shorter than minLength ($minLen).',
            ),
          );
        }
      }

      if (schema.containsKey('maxLength')) {
        final maxLen = schema['maxLength'] as int;
        if (value.length > maxLen) {
          violations.add(
            JsonSchemaViolation(
              path: path,
              message:
                  'String length (${value.length}) exceeds maxLength ($maxLen).',
            ),
          );
        }
      }

      if (schema.containsKey('pattern')) {
        final patternStr = schema['pattern'] as String;
        try {
          final reg = RegExp(patternStr);
          if (!reg.hasMatch(value)) {
            violations.add(
              JsonSchemaViolation(
                path: path,
                message:
                    "String does not match required regex pattern: '$patternStr'.",
              ),
            );
          }
        } catch (_) {}
      }
    }

    // 6. Numeric validation (minimum, maximum)
    if (value is num) {
      if (schema.containsKey('minimum')) {
        final minVal = schema['minimum'] as num;
        if (value < minVal) {
          violations.add(
            JsonSchemaViolation(
              path: path,
              message: 'Numeric value ($value) is less than minimum ($minVal).',
            ),
          );
        }
      }

      if (schema.containsKey('maximum')) {
        final maxVal = schema['maximum'] as num;
        if (value > maxVal) {
          violations.add(
            JsonSchemaViolation(
              path: path,
              message:
                  'Numeric value ($value) is greater than maximum ($maxVal).',
            ),
          );
        }
      }
    }
  }

  static String _getJsonType(dynamic val) {
    if (val == null) return 'null';
    if (val is bool) return 'boolean';
    if (val is int) return 'integer';
    if (val is num) return 'number';
    if (val is String) return 'string';
    if (val is List) return 'array';
    if (val is Map) return 'object';
    return 'unknown';
  }

  static bool _isTypeMatch(String expected, String actual, dynamic val) {
    if (expected == 'number') {
      return actual == 'number' || actual == 'integer';
    }
    return expected == actual;
  }

  /// Generates clean Dart model code from a JSON schema object
  static String generateDartModel({
    required String className,
    required String schemaString,
  }) {
    try {
      final decoded = jsonDecode(schemaString);
      if (decoded is! Map<String, dynamic>) {
        return '// Invalid JSON Schema: root must be an object.';
      }

      final properties = decoded['properties'] as Map<String, dynamic>? ?? {};
      final requiredKeys =
          (decoded['required'] as List<dynamic>?)?.cast<String>() ?? [];

      final buffer = StringBuffer();
      buffer.writeln('/// Auto-generated Dart Data Model for `$className`');
      buffer.writeln('class $className {');

      // Fields
      for (final entry in properties.entries) {
        final name = entry.key;
        final prop = entry.value as Map<String, dynamic>;
        final type = _dartTypeFromSchema(prop);
        final isRequired = requiredKeys.contains(name);
        final nullable = isRequired ? '' : '?';
        buffer.writeln('  final $type$nullable $name;');
      }

      buffer.writeln();
      // Constructor
      buffer.writeln('  const $className({');
      for (final entry in properties.entries) {
        final name = entry.key;
        final isRequired = requiredKeys.contains(name);
        if (isRequired) {
          buffer.writeln('    required this.$name,');
        } else {
          buffer.writeln('    this.$name,');
        }
      }
      buffer.writeln('  });');

      buffer.writeln();
      // fromJson
      buffer.writeln(
        '  factory $className.fromJson(Map<String, dynamic> json) {',
      );
      buffer.writeln('    return $className(');
      for (final entry in properties.entries) {
        final name = entry.key;
        final prop = entry.value as Map<String, dynamic>;
        final rawType = prop['type'] as String? ?? 'string';
        final isRequired = requiredKeys.contains(name);

        if (rawType == 'integer') {
          if (isRequired) {
            buffer.writeln("      $name: (json['$name'] as num).toInt(),");
          } else {
            buffer.writeln("      $name: (json['$name'] as num?)?.toInt(),");
          }
        } else if (rawType == 'number') {
          if (isRequired) {
            buffer.writeln("      $name: (json['$name'] as num).toDouble(),");
          } else {
            buffer.writeln("      $name: (json['$name'] as num?)?.toDouble(),");
          }
        } else if (rawType == 'boolean') {
          if (isRequired) {
            buffer.writeln("      $name: json['$name'] as bool,");
          } else {
            buffer.writeln("      $name: json['$name'] as bool?,");
          }
        } else if (rawType == 'array') {
          buffer.writeln(
            "      $name: (json['$name'] as List<dynamic>?) ?? [],",
          );
        } else {
          if (isRequired) {
            buffer.writeln("      $name: json['$name'] as String,");
          } else {
            buffer.writeln("      $name: json['$name'] as String?,");
          }
        }
      }
      buffer.writeln('    );');
      buffer.writeln('  }');

      buffer.writeln();
      // toJson
      buffer.writeln('  Map<String, dynamic> toJson() {');
      buffer.writeln('    return {');
      for (final entry in properties.entries) {
        final name = entry.key;
        buffer.writeln("      '$name': $name,");
      }
      buffer.writeln('    };');
      buffer.writeln('  }');
      buffer.writeln('}');

      return buffer.toString();
    } catch (e) {
      return '// Failed to generate Dart Model: $e';
    }
  }

  static String _dartTypeFromSchema(Map<String, dynamic> prop) {
    final type = prop['type'] as String? ?? 'string';
    switch (type) {
      case 'integer':
        return 'int';
      case 'number':
        return 'double';
      case 'boolean':
        return 'bool';
      case 'array':
        return 'List<dynamic>';
      case 'object':
        return 'Map<String, dynamic>';
      case 'string':
      default:
        return 'String';
    }
  }
}
