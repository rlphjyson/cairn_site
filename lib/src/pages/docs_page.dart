import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/site_theme.dart';
import '../data/docs_catalog.dart';
import '../shell/site_footer.dart';
import '../widgets/code_block.dart';
import '../widgets/site_icons.dart';
import '../widgets/surfaces.dart';

/// The documentation layout: a sticky sidebar, the article, and an
/// "On this page" rail — three independent scrollers side by side.
class DocsPage extends StatefulWidget {
  /// Creates the page for [page].
  const DocsPage({super.key, required this.page});

  /// The documentation page being shown.
  final DocPage page;

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  Map<String, GlobalKey> _anchors = <String, GlobalKey>{};
  String? _activeAnchor;

  @override
  void initState() {
    super.initState();
    _rebuildAnchors();
  }

  @override
  void didUpdateWidget(DocsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.slug != widget.page.slug) _rebuildAnchors();
  }

  void _rebuildAnchors() {
    _anchors = <String, GlobalKey>{
      for (final DocHeading heading
          in widget.page.nodes.whereType<DocHeading>())
        heading.id: GlobalKey(debugLabel: heading.id),
    };
    _activeAnchor = widget.page.outline.isEmpty
        ? null
        : widget.page.outline.first.id;
  }

  Future<void> _jumpTo(String id) async {
    final BuildContext? target = _anchors[id]?.currentContext;
    if (target == null) return;
    setState(() => _activeAnchor = id);
    await Scrollable.ensureVisible(
      target,
      duration: CairnMotion.d500,
      curve: CairnMotion.standard,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final bool showSidebar = width >= SiteTokens.desktopBreakpoint;
    final bool showToc = width >= 1360;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showSidebar)
          Container(
            width: SiteTokens.sidebarWidth,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: theme.border)),
            ),
            child: CairnScrollArea(
              padding: const EdgeInsets.symmetric(
                horizontal: CairnSpacing.s4,
                vertical: CairnSpacing.s8,
              ),
              child: DocsSidebar(active: widget.page.slug),
            ),
          ),
        Expanded(
          child: CairnScrollArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                PageContainer(
                  maxWidth: 820,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (!showSidebar) ...<Widget>[
                        _CompactDocNav(active: widget.page.slug),
                        const SizedBox(height: CairnSpacing.s6),
                      ],
                      CairnBreadcrumb(
                        crumbs: <CairnCrumb>[
                          CairnCrumb(
                            label: 'Docs',
                            onTap: () => context.go('/docs'),
                          ),
                          CairnCrumb(
                            label: widget.page.group,
                            onTap: () => context.go('/docs'),
                          ),
                          CairnCrumb.current(label: widget.page.title),
                        ],
                      ),
                      const SizedBox(height: CairnSpacing.s6),
                      PageHeading(
                        title: widget.page.title,
                        lead: widget.page.summary,
                      ),
                      if (!showToc &&
                          widget.page.outline.length > 1) ...<Widget>[
                        const SizedBox(height: CairnSpacing.s8),
                        _InlineToc(
                          headings: widget.page.outline,
                          onTap: _jumpTo,
                        ),
                      ],
                      const SizedBox(height: CairnSpacing.s10),
                      for (final DocNode node in widget.page.nodes)
                        DocNodeView(
                          key: node is DocHeading ? _anchors[node.id] : null,
                          node: node,
                        ),
                      const SizedBox(height: CairnSpacing.s10),
                      const CairnSeparator(),
                      const SizedBox(height: CairnSpacing.s5),
                      _DocFooterNav(page: widget.page),
                    ],
                  ),
                ),
                const SiteFooter(),
              ],
            ),
          ),
        ),
        if (showToc)
          SizedBox(
            width: SiteTokens.tocWidth,
            child: CairnScrollArea(
              padding: const EdgeInsets.only(
                right: CairnSpacing.s6,
                top: CairnSpacing.s10,
              ),
              child: _Toc(
                headings: widget.page.outline,
                active: _activeAnchor,
                onTap: _jumpTo,
              ),
            ),
          ),
      ],
    );
  }
}

/// The grouped list of documentation pages.
class DocsSidebar extends StatelessWidget {
  /// Creates the sidebar.
  const DocsSidebar({super.key, required this.active, this.onNavigate});

  /// The slug of the page currently being read.
  final String active;

  /// Called after a link is followed, so a sheet can close itself.
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final String group in docGroups) ...<Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CairnSpacing.s2,
              CairnSpacing.s4,
              CairnSpacing.s2,
              CairnSpacing.s2,
            ),
            child: Text(
              group,
              style: theme
                  .textStyle(CairnTypography.sm)
                  .copyWith(
                    color: theme.foreground,
                    fontWeight: CairnTypography.semibold,
                  ),
            ),
          ),
          for (final DocPage page in docsCatalog.where(
            (DocPage p) => p.group == group,
          ))
            _SidebarLink(
              label: page.title,
              selected: page.slug == active,
              onTap: () {
                context.go(page.path);
                onNavigate?.call();
              },
            ),
        ],
      ],
    );
  }
}

