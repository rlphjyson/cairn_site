/// A run of text, either plain or a link.
class TextPart {
  /// Creates a part.
  const TextPart(this.text, {this.isLink = false});

  /// The characters.
  final String text;

  /// Whether [text] is a web address.
  final bool isLink;
}

final RegExp _link = RegExp(r'(?:https?://|www\.)[^\s]+');

/// Splits [text] into plain runs and web addresses, in order.
///
/// Trailing punctuation (`.`, `,`, `!`, `?`, `)`) stays outside the link.
List<TextPart> splitLinks(String text) {
  final List<TextPart> parts = <TextPart>[];
  int cursor = 0;
  for (final RegExpMatch match in _link.allMatches(text)) {
    String url = match.group(0)!;
    int end = match.end;
    while (url.isNotEmpty && '.,!?)'.contains(url[url.length - 1])) {
      url = url.substring(0, url.length - 1);
      end--;
    }
    if (url.isEmpty) continue;
    if (match.start > cursor) {
      parts.add(TextPart(text.substring(cursor, match.start)));
    }
    parts.add(TextPart(url, isLink: true));
    cursor = end;
  }
  if (cursor < text.length) parts.add(TextPart(text.substring(cursor)));
  return parts;
}
