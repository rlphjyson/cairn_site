import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../data/templates_catalog.dart';
import '../widgets/surfaces.dart';

/// Full-app templates, built from Cairn components and nothing else.
///
/// Blocks are single screens; a template is a whole app you can click through.
/// This page lists them as cards, grouped into phone and browser apps; each
/// card opens the template's own page with the live app, its screenshots and
/// its architecture.
class TemplatesPage extends StatelessWidget {
  /// Creates the page.
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<TemplateEntry> of(TemplateKind kind) =>
        templateCatalog.where((TemplateEntry t) => t.kind == kind).toList();
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageHeading(
            eyebrow: 'Templates',
            title: 'Whole apps, not just screens',
            lead:
                'Blocks compose one screen. Templates compose an app you can '
                'click through, themed only through CairnTheme, with light '
                'and dark for free. Each is its own package with its own '
                'assets, tests and HTML documentation.',
          ),
          const SizedBox(height: CairnSpacing.s12),
          const SectionHeading(
            'Mobile apps',
            subtitle:
                'Phone apps with a bottom dock or a stack of screens. On a '
                'tablet the list-and-detail ones become two panes.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          _TemplateGrid(entries: of(TemplateKind.mobile)),
          const SizedBox(height: CairnSpacing.s16),
          const SectionHeading(
            'Web apps',
            subtitle:
                'Browser apps and pages, responsive from a phone to a wide '
                'desktop.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          _TemplateGrid(entries: of(TemplateKind.web)),
        ],
      ),
    );
  }
}

class _TemplateGrid extends StatelessWidget {
  const _TemplateGrid({required this.entries});

  final List<TemplateEntry> entries;

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
            for (final TemplateEntry entry in entries)
              SizedBox(
                width: cell,
                child: TemplateCard(entry: entry),
              ),
          ],
        );
      },
    );
  }
}

/// One template in the index: a glimpse of its screens over its name and
/// summary. Tapping it opens the template's page.
class TemplateCard extends StatelessWidget {
  /// Creates a card.
  const TemplateCard({super.key, required this.entry});

  /// The template to show.
  final TemplateEntry entry;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle meta = theme
        .textStyle(CairnTypography.xs)
        .copyWith(color: theme.mutedForeground);
    return Semantics(
      button: true,
      label: '${entry.name} template, ${entry.kind.label}',
      excludeSemantics: true,
      child: HoverLift(
        lift: 3,
        onTap: () => context.go(Routes.template(entry.slug)),
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
                _Thumbnail(entry: entry),
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
                            variant: entry.serverRendered
                                ? CairnBadgeVariant.outline
                                : CairnBadgeVariant.secondary,
                            label: Text(
                              entry.serverRendered ? 'Jaspr' : entry.kind.label,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: CairnSpacing.s1p5),
                      Text(
                        entry.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(color: theme.mutedForeground),
                      ),
                      const SizedBox(height: CairnSpacing.s4),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              entry.serverRendered
                                  ? '${entry.screens.length} pages  ·  '
                                        'server-rendered HTML'
                                  : '${entry.screens.length} screens  ·  '
                                        '${entry.uses.length} components',
                              style: meta,
                            ),
                          ),
                          Text(
                            'View template',
                            style: meta.copyWith(
                              color: theme.foreground,
                              fontWeight: CairnTypography.medium,
                            ),
                          ),
                          const SizedBox(width: CairnSpacing.s1),
                          CairnIcon(
                            CairnIconData.chevronRight,
                            size: 14,
                            color: theme.foreground,
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
      ),
    );
  }
}

/// The card's picture: up to three phone screens side by side, or the top of
/// the first browser screen, bleeding off the bottom edge.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.entry});

  final TemplateEntry entry;

  static const double _height = 216;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String mode = theme.brightness == Brightness.dark ? 'dark' : 'light';
    String path(TemplateShot shot) =>
        'assets/screenshots/${entry.slug}-${shot.file}-$mode.${entry.shotExt}';

    return SizedBox(
      height: _height,
      child: ColoredBox(
        color: theme.muted.withValues(alpha: 0.5),
        child: DotGrid(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (entry.kind == TemplateKind.mobile) {
                final List<TemplateShot> shots = entry.shots.take(3).toList();
                const double gap = CairnSpacing.s3;
                final double phone =
                    ((constraints.maxWidth -
                                CairnSpacing.s8 -
                                gap * (shots.length - 1)) /
                            shots.length)
                        .clamp(0, 112)
                        .toDouble();
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: <Widget>[
                    Positioned(
                      top: CairnSpacing.s6,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: gap,
                        children: <Widget>[
                          for (int i = 0; i < shots.length; i++)
                            Padding(
                              // The middle phone sits a little higher.
                              padding: EdgeInsets.only(
                                top: shots.length == 3 && i != 1
                                    ? CairnSpacing.s4
                                    : 0,
                              ),
                              child: Image.asset(
                                path(shots[i]),
                                width: phone,
                                fit: BoxFit.fitWidth,
                                filterQuality: FilterQuality.medium,
                                excludeFromSemantics: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              final Radius radius = Radius.circular(theme.radiusScale.lg);
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  // Taller than the box, so the bottom edge and its corners
                  // are cut off and the page reads as continuing below.
                  Positioned(
                    top: CairnSpacing.s6,
                    left: CairnSpacing.s6,
                    right: CairnSpacing.s6,
                    bottom: -CairnSpacing.s6,
                    child: DecoratedBox(
                      position: DecorationPosition.foreground,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.border),
                        borderRadius: BorderRadius.all(radius),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(radius),
                        child: Image.asset(
                          path(entry.shots.first),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          filterQuality: FilterQuality.medium,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
