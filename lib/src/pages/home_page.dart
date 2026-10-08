import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/links.dart';
import '../app/routes.dart';
import '../app/site_theme.dart';
import '../data/block_previews.dart';
import '../data/component_previews.dart';
import '../data/components_catalog.dart';
import '../widgets/bento.dart';
import '../widgets/clickable_variant.dart';
import '../widgets/code_block.dart';
import '../widgets/reveal.dart';
import '../widgets/site_icons.dart';
import '../widgets/surfaces.dart';
import '../widgets/syntax.dart';

/// The landing page.
class HomePage extends StatelessWidget {
  /// Creates the landing page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Hero(),
        _BentoSection(),
        _FeatureSection(),
        _DogfoodSection(),
        _BlocksStrip(),
        _ClosingCta(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= SiteTokens.tabletBreakpoint;

    final TextStyle headline = theme
        .textStyle(wide ? SiteTokens.display2 : SiteTokens.display1)
        .copyWith(
          color: theme.foreground,
          fontWeight: CairnTypography.semibold,
          letterSpacing: CairnTypography.trackingTight(wide ? 60 : 48),
        );

    return _Band(
      child: PageContainer(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? CairnSpacing.s10 : CairnSpacing.s5,
          vertical: wide ? CairnSpacing.s24 : CairnSpacing.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Reveal(child: _AnnouncementPill()),
            const SizedBox(height: CairnSpacing.s8),
            Reveal(
              delay: const Duration(milliseconds: 70),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Text(
                  'A modern, accessible component library for Flutter.',
                  style: headline,
                ),
              ),
            ),
            const SizedBox(height: CairnSpacing.s6),
            Reveal(
              delay: const Duration(milliseconds: 140),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Sixty-five components on one design-token layer — OKLCH '
                  'colour, a multiplier-based radius scale, focus-visible '
                  'rings. Every padding, radius, colour and easing curve is a '
                  'named token rather than a number typed into a widget, and '
                  'golden tests hold it there. No runtime dependencies beyond '
                  'Flutter itself.',
                  style: theme
                      .textStyle(CairnTypography.lg)
                      .copyWith(color: theme.mutedForeground, height: 1.6),
                ),
              ),
            ),
            const SizedBox(height: CairnSpacing.s8),
            Reveal(
              delay: const Duration(milliseconds: 210),
              child: Wrap(
                spacing: CairnSpacing.s3,
                runSpacing: CairnSpacing.s3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  CairnButton(
                    size: CairnButtonSize.lg,
                    onPressed: () => context.go('/docs/installation'),
                    trailing: const SiteIcon(SiteIconData.arrowRight, size: 16),
                    child: const Text('Get started'),
                  ),
                  CairnButton(
                    variant: CairnButtonVariant.outline,
                    size: CairnButtonSize.lg,
                    onPressed: () => context.go(Routes.components),
                    child: const Text('Browse components'),
                  ),
                  CairnButton(
                    variant: CairnButtonVariant.ghost,
                    size: CairnButtonSize.lg,
                    onPressed: () => openExternal(SiteLinks.libraryRepo),
                    trailing: const SiteIcon(
                      SiteIconData.externalLink,
                      size: 15,
                    ),
                    child: const Text('Source'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CairnSpacing.s8),
            Reveal(
              delay: const Duration(milliseconds: 280),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const CodeBlock(
                  'flutter pub add cairn_ui',
                  language: CodeLanguage.shell,
                  filename: 'terminal',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementPill extends StatelessWidget {
  const _AnnouncementPill();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool roomy = MediaQuery.sizeOf(context).width >= 520;
    return HoverLift(
      lift: 1,
      borderRadius: CairnRadius.brFull,
      onTap: () => context.go('/docs/introduction'),
      child: Container(
        padding: const EdgeInsets.all(CairnSpacing.s1),
        decoration: BoxDecoration(
          color: theme.subtleSurface,
          border: Border.all(color: theme.border),
          borderRadius: CairnRadius.brFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CairnBadge(label: Text('v0.2.0')),
            const SizedBox(width: CairnSpacing.s2p5),
            Flexible(
              child: Text(
                roomy
                    ? '65 components, 172 tests, golden-locked'
                    : '65 components, golden-locked',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .textStyle(CairnTypography.sm)
                    .copyWith(color: theme.mutedForeground),
              ),
            ),
            const SizedBox(width: CairnSpacing.s2),
            CairnIcon(
              CairnIconData.chevronRight,
              size: 14,
              color: theme.mutedForeground,
            ),
            const SizedBox(width: CairnSpacing.s2),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bento grid
// ---------------------------------------------------------------------------

class _BentoSection extends StatelessWidget {
  const _BentoSection();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);

    return _Band(
      bordered: true,
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SectionHeading(
              'Everything below is live',
              subtitle:
                  'Not screenshots. Every tile is the real widget from '
                  'package:cairn_ui, mounted in this page — click, drag, tab '
                  'through and type in them.',
            ),
            const SizedBox(height: CairnSpacing.s8),
            BentoGrid(
              tiles: <BentoTile>[
                BentoTile(
                  label: 'Button',
                  caption: '6 variants, 8 sizes',
                  span: 2,
                  child: VariantSetView(set: Previews.button(context)),
                ),
                BentoTile(
                  label: 'Card',
                  child: SizedBox(
                    width: 260,
                    child: CairnCard(
                      gap: CairnSpacing.s4,
                      children: <Widget>[
                        const CairnCardHeader(
                          title: Text('Total revenue'),
                          description: Text('Last 30 days'),
                        ),
                        CairnCardContent(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: CairnSpacing.s2,
                            children: <Widget>[
                              Text(
                                r'$45,231.89',
                                style: theme
                                    .textStyle(CairnTypography.xl2)
                                    .copyWith(
                                      color: theme.foreground,
                                      fontWeight: CairnTypography.semibold,
                                    ),
                              ),
                              const CairnProgress(
                                value: 0.72,
                                height: 6,
                                semanticLabel: 'Revenue',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BentoTile(
                  label: 'Badge & Avatar',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: CairnSpacing.s5,
                    children: <Widget>[
                      VariantSetView(set: Previews.badge(context)),
                      VariantSetView(set: Previews.avatar(context)),
                    ],
                  ),
                ),
                BentoTile(
                  label: 'Calendar',
                  caption: 'fixed 7 x 6 grid',
                  span: 2,
                  height: 380,
                  child: VariantSetView(set: Previews.calendar(context)),
                ),
                BentoTile(
                  label: 'Data Table',
                  caption: 'sort, filter, paginate',
                  span: 2,
                  height: 380,
                  minContentWidth: 560,
                  // Tighter gutters so the 560px table fits a two-column tile
                  // exactly at the 1280px content width.
                  padding: const EdgeInsets.fromLTRB(
                    CairnSpacing.s4,
                    CairnSpacing.s12,
                    CairnSpacing.s4,
                    CairnSpacing.s4,
                  ),
                  child: VariantSetView(set: Previews.dataTable(context)),
                ),
                BentoTile(
                  label: 'Tabs',
                  caption: 'filled and line variants',
                  span: 2,
                  child: VariantSetView(set: Previews.tabs(context)),
                ),
                BentoTile(
                  label: 'Controls',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: CairnSpacing.s5,
                    children: <Widget>[
                      VariantSetView(set: Previews.switchToggle(context)),
                      SizedBox(
                        width: 200,
                        child: VariantSetView(set: Previews.slider(context)),
                      ),
                    ],
                  ),
                ),
                BentoTile(
                  label: 'Toast',
                  caption: 'try one',
                  child: VariantSetView(set: Previews.toast(context)),
                ),
              ],
            ),
            const SizedBox(height: CairnSpacing.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => context.go(Routes.components),
                trailing: const SiteIcon(SiteIconData.arrowRight, size: 15),
                child: Text('See all ${componentCatalog.length} previews'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Features
// ---------------------------------------------------------------------------

class _FeatureSection extends StatelessWidget {
  const _FeatureSection();

  static const List<_Feature> _features = <_Feature>[
    _Feature(
      icon: SiteIconData.ruler,
      title: 'Specified, not eyeballed',
      body:
          'Every token is written as the CSS value it stands for — '
          'oklch(0.205 0 0), px-4, rounded-md — and converted in exactly one '
          'place, with the source string recorded next to the result. The '
          'provenance of any number in the library is one click away.',
    ),
    _Feature(
      icon: SiteIconData.contrast,
      title: 'One theme extension',
      body:
          'CairnTheme rides on ThemeData.extensions rather than introducing a '
          'second theme system. Material widgets keep working, Theme.of stays '
          'the single lookup path, and Flutter animates every token across a '
          'light/dark change for free.',
    ),
    _Feature(
      icon: SiteIconData.shieldCheck,
      title: 'Behaviour, not just appearance',
      body:
          'focus-visible rather than focus, roving focus in tabs and radio '
          'groups, focus trapping and restore in modals, Escape semantics that '
          'differ for Alert Dialog on purpose, and reduced-motion support in '
          'everything that loops.',
    ),
    _Feature(
      icon: SiteIconData.package,
      title: 'No runtime dependencies',
      body:
          'Pure Dart. No icon font, no asset bundle, no platform channels — '
          'the glyphs components need are drawn from Lucide\'s geometry with a '
          'CustomPainter. Every platform Flutter supports is declared because '
          'there is nothing platform-specific to break.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Band(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SectionHeading(
              'Why it is built this way',
              subtitle:
                  'Four decisions that account for most of the difference '
                  'between this and a component library assembled one widget '
                  'at a time.',
            ),
            const SizedBox(height: CairnSpacing.s8),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int columns = constraints.maxWidth >= 1000
                    ? 4
                    : constraints.maxWidth >= 640
                    ? 2
                    : 1;
                final double cell =
                    (constraints.maxWidth - CairnSpacing.s4 * (columns - 1)) /
                    columns;
                return Wrap(
                  spacing: CairnSpacing.s4,
                  runSpacing: CairnSpacing.s4,
                  children: <Widget>[
                    for (final _Feature feature in _features)
                      SizedBox(
                        width: cell,
                        child: _FeatureCard(feature: feature),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature({required this.icon, required this.title, required this.body});

  final SiteIconData icon;
  final String title;
  final String body;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return HoverLift(
      child: CairnCard(
        gap: CairnSpacing.s4,
        children: <Widget>[
          CairnCardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CairnSpacing.s4,
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.secondary,
                    border: Border.all(color: theme.border),
                    borderRadius: BorderRadius.circular(theme.radiusScale.md),
                  ),
                  child: SiteIcon(
                    feature.icon,
                    size: 18,
                    color: theme.foreground,
                  ),
                ),
                Text(
                  feature.title,
                  style: theme
                      .textStyle(CairnTypography.base)
                      .copyWith(
                        color: theme.foreground,
                        fontWeight: CairnTypography.semibold,
                      ),
                ),
                Text(
                  feature.body,
                  style: theme
                      .textStyle(CairnTypography.sm)
                      .copyWith(
                        color: theme.mutedForeground,
                        height: CairnTypography.leadingRelaxed,
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

// ---------------------------------------------------------------------------
// Dogfooding
// ---------------------------------------------------------------------------

class _DogfoodSection extends StatelessWidget {
  const _DogfoodSection();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    final Widget copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeading(
          'This site is the example app',
          subtitle:
              'A component library that only ever shows its components in '
              'isolation has not proved very much. So this site adds cairn_ui '
              'as a pub.dev dependency and builds its own chrome out of it.',
        ),
        const SizedBox(height: CairnSpacing.s6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: CairnSpacing.s3,
          children: <Widget>[
            for (final (String widgetName, String job) in <(String, String)>[
              ('CairnButton', 'every nav link, CTA and toolbar control'),
              ('CairnTabs', 'the Preview / Code toggle on every example'),
              ('CairnSheet', 'the navigation drawer on narrow screens'),
              ('CairnCommand', 'the Ctrl+K palette, wired to the real routes'),
              ('CairnToast', 'the confirmation after a code block is copied'),
              ('CairnTooltip', 'the theme toggle and copy-button hints'),
              ('CairnScrollArea', 'the page scroller and the docs sidebar'),
              (
                'CairnDataTable',
                'the component directory, sortable and filterable',
              ),
            ])
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: CairnIcon(
                      CairnIconData.check,
                      size: 14,
                      color: theme.foreground,
                    ),
                  ),
                  const SizedBox(width: CairnSpacing.s3),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: widgetName,
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(
                                  fontFamily: 'monospace',
                                  fontFamilyFallback: SiteTokens.monoFallback,
                                  color: theme.foreground,
                                ),
                          ),
                          TextSpan(
                            text: '  $job',
                            style: theme
                                .textStyle(CairnTypography.sm)
                                .copyWith(color: theme.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s6),
        Wrap(
          spacing: CairnSpacing.s3,
          runSpacing: CairnSpacing.s3,
          children: <Widget>[
            CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () => openExternal(SiteLinks.siteRepo),
              trailing: const SiteIcon(SiteIconData.externalLink, size: 15),
              child: const Text('Read this site\'s source'),
            ),
            CairnButton(
              variant: CairnButtonVariant.ghost,
              onPressed: () => context.go('/docs/introduction'),
              child: const Text('How it fits together'),
            ),
          ],
        ),
      ],
    );

    const Widget snippet = CodeBlock(
      '''
dependencies:
  # A published release from pub.dev, not a floating branch, so an
  # upstream push cannot change what this site renders between two
  # builds of the same source.
  cairn_ui: ^0.2.0
  fl_chart: ^1.2.0
  go_router: ^17.5.0''',
      language: CodeLanguage.yaml,
      filename: 'cairn_site/pubspec.yaml',
    );

    return _Band(
      bordered: true,
      tinted: true,
      child: PageContainer(
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 5, child: copy),
                  const SizedBox(width: CairnSpacing.s12),
                  const Expanded(flex: 4, child: snippet),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  copy,
                  const SizedBox(height: CairnSpacing.s8),
                  snippet,
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Blocks strip
// ---------------------------------------------------------------------------

class _BlocksStrip extends StatelessWidget {
  const _BlocksStrip();

  @override
  Widget build(BuildContext context) {
    return _Band(
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SectionHeading(
              'Blocks: whole screens, not primitives',
              subtitle:
                  'Login, dashboard, settings, pricing and team — each one '
                  'composed entirely from the components above, with nothing '
                  'new invented to make them look good.',
            ),
            const SizedBox(height: CairnSpacing.s8),
            const Builder(builder: BlockPreviews.pricing),
            const SizedBox(height: CairnSpacing.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: CairnButton(
                variant: CairnButtonVariant.outline,
                onPressed: () => context.go(Routes.blocks),
                trailing: const SiteIcon(SiteIconData.arrowRight, size: 15),
                child: const Text('Browse blocks'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Closing
// ---------------------------------------------------------------------------

class _ClosingCta extends StatelessWidget {
  const _ClosingCta();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 760;

    return _Band(
      bordered: true,
      child: PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Start with the installation guide.',
              textAlign: TextAlign.center,
              style: theme
                  .textStyle(wide ? CairnTypography.xl4 : CairnTypography.xl2)
                  .copyWith(
                    color: theme.foreground,
                    fontWeight: CairnTypography.semibold,
                    letterSpacing: CairnTypography.trackingTight(
                      wide ? 36 : 24,
                    ),
                  ),
            ),
            const SizedBox(height: CairnSpacing.s4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                'Two lines of pubspec, one import, one theme call. Then read '
                'the theming page, because that is where the interesting '
                'decisions are.',
                textAlign: TextAlign.center,
                style: theme
                    .textStyle(CairnTypography.base)
                    .copyWith(color: theme.mutedForeground),
              ),
            ),
            const SizedBox(height: CairnSpacing.s8),
            Wrap(
              spacing: CairnSpacing.s3,
              runSpacing: CairnSpacing.s3,
              alignment: WrapAlignment.center,
              children: <Widget>[
                CairnButton(
                  size: CairnButtonSize.lg,
                  onPressed: () => context.go('/docs/installation'),
                  trailing: const SiteIcon(SiteIconData.arrowRight, size: 16),
                  child: const Text('Install Cairn'),
                ),
                CairnButton(
                  variant: CairnButtonVariant.outline,
                  size: CairnButtonSize.lg,
                  onPressed: () => context.go('/docs/theming'),
                  child: const Text('Read about theming'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared band
// ---------------------------------------------------------------------------

class _Band extends StatelessWidget {
  const _Band({
    required this.child,
    this.bordered = false,
    this.tinted = false,
  });

  final Widget child;
  final bool bordered;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tinted ? theme.subtleSurface : null,
        border: bordered ? Border(top: BorderSide(color: theme.border)) : null,
      ),
      child: child,
    );
  }
}
