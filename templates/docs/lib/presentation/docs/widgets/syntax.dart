import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/docs/models/doc_block.dart';

/// The colours a highlighted snippet uses.
///
/// Cairn's own palette is deliberately achromatic. Syntax highlighting is the
/// one place a docs site genuinely needs hue, so these are authored as
/// `oklch()` triples and converted with `Oklch.toColor`, the same function the
/// library uses for its own tokens. Chroma is kept low so a code block still
/// reads as part of a restrained page, and every token clears 4.5:1 on the
/// block background in both themes.
@immutable
class SyntaxTheme {
  /// Creates a palette.
  const SyntaxTheme({
    required this.plain,
    required this.comment,
    required this.keyword,
    required this.string,
    required this.number,
    required this.type,
  });

  /// Builds the palette for the ambient Cairn theme.
  factory SyntaxTheme.of(CairnTheme theme) =>
      theme.brightness == Brightness.dark
      ? SyntaxTheme.dark(theme)
      : SyntaxTheme.light(theme);

  /// The dark palette.
  factory SyntaxTheme.dark(CairnTheme theme) => SyntaxTheme(
    plain: theme.foreground,
    comment: theme.mutedForeground,
    keyword: Oklch.toColor(0.74, 0.13, 305),
    string: Oklch.toColor(0.78, 0.12, 155),
    number: Oklch.toColor(0.82, 0.11, 80),
    type: Oklch.toColor(0.80, 0.10, 225),
  );

  /// The light palette.
  factory SyntaxTheme.light(CairnTheme theme) => SyntaxTheme(
    plain: theme.foreground,
    comment: theme.mutedForeground,
    keyword: Oklch.toColor(0.48, 0.19, 305),
    string: Oklch.toColor(0.46, 0.13, 155),
    number: Oklch.toColor(0.50, 0.13, 65),
    type: Oklch.toColor(0.48, 0.14, 245),
  );

  /// Punctuation and identifiers.
  final Color plain;

  /// `//` and `#` comments.
  final Color comment;

  /// Language keywords and object keys.
  final Color keyword;

  /// Quoted literals.
  final Color string;

  /// Numbers and command-line flags.
  final Color number;

  /// Capitalised identifiers: in Dart, overwhelmingly types.
  final Color type;
}

const Set<String> _dartKeywords = <String>{
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'get',
  'if',
  'implements',
  'import',
  'in',
  'is',
  'late',
  'new',
  'null',
  'on',
  'required',
  'return',
  'sealed',
  'set',
  'static',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'var',
  'void',
  'while',
  'with',
  'yield',
};

const Set<String> _shellKeywords = <String>{
  'cd',
  'curl',
  'dart',
  'echo',
  'flutter',
  'git',
  'npm',
  'npx',
  'pub',
  'run',
  'test',
  'add',
  'build',
  'upgrade',
  'get',
};

const Set<String> _jsonKeywords = <String>{'true', 'false', 'null'};

/// Splits [source] into styled spans.
///
/// A deliberately small tokeniser: comments, strings, numbers, keywords and
/// capitalised identifiers, and everything else plain. A real lexer would be
/// more correct and about forty times the size.
List<TextSpan> highlight(
  String source,
  CodeLanguage language,
  SyntaxTheme palette,
) {
  if (language == CodeLanguage.text) {
    return <TextSpan>[
      TextSpan(
        text: source,
        style: TextStyle(color: palette.plain),
      ),
    ];
  }

  final String commentAlt = switch (language) {
    CodeLanguage.dart => r'(?<comment>//[^\n]*)',
    CodeLanguage.json => r'(?<comment>(?!x)x)',
    _ => r'(?<comment>(?:^|(?<=\s))#[^\n]*)',
  };
  const String stringAlt =
      r'''(?<string>r?'(?:\\.|[^'\\\n])*'|"(?:\\.|[^"\\\n])*")''';
  final RegExp pattern = RegExp(
    <String>[
      commentAlt,
      stringAlt,
      language == CodeLanguage.bash
          ? r'(?<flag>(?<![\w-])--?[A-Za-z][\w-]*)'
          : r'(?<flag>(?!x)x)',
      r'(?<number>\b\d+(?:\.\d+)?\b)',
      r'(?<word>[A-Za-z_][A-Za-z0-9_]*)',
    ].join('|'),
    multiLine: true,
  );

  final List<TextSpan> spans = <TextSpan>[];
  int cursor = 0;

  void emit(String text, Color color) {
    if (text.isEmpty) return;
    spans.add(
      TextSpan(
        text: text,
        style: TextStyle(color: color),
      ),
    );
  }

  final Set<String> keywords = switch (language) {
    CodeLanguage.dart => _dartKeywords,
    CodeLanguage.json => _jsonKeywords,
    _ => _shellKeywords,
  };

  for (final RegExpMatch match in pattern.allMatches(source)) {
    emit(source.substring(cursor, match.start), palette.plain);
    cursor = match.end;

    final String text = match[0]!;
    if (match.namedGroup('comment') != null) {
      emit(text, palette.comment);
    } else if (match.namedGroup('string') != null) {
      // A JSON key is a string followed by a colon.
      final bool isKey =
          language == CodeLanguage.json &&
          RegExp(r'\s*:').matchAsPrefix(source, match.end) != null;
      emit(text, isKey ? palette.keyword : palette.string);
    } else if (match.namedGroup('flag') != null ||
        match.namedGroup('number') != null) {
      emit(text, palette.number);
    } else {
      final bool isYamlKey =
          language == CodeLanguage.yaml &&
          match.end < source.length &&
          source[match.end] == ':';
      if (isYamlKey ||
          (language != CodeLanguage.yaml && keywords.contains(text))) {
        emit(text, palette.keyword);
      } else if (language != CodeLanguage.bash &&
          text[0].toUpperCase() == text[0] &&
          text[0].toLowerCase() != text[0]) {
        emit(text, palette.type);
      } else {
        emit(text, palette.plain);
      }
    }
  }
  emit(source.substring(cursor), palette.plain);
  return spans;
}
