import '../models/post.dart';
import '../models/post_page.dart';
import '../models/post_query.dart';

/// Filters, searches and paginates [posts].
///
/// Pure and synchronous: it works on a list the caller already loaded, so the
/// same code serves an in-memory source and a backend that returns everything.
/// If your backend paginates, replace this use case with one that calls it.
class QueryPosts {
  /// Creates the use case.
  const QueryPosts();

  /// Runs it.
  ///
  /// [excludeId] drops one post before paging, for the home page whose hero
  /// already shows it. The page number is clamped into range.
  PostPage call(List<Post> posts, PostQuery query, {String? excludeId}) {
    final List<String> terms = query.search
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((String t) => t.isNotEmpty)
        .toList();

    final List<Post> matches = <Post>[
      for (final Post p in posts)
        if (p.id != excludeId &&
            (query.category == null || p.category == query.category) &&
            _matches(p, terms))
          p,
    ];

    final int size = query.pageSize < 1 ? 1 : query.pageSize;
    final int pageCount = matches.isEmpty ? 1 : (matches.length / size).ceil();
    final int page = query.page.clamp(1, pageCount);
    final int start = (page - 1) * size;
    final int end = start + size > matches.length
        ? matches.length
        : start + size;

    return PostPage(
      items: matches.sublist(start, end),
      page: page,
      pageCount: pageCount,
      total: matches.length,
    );
  }

  /// Every term must appear somewhere in the searchable text.
  bool _matches(Post post, List<String> terms) {
    if (terms.isEmpty) return true;
    final String haystack = <String>[
      post.title,
      post.excerpt,
      post.category,
      post.author.name,
      ...post.tags,
    ].join(' ').toLowerCase();
    return terms.every(haystack.contains);
  }
}
