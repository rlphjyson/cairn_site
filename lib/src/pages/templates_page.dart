import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/links.dart';
import '../app/routes.dart';
import '../app/site_theme.dart';
import '../data/components_catalog.dart';
import '../templates/shop/shop_app.dart';
import '../widgets/surfaces.dart';

/// Full-app templates, built from Cairn components and nothing else.
///
/// Blocks are single screens; a template is a whole app you can click through.
/// The first one is a mobile storefront, shown live inside a phone frame. The
/// design follows daisyUI's Online Store template, reshaped for a phone.
class TemplatesPage extends StatelessWidget {
  /// Creates the page.
  const TemplatesPage({super.key});

  /// The components the e-commerce template is built from.
  static const List<String> shopUses = <String>[
    'Dock',
    'Input',
    'Button',
    'Badge',
    'Avatar',
    'Indicator',
    'Status',
    'Toggle Group',
    'Rating',
    'List',
    'Steps',
    'Progress',
    'Radial Progress',
    'Timeline',
    'Stat',
    'Switch',
    'Separator',
    'Mockup',
  ];

  /// What is planned next.
  static const List<Planned> roadmap = <Planned>[
    Planned(
      title: 'Web templates',
      status: 'Planned',
      body:
          'Landing page, dashboard, docs shell and auth screens for Flutter '
          'web.',
    ),
    Planned(
      title: 'More mobile templates',
      status: 'Planned',
      body:
          'Onboarding, settings and chat apps to sit beside the storefront, '
          'following daisyUI\'s landing, auth and dashboard templates.',
    ),
    Planned(
      title: 'Paid templates',
      status: 'Planned',
      body:
          'Cairn Site will sell its templates. Payments, licensing and '
          'delivery are to be set up later; until then the e-commerce '
          'template is a free preview.',
    ),
    Planned(
      title: 'Cairn MCP server',
      status: 'Planned',
      body:
          'An MCP server for cairn_ui, so an AI assistant can look up '
          'components, tokens and exact snippets instead of guessing the '
          'API.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool wide =
        MediaQuery.sizeOf(context).width >= SiteTokens.tabletBreakpoint;

    const Widget phone = Center(
      child: CairnMockupPhone(width: 360, child: ShopApp()),
    );
    const Widget info = _ShopInfo();

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
                'and dark for free. Mobile first, for now.',
          ),
          const SizedBox(height: CairnSpacing.s10),
          if (wide)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                phone,
                SizedBox(width: CairnSpacing.s12),
                Expanded(child: info),
              ],
            )
          else ...<Widget>[
            phone,
            const SizedBox(height: CairnSpacing.s10),
            info,
          ],
          const SizedBox(height: CairnSpacing.s16),
          const CairnSeparator(),
          const SizedBox(height: CairnSpacing.s10),
          const _Screenshots(),
          const SizedBox(height: CairnSpacing.s16),
          const CairnSeparator(),
          const SizedBox(height: CairnSpacing.s10),
          const SectionHeading(
            'Roadmap',
            subtitle:
                'What is planned. None of this exists yet, and nothing in the '
                'cairn_ui package depends on it.',
          ),
          const SizedBox(height: CairnSpacing.s6),
          Wrap(
            spacing: CairnSpacing.s4,
            runSpacing: CairnSpacing.s4,
            children: <Widget>[
              for (final Planned item in roadmap)
                SizedBox(width: 320, child: _PlannedCard(item: item)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShopInfo extends StatelessWidget {
  const _ShopInfo();

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final TextStyle muted = theme
        .textStyle(CairnTypography.sm)
        .copyWith(color: theme.mutedForeground, height: 1.55);

    Widget screen(String name, String body) => Padding(
      padding: const EdgeInsets.only(bottom: CairnSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 3, right: CairnSpacing.s3),
            child: CairnStatus(tone: CairnTone.success, size: 8),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '$name  ',
                    style: theme
                        .textStyle(CairnTypography.sm)
                        .copyWith(
                          color: theme.foreground,
                          fontWeight: CairnTypography.medium,
                        ),
                  ),
                  TextSpan(text: body, style: muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          spacing: CairnSpacing.s3,
          children: <Widget>[
            Flexible(
              child: Text(
                'E-commerce',
                style: theme
                    .textStyle(CairnTypography.xl2)
                    .copyWith(
                      color: theme.foreground,
                      fontWeight: CairnTypography.semibold,
                    ),
              ),
            ),
            const CairnBadge(label: Text('Available')),
          ],
        ),
        const SizedBox(height: CairnSpacing.s2),
        Text(
          'A sample storefront in a phone frame, and it is live: search, '
          'filter, save, add to cart and check out. Modelled on daisyUI\'s '
          'Online Store template, with a bottom Dock where the web version '
          'has a navbar.',
          style: muted,
        ),
        const SizedBox(height: CairnSpacing.s6),
        Text(
          'Screens',
          style: theme
              .textStyle(CairnTypography.base)
              .copyWith(
                color: theme.foreground,
                fontWeight: CairnTypography.semibold,
              ),
        ),
        const SizedBox(height: CairnSpacing.s3),
        screen('Shop', 'Promo banner, search, category chips and a grid.'),
        screen('Product', 'Photo, rating, option picker and a sticky buy bar.'),
        screen('Saved', 'Everything you have hearted, with an empty state.'),
        screen('Cart', 'Quantities, free-shipping progress and totals.'),
        screen('Checkout', 'A stepped flow ending in order tracking.'),
        screen('Profile', 'Account stats and preference switches.'),
        const SizedBox(height: CairnSpacing.s3),
        Text(
          'Architecture',
          style: theme
              .textStyle(CairnTypography.base)
              .copyWith(
                color: theme.foreground,
                fontWeight: CairnTypography.semibold,
              ),
        ),
        const SizedBox(height: CairnSpacing.s2),
        Text(
          'Clean architecture, organised by layer and then by feature: '
          'presentation depends on domain, data depends on domain, and the '
          'domain depends on nothing. State is flutter_bloc cubits, wired with '
          'get_it and written out by hand, so there is no code generation.',
          style: muted,
        ),
        const SizedBox(height: CairnSpacing.s3),
        const Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          children: <Widget>[
            CairnBadge(label: Text('Layers by feature')),
            CairnBadge(label: Text('Clean architecture')),
            CairnBadge(label: Text('flutter_bloc')),
            CairnBadge(label: Text('get_it')),
            CairnBadge(label: Text('View models')),
          ],
        ),
        const SizedBox(height: CairnSpacing.s4),
        const CairnMockupCode(
          lines: <String>[
            'lib/',
            '  core/          DI container, navigation, shared widgets',
            '  common/        constants and utils',
            '  data/<feature>/          remote, repositories',
            '  domain/<feature>/        models, mappers, repositories, use_cases',
            '  presentation/<feature>/  bloc, view_models, views, widgets',
          ],
        ),
        const SizedBox(height: CairnSpacing.s3),
        Text(
          'Five features: catalog, saved, cart, checkout and profile. Session '
          'state (cart, saved, checkout, profile) lives in singleton cubits; '
          'the state of each screen lives in a cubit owned by its view model '
          'and closed with it.',
          style: muted,
        ),
        const SizedBox(height: CairnSpacing.s6),
        Text(
          'Built from',
          style: theme
              .textStyle(CairnTypography.base)
              .copyWith(
                color: theme.foreground,
                fontWeight: CairnTypography.semibold,
              ),
        ),
        const SizedBox(height: CairnSpacing.s3),
        Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          children: <Widget>[
            for (final String name in TemplatesPage.shopUses)
              _UseChip(name: name),
          ],
        ),
        const SizedBox(height: CairnSpacing.s6),
        Wrap(
          spacing: CairnSpacing.s2,
          runSpacing: CairnSpacing.s2,
          children: <Widget>[
            CairnButton(
              onPressed: () => openExternal(
                '${SiteLinks.siteRepo}/tree/main/lib/src/templates/'
                'shop',
              ),
              child: const Text('Browse the source'),
            ),
            CairnButton(
              variant: CairnButtonVariant.outline,
              onPressed: () => context.go(Routes.blocks),
              child: const Text('See single-screen blocks'),
            ),
          ],
        ),
        const SizedBox(height: CairnSpacing.s4),
        Text(
          'Photographs from Pexels, used under the Pexels licence. Organised '
          'clean architecture by layer and feature, with flutter_bloc and get_it; '
          'the README in the source folder explains the layers.',
          style: theme
              .textStyle(CairnTypography.xs)
              .copyWith(color: theme.mutedForeground),
        ),
      ],
    );
  }
}

