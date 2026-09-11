import 'dart:async';

import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/components_catalog.dart';
import '../widgets/code_block.dart';
import '../widgets/site_icons.dart';
import '../widgets/surfaces.dart';

/// The component catalogue: every component, live, with its snippet one click
/// away.
class ComponentsPage extends StatefulWidget {
  /// Creates the catalogue.
  const ComponentsPage({super.key});

  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  final TextEditingController _search = TextEditingController();
  ComponentCategory? _category;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ComponentEntry> get _visible {
    final String q = _query.trim().toLowerCase();
    return componentCatalog.where((ComponentEntry e) {
      if (_category != null && e.category != _category) return false;
      if (q.isEmpty) return true;
      return e.name.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q) ||
          e.alsoExports.any((String w) => w.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final List<ComponentEntry> visible = _visible;
    const int moduleCount = 45;

    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PageHeading(
            eyebrow: 'Catalogue',
            title: 'Components',
            lead:
                'All $moduleCount component modules in package:cairn_ui, '
                'rendered live. Five of the ${componentCatalog.length} cards '
                'below — Alert Dialog, Drawer, Collapsible, Navigation Menu '
                'and Hover Card — ship inside a sibling\'s source file rather '
                'than their own, which is how $moduleCount modules produce '
                '${componentCatalog.length} widgets worth browsing.',
          ),
          const SizedBox(height: CairnSpacing.s8),
          _Filters(
            search: _search,
            category: _category,
            onCategory: (ComponentCategory? c) => setState(() => _category = c),
            onQuery: (String q) => setState(() => _query = q),
          ),
          const SizedBox(height: CairnSpacing.s6),
          Text(
            visible.length == componentCatalog.length
                ? '${visible.length} components'
                : '${visible.length} of ${componentCatalog.length} components',
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: theme.mutedForeground),
          ),
          const SizedBox(height: CairnSpacing.s5),
          if (visible.isEmpty)
            CairnEmpty(
              media: const CairnIcon(CairnIconData.search, size: 32),
              title: 'Nothing matches',
              description:
                  'No component name or description contains "$_query".',
              actions: <Widget>[
                CairnButton(
                  variant: CairnButtonVariant.outline,
                  onPressed: () {
                    _search.clear();
                    setState(() {
                      _query = '';
                      _category = null;
                    });
                  },
                  child: const Text('Clear filters'),
                ),
              ],
            )
          else
            _CatalogueGrid(entries: visible),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.search,
    required this.category,
    required this.onCategory,
    required this.onQuery,
  });

  final TextEditingController search;
  final ComponentCategory? category;
  final ValueChanged<ComponentCategory?> onCategory;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Wrap(
      spacing: CairnSpacing.s4,
      runSpacing: CairnSpacing.s4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        CairnScrollArea(
          axis: Axis.horizontal,
          child: CairnTabs<ComponentCategory?>(
            value: category,
            onChanged: onCategory,
            tabs: <CairnTab<ComponentCategory?>>[
              const CairnTab<ComponentCategory?>(
                value: null,
                label: Text('All'),
              ),
              for (final ComponentCategory c in ComponentCategory.values)
                CairnTab<ComponentCategory?>(value: c, label: Text(c.label)),
            ],
          ),
        ),
        SizedBox(
          width: 260,
          child: CairnInput(
            controller: search,
            placeholder: 'Filter components...',
            semanticLabel: 'Filter components',
            leading: CairnIcon(
              CairnIconData.search,
              color: theme.mutedForeground,
            ),
            onChanged: onQuery,
          ),
        ),
      ],
    );
  }
}

class _CatalogueGrid extends StatelessWidget {
  const _CatalogueGrid({required this.entries});

  final List<ComponentEntry> entries;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 1080
            ? 3
            : constraints.maxWidth >= 680
            ? 2
            : 1;
        final double cell =
            (constraints.maxWidth - CairnSpacing.s5 * (columns - 1)) / columns;
        return Wrap(
          spacing: CairnSpacing.s5,
          runSpacing: CairnSpacing.s5,
          children: <Widget>[
            for (final ComponentEntry entry in entries)
              SizedBox(
                width: cell,
                child: ComponentCard(entry: entry),
              ),
          ],
        );
      },
    );
  }
}

/// One catalogue card: a live, interactive preview over the component's name,
/// description and snippet.
class ComponentCard extends StatelessWidget {
  /// Creates a card.
  const ComponentCard({super.key, required this.entry});

  /// The component to show.
  final ComponentEntry entry;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return HoverLift(
      lift: 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.card,
          border: Border.all(color: theme.border),
          borderRadius: BorderRadius.circular(theme.radiusScale.xl),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radiusScale.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // The live widget. FittedBox scales oversized previews — the
              // data table is 560 wide — down into the card without clipping
              // them, and the scale transform still hit-tests correctly, so
              // the shrunken component stays interactive.
              SizedBox(
                height: 190,
                child: DotGrid(
                  child: Padding(
                    padding: const EdgeInsets.all(CairnSpacing.s4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Builder(builder: entry.preview),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.border)),
                ),
                padding: const EdgeInsets.all(CairnSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entry.name,
                            style: theme
                                .textStyle(CairnTypography.base)
                                .copyWith(
                                  color: theme.foreground,
                                  fontWeight: CairnTypography.semibold,
                                ),
                          ),
                        ),
                        CairnBadge(
                          variant: CairnBadgeVariant.outline,
                          label: Text(entry.category.label),
                        ),
                      ],
                    ),
                    const SizedBox(height: CairnSpacing.s2),
                    SizedBox(
                      height: 40,
                      child: Text(
                        entry.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(color: theme.mutedForeground),
                      ),
                    ),
                    const SizedBox(height: CairnSpacing.s3),
                    Row(
                      children: <Widget>[
                        CairnButton(
                          variant: CairnButtonVariant.outline,
                          size: CairnButtonSize.sm,
                          onPressed: () => context.go(entry.path),
                          child: const Text('Details'),
                        ),
                        const SizedBox(width: CairnSpacing.s2),
                        CairnButton(
                          variant: CairnButtonVariant.ghost,
                          size: CairnButtonSize.sm,
                          onPressed: () => unawaited(showCode(context, entry)),
                          leading: const SiteIcon(SiteIconData.code, size: 14),
                          child: const Text('Code'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens a component's snippet in a Cairn dialog.
Future<void> showCode(BuildContext context, ComponentEntry entry) {
  return showCairnDialog<void>(
    context: context,
    builder: (BuildContext context) => CairnDialog(
      maxWidth: 680,
      title: Text(entry.name),
      description: Text(entry.description),
      content: SizedBox(
        width: double.infinity,
        child: CodeBlock(entry.code, maxHeight: 360),
      ),
      actions: <Widget>[
        CairnButton(
          variant: CairnButtonVariant.outline,
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        CairnButton(
          onPressed: () {
            Navigator.pop(context);
            context.go(entry.path);
          },
          child: const Text('Open page'),
        ),
      ],
    ),
  );
}
