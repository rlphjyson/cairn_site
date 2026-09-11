import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../app/site_theme.dart';
import '../data/blocks_catalog.dart';
import '../data/components_catalog.dart';
import '../data/docs_catalog.dart';
import '../widgets/site_icons.dart';
import '../widgets/surfaces.dart';

/// What kind of thing a directory row points at.
enum DirectoryKind {
  /// A component module with its own catalogue page.
  component('Component'),

  /// A widget exported from a sibling's module.
  widget('Widget'),

  /// A pre-composed screen.
  block('Block'),

  /// A documentation page.
  doc('Doc');

  const DirectoryKind(this.label);

  /// The badge text.
  final String label;
}

/// One row in the directory.
@immutable
class DirectoryRow {
  /// Creates a row.
  const DirectoryRow({
    required this.name,
    required this.kind,
    required this.group,
    required this.description,
    required this.target,
  });

  /// The thing's name.
  final String name;

  /// Which kind of thing it is.
  final DirectoryKind kind;

  /// Its category or sidebar group.
  final String group;

  /// A one-line summary.
  final String description;

  /// Where the row links to.
  final String target;
}

/// Every component, widget, block and doc page in one searchable index.
///
/// A catalogue grouped by category is good for browsing and bad for finding: a
/// visitor who already knows the name of the thing they want should not have to
/// guess which group it was filed under. So this page flattens the entire site
/// into one sortable, filterable table — every component module, every widget
/// exported alongside one, every block and every documentation page — with a
/// description and a link on each row.
///
/// The table is itself a `CairnDataTable`, so the sorting, filtering and
/// pagination on this page are the library's, not the site's.
class DirectoryPage extends StatelessWidget {
  /// Creates the page.
  const DirectoryPage({super.key});

