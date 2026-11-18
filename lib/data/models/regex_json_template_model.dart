import 'dart:convert';

class RegexJsonTemplateModel {
  final String id;
  final String title;
  final String type; // 'regex' or 'json_schema'
  final String pattern;
  final String sampleInput;
  final Map<String, dynamic> options;
  final bool isPreset;
  final DateTime createdAt;

  const RegexJsonTemplateModel({
    required this.id,
    required this.title,
    required this.type,
    required this.pattern,
    required this.sampleInput,
    this.options = const {},
    this.isPreset = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'pattern': pattern,
      'sampleInput': sampleInput,
      'optionsJson': jsonEncode(options),
      'isPreset': isPreset ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RegexJsonTemplateModel.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> parsedOptions = {};
    if (map['optionsJson'] != null) {
      try {
        parsedOptions =
            jsonDecode(map['optionsJson'] as String) as Map<String, dynamic>;
      } catch (_) {}
    }

    return RegexJsonTemplateModel(
      id: map['id'] as String,
      title: map['title'] as String,
      type: map['type'] as String,
      pattern: map['pattern'] as String,
      sampleInput: map['sampleInput'] as String,
      options: parsedOptions,
      isPreset: (map['isPreset'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  RegexJsonTemplateModel copyWith({
    String? id,
    String? title,
    String? type,
    String? pattern,
    String? sampleInput,
    Map<String, dynamic>? options,
    bool? isPreset,
    DateTime? createdAt,
  }) {
    return RegexJsonTemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      pattern: pattern ?? this.pattern,
      sampleInput: sampleInput ?? this.sampleInput,
      options: options ?? this.options,
      isPreset: isPreset ?? this.isPreset,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegexJsonTemplateModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
