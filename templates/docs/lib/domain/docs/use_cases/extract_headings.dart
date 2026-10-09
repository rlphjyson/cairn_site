import '../models/doc_block.dart';
import '../models/doc_page.dart';
import '../models/toc_entry.dart';

/// Lists a page's `h2` and `h3` headings, in order, for the "On this page"
/// rail. Headings inside tabs and steps are not included: they are not stable
/// anchors, because only the selected tab is on screen.
class ExtractHeadings {
  /// Creates the use case.
  const ExtractHeadings();

  /// Runs it.
  List<TocEntry> call(DocPage page) => <TocEntry>[
    for (final DocBlock b in page.blocks)
      if (b is HeadingBlock) TocEntry(id: b.id, text: b.text, level: b.level),
  ];
}