class _SidebarLink extends StatefulWidget {
  const _SidebarLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarLink> createState() => _SidebarLinkState();
}

class _SidebarLinkState extends State<_SidebarLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: CairnMotion.d150,
          curve: CairnMotion.standard,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: CairnSpacing.s2,
            vertical: CairnSpacing.s1p5,
          ),
          decoration: BoxDecoration(
            color: widget.selected
                ? theme.accent
                : (_hovered ? theme.hoverTint : const Color(0x00000000)),
            borderRadius: BorderRadius.circular(theme.radiusScale.md),
          ),
          child: Text(
            widget.label,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  color: widget.selected
                      ? theme.accentForeground
                      : theme.mutedForeground,
                  fontWeight: widget.selected
                      ? CairnTypography.medium
                      : CairnTypography.normal,
                ),
          ),
        ),
      ),
    );
  }
}

class _CompactDocNav extends StatelessWidget {
  const _CompactDocNav({required this.active});

  final String active;

  @override
  Widget build(BuildContext context) {
    return CairnSelect<String>(
      value: active,
      width: double.infinity,
      semanticLabel: 'Documentation pages',
      options: <CairnSelectOption<String>>[
        for (final DocPage page in docsCatalog)
          CairnSelectOption<String>(
            value: page.slug,
            label: '${page.group} · ${page.title}',
          ),
      ],
      onChanged: (String slug) => context.go('/docs/$slug'),
    );
  }
}

class _Toc extends StatelessWidget {
  const _Toc({
    required this.headings,
    required this.active,
    required this.onTap,
  });

  final List<DocHeading> headings;
  final String? active;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    if (headings.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'On this page',
          style: theme
              .textStyle(CairnTypography.sm)
              .copyWith(
                color: theme.foreground,
                fontWeight: CairnTypography.semibold,
              ),
        ),
        const SizedBox(height: CairnSpacing.s3),
        for (final DocHeading heading in headings)
          _TocLink(
            heading: heading,
            selected: heading.id == active,
            onTap: () => onTap(heading.id),
          ),
      ],
    );
  }
}

class _TocLink extends StatefulWidget {
  const _TocLink({
    required this.heading,
    required this.selected,
    required this.onTap,
  });

  final DocHeading heading;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_TocLink> createState() => _TocLinkState();
}

class _TocLinkState extends State<_TocLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: CairnSpacing.s1p5,
            horizontal: CairnSpacing.s3,
          ),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: widget.selected ? theme.foreground : theme.border,
                width: 2,
              ),
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: CairnMotion.d150,
            curve: CairnMotion.standard,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  color: widget.selected || _hovered
                      ? theme.foreground
                      : theme.mutedForeground,
                ),
            child: Text(widget.heading.text),
          ),
        ),
      ),
    );
  }
}

class _InlineToc extends StatelessWidget {
  const _InlineToc({required this.headings, required this.onTap});

