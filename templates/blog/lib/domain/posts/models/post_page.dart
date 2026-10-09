import 'package:equatable/equatable.dart';

import 'post.dart';

/// One page of a [PostQuery]'s results.
class PostPage extends Equatable {
  /// Creates a page.
  const PostPage({
    required this.items,
    required this.page,
    required this.pageCount,
    required this.total,
  });

  /// An empty first page.
  static const PostPage empty = PostPage(
    items: <Post>[],
    page: 1,
    pageCount: 1,
    total: 0,
  );

  /// The posts on this page.
  final List<Post> items;

  /// 1-based, already clamped into range.
  final int page;

  /// At least 1.
  final int pageCount;

  /// Matches across all pages.
  final int total;

  @override
  List<Object?> get props => <Object?>[items, page, pageCount, total];
}
