import 'package:equatable/equatable.dart';

import '../../authors/models/author.dart';
import 'content_block.dart';

/// A published article.
class Post extends Equatable {
  /// Creates a post.
  const Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.category,
    required this.tags,
    required this.author,
    required this.publishedAt,
    required this.cover,
    required this.coverAlt,
    required this.body,
    required this.readingMinutes,
    this.featured = false,
  });

  /// Stable identifier and URL slug.
  final String id;

  /// Headline.
  final String title;

  /// One or two sentences for cards.
  final String excerpt;

  /// The one category the post belongs to.
  final String category;

  /// Free-form tags.
  final List<String> tags;

  /// Who wrote it.
  final Author author;

  /// When it went live.
  final DateTime publishedAt;

  /// Bundled asset path or an `http(s)` URL.
  final String cover;

  /// A description of the cover for screen readers.
  final String coverAlt;

  /// The article, block by block.
  final List<ContentBlock> body;

  /// Minutes to read.
  final int readingMinutes;

  /// Whether the editors want it at the top of the home page.
  final bool featured;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    excerpt,
    category,
    tags,
    author,
    publishedAt,
    cover,
    coverAlt,
    body,
    readingMinutes,
    featured,
  ];
}
