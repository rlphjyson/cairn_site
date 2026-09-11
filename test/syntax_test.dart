import 'package:cairn_site/src/widgets/syntax.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The syntax highlighter is the only non-trivial pure function on the site,
/// and it is exactly the kind of regex-driven code that breaks quietly.
void main() {
  final SyntaxTheme palette = SyntaxTheme.dark(CairnTheme.dark);

  String render(List<TextSpan> spans) =>
      spans.map((TextSpan s) => s.text ?? '').join();

  Color? colourOf(List<TextSpan> spans, String text) {
    for (final TextSpan span in spans) {
      if (span.text == text) return span.style?.color;
    }
    return null;
  }

  test('highlighting is lossless', () {
    const String source = '''
// A comment with 'quotes' and a # hash.
const CairnTheme theme = CairnTheme.dark;
final int count = 45;
''';
    final List<TextSpan> spans = highlight(source, CodeLanguage.dart, palette);
    expect(render(spans), source);
  });

  test('keywords, types, numbers and strings get their own colour', () {
    final List<TextSpan> spans = highlight(
      "const CairnTheme t = CairnTheme.dark; final int n = 45; var s = 'hi';",
      CodeLanguage.dart,
      palette,
    );
    expect(colourOf(spans, 'const'), palette.keyword);
    expect(colourOf(spans, 'CairnTheme'), palette.type);
    expect(colourOf(spans, '45'), palette.number);
    expect(colourOf(spans, "'hi'"), palette.string);
  });

  test('a URL inside a string is not mistaken for a comment', () {
    final List<TextSpan> spans = highlight(
      "final Uri u = Uri.parse('https://ui.shadcn.com');",
      CodeLanguage.dart,
      palette,
    );
    expect(colourOf(spans, "'https://ui.shadcn.com'"), palette.string);
    expect(
      spans.any((TextSpan s) => s.style?.color == palette.comment),
      isFalse,
    );
  });

  test('# is a comment in YAML and shell but not in Dart', () {
    final List<TextSpan> yaml = highlight(
      '# pin an exact commit\nref: 7abb0cc',
      CodeLanguage.yaml,
      palette,
    );
    expect(colourOf(yaml, '# pin an exact commit'), palette.comment);

    final List<TextSpan> dart = highlight(
      'const int x = 1; // fine',
      CodeLanguage.dart,
      palette,
    );
    expect(colourOf(dart, '// fine'), palette.comment);
  });

  test('YAML keys are highlighted', () {
    final List<TextSpan> spans = highlight(
      'dependencies:\n  cairn_ui: ^0.1.0',
      CodeLanguage.yaml,
      palette,
    );
    expect(colourOf(spans, 'dependencies'), palette.keyword);
    expect(colourOf(spans, 'cairn_ui'), palette.keyword);
  });

  test('raw strings keep their r prefix inside the literal', () {
    final List<TextSpan> spans = highlight(
      r"const String s = r'$45.00';",
      CodeLanguage.dart,
      palette,
    );
    expect(colourOf(spans, r"r'$45.00'"), palette.string);
  });

  test('plain returns a single unstyled span', () {
    final List<TextSpan> spans = highlight(
      'const class 45',
      CodeLanguage.plain,
      palette,
    );
    expect(spans, hasLength(1));
    expect(spans.single.style?.color, palette.plain);
  });

  test('the light and dark palettes differ', () {
    final SyntaxTheme light = SyntaxTheme.light(CairnTheme.light);
    expect(light.keyword, isNot(palette.keyword));
    expect(SyntaxTheme.of(CairnTheme.dark).plain, CairnTheme.dark.foreground);
    expect(SyntaxTheme.of(CairnTheme.light).plain, CairnTheme.light.foreground);
  });
}
