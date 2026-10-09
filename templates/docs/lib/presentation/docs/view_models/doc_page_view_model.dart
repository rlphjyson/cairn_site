import 'package:flutter/widgets.dart';

import '../../../core/presentation/view_model.dart';
import '../../../domain/docs/models/doc_page.dart';
import '../../../domain/docs/models/docs_site.dart';
import '../../../domain/docs/models/toc_entry.dart';
import '../../../domain/docs/use_cases/extract_headings.dart';
import '../../../domain/docs/use_cases/get_page_neighbours.dart';
import '../bloc/toc_cubit.dart';

/// Owns everything scoped to one open page: the scroll controller, the key of
/// every heading, and the cubit tracking which heading is at the top.
///
/// The page view is rebuilt per page (it is keyed by version and slug), so a
/// new instance starts at the top with no stale keys.
class DocPageViewModel implements ViewModel {
  /// Creates the view model.
  DocPageViewModel(this.toc, this._extractHeadings, this._getNeighbours);

  /// The active-heading cursor the table of contents listens to.
  final TocCubit toc;

  final ExtractHeadings _extractHeadings;
  final GetPageNeighbours _getNeighbours;

  /// Drives the article's scroll view.
  final ScrollController scroll = ScrollController();

  /// Identifies the scroll viewport, to measure headings against.
  final GlobalKey viewportKey = GlobalKey(debugLabel: 'docs viewport');

  final Map<String, GlobalKey> _keys = <String, GlobalKey>{};
  List<TocEntry> _entries = const <TocEntry>[];

  /// How far below the viewport's top a heading rests after a jump, and the
  /// line above which a heading counts as "passed" for the active highlight.
  static const double anchorOffset = 24;

  /// The headings of the bound page, in order.
  List<TocEntry> get entries => _entries;

  /// The previous / next pages of the bound page.
  PageNeighbours neighbours = const PageNeighbours();

  /// Starts tracking [page]'s headings and works out its neighbours in [site].
  void bind(DocsSite site, DocPage page) {
    _entries = _extractHeadings(page);
    neighbours = _getNeighbours(site, page.slug);
    scroll.addListener(_updateActive);
    toc.setActive(_entries.isEmpty ? null : _entries.first.id);
  }

  /// The key a heading widget attaches, so it can be found and measured.
  GlobalKey keyFor(String headingId) => _keys.putIfAbsent(
    headingId,
    () => GlobalKey(debugLabel: 'heading $headingId'),
  );

  /// Scrolls so [headingId] rests just below the top of the viewport.
  void scrollTo(String headingId, {bool animate = true}) {
    final double? target = _targetOffset(headingId);
    if (target == null || !scroll.hasClients) return;
    toc.setActive(headingId);
    if (animate) {
      scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
      );
    } else {
      scroll.jumpTo(target);
    }
  }

  double? _targetOffset(String headingId) {
    final RenderBox? box = _boxFor(headingId);
    final RenderBox? viewport = _viewport;
    if (box == null || viewport == null || !scroll.hasClients) return null;
    final double top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final ScrollPosition p = scroll.position;
    return (p.pixels + top - anchorOffset).clamp(
      p.minScrollExtent,
      p.maxScrollExtent,
    );
  }

  RenderBox? get _viewport =>
      viewportKey.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? _boxFor(String id) {
    final RenderObject? o = _keys[id]?.currentContext?.findRenderObject();
    return o is RenderBox && o.attached ? o : null;
  }

  void _updateActive() {
    if (_entries.isEmpty || !scroll.hasClients) return;
    final RenderBox? viewport = _viewport;
    if (viewport == null) return;
    final ScrollPosition p = scroll.position;
    String active = _entries.first.id;
    if (p.maxScrollExtent > 0 && p.pixels >= p.maxScrollExtent - 2) {
      // At the very end the last headings can never reach the top line.
      active = _entries.last.id;
    } else {
      for (final TocEntry e in _entries) {
        final RenderBox? box = _boxFor(e.id);
        if (box == null) continue;
        final double top = box
            .localToGlobal(Offset.zero, ancestor: viewport)
            .dy;
        if (top <= anchorOffset + 8) active = e.id;
      }
    }
    toc.setActive(active);
  }

  @override
  void dispose() {
    scroll
      ..removeListener(_updateActive)
      ..dispose();
    toc.close();
  }
}
