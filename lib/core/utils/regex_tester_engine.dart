import '../../data/models/regex_match_result.dart';

class RegexExecutionResult {
  final bool isPatternValid;
  final String? patternError;
  final List<RegexMatchResult> matches;
  final int executionTimeMicros;

  const RegexExecutionResult({
    required this.isPatternValid,
    this.patternError,
    required this.matches,
    required this.executionTimeMicros,
  });
}

class RegexTesterEngine {
  /// Evaluates the regex against the input string and captures all group tokens.
  static RegexExecutionResult evaluate({
    required String pattern,
    required String input,
    bool caseInsensitive = false,
    bool multiLine = false,
    bool dotAll = false,
    bool unicode = false,
  }) {
    if (pattern.isEmpty) {
      return const RegexExecutionResult(
        isPatternValid: true,
        matches: [],
        executionTimeMicros: 0,
      );
    }

    final stopwatch = Stopwatch()..start();
    try {
      final regExp = RegExp(
        pattern,
        caseSensitive: !caseInsensitive,
        multiLine: multiLine,
        dotAll: dotAll,
        unicode: unicode,
      );

      final matches = <RegexMatchResult>[];
      final regMatches = regExp.allMatches(input);

      int matchIdx = 0;
      for (final match in regMatches) {
        final groups = <RegexGroupCapture>[];
        // Group 0 is the full match
        groups.add(
          RegexGroupCapture(
            groupIndex: 0,
            groupName: 'Full Match',
            value: match.group(0) ?? '',
            start: match.start,
            end: match.end,
          ),
        );

        // Group 1..N
        for (int g = 1; g <= match.groupCount; g++) {
          final groupText = match.group(g);
          if (groupText != null) {
            groups.add(
              RegexGroupCapture(
                groupIndex: g,
                groupName: 'Group $g',
                value: groupText,
                start: match.start,
                end: match.end,
              ),
            );
          }
        }

        matches.add(
          RegexMatchResult(
            index: matchIdx++,
            start: match.start,
            end: match.end,
            matchedText: match.group(0) ?? '',
            groups: groups,
          ),
        );
      }

      stopwatch.stop();
      return RegexExecutionResult(
        isPatternValid: true,
        matches: matches,
        executionTimeMicros: stopwatch.elapsedMicroseconds,
      );
    } on FormatException catch (e) {
      stopwatch.stop();
      return RegexExecutionResult(
        isPatternValid: false,
        patternError: e.message,
        matches: const [],
        executionTimeMicros: stopwatch.elapsedMicroseconds,
      );
    } catch (e) {
      stopwatch.stop();
      return RegexExecutionResult(
        isPatternValid: false,
        patternError: e.toString(),
        matches: const [],
        executionTimeMicros: stopwatch.elapsedMicroseconds,
      );
    }
  }
}
