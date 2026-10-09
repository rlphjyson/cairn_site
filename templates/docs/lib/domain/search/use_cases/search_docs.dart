import '../../../common/utils/inline_markup.dart';
import '../../docs/models/doc_block.dart';
import '../../docs/models/doc_page.dart';
import '../../docs/models/docs_site.dart';
import '../models/search_hit.dart';

/// Searches page titles, descriptions and headings.
///
/// With an empty query it returns the whole index, which is what the command
/// palette loads: pages first (grouped by sidebar section), then headings. The
/// palette then filters as the reader types; [call] with a query gives a ranked
/// answer for code that wants one (a results page, a test).
class SearchDocs {
  /// Creates the use case.
  const SearchDocs();

  /// Runs it.
  List<SearchHit> call(DocsSite site, {String query = ''}) {
    final List<SearchHit> pages = <SearchHit>[];
    final List<SearchHit> headings = <SearchHit>[];
    for (final SidebarSection section in site.sidebar) {
      for (final SidebarItem item in section.items) {
        final DocPage? page = site.pageFor(item.slug);
        if (page == null) continue;
        pages.add(
          SearchHit(
            kind: SearchHitKind.page,
            pageSlug: page.slug,
            pageTitle: page.title,
            label: page.title,
            group: section.title,
            keywords: <String>[page.description],
          ),
        );
        for (final DocBlock b in page.blocks) {
          if (b is! HeadingBlock) continue;
          final String text = plainText(b.text);
          headings.add(
            SearchHit(
              kind: SearchHitKind.heading,
              pageSlug: page.slug,
              pageTitle: page.title,
              headingId: b.id,
              label: '${page.title} › $text',
              group: 'Headings',
              keywords: <String>[text],
            ),
          );
        }
      }
    }
    final List<SearchHit> all = <SearchHit>[...pages, ...headings];
    final String q = query.trim();
    if (q.isEmpty) return all;

    // Title matches first, then everything else, each in reading order.
    final String lower = q.toLowerCase();
    int rank(SearchHit h) {
      final String l = h.label.toLowerCase();
      if (h.kind == SearchHitKind.page && l == lower) return 0;
      if (h.kind == SearchHitKind.page && l.contains(lower)) return 1;
      if (l.contains(lower)) return 2;
      return 3;
    }

    final List<SearchHit> found = all
        .where((SearchHit h) => h.matches(q))
        .toList();
    final List<MapEntry<int, SearchHit>> ranked = <MapEntry<int, SearchHit>>[
      for (int i = 0; i < found.length; i++)
        MapEntry<int, SearchHit>(i, found[i]),
    ];
    ranked.sort((MapEntry<int, SearchHit> a, MapEntry<int, SearchHit> b) {
      final int r = rank(a.value).compareTo(rank(b.value));
      return r != 0 ? r : a.key.compareTo(b.key);
    });
    return <SearchHit>[
      for (final MapEntry<int, SearchHit> e in ranked) e.value,
    ];
  }
}
