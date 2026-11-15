import 'package:flutter/material.dart';

class CodeSyntaxView extends StatelessWidget {
  final String code;
  final bool showLineNumbers;
  final double fontSize;

  const CodeSyntaxView({
    super.key,
    required this.code,
    this.showLineNumbers = true,
    this.fontSize = 12.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lines = code.split('\n');

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(lines.length, (index) {
          final line = lines[index];
          final lineNumber = index + 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLineNumbers)
                SizedBox(
                  width: 28,
                  child: Text(
                    '$lineNumber',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: fontSize,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: RichText(
                  text: _highlightSyntax(line, colorScheme, fontSize),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  TextSpan _highlightSyntax(String line, ColorScheme cs, double size) {
    if (line.trim().startsWith('//')) {
      return TextSpan(
        text: line,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: size,
          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final spans = <TextSpan>[];

    final keywords = {
      'class',
      'final',
      'const',
      'var',
      'void',
      'return',
      'if',
      'else',
      'for',
      'while',
      'import',
      'async',
      'await',
      'static',
      'override',
      'extends',
      'implements',
      'with',
      'true',
      'false',
      'null',
      'new',
      'try',
      'catch',
    };

    final types = {
      'String',
      'int',
      'double',
      'bool',
      'List',
      'Map',
      'Set',
      'Future',
      'Stream',
      'Widget',
      'BuildContext',
      'State',
      'StatefulWidget',
      'StatelessWidget',
      'RenderBox',
      'PaintingContext',
      'Offset',
      'Size',
    };

    int currentPos = 0;
    while (currentPos < line.length) {
      if (line.substring(currentPos).startsWith('//')) {
        spans.add(
          TextSpan(
            text: line.substring(currentPos),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: size,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        );
        break;
      }

      final char = line[currentPos];
      if (char == "'" || char == '"') {
        final quote = char;
        int nextQuote = line.indexOf(quote, currentPos + 1);
        if (nextQuote == -1) nextQuote = line.length - 1;
        final stringVal = line.substring(currentPos, nextQuote + 1);
        spans.add(
          TextSpan(
            text: stringVal,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: size,
              color: cs.secondary,
            ),
          ),
        );
        currentPos = nextQuote + 1;
        continue;
      }

      final match = RegExp(r'^[a-zA-Z0-9_]+')
          .firstMatch(line.substring(currentPos));
      if (match != null) {
        final token = match.group(0)!;
        Color tokenColor = cs.onSurface;
        FontWeight weight = FontWeight.normal;

        if (keywords.contains(token)) {
          tokenColor = cs.primary;
          weight = FontWeight.bold;
        } else if (types.contains(token)) {
          tokenColor = cs.tertiary;
          weight = FontWeight.w600;
        } else if (int.tryParse(token) != null ||
            double.tryParse(token) != null) {
          tokenColor = cs.secondary;
        }

        spans.add(
          TextSpan(
            text: token,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: size,
              color: tokenColor,
              fontWeight: weight,
            ),
          ),
        );
        currentPos += token.length;
      } else {
        spans.add(
          TextSpan(
            text: char,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: size,
              color: cs.onSurfaceVariant,
            ),
          ),
        );
        currentPos++;
      }
    }

    return TextSpan(children: spans);
  }
}
