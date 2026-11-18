class RegexGroupCapture {
  final int groupIndex;
  final String? groupName;
  final String value;
  final int start;
  final int end;

  const RegexGroupCapture({
    required this.groupIndex,
    this.groupName,
    required this.value,
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegexGroupCapture &&
          runtimeType == other.runtimeType &&
          groupIndex == other.groupIndex &&
          groupName == other.groupName &&
          value == other.value &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode =>
      groupIndex.hashCode ^
      groupName.hashCode ^
      value.hashCode ^
      start.hashCode ^
      end.hashCode;
}

class RegexMatchResult {
  final int index;
  final int start;
  final int end;
  final String matchedText;
  final List<RegexGroupCapture> groups;

  const RegexMatchResult({
    required this.index,
    required this.start,
    required this.end,
    required this.matchedText,
    required this.groups,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegexMatchResult &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          start == other.start &&
          end == other.end &&
          matchedText == other.matchedText;

  @override
  int get hashCode =>
      index.hashCode ^ start.hashCode ^ end.hashCode ^ matchedText.hashCode;
}
