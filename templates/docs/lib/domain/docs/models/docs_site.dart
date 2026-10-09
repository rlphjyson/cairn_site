import 'package:equatable/equatable.dart';

import 'doc_page.dart';

/// A page link in the sidebar.
class SidebarItem extends Equatable {
  /// Creates an item.
  const SidebarItem({required this.slug, required this.title});

  /// The page it opens.
  final String slug;

  /// The label.
  final String title;

  @override
  List<Object?> get props => <Object?>[slug, title];
}

/// A collapsible group of pages in the sidebar.
class SidebarSection extends Equatable {
  /// Creates a section.
  const SidebarSection({
    required this.id,
    required this.title,
    required this.items,
  });

  /// The stable id, used to remember whether it is collapsed.
  final String id;

  /// The section heading.
  final String title;

  /// The pages in it, in reading order.
  final List<SidebarItem> items;

  @override
  List<Object?> get props => <Object?>[id, title, items];
}

/// The whole content set of one version: the sidebar tree and every page.
class DocsSite extends Equatable {
  /// Creates a site.
  const DocsSite({
    required this.versionId,
    required this.sidebar,
    required this.pages,
  });

  /// The version this content belongs to.
  final String versionId;

  /// The navigation tree. Its order is the reading order.
  final List<SidebarSection> sidebar;

  /// Every page, by slug.
  final Map<String, DocPage> pages;

  /// The slugs in reading order (sidebar order).
  List<String> get orderedSlugs => <String>[
    for (final SidebarSection s in sidebar)
      for (final SidebarItem i in s.items) i.slug,
  ];

  /// The first page in reading order, or `null` for an empty site.
  String? get firstSlug {
    final List<String> slugs = orderedSlugs;
    return slugs.isEmpty ? null : slugs.first;
  }

  /// The page for [slug], or `null` when this version has none.
  DocPage? pageFor(String slug) => pages[slug];

  /// The sidebar section that lists [slug], or `null`.
  SidebarSection? sectionOf(String slug) {
    for (final SidebarSection s in sidebar) {
      if (s.items.any((SidebarItem i) => i.slug == slug)) return s;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[versionId, sidebar, pages];
}
