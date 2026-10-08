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
          const CairnSeparator(),
          const SizedBox(height: CairnSpacing.s6),
          Center(
            child: CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () => context.go(Routes.components),
              child: const Text('Browse the components these are made of'),
            ),
          ),
          const SizedBox(height: CairnSpacing.s3),
          Center(
            child: CairnButton(
              variant: CairnButtonVariant.ghost,
              onPressed: () => context.go(Routes.templates),
              child: const Text('Want a whole app? See the templates'),
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
