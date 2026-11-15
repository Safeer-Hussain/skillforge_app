class AstAnalysisResult {
  final int cyclomaticComplexity;
  final String rating;
  final int decisionPoints;
  final int linesOfCode;
  final List<String> detectedKeywords;

  const AstAnalysisResult({
    required this.cyclomaticComplexity,
    required this.rating,
    required this.decisionPoints,
    required this.linesOfCode,
    required this.detectedKeywords,
  });
}

class AstAnalyzer {
  static AstAnalysisResult analyze(String code) {
    if (code.trim().isEmpty) {
      return const AstAnalysisResult(
        cyclomaticComplexity: 1,
        rating: 'Trivial (A+)',
        decisionPoints: 0,
        linesOfCode: 0,
        detectedKeywords: [],
      );
    }

    final lines = code.split('\n');
    final loc = lines
        .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('//'))
        .length;

    final keywords = [
      'if ',
      'else if ',
      'for ',
      'while ',
      'case ',
      '&&',
      '||',
      '?',
      'catch ',
    ];

    int decisionPoints = 0;
    final detected = <String>[];

    for (final kw in keywords) {
      int idx = 0;
      while (true) {
        idx = code.indexOf(kw, idx);
        if (idx == -1) break;
        decisionPoints++;
        if (!detected.contains(kw.trim())) {
          detected.add(kw.trim());
        }
        idx += kw.length;
      }
    }

    final complexity = 1 + decisionPoints;
    final rating = _getRating(complexity);

    return AstAnalysisResult(
      cyclomaticComplexity: complexity,
      rating: rating,
      decisionPoints: decisionPoints,
      linesOfCode: loc,
      detectedKeywords: detected,
    );
  }

  static String _getRating(int complexity) {
    if (complexity <= 4) return 'A+ (Optimal)';
    if (complexity <= 8) return 'B+ (Maintainable)';
    if (complexity <= 12) return 'C (Refactor Recommended)';
    return 'D (High Cognitive Load)';
  }
}
