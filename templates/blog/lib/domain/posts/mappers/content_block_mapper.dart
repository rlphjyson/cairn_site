import '../models/content_block.dart';

/// Remote JSON -> [ContentBlock].
///
/// The shape of each block:
///
/// ```json
/// {"type": "heading", "level": 2, "text": "..."}
/// {"type": "paragraph", "text": "..."}
/// {"type": "quote", "text": "...", "cite": "..."}
/// {"type": "list", "items": ["...", "..."]}
/// {"type": "code", "language": "dart", "code": "..."}
/// {"type": "image", "src": "assets/images/x.jpg", "caption": "...", "alt": "..."}
/// ```
abstract final class ContentBlockMapper {
  /// Maps one block. Throws [FormatException] on an unknown or malformed one.
  static ContentBlock fromJson(Map<String, Object?> json) {
    final Object? type = json['type'];
    switch (type) {
      case 'heading':
        final Object? level = json['level'];
        return HeadingBlock(
          _text(json, 'text'),
          level: level is int && level == 3 ? 3 : 2,
        );
      case 'paragraph':
        return ParagraphBlock(_text(json, 'text'));
      case 'quote':
        return QuoteBlock(_text(json, 'text'), cite: json['cite'] as String?);
      case 'list':
        final Object? items = json['items'];
        if (items is! List<Object?> || items.isEmpty) {
          throw FormatException('List block needs "items"', json);
        }
        return BulletListBlock(<String>[for (final Object? i in items) '$i']);
      case 'code':
        return CodeBlock(
          _text(json, 'code'),
          language: json['language'] as String?,
        );
      case 'image':
        return ImageBlock(
          _text(json, 'src'),
          caption: json['caption'] as String?,
          alt: json['alt'] as String?,
        );
    }
    throw FormatException('Unknown block type "$type"', json);
  }

  static String _text(Map<String, Object?> json, String key) {
    final Object? value = json[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Block is missing "$key"', json);
  }
}
