import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../data/blocks_catalog.dart';
import '../data/components_catalog.dart';
import '../widgets/preview_pane.dart';
import '../widgets/surfaces.dart';

/// Pre-composed screens, each built entirely from catalogue components.
class BlocksPage extends StatefulWidget {
  /// Creates the page.
  const BlocksPage({super.key});

  @override
  State<BlocksPage> createState() => _BlocksPageState();
}

class _BlocksPageState extends State<BlocksPage> {
  final Map<String, GlobalKey> _anchors = <String, GlobalKey>{
    for (final BlockEntry block in blockCatalog)
      block.slug: GlobalKey(debugLabel: block.slug),
  };

  Future<void> _jumpTo(String slug) async {
    final BuildContext? target = _anchors[slug]?.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: CairnMotion.d500,
      curve: CairnMotion.standard,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageHeading(
            eyebrow: 'Compositions',
            title: 'Blocks',
            lead:
                'Whole screens assembled from the components in the '
                'catalogue. Nothing here introduces a new widget — the point '
                'of a block is that a design system holds together at screen '
                'scale without needing one.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          Wrap(
            spacing: CairnSpacing.s2,
            runSpacing: CairnSpacing.s2,
            children: <Widget>[
              for (final BlockEntry block in blockCatalog)
                CairnButton(
                  variant: CairnButtonVariant.outline,
                  size: CairnButtonSize.sm,
                  onPressed: () => _jumpTo(block.slug),
                  child: Text(block.name),
                ),
            ],
          ),
          for (final BlockEntry block in blockCatalog) ...<Widget>[
            const SizedBox(height: CairnSpacing.s16),
            _BlockSection(key: _anchors[block.slug], block: block),
          ],
          const SizedBox(height: CairnSpacing.s16),
          const _TemplatesComingSoon(),
          const SizedBox(height: CairnSpacing.s16),
          const CairnSeparator(),
          const SizedBox(height: CairnSpacing.s6),
          Center(
            child: CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () => context.go(Routes.components),
              child: const Text('Browse the components these are made of'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockSection extends StatelessWidget {
  const _BlockSection({super.key, required this.block});

  final BlockEntry block;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionHeading(block.name, subtitle: block.description),
        const SizedBox(height: CairnSpacing.s4),
        Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              'Built from',
              style: theme
                  .textStyle(CairnTypography.xs)
                  .copyWith(color: theme.mutedForeground),
            ),
            for (final String component in block.uses)
              _ComponentChip(name: component),
          ],
        ),
        const SizedBox(height: CairnSpacing.s6),
        PreviewPane(
          preview: block.builder,
          code: block.code,
          minContentWidth: block.wide ? 1060 : 680,
          minHeight: block.wide ? 660 : 420,
          padding: EdgeInsets.all(
            block.wide ? CairnSpacing.s6 : CairnSpacing.s10,
          ),
          codeMaxHeight: 520,
        ),
      ],
    );
  }
}

class _ComponentChip extends StatelessWidget {
  const _ComponentChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final ComponentEntry? match = componentCatalog
        .where((ComponentEntry e) => e.name == name)
        .firstOrNull;
    final Widget badge = CairnBadge(
      variant: CairnBadgeVariant.outline,
      label: Text(name),
    );
    if (match == null) return badge;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: () => context.go(match.path), child: badge),
    );
  }
}

/// The roadmap note for the planned Flutter web and mobile templates.
///
/// Deliberately text only: nothing is built yet, and a preview of an unbuilt
/// template would be a promise the site cannot keep.
class _TemplatesComingSoon extends StatelessWidget {
  const _TemplatesComingSoon();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle small = theme
        .textStyle(CairnTypography.sm)
        .copyWith(color: theme.mutedForeground);

    Widget set(String title, List<String> items) => Expanded(
      child: CairnCard(
        children: <Widget>[
          CairnCardHeader(title: Text(title)),
          CairnCardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s1p5,
              children: <Widget>[
                for (final String item in items) Text(item, style: small),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          spacing: CairnSpacing.s3,
          children: <Widget>[
            Flexible(
              child: Text(
                'Templates',
                style: theme
                    .textStyle(CairnTypography.xl2)
                    .copyWith(
                      color: theme.foreground,
                      fontWeight: CairnTypography.semibold,
                    ),
              ),
            ),
            const CairnBadge(
              variant: CairnBadgeVariant.secondary,
              label: Text('Coming soon'),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s2),
        Text(
          'Flutter web and mobile templates will be provided here. They are '
          'copy-and-run, themed purely through CairnTheme, and ship in light '
          'and dark. Planned, not built yet.',
          style: small,
        ),
        const SizedBox(height: CairnSpacing.s6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: CairnSpacing.s4,
          children: <Widget>[
            set('Web', const <String>[
              'Landing page',
              'Dashboard',
              'Docs shell',
              'Auth screens',
            ]),
            set('Mobile', const <String>[
              'Onboarding',
              'Tab-bar app shell, built on Dock',
              'Settings',
              'Chat',
            ]),
          ],
        ),
      ],
    );
  }
}