class _UseChip extends StatelessWidget {
  const _UseChip({required this.name});

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

/// One roadmap item.
class Planned {
  const Planned({
    required this.title,
    required this.status,
    required this.body,
  });

  final String title;
  final String status;
  final String body;
}

class _PlannedCard extends StatelessWidget {
  const _PlannedCard({required this.item});

  final Planned item;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return CairnCard(
      children: <Widget>[
        CairnCardHeader(
          title: Text(item.title),
          action: CairnBadge(
            variant: CairnBadgeVariant.secondary,
            label: Text(item.status),
          ),
        ),
        CairnCardContent(
          child: Text(
            item.body,
            style: theme
                .textStyle(CairnTypography.sm)
                .copyWith(color: theme.mutedForeground, height: 1.5),
          ),
        ),
      ],
    );
  }
}

/// One captured screen.
class _Shot {
  const _Shot(this.file, this.caption);

  final String file;
  final String caption;
}

/// Every screen of the template, as captured from the running app.
///
/// Regenerate with `CAPTURE_SCREENSHOTS=1 flutter test
/// test/capture_template_screenshots_test.dart`. Shows the variant matching
/// the site's current theme.
class _Screenshots extends StatelessWidget {
  const _Screenshots();

  static const List<_Shot> shots = <_Shot>[
    _Shot('1-shop', 'Shop'),
    _Shot('2-shop-grid', 'Product grid'),
    _Shot('3-product', 'Product'),
    _Shot('4-saved', 'Saved'),
    _Shot('5-cart', 'Cart'),
    _Shot('6-confirmation', 'Order placed'),
    _Shot('7-profile', 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String mode = theme.brightness == Brightness.dark ? 'dark' : 'light';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHeading(
          'Screenshots',
          subtitle:
              'Every screen of the e-commerce template, in the current theme. '
              'Toggle light and dark in the header to compare.',
        ),
        const SizedBox(height: CairnSpacing.s6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: CairnSpacing.s5,
            children: <Widget>[
              for (final _Shot shot in shots)
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: CairnSpacing.s2,
                    children: <Widget>[
                      Image.asset(
                        'assets/screenshots/shop-${shot.file}-$mode.png',
                        semanticLabel: '${shot.caption} screen, $mode theme',
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.medium,
                      ),
                      Text(
                        shot.caption,
                        style: theme
                            .textStyle(CairnTypography.sm)
                            .copyWith(
                              color: theme.mutedForeground,
                              fontWeight: CairnTypography.medium,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
