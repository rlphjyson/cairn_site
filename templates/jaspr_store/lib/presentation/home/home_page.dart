library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/utils/money.dart';
import '../../core/config/brand.dart';
import '../../core/config/store_config.dart';
import '../../domain/catalog/models/product.dart';
import '../components/buttons.dart';
import '../components/commerce.dart';
import '../components/forms.dart';
import '../components/html.dart';
import '../components/icons.dart';
import '../components/media.dart';
import '../theme/tokens.dart';

class HomePage extends StatelessComponent {
  const HomePage({
    required this.config,
    required this.featured,
    required this.categories,
    required this.categoryCounts,
    super.key,
  });

  final StoreConfig config;
  final List<Product> featured;
  final List<Category> categories;
  final Map<String, int> categoryCounts;

  @override
  Component build(BuildContext context) {
    final threshold = formatMoney(config.shipping.freeThresholdCents, currency: config.currency);
    return Component.fragment([
      section(classes: 'hero', [
        div(classes: 'container hero__inner', [
          div(classes: 'hero__copy', [
            p(classes: 'eyebrow', [t('New season')]),
            h1([t(Brand.tagline)]),
            p(classes: 'hero__lead', [
              t(
                'Sneakers, headphones, watches and bags chosen for how long they last, not how loudly they shout. Free shipping over $threshold.',
              ),
            ]),
            div(classes: 'row hero__actions', [
              const ButtonLink(href: '/products', label: 'Shop all products', size: ButtonSize.lg),
              const ButtonLink(
                href: '/categories/footwear',
                label: 'Shop footwear',
                variant: ButtonVariant.outline,
                size: ButtonSize.lg,
              ),
            ]),
          ]),
          div(classes: 'hero__media', [const HeroImage()]),
        ]),
      ]),
      section(
        classes: 'section',
        attributes: const {'aria-labelledby': 'cats-title'},
        [
          div(classes: 'container', [
            div(classes: 'section-head', [
              div([
                h2(id: 'cats-title', [t('Shop by category')]),
                p([t('Five small collections, each with a point of view.')]),
              ]),
            ]),
            ul(classes: 'cat-grid', [
              for (final c in categories)
                li([
                  a(href: '/categories/${c.slug}', classes: 'cat-tile', [
                    div(classes: 'media cat-tile__media', [
                      ResponsiveImage(image: c.image, sizes: '(min-width: 64rem) 18vw, (min-width: 40rem) 30vw, 46vw'),
                    ]),
                    span(classes: 'cat-tile__name', [t(c.name)]),
                    span(classes: 'cat-tile__count', [t('${categoryCounts[c.slug] ?? 0} products')]),
                  ]),
                ]),
            ]),
          ]),
        ],
      ),
      section(
        classes: 'section section--muted',
        attributes: const {'aria-labelledby': 'featured-title'},
        [
          div(classes: 'container', [
            div(classes: 'section-head', [
              div([
                h2(id: 'featured-title', [t('Featured')]),
                p([t('The things we reach for first.')]),
              ]),
              const ButtonLink(
                href: '/products',
                label: 'View all',
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
              ),
            ]),
            ul(classes: 'product-grid', [
              for (final p in featured) li([ProductCard(product: p, currency: config.currency)]),
            ]),
          ]),
        ],
      ),
      section(
        classes: 'section',
        attributes: const {'aria-labelledby': 'values-title'},
        [
          div(classes: 'container', [
            h2(id: 'values-title', classes: 'sr-only', [t('Why shop with us')]),
            ul(classes: 'values', [
              _value(
                Icons.truck(),
                'Free shipping over $threshold',
                'Standard delivery in 3-5 business days; express in 1-2.',
              ),
              _value(Icons.refresh(), '30-day returns', 'Changed your mind? Send it back unworn for a full refund.'),
              _value(Icons.leaf(), 'Made to last', 'Repairable leather, replaceable straps, spare parts for years.'),
              _value(Icons.shield(), 'Honest reviews', 'Every review is from a real, verified order.'),
            ]),
          ]),
        ],
      ),
      section(
        classes: 'section section--muted',
        id: 'newsletter',
        attributes: const {'aria-labelledby': 'news-title'},
        [
          div(classes: 'container newsletter', [
            div([
              h2(id: 'news-title', [t('Letters from the shop')]),
              p(classes: 'muted', [
                t('One short email a month: new arrivals, restocks and a repair tip. Unsubscribe any time.'),
              ]),
            ]),
            form(action: '/newsletter', method: FormMethod.post, classes: 'newsletter__form', [
              const TextField(
                name: 'email',
                label: 'Email address',
                type: 'email',
                autocomplete: 'email',
                required: true,
                placeholder: 'you@example.com',
                idPrefix: 'home-news',
              ),
              const SubmitButton(label: 'Subscribe', size: ButtonSize.md),
            ]),
          ]),
        ],
      ),
    ]);
  }

