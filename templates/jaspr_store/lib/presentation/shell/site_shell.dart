/// Chrome shared by every page: skip link, announcement bar, header (with a
/// no-JS mobile menu), `<main>` landmark and footer.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/utils/money.dart';
import '../../core/config/brand.dart';
import '../../core/config/store_config.dart';
import '../../domain/catalog/models/product.dart';
import '../components/html.dart';
import '../components/icons.dart';
import '../islands/cart_link.dart';
import '../islands/theme_toggle.dart';
import '../theme/tokens.dart';

class SiteShell extends StatelessComponent {
  const SiteShell({
    required this.config,
    required this.categories,
    required this.currentPath,
    required this.theme,
    required this.child,
    super.key,
  });

  final StoreConfig config;
  final List<Category> categories;
  final String currentPath;

  /// `light`, `dark` or `system`.
  final String theme;
  final Component child;

  bool _active(String path) =>
      path == '/' ? currentPath == '/' : currentPath == path || currentPath.startsWith('$path/');

  Component _navLink(String href, String label) => a(
    href: href,
    classes: _active(href) ? 'is-active' : null,
    attributes: _active(href) ? const {'aria-current': 'page'} : null,
    [t(label)],
  );

  List<Component> _navLinks() => [
    _navLink('/products', 'Shop all'),
    for (final c in categories) _navLink('/categories/${c.slug}', c.name),
    _navLink('/about', 'About'),
  ];

  Component _searchForm({String idSuffix = 'desktop'}) => form(
    action: '/products',
    method: FormMethod.get,
    classes: 'search',
    attributes: const {'role': 'search'},
    [
      el('label', classes: 'sr-only', attrs: {'for': 'search-$idSuffix'}, children: [t('Search products')]),
      span(classes: 'search__icon', [Icons.search()]),
      el(
        'input',
        id: 'search-$idSuffix',
        classes: 'input search__input',
        attrs: const {
          'type': 'search',
          'name': 'q',
          'placeholder': 'Search products',
          'autocomplete': 'off',
          'enterkeyhint': 'search',
        },
      ),
    ],
  );

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      a(href: '#main', classes: 'skip-link', [t('Skip to content')]),
      div(classes: 'announce', [
        div(classes: 'container', [
          p([
            t(
              'Free standard shipping over ${formatMoney(config.shipping.freeThresholdCents, currency: config.currency)}',
            ),
            span(classes: 'announce__sep', attributes: const {'aria-hidden': 'true'}, [t(' · ')]),
            span(classes: 'announce__demo', [t('Demo store: no real orders or payments')]),
          ]),
        ]),
      ]),
      header(classes: 'site-header', [
        div(classes: 'container header-bar', [
          details(classes: 'mobile-menu', [
            summary(
              classes: 'icon-btn mobile-menu__button',
              attributes: const {'aria-label': 'Menu'},
              [
                span(classes: 'mobile-menu__open', [Icons.menu()]),
                span(classes: 'mobile-menu__close', [Icons.close()]),
              ],
            ),
            div(classes: 'mobile-menu__panel', [
              _searchForm(idSuffix: 'mobile'),
              nav(attributes: const {'aria-label': 'Mobile'}, _navLinks()),
            ]),
          ]),
          a(
            href: '/',
            classes: 'brand',
            attributes: {'aria-label': '${Brand.name}, home'},
            [
              brandMark(),
              span(classes: 'brand__name', [t(Brand.name)]),
            ],
          ),
          nav(classes: 'primary-nav', attributes: const {'aria-label': 'Primary'}, _navLinks()),
          div(classes: 'header-actions', [
            _searchForm(),
            ThemeToggle(initialTheme: theme),
            const CartLink(),
          ]),
        ]),
      ]),
      main_(id: 'main', [child]),
      footer(classes: 'site-footer', [
        div(classes: 'container', [
          div(classes: 'footer-grid', [
            div(classes: 'footer-about', [
              a(
                href: '/',
                classes: 'brand',
                attributes: {'aria-label': '${Brand.name}, home'},
                [
                  brandMark(),
                  span(classes: 'brand__name', [t(Brand.name)]),
                ],
              ),
              p(classes: 'muted text-sm', [t(Brand.tagline)]),
              p(classes: 'muted text-sm', [
                t('${Brand.address1}, ${Brand.addressCity}, ${Brand.addressRegion} ${Brand.addressPostal}'),
              ]),
            ]),
            nav(
              classes: 'footer-col',
              attributes: const {'aria-label': 'Shop'},
              [
                h2(classes: 'footer-col__title', [t('Shop')]),
                ul([
                  li([
                    a(href: '/products', [t('All products')]),
                  ]),
                  for (final c in categories)
                    li([
                      a(href: '/categories/${c.slug}', [t(c.name)]),
                    ]),
                ]),
              ],
            ),
            nav(
              classes: 'footer-col',
              attributes: const {'aria-label': 'Help'},
              [
                h2(classes: 'footer-col__title', [t('Help')]),
                ul([
                  li([
                    a(href: '/cart', [t('Your cart')]),
                  ]),
                  li([
                    a(href: '/about#shipping', [t('Shipping and returns')]),
                  ]),
                  li([
                    a(href: '/newsletter', [t('Newsletter')]),
                  ]),
                  li([
                    a(href: 'mailto:${Brand.supportEmail}', [t('Contact us')]),
                  ]),
                ]),
              ],
            ),
            nav(
              classes: 'footer-col',
              attributes: const {'aria-label': 'Company'},
              [
                h2(classes: 'footer-col__title', [t('Company')]),
                ul([
                  li([
                    a(href: '/about', [t('About ${Brand.shortName}')]),
                  ]),
                  li([
                    a(href: '/sitemap.xml', [t('Sitemap')]),
                  ]),
                ]),
              ],
            ),
          ]),
          div(classes: 'footer-base', [
            p(classes: 'muted text-sm', [
              t(
                '© ${DateTime.now().year} ${Brand.legalName} This is a demo store built from a template; nothing here can be bought.',
              ),
            ]),
          ]),
        ]),
      ]),
    ]);
  }
}

