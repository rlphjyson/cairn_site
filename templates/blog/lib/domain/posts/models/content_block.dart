import 'package:equatable/equatable.dart';

/// One piece of an article's body.
sealed class ContentBlock extends Equatable {
  const ContentBlock();

  /// The block's text, used for the reading time.
  String get plainText;
}

/// A section heading. [level] 2 is a section, 3 a subsection.
class HeadingBlock extends ContentBlock {
  /// Creates a heading.
  const HeadingBlock(this.text, {this.level = 2});

  /// The heading.
  final String text;

  /// 2 or 3.
  final int level;

  @override
  String get plainText => text;

  @override
  List<Object?> get props => <Object?>[text, level];
}

/// A paragraph.
class ParagraphBlock extends ContentBlock {
  /// Creates a paragraph.
  const ParagraphBlock(this.text);

  /// The paragraph.
  final String text;

  @override
  String get plainText => text;

  @override
  List<Object?> get props => <Object?>[text];
}

/// A pull quote.
class QuoteBlock extends ContentBlock {
  /// Creates a quote.
  const QuoteBlock(this.text, {this.cite});

  /// The quote.
  final String text;

  /// Who said it, if anyone.
  final String? cite;

  @override
  String get plainText => text;

  @override
  List<Object?> get props => <Object?>[text, cite];
}

/// A bulleted list.
class BulletListBlock extends ContentBlock {
  /// Creates a list.
  const BulletListBlock(this.items);

  /// One entry per bullet.
  final List<String> items;

  @override
  String get plainText => items.join(' ');

  @override
  List<Object?> get props => <Object?>[items];
}

/// A code listing.
class CodeBlock extends ContentBlock {
  /// Creates a listing.
  const CodeBlock(this.code, {this.language});

  /// The source.
  final String code;

  /// A label such as `dart`.
  final String? language;

  // Code is skimmed, not read: it is left out of the reading time.
  @override
  String get plainText => '';

  @override
  List<Object?> get props => <Object?>[code, language];
}

/// An inline image with an optional caption.
class ImageBlock extends ContentBlock {
  /// Creates an image.
  const ImageBlock(this.source, {this.caption, this.alt});

  /// Bundled asset path or an `http(s)` URL.
  final String source;

  /// A visible caption.
  final String? caption;

  /// A description for screen readers; falls back to the caption.
  final String? alt;

  @override
  String get plainText => '';

  @override
  List<Object?> get props => <Object?>[source, caption, alt];
}
