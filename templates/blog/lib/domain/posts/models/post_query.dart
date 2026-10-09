import 'package:equatable/equatable.dart';

/// What the grid is asked to show.
class PostQuery extends Equatable {
  /// Creates a query.
  const PostQuery({
    this.category,
    this.search = '',
    this.page = 1,
    this.pageSize = 6,
  });

  /// Only this category, or `null` for all.
  final String? category;

  /// Free text matched against title, excerpt, category, tags and author.
  final String search;

  /// 1-based page.
  final int page;

  /// Posts per page.
  final int pageSize;

  /// Whether a category or a search narrows the list.
  bool get isFiltered => category != null || search.trim().isNotEmpty;

  /// A copy with changes. Pass [clearCategory] to go back to "all".
  PostQuery copyWith({
    String? category,
    bool clearCategory = false,
    String? search,
    int? page,
    int? pageSize,
  }) => PostQuery(
    category: clearCategory ? null : (category ?? this.category),
    search: search ?? this.search,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  @override
  List<Object?> get props => <Object?>[category, search, page, pageSize];
}
