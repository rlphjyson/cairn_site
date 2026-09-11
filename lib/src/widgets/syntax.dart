import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// Which grammar a snippet should be highlighted with.
enum CodeLanguage {
  /// Dart source.
  dart('dart'),

  /// A `pubspec.yaml` fragment or other YAML.
  yaml('yaml'),

  /// A shell command.
  shell('bash'),

  /// No highlighting at all.
  plain('text');

  const CodeLanguage(this.label);

  /// The label shown in a code block's header.
  final String label;
}

/// The colours a highlighted snippet uses.
///
/// Cairn's own palette is deliberately achromatic — nineteen semantic slots,
/// every grey landing exactly on Tailwind's `neutral` ramp. Syntax highlighting
/// is the one place on this site that genuinely needs hue, so rather than
/// eyeballing hex values these are authored as `oklch()` triples and converted
/// with `Oklch.toColor` — the exact function the library uses for its own
/// tokens. Same pipeline, same provenance, just five extra colours.
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

  /// The dark palette. Chroma is kept low so the block still reads as part of
  /// a monochrome page rather than a rainbow.
  factory SyntaxTheme.dark(CairnTheme theme) => SyntaxTheme(
    plain: theme.foreground,
    comment: theme.mutedForeground,
    keyword: Oklch.toColor(0.74, 0.13, 305),
    string: Oklch.toColor(0.78, 0.12, 155),
    number: Oklch.toColor(0.82, 0.11, 80),
    type: Oklch.toColor(0.80, 0.10, 225),
  );

  /// The light palette, darkened so every token clears 4.5:1 on `--card`.
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

  /// Language keywords.
  final Color keyword;

  /// Quoted literals.
  final Color string;

  /// Numeric literals.
  final Color number;

  /// Capitalised identifiers — in Dart, overwhelmingly types.
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
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

const Set<String> _shellKeywords = <String>{
  'cd',
  'dart',
  'echo',
  'flutter',
  'git',
  'gh',
  'npx',
  'pub',
  'run',
  'test',
  'add',
  'build',
  'analyze',
  'format',
  'web',
  'create',
};

/// Splits [source] into styled spans.
///
/// A deliberately small tokeniser: comments, strings, numbers, keywords and
/// capitalised identifiers, and everything else plain. A real Dart lexer would
/// be more correct and about forty times the size, and nobody has ever chosen a
/// UI library because its docs site parsed generics properly.
List<TextSpan> highlight(
  String source,
  CodeLanguage language,
  SyntaxTheme palette,
) {
  if (language == CodeLanguage.plain) {
    return <TextSpan>[
      TextSpan(
        text: source,
        style: TextStyle(color: palette.plain),
      ),
    ];
  }

  final bool hashComments = language != CodeLanguage.dart;
  final String commentAlt = hashComments
      ? r'(?<comment>//[^\n]*|#[^\n]*)'
      : r'(?<comment>//[^\n]*)';
  // Single- and double-quoted literals, with an optional Dart `r` prefix.
  // Written as a triple-quoted raw string because the pattern contains both
  // quote characters and backslashes, and escaping either would change it.
  const String stringAlt =
      r'''(?<string>r?'(?:\\.|[^'\\\n])*'|"(?:\\.|[^"\\\n])*")''';
  final RegExp pattern = RegExp(
    <String>[
      commentAlt,
      stringAlt,
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

  for (final RegExpMatch match in pattern.allMatches(source)) {
    emit(source.substring(cursor, match.start), palette.plain);
    cursor = match.end;

    final String text = match[0]!;
    if (match.namedGroup('comment') != null) {
      emit(text, palette.comment);
    } else if (match.namedGroup('string') != null) {
      emit(text, palette.string);
    } else if (match.namedGroup('number') != null) {
      emit(text, palette.number);
    } else {
      final Set<String> keywords = language == CodeLanguage.dart
          ? _dartKeywords
          : _shellKeywords;
      final bool isYamlKey =
          language == CodeLanguage.yaml &&
          match.end < source.length &&
          source[match.end] == ':';
      if (isYamlKey || keywords.contains(text)) {
        emit(text, palette.keyword);
      } else if (text.isNotEmpty &&
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
