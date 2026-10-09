import 'package:equatable/equatable.dart';

/// A piece of inline text produced by [parseInline].
sealed class InlineNode extends Equatable {
  const InlineNode();
}

/// Plain text.
class InlineText extends InlineNode {
  /// Creates a text node.
  const InlineText(this.text);

  /// The characters.
  final String text;

  @override
  List<Object?> get props => <Object?>[text];
}

/// `**bold**` text.
class InlineBold extends InlineNode {
  /// Creates a bold node.
  const InlineBold(this.text);

  /// The characters between the asterisks.
  final String text;

  @override
  List<Object?> get props => <Object?>[text];
}

/// `` `code` `` text.
class InlineCode extends InlineNode {
  /// Creates a code node.
  const InlineCode(this.text);

  /// The characters between the backticks.
  final String text;

  @override
  List<Object?> get props => <Object?>[text];
}

/// A `[text](target)` link.
class InlineLink extends InlineNode {
  /// Creates a link node.
  const InlineLink(this.text, this.target);

  /// The visible label.
  final String text;

  /// An external URL, or an internal `slug`, `slug#heading` or `#heading`.
  final String target;

  /// Whether [target] leaves the docs (`http`, `https` or `mailto`).
  bool get isExternal => isExternalTarget(target);

  @override
  List<Object?> get props => <Object?>[text, target];
}

/// Whether [target] points outside the documentation.
bool isExternalTarget(String target) =>
    target.startsWith('http://') ||
    target.startsWith('https://') ||
    target.startsWith('mailto:');

final RegExp _token = RegExp(
  r'`([^`]+)`|\*\*([^*]+)\*\*|\[([^\]]+)\]\(([^)\s]+)\)',
);

/// Parses the small inline markup the content blocks use: `**bold**`,
/// `` `code` `` and `[text](route-or-url)`. Anything else is plain text, and an
/// unmatched marker is left as written, so a stray `*` never throws.
List<InlineNode> parseInline(String source) {
  final List<InlineNode> nodes = <InlineNode>[];
  int cursor = 0;
  for (final RegExpMatch m in _token.allMatches(source)) {
    if (m.start > cursor) {
      nodes.add(InlineText(source.substring(cursor, m.start)));
    }
    if (m.group(1) != null) {
      nodes.add(InlineCode(m.group(1)!));
    } else if (m.group(2) != null) {
      nodes.add(InlineBold(m.group(2)!));
    } else {
      nodes.add(InlineLink(m.group(3)!, m.group(4)!));
    }
    cursor = m.end;
  }
  if (cursor < source.length) nodes.add(InlineText(source.substring(cursor)));
  return nodes;
}

/// The text of [source] with the markup stripped, for search and semantics.
String plainText(String source) => parseInline(source)
    .map(
      (InlineNode n) => switch (n) {
        InlineText(:final String text) => text,
        InlineBold(:final String text) => text,
        InlineCode(:final String text) => text,
        InlineLink(:final String text) => text,
      },
    )
    .join();
