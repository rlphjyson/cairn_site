import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/links.dart';
import '../app/routes.dart';
import '../app/site_theme.dart';
import '../widgets/site_icons.dart';

/// The site footer: navigation, credits and the licence line.
///
/// The credits block is not decoration. Cairn is an independent implementation
/// that reproduces shadcn/ui's *measurements*, bundles Vercel's Geist and
/// redraws Lucide's geometry — every one of those obligations is discharged
/// here as well as in the repository's NOTICE.md.
class SiteFooter extends StatelessWidget {
  /// Creates the footer.
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.border)),
        color: theme.subtleSurface,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: SiteTokens.contentMaxWidth,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? CairnSpacing.s10 : CairnSpacing.s5,
              vertical: CairnSpacing.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: CairnSpacing.s16,
                  runSpacing: CairnSpacing.s10,
                  children: <Widget>[
                    SizedBox(
                      width: wide ? 300 : double.infinity,
                      child: const _Brand(),
                    ),
                    const _FooterColumn(
                      heading: 'Documentation',
                      links: <_FooterLink>[
                        _FooterLink('Introduction', Routes.docsIntroduction),
                        _FooterLink('Installation', '/docs/installation'),
                        _FooterLink('Quick start', '/docs/quick-start'),
                        _FooterLink('Theming', '/docs/theming'),
                        _FooterLink('Accessibility', '/docs/accessibility'),
                      ],
                    ),
                    const _FooterColumn(
                      heading: 'Browse',
                      links: <_FooterLink>[
                        _FooterLink('Components', Routes.components),
                        _FooterLink('Blocks', Routes.blocks),
                        _FooterLink('Charts', Routes.charts),
                        _FooterLink('Directory', Routes.directory),
                        _FooterLink('Typeset', Routes.typeset),
                      ],
                    ),
                    const _FooterColumn(
                      heading: 'Credits',
                      links: <_FooterLink>[
                        _FooterLink(
                          'shadcn/ui',
                          SiteLinks.shadcn,
                          external: true,
                        ),
                        _FooterLink(
                          'Radix UI',
                          SiteLinks.radix,
                          external: true,
                        ),
                        _FooterLink('Geist', SiteLinks.geist, external: true),
                        _FooterLink('Lucide', SiteLinks.lucide, external: true),
                        _FooterLink(
                          'fl_chart',
                          SiteLinks.flChart,
                          external: true,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: CairnSpacing.s12),
                const CairnSeparator(),
                const SizedBox(height: CairnSpacing.s6),
                Wrap(
                  spacing: CairnSpacing.s6,
                  runSpacing: CairnSpacing.s3,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      'MIT licensed. Cairn is an independent implementation and '
                      'is not affiliated with shadcn/ui, Radix UI or Vercel.',
                      style: theme
                          .textStyle(CairnTypography.xs)
                          .copyWith(color: theme.mutedForeground),
                    ),
                    const _PinnedCommitBadge(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(width: 2),
            Text(
              'Cairn UI',
              style: theme
                  .textStyle(CairnTypography.base)
                  .copyWith(
                    color: theme.foreground,
                    fontWeight: CairnTypography.semibold,
                  ),
            ),
            const SizedBox(width: CairnSpacing.s2),
            const CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text('0.1.0'),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s3),
        Text(
          'A Flutter component library rebuilt to shadcn/ui\'s measurements — '
          'the same spacing, radii, colour tokens, type scale and focus-ring '
          'treatment, held in place by golden tests.',
          style: theme
              .textStyle(CairnTypography.sm)
              .copyWith(
                color: theme.mutedForeground,
                height: CairnTypography.leadingRelaxed,
              ),
        ),
        const SizedBox(height: CairnSpacing.s4),
        Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          children: <Widget>[
            CairnButton(
              variant: CairnButtonVariant.outline,
              size: CairnButtonSize.sm,
              onPressed: () => openExternal(SiteLinks.libraryRepo),
              trailing: const SiteIcon(SiteIconData.externalLink, size: 13),
              child: const Text('cairn_ui'),
            ),
            CairnButton(
              variant: CairnButtonVariant.outline,
              size: CairnButtonSize.sm,
              onPressed: () => openExternal(SiteLinks.siteRepo),
              trailing: const SiteIcon(SiteIconData.externalLink, size: 13),
              child: const Text('cairn_site'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinnedCommitBadge extends StatelessWidget {
  const _PinnedCommitBadge();

  @override
  Widget build(BuildContext context) {
    return CairnTooltip(
      message:
          'This site is built against an exact commit of cairn_ui, '
          'not a floating branch.',
      child: CairnButton(
        variant: CairnButtonVariant.ghost,
        size: CairnButtonSize.xs,
        onPressed: () => openExternal(SiteLinks.pinnedCommit),
        // xs buttons force a 12px icon box (`[&_svg]:size-3`), so 12 it is.
        leading: const SiteIcon(SiteIconData.package, size: 12),
        child: const Text('cairn_ui @ ${SiteLinks.pinnedCommitShort}'),
      ),
    );
  }
}

class _FooterLink {
  const _FooterLink(this.label, this.target, {this.external = false});

  final String label;
  final String target;
  final bool external;
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.heading, required this.links});

  final String heading;
  final List<_FooterLink> links;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            heading,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  color: theme.foreground,
                  fontWeight: CairnTypography.medium,
                ),
          ),
          const SizedBox(height: CairnSpacing.s3),
          for (final _FooterLink link in links)
            _FooterLinkRow(key: ValueKey<String>(link.target), link: link),
        ],
      ),
    );
  }
}

class _FooterLinkRow extends StatefulWidget {
  const _FooterLinkRow({super.key, required this.link});

  final _FooterLink link;

  @override
  State<_FooterLinkRow> createState() => _FooterLinkRowState();
}

class _FooterLinkRowState extends State<_FooterLinkRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.link.external
            ? openExternal(widget.link.target)
            : context.go(widget.link.target),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: CairnSpacing.s1p5),
          child: AnimatedDefaultTextStyle(
            duration: CairnMotion.d150,
            curve: CairnMotion.standard,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(
                  color: _hovered ? theme.foreground : theme.mutedForeground,
                ),
            child: Text(widget.link.label),
          ),
        ),
      ),
    );
  }
}
