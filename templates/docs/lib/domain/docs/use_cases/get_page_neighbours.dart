import 'package:equatable/equatable.dart';

import '../models/docs_site.dart';

/// The pages either side of one in reading order.
class PageNeighbours extends Equatable {
  /// Creates a pair.
  const PageNeighbours({this.previous, this.next});

  /// The page before, or `null` on the first page.
  final SidebarItem? previous;

  /// The page after, or `null` on the last page.
  final SidebarItem? next;

  @override
  List<Object?> get props => <Object?>[previous, next];
}

/// Works out the previous / next links at the foot of a page. Reading order is
/// the sidebar order, and the links cross section boundaries.
class GetPageNeighbours {
  /// Creates the use case.
  const GetPageNeighbours();

  /// Runs it. An unknown [slug] has no neighbours.
  PageNeighbours call(DocsSite site, String slug) {
    final List<SidebarItem> flat = <SidebarItem>[
      for (final SidebarSection s in site.sidebar) ...s.items,
    ];
    final int i = flat.indexWhere((SidebarItem e) => e.slug == slug);
    if (i < 0) return const PageNeighbours();
    return PageNeighbours(
      previous: i > 0 ? flat[i - 1] : null,
      next: i < flat.length - 1 ? flat[i + 1] : null,
    );
  }
}