  Component _value(Component icon, String title, String body) => li(classes: 'value', [
    span(classes: 'value__icon', [icon]),
    h3([t(title)]),
    p(classes: 'muted text-sm', [t(body)]),
  ]);
}

@css
List<StyleRule> get homeStyles => [
  rule('.hero', {'padding-block': '${Tok.space(6)} ${Tok.space(2)}'}),
  rule('.hero__inner', {'display': 'grid', 'gap': Tok.space(8), 'align-items': 'center'}),
  rule('.hero__copy', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(5),
    'align-items': 'flex-start',
  }),
  rule('.hero__copy h1', {
    'font-size': 'clamp(2.25rem, 1.5rem + 3.4vw, 3.75rem)',
    'line-height': '1.05',
    'letter-spacing': '-0.035em',
  }),
  rule('.hero__lead', {
    'font-size': 'var(--text-lg)',
    'color': Tok.mutedForeground,
    'max-width': '34rem',
    'line-height': '1.6',
  }),
  rule('.hero__media', {
    'aspect-ratio': '4 / 3',
    'overflow': 'hidden',
    'border-radius': Tok.radiusXl,
    'background': Tok.muted,
    'border': '1px solid var(--border)',
    'box-shadow': Tok.shadowSm,
  }),
  atMin('64rem', [
    rule('.hero', {'padding-block': '${Tok.space(16)} ${Tok.space(20)}'}),
    rule('.hero__inner', {'grid-template-columns': '1fr 1fr', 'gap': Tok.space(16)}),
  ]),
  rule('.cat-grid', {'display': 'grid', 'grid-template-columns': 'repeat(2, minmax(0, 1fr))', 'gap': Tok.space(4)}),
  atMin('40rem', [
    rule('.cat-grid', {'grid-template-columns': 'repeat(3, minmax(0, 1fr))'}),
  ]),
  atMin('64rem', [
    rule('.cat-grid', {'grid-template-columns': 'repeat(5, minmax(0, 1fr))', 'gap': Tok.space(5)}),
  ]),
  rule('.cat-tile', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(1)}),
  rule('.cat-tile__media', {
    'aspect-ratio': '4 / 5',
    'border-radius': Tok.radiusXl,
    'border': '1px solid var(--border)',
    'margin-bottom': Tok.space(2),
  }),
  rule('.cat-tile__media img', {'transition': 'transform 400ms var(--ease)'}),
  rule('.cat-tile:hover .cat-tile__media img', {'transform': 'scale(1.05)'}),
  rule('.cat-tile__name', {'font-weight': '600', 'letter-spacing': '-0.01em'}),
  rule('.cat-tile__count', {'font-size': 'var(--text-sm)', 'color': Tok.mutedForeground}),
  rule('.product-grid', {
    'display': 'grid',
    'grid-template-columns': 'repeat(2, minmax(0, 1fr))',
    'gap': '${Tok.space(8)} ${Tok.space(4)}',
  }),
  atMin('40rem', [
    rule('.product-grid', {
      'grid-template-columns': 'repeat(3, minmax(0, 1fr))',
      'gap': '${Tok.space(10)} ${Tok.space(5)}',
    }),
  ]),
  atMin('64rem', [
    rule('.product-grid', {'grid-template-columns': 'repeat(4, minmax(0, 1fr))'}),
  ]),
  rule('.values', {'display': 'grid', 'grid-template-columns': '1fr', 'gap': Tok.space(8)}),
  atMin('40rem', [
    rule('.values', {'grid-template-columns': 'repeat(2, 1fr)'}),
  ]),
  atMin('64rem', [
    rule('.values', {'grid-template-columns': 'repeat(4, 1fr)'}),
  ]),
  rule('.value', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(2), 'align-items': 'flex-start'}),
  rule('.value__icon', {
    'display': 'inline-flex',
    'padding': Tok.space(2.5),
    'border-radius': Tok.radiusLg,
    'background': Tok.secondary,
    'margin-bottom': Tok.space(1),
  }),
  rule('.newsletter', {'display': 'grid', 'gap': Tok.space(6), 'align-items': 'center'}),
  rule('.newsletter__form', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(3), 'max-width': '28rem'}),
  atMin('48rem', [
    rule('.newsletter', {'grid-template-columns': '1fr 1fr', 'gap': Tok.space(12)}),
  ]),
];