@css
List<StyleRule> get shellStyles => [
  rule('.announce', {
    'background': Tok.primary,
    'color': Tok.primaryForeground,
    'font-size': 'var(--text-xs)',
    'text-align': 'center',
    'padding': '${Tok.space(2)} 0',
  }),
  rule('.announce__demo', {'display': 'none'}),
  rule('.announce__sep', {'display': 'none'}),
  atMin('40rem', [
    rule('.announce__demo, .announce__sep', {'display': 'inline'}),
  ]),
  rule('.site-header', {
    'position': 'sticky',
    'top': '0',
    'z-index': '40',
    'background': 'color-mix(in oklab, var(--background) 92%, transparent)',
    '-webkit-backdrop-filter': 'saturate(1.4) blur(10px)',
    'backdrop-filter': 'saturate(1.4) blur(10px)',
    'border-bottom': '1px solid var(--border)',
  }),
  rule('.header-bar', {'display': 'flex', 'align-items': 'center', 'gap': Tok.space(3), 'height': '4rem'}),
  rule('.brand', {
    'display': 'inline-flex',
    'align-items': 'center',
    'gap': Tok.space(2.5),
    'font-weight': '600',
    'letter-spacing': '-0.02em',
    'color': Tok.foreground,
  }),
  rule('.brand-mark', {'color': Tok.primary, 'flex': 'none'}),
  rule('.brand__name', {'font-size': 'var(--text-base)', 'white-space': 'nowrap'}),
  rule('.primary-nav', {'display': 'none'}),
  rule('.primary-nav a', {
    'padding': '${Tok.space(1.5)} ${Tok.space(2.5)}',
    'border-radius': Tok.radiusMd,
    'font-size': 'var(--text-sm)',
    'font-weight': '500',
    'color': Tok.mutedForeground,
    'white-space': 'nowrap',
  }),
  rule('.primary-nav a:hover', {'color': Tok.foreground, 'background': Tok.accent}),
  rule('.primary-nav a.is-active', {'color': Tok.foreground}),
  rule('.header-actions', {'display': 'flex', 'align-items': 'center', 'gap': Tok.space(1), 'margin-left': 'auto'}),
  rule('.header-actions .search', {'display': 'none'}),
  atMin('64rem', [
    rule('.primary-nav', {
      'display': 'flex',
      'align-items': 'center',
      'gap': Tok.space(0.5),
      'margin-left': Tok.space(4),
    }),
    rule('.mobile-menu', {'display': 'none'}),
    rule('.header-actions .search', {'display': 'block', 'width': '11rem'}),
  ]),
  atMin('80rem', [
    rule('.header-actions .search', {'width': '14rem'}),
  ]),
  rule('.icon-btn', {
    'display': 'inline-flex',
    'align-items': 'center',
    'justify-content': 'center',
    'width': '2.25rem',
    'height': '2.25rem',
    'border': '0',
    'border-radius': Tok.radiusMd,
    'background': 'transparent',
    'color': Tok.foreground,
    'cursor': 'pointer',
    'list-style': 'none',
  }),
  rule('.icon-btn:hover', {'background': Tok.accent}),
  rule('.icon-btn::-webkit-details-marker', {'display': 'none'}),
  rule('.cart-link', {
    'position': 'relative',
    'display': 'inline-flex',
    'align-items': 'center',
    'gap': Tok.space(2),
    'height': '2.25rem',
    'padding': '0 ${Tok.space(2.5)}',
    'border-radius': Tok.radiusMd,
    'font-size': 'var(--text-sm)',
    'font-weight': '500',
  }),
  rule('.cart-link:hover', {'background': Tok.accent}),
  rule('.cart-link__text', {'display': 'none'}),
  atMin('40rem', [
    rule('.cart-link__text', {'display': 'inline'}),
  ]),
  rule('.cart-link__count', {
    'display': 'inline-flex',
    'align-items': 'center',
    'justify-content': 'center',
    'min-width': '1.25rem',
    'height': '1.25rem',
    'padding': '0 0.3rem',
    'border-radius': '9999px',
    'background': Tok.primary,
    'color': Tok.primaryForeground,
    'font-size': '0.6875rem',
    'font-weight': '600',
    'font-variant-numeric': 'tabular-nums',
  }),
  rule('.search', {'position': 'relative'}),
  rule('.search__icon', {
    'position': 'absolute',
    'left': Tok.space(2.5),
    'top': '50%',
    'transform': 'translateY(-50%)',
    'color': Tok.mutedForeground,
    'display': 'flex',
    'pointer-events': 'none',
  }),
  rule('.search__input', {'padding-left': '2rem'}),
  // Mobile menu: a native <details>, so it opens and closes with no JavaScript.
  rule('.mobile-menu__close', {'display': 'none'}),
  rule('.mobile-menu[open] .mobile-menu__close', {'display': 'inline-flex'}),
  rule('.mobile-menu[open] .mobile-menu__open', {'display': 'none'}),
  rule('.mobile-menu__panel', {
    'position': 'absolute',
    'left': '0',
    'right': '0',
    'top': '100%',
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(4),
    'padding': Tok.space(4),
    'background': Tok.background,
    'border-bottom': '1px solid var(--border)',
    'box-shadow': Tok.shadowLg,
    'max-height': 'calc(100vh - 6rem)',
    'overflow': 'auto',
  }),
  rule('.mobile-menu__panel nav', {'display': 'flex', 'flex-direction': 'column'}),
  rule('.mobile-menu__panel nav a', {
    'padding': '${Tok.space(3)} ${Tok.space(2)}',
    'border-bottom': '1px solid var(--border)',
    'font-weight': '500',
  }),
  rule('.mobile-menu__panel nav a.is-active', {'color': Tok.foreground, 'font-weight': '600'}),
  rule('main', {'padding-bottom': Tok.space(16)}),
  rule('main:has(> section.section--muted:last-child)', {'padding-bottom': '0'}),
  rule('.site-footer', {
    'border-top': '1px solid var(--border)',
    'background': Tok.muted,
    'padding-block': '${Tok.space(12)} ${Tok.space(8)}',
  }),
  rule('.footer-grid', {'display': 'grid', 'grid-template-columns': 'repeat(2, minmax(0, 1fr))', 'gap': Tok.space(8)}),
  rule('.footer-about', {
    'grid-column': '1 / -1',
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(3),
    'align-items': 'flex-start',
  }),
  atMin('48rem', [
    rule('.footer-grid', {'grid-template-columns': '2fr repeat(3, 1fr)'}),
    rule('.footer-about', {'grid-column': 'auto'}),
  ]),
  rule('.footer-col__title', {
    'font-size': 'var(--text-sm)',
    'font-weight': '600',
    'margin-bottom': Tok.space(3),
    'letter-spacing': '0',
  }),
  rule('.footer-col ul', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(2)}),
  rule('.footer-col a', {'font-size': 'var(--text-sm)', 'color': Tok.mutedForeground}),
  rule('.footer-col a:hover', {'color': Tok.foreground, 'text-decoration': 'underline'}),
  rule('.footer-base', {
    'margin-top': Tok.space(10),
    'padding-top': Tok.space(6),
    'border-top': '1px solid var(--border)',
  }),
];