  /// The full index.
  static List<DirectoryRow> get rows => <DirectoryRow>[
    for (final ComponentEntry entry in componentCatalog) ...<DirectoryRow>[
      DirectoryRow(
        name: entry.name,
        kind: DirectoryKind.component,
        group: entry.category.label,
        description: entry.description,
        target: entry.path,
      ),
      for (final String widgetName in entry.alsoExports)
        DirectoryRow(
          name: widgetName,
          kind: DirectoryKind.widget,
          group: entry.category.label,
          description: 'Exported alongside ${entry.name}.',
          target: entry.path,
        ),
    ],
    for (final BlockEntry block in blockCatalog)
      DirectoryRow(
        name: block.name,
        kind: DirectoryKind.block,
        group: 'Blocks',
        description: block.description,
        target: Routes.blocks,
      ),
    for (final DocPage page in docsCatalog)
      DirectoryRow(
        name: page.title,
        kind: DirectoryKind.doc,
        group: page.group,
        description: page.summary,
        target: page.path,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<DirectoryRow> all = rows;
    final int componentCount = all
        .where((DirectoryRow r) => r.kind == DirectoryKind.component)
        .length;
    final int widgetCount = all
        .where((DirectoryRow r) => r.kind == DirectoryKind.widget)
        .length;

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageHeading(
            eyebrow: 'Index',
            title: 'Directory',
            lead:
                'Everything in one sortable, filterable table: every component '
                'module, every widget exported alongside one, every block and '
                'every documentation page.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          const _NoteOnTheIndex(),
          const SizedBox(height: CairnSpacing.s8),
          Wrap(
            spacing: CairnSpacing.s3,
            runSpacing: CairnSpacing.s3,
            children: <Widget>[
              _Stat(value: '$componentCount', label: 'component pages'),
              _Stat(value: '$widgetCount', label: 'co-located widgets'),
              _Stat(value: '${blockCatalog.length}', label: 'blocks'),
              _Stat(value: '${docsCatalog.length}', label: 'doc pages'),
              _Stat(value: '${all.length}', label: 'rows below'),
            ],
          ),
          const SizedBox(height: CairnSpacing.s8),
          // The directory is itself a CairnDataTable: sorting, filtering and
          // pagination all come from the library rather than being rebuilt.
          //
          // Five columns cannot reflow onto a phone, and the table's flex
          // columns need bounded width, so below 880 it scrolls sideways
          // rather than being squeezed or re-laid-out as cards.
          MinWidthScroller(
            minWidth: 920,
            child: CairnDataTable<DirectoryRow>(
              rows: all,
              pageSize: 15,
              searchBy: (DirectoryRow r) => '${r.name} ${r.description}',
              searchPlaceholder: 'Filter the directory...',
              emptyMessage: 'Nothing in the index matches that.',
              onRowTap: (int index, DirectoryRow r) => context.go(r.target),
              columns: <CairnColumn<DirectoryRow>>[
                CairnColumn<DirectoryRow>(
                  label: 'Name',
                  flex: 2,
                  sortKey: (DirectoryRow r) => r.name,
                  cell: (DirectoryRow r) => Text(
                    r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(
                          color: theme.foreground,
                          fontWeight: CairnTypography.medium,
                        ),
                  ),
                ),
                CairnColumn<DirectoryRow>(
                  label: 'Kind',
                  // Fixed rather than flexed: the badge inside is intrinsically
                  // sized, so a flex share one pixel short of "Component" clips
                  // it rather than shrinking it.
                  width: 116,
                  sortKey: (DirectoryRow r) => r.kind.label,
                  cell: (DirectoryRow r) => CairnBadge(
                    variant: switch (r.kind) {
                      DirectoryKind.component => CairnBadgeVariant.primary,
                      DirectoryKind.block => CairnBadgeVariant.secondary,
                      DirectoryKind.doc => CairnBadgeVariant.outline,
                      DirectoryKind.widget => CairnBadgeVariant.outline,
                    },
                    label: Text(r.kind.label),
                  ),
                ),
                CairnColumn<DirectoryRow>(
                  label: 'Group',
                  sortKey: (DirectoryRow r) => r.group,
                  cell: (DirectoryRow r) => Text(
                    r.group,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CairnColumn<DirectoryRow>(
                  label: 'Description',
                  flex: 4,
                  cell: (DirectoryRow r) => Text(
                    r.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(color: theme.mutedForeground),
                  ),
                ),
                CairnColumn<DirectoryRow>(
                  label: '',
                  width: 96,
                  alignment: Alignment.centerRight,
                  cell: (DirectoryRow r) => CairnButton(
                    variant: CairnButtonVariant.ghost,
                    size: CairnButtonSize.xs,
                    onPressed: () => context.go(r.target),
                    trailing: const SiteIcon(SiteIconData.arrowRight, size: 12),
                    child: const Text('Open'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteOnTheIndex extends StatelessWidget {
  const _NoteOnTheIndex();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(CairnSpacing.s5),
      decoration: BoxDecoration(
        color: theme.subtleSurface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Why a flat index as well as a catalogue',
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  color: theme.foreground,
                  fontWeight: CairnTypography.semibold,
                ),
          ),
          const SizedBox(height: CairnSpacing.s2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              'The Components page groups by what a thing does, which is right '
              'for browsing and wrong for looking something up — a visitor who '
              'already knows the name should not have to guess the group. This '
              'page is the flat view: everything the library and these docs '
              'contain, in one table you can sort, filter and page through. '
              'The table is a CairnDataTable, so the sorting and filtering you '
              'are using are the library\'s, not this site\'s.',
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(
                    color: theme.mutedForeground,
                    height: CairnTypography.leadingRelaxed,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CairnSpacing.s4,
        vertical: CairnSpacing.s3,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            value,
            style: theme
                .textStyle(CairnTypography.xl)
                .copyWith(
                  color: theme.foreground,
                  fontWeight: CairnTypography.semibold,
                ),
          ),
          const SizedBox(width: CairnSpacing.s2),
          Text(
            label,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: theme.mutedForeground),
          ),
        ],
      ),
    );
  }
}
