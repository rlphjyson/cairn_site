import 'package:equatable/equatable.dart';

/// What a [SearchHit] points at.
enum SearchHitKind {
  /// A whole page.
  page,

  /// A heading inside a page.
  heading,
}

/// One result of searching the documentation.
class SearchHit extends Equatable {
  /// Creates a hit.
  const SearchHit({
    required this.kind,
    required this.pageSlug,
    required this.pageTitle,
    required this.label,
    required this.group,
    this.headingId,
    this.keywords = const <String>[],
  });

  /// Page or heading.
  final SearchHitKind kind;

  /// The page it lives on.
  final String pageSlug;

  /// That page's title.
  final String pageTitle;

  /// The anchor to scroll to, for a heading hit.
  final String? headingId;

  /// What the palette shows: the page title, or `Page › Heading`.
  final String label;

  /// The palette group: the section for pages, `Headings` for headings.
  final String group;

  /// Extra searchable terms (the description, the heading text).
  final List<String> keywords;

  /// Whether this hit matches [query] (case-insensitive, every word).
  bool matches(String query) {
    final List<String> words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return true;
    final String haystack = <String>[
      label,
      ...keywords,
    ].join(' ').toLowerCase();
    return words.every(haystack.contains);
  }

  @override
  List<Object?> get props => <Object?>[
    kind,
    pageSlug,
    pageTitle,
    headingId,
    label,
    group,
    keywords,
  ];
}