  final List<DocHeading> headings;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(CairnSpacing.s4),
      decoration: BoxDecoration(
        color: theme.subtleSurface,
        border: Border.all(color: theme.border),
        borderRadius: BorderRadius.circular(theme.radiusScale.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'On this page',
            style: theme
                .textStyle(CairnTypography.xs)
                .copyWith(
                  color: theme.mutedForeground,
                  fontWeight: CairnTypography.medium,
                ),
          ),
          const SizedBox(height: CairnSpacing.s2),
          Wrap(
            spacing: CairnSpacing.s2,
            runSpacing: CairnSpacing.s1,
            children: <Widget>[
              for (final DocHeading heading in headings)
                CairnButton(
                  variant: CairnButtonVariant.link,
                  size: CairnButtonSize.sm,
                  onPressed: () => onTap(heading.id),
                  child: Text(heading.text),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DocFooterNav extends StatelessWidget {
  const _DocFooterNav({required this.page});

  final DocPage page;

  @override
  Widget build(BuildContext context) {
    final int index = docsCatalog.indexWhere(
      (DocPage p) => p.slug == page.slug,
    );
    final DocPage? previous = index > 0 ? docsCatalog[index - 1] : null;
    final DocPage? next = index < docsCatalog.length - 1
        ? docsCatalog[index + 1]
        : null;

    return Row(
      children: <Widget>[
        if (previous != null)
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () => context.go(previous.path),
            leading: const CairnIcon(CairnIconData.chevronLeft, size: 15),
            child: Text(previous.title),
          ),
        const Spacer(),
        if (next != null)
          CairnButton(
            variant: CairnButtonVariant.outline,
            onPressed: () => context.go(next.path),
            trailing: const CairnIcon(CairnIconData.chevronRight, size: 15),
            child: Text(next.title),
          ),
      ],
    );
  }
}

/// Renders one [DocNode].
class DocNodeView extends StatelessWidget {
  /// Creates a renderer for [node].
  const DocNodeView({super.key, required this.node});

  /// The node to render.
  final DocNode node;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    switch (node) {
      case final DocHeading heading:
        return Padding(
          padding: EdgeInsets.only(
            top: heading.level == 2 ? CairnSpacing.s10 : CairnSpacing.s6,
            bottom: CairnSpacing.s4,
          ),
          child: Text(
            heading.text,
            style: theme
                .textStyle(
                  heading.level == 2 ? CairnTypography.xl2 : CairnTypography.lg,
                )
                .copyWith(
                  color: theme.foreground,
                  fontWeight: CairnTypography.semibold,
                  letterSpacing: CairnTypography.trackingTight(
                    heading.level == 2 ? 24 : 18,
                  ),
                ),
          ),
        );

      case final DocParagraph paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: CairnSpacing.s5),
          child: Text(
            paragraph.text,
            style: theme
                .textStyle(CairnTypography.base)
                .copyWith(
                  color: theme.mutedForeground,
                  height: CairnTypography.leadingRelaxed,
                ),
          ),
        );

      case final DocCode code:
        return Padding(
          padding: const EdgeInsets.only(bottom: CairnSpacing.s6),
          child: CodeBlock(
            code.code,
            language: code.language,
            filename: code.filename,
          ),
        );

      case final DocList list:
        return Padding(
          padding: const EdgeInsets.only(bottom: CairnSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (int i = 0; i < list.items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: CairnSpacing.s3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // The Align matters: SizedBox(width: 24) passes a
                      // *tight* width to its child, so a 5px bullet without it
                      // is stretched into a 24px dash.
                      SizedBox(
                        width: 24,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: list.ordered
                              ? Text(
                                  '${i + 1}.',
                                  style: theme
                                      .textStyle(CairnTypography.base)
                                      .copyWith(color: theme.mutedForeground),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: theme.mutedForeground,
                                      borderRadius: CairnRadius.brFull,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          list.items[i],
                          style: theme
                              .textStyle(CairnTypography.base)
                              .copyWith(
                                color: theme.mutedForeground,
                                height: CairnTypography.leadingRelaxed,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

      case final DocCallout callout:
        return Padding(
          padding: const EdgeInsets.only(bottom: CairnSpacing.s6),
          child: CairnAlert(
            variant: callout.destructive
                ? CairnAlertVariant.destructive
                : CairnAlertVariant.normal,
            icon: CairnIcon(
              callout.destructive ? CairnIconData.alert : CairnIconData.info,
            ),
            title: Text(callout.title),
            description: Text(callout.body),
          ),
        );

      case final DocTable table:
        return Padding(
          padding: const EdgeInsets.only(bottom: CairnSpacing.s6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.border),
              borderRadius: BorderRadius.circular(theme.radiusScale.lg),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.radiusScale.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CairnSpacing.s3,
                ),
                child: CairnTable<List<String>>(
                  rows: table.rows,
                  columns: <CairnColumn<List<String>>>[
                    for (int i = 0; i < table.headers.length; i++)
                      CairnColumn<List<String>>(
                        label: table.headers[i],
                        flex: i == table.headers.length - 1 ? 3 : 2,
                        cell: (List<String> row) => Text(
                          i < row.length ? row[i] : '',
                          style: theme
                              .textStyle(CairnTypography.sm)
                              .copyWith(
                                color: i == 0
                                    ? theme.foreground
                                    : theme.mutedForeground,
                                fontFamily: i == 0 ? 'monospace' : null,
                                fontFamilyFallback: i == 0
                                    ? SiteTokens.monoFallback
                                    : null,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

      case final DocPreview preview:
        return Padding(
          padding: const EdgeInsets.only(bottom: CairnSpacing.s6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.border),
                  borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radiusScale.lg),
                  child: DotGrid(
                    child: MinWidthScroller(
                      minWidth: 560,
                      child: Padding(
                        padding: const EdgeInsets.all(CairnSpacing.s8),
                        child: Builder(builder: preview.builder),
                      ),
                    ),
                  ),
                ),
              ),
              if (preview.caption != null) ...<Widget>[
                const SizedBox(height: CairnSpacing.s3),
                Row(
                  children: <Widget>[
                    SiteIcon(
                      SiteIconData.code,
                      size: 13,
                      color: theme.mutedForeground,
                    ),
                    const SizedBox(width: CairnSpacing.s2),
                    Expanded(
                      child: Text(
                        preview.caption!,
                        style: theme
                            .textStyle(CairnTypography.xs)
                            .copyWith(color: theme.mutedForeground),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
    }
  }
}
