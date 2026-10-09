library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/constants.dart';
import '../../common/utils/money.dart';
import '../../common/utils/text.dart';
import '../../core/config/store_config.dart';
import '../../domain/catalog/models/product.dart';
import '../../domain/reviews/models/review.dart';
import '../components/buttons.dart';
import '../components/commerce.dart';
import '../components/feedback.dart';
import '../components/html.dart';
import '../components/icons.dart';
import '../components/media.dart';
import '../components/navigation.dart';
import '../islands/add_to_cart_button.dart';
import '../theme/tokens.dart';

/// Messages for `?error=` on the product page. A fixed map, never echoed
/// input, so the query string cannot inject text into the page.
const Map<String, String> kProductErrors = {
  'out_of_stock': 'Sorry, that option is sold out. Please choose another.',
  'unknown_variant': 'Please choose one of the available options.',
  'unknown_product': 'That product is no longer available.',
  'bad_quantity': 'Please enter a quantity of at least 1.',
  'cart_full': 'Your cart is full. Remove something before adding more.',
};

String formatDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

String isoDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class ProductPage extends StatelessComponent {
  const ProductPage({
    required this.config,
    required this.product,
    required this.category,
    required this.reviews,
    required this.related,
    required this.crumbs,
    this.errorCode,
    this.selectedVariantId,
    super.key,
  });

  final StoreConfig config;
  final Product product;
  final Category? category;
  final List<Review> reviews;
  final List<Product> related;
  final List<Crumb> crumbs;
  final String? errorCode;

  /// `?variant=` preselection (never part of the canonical URL).
  final String? selectedVariantId;

  @override
  Component build(BuildContext context) {
    final pct = discountPercent(price: product.priceCents, compareAt: product.compareAtCents);
    final selected =
        (selectedVariantId == null ? null : product.variantById(selectedVariantId!)) ?? product.defaultVariant;
    return Component.fragment([
      div(classes: 'container page-head page-head--tight', [Breadcrumb(crumbs)]),
      div(classes: 'container', [
        div(classes: 'pdp', [
          _gallery(),
          div(classes: 'pdp__info', [
            p(classes: 'eyebrow', [t(product.brand)]),
            h1(classes: 'pdp__title', [t(product.name)]),
            div(classes: 'row pdp__rating', [
              Rating(summary: product.rating, large: true),
              if (product.rating.hasReviews)
                a(href: '#reviews', classes: 'muted text-sm pdp__reviews-link', [
                  t('Read ${product.rating.count} ${pluralize(product.rating.count, 'review')}'),
                ]),
            ]),
            div(classes: 'row pdp__price', [
              Price(
                cents: product.priceCents,
                compareAtCents: product.compareAtCents,
                currency: config.currency,
                large: true,
              ),
              if (pct > 0) Badge('Save $pct%', variant: BadgeVariant.destructive),
              StockBadge(product),
            ]),
            p(classes: 'pdp__summary', [t(product.summary)]),
            if (errorCode != null && kProductErrors.containsKey(errorCode))
              Alert(
                variant: AlertVariant.destructive,
                live: true,
                title: 'We could not add that to your cart',
                children: [
                  p([t(kProductErrors[errorCode]!)]),
                ],
              ),
            _buyForm(selected),
            ul(classes: 'pdp__perks', [
              li([
                Icons.truck(size: 18),
                span([
                  t('Free shipping over ${formatMoney(config.shipping.freeThresholdCents, currency: config.currency)}'),
                ]),
              ]),
              li([
                Icons.refresh(size: 18),
                span([t('Free 30-day returns')]),
              ]),
              li([
                Icons.shield(size: 18),
                span([t('SKU ${product.sku}')]),
              ]),
            ]),
            Accordion(
              openFirst: true,
              items: [
                for (final d in product.details) (title: d.title, content: p([t(d.body)])),
              ],
            ),
          ]),
        ]),
      ]),
      section(
        classes: 'section pdp-about',
        attributes: const {'aria-labelledby': 'about-title'},
        [
          div(classes: 'container', [
            div(classes: 'prose', [
              h2(id: 'about-title', [t('About the ${product.name}')]),
              for (final para in product.description) p([t(para)]),
            ]),
          ]),
        ],
      ),
      section(
        classes: 'section section--muted',
        id: 'reviews',
        attributes: const {'aria-labelledby': 'reviews-title'},
        [
          div(classes: 'container', [_reviews()]),
        ],
      ),
      if (related.isNotEmpty)
        section(
          classes: 'section',
          attributes: const {'aria-labelledby': 'related-title'},
          [
            div(classes: 'container', [
              div(classes: 'section-head', [
                h2(id: 'related-title', [t('You may also like')]),
              ]),
              ul(classes: 'product-grid', [
                for (final r in related) li([ProductCard(product: r, currency: config.currency)]),
              ]),
            ]),
          ],
        ),
    ]);
  }

  Component _gallery() {
    final images = product.images;
    return div(classes: 'gallery', [
      div(
        classes: 'gallery__track',
        attributes: const {'tabindex': '0', 'role': 'group', 'aria-label': 'Product images'},
        [
          for (var i = 0; i < images.length; i++)
            figure(id: 'gallery-${i + 1}', classes: 'media gallery__slide', [
              ResponsiveImage(image: images[i], sizes: '(min-width: 64rem) 48vw, 100vw', priority: i == 0),
            ]),
        ],
      ),
      if (images.length > 1)
        nav(
          classes: 'gallery__thumbs',
          attributes: const {'aria-label': 'Choose an image'},
          [
            for (var i = 0; i < images.length; i++)
              a(
                href: '#gallery-${i + 1}',
                classes: 'media gallery__thumb',
                attributes: {'aria-label': 'Show image ${i + 1} of ${images.length}'},
                [
                  ResponsiveImage(image: images[i], sizes: '5rem', altOverride: ''),
                ],
              ),
          ],
        ),
    ]);
  }

  Component _buyForm(ProductVariant selected) {
    final multiple = product.variants.length > 1;
    return form(action: '/cart/add', method: FormMethod.post, id: 'add-to-cart', classes: 'buy', [
      el('input', attrs: {'type': 'hidden', 'name': 'productId', 'value': product.id}),
      el('input', attrs: {'type': 'hidden', 'name': 'redirect', 'value': 'cart'}),
      if (multiple)
        fieldset(classes: 'variants', [
          legend(classes: 'label', [
            t('${product.variantLabel}: '),
            span(classes: 'muted', [t('choose one')]),
          ]),
          div(classes: 'variants__list', [
            for (final v in product.variants)
              el(
                'label',
                classes: cx(['variant', if (!v.inStock) 'is-soldout']),
                children: [
                  el(
                    'input',
                    classes: 'variant__input',
                    attrs: {
                      'type': 'radio',
                      'name': 'variantId',
                      'value': v.id,
                      'required': '',
                      if (v.id == selected.id) 'checked': '',
                      if (!v.inStock) 'disabled': '',
                    },
                  ),
                  span(classes: 'variant__label', [
                    t(v.label),
                    if (!v.inStock) span(classes: 'sr-only', [t(' (sold out)')]),
                  ]),
                ],
              ),
          ]),
        ])
      else ...[
        el('input', attrs: {'type': 'hidden', 'name': 'variantId', 'value': selected.id}),
        p(classes: 'text-sm', [
          span(classes: 'label', [t('${product.variantLabel}: ')]),
          t(selected.label),
        ]),
      ],
      div(classes: 'buy__row', [
        div(classes: 'field buy__qty', [
          el('label', classes: 'label', attrs: {'for': 'qty'}, children: [t('Quantity')]),
          el(
            'input',
            id: 'qty',
            classes: 'input',
            attrs: {
              'type': 'number',
              'name': 'quantity',
              'value': '1',
              'min': '1',
              'max': '$kMaxLineQuantity',
              'inputmode': 'numeric',
              'required': '',
            },
          ),
        ]),
        div(classes: 'buy__submit', [
          if (product.inStock)
            const AddToCartButton()
          else
            const SubmitButton(label: 'Sold out', size: ButtonSize.lg, block: true, disabled: true),
        ]),
      ]),
    ]);
  }

  Component _reviews() {
    final summary = product.rating;
    return div(classes: 'reviews', [
      div(classes: 'reviews__summary', [
        h2(id: 'reviews-title', [t('Customer reviews')]),
        if (summary.hasReviews) ...[
          p(classes: 'reviews__avg', [
            span(classes: 'reviews__score', [t(summary.average.toStringAsFixed(1))]),
            t(' out of 5'),
          ]),
          Rating(summary: summary, showCount: false, large: true),
          p(classes: 'muted text-sm', [t('Based on ${summary.count} ${pluralize(summary.count, 'review')}')]),
          ul(classes: 'dist', [
            for (var star = 5; star >= 1; star--)
              li([
                span(classes: 'dist__label', [t('$star star')]),
                span(
                  classes: 'dist__bar',
                  attributes: const {'aria-hidden': 'true'},
                  [
                    span(
                      classes: 'dist__fill',
                      attributes: {
                        'style':
                            'width:${summary.count == 0 ? 0 : ((summary.distribution[star] ?? 0) * 100 / summary.count).round()}%',
                      },
                      const [],
                    ),
                  ],
                ),
                span(classes: 'dist__count', [t('${summary.distribution[star] ?? 0}')]),
              ]),
          ]),
        ] else
          p(classes: 'muted', [t('No reviews yet.')]),
      ]),
      div(classes: 'reviews__list', [
        for (final r in reviews)
          article(classes: 'review', [
            div(classes: 'row review__head', [
              Rating(summary: RatingSummary(average: r.rating.toDouble(), count: 1), showCount: false),
              if (r.verified) const Badge('Verified purchase', variant: BadgeVariant.outline),
            ]),
            h3(classes: 'review__title', [t(r.title)]),
            p([t(r.body)]),
            p(classes: 'muted text-sm', [
              t('${r.author} · '),
              el('time', attrs: {'datetime': isoDate(r.date)}, children: [t(formatDate(r.date))]),
            ]),
          ]),
      ]),
    ]);
  }
}

@css
List<StyleRule> get productPageStyles => [
  rule('.page-head--tight', {'padding-block': '${Tok.space(6)} ${Tok.space(4)}'}),
  rule('.pdp', {'display': 'grid', 'gap': Tok.space(8), 'grid-template-columns': 'minmax(0, 1fr)'}),
  atMin('64rem', [
    rule('.pdp', {
      'grid-template-columns': 'minmax(0, 1.1fr) minmax(0, 1fr)',
      'gap': Tok.space(12),
      'align-items': 'start',
    }),
  ]),
  rule('.gallery', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(3), 'min-width': '0'}),
  atMin('64rem', [
    rule('.gallery', {'position': 'sticky', 'top': '5.5rem'}),
  ]),
  rule('.gallery__track', {
    'display': 'flex',
    'overflow-x': 'auto',
    'scroll-snap-type': 'x mandatory',
    'gap': Tok.space(3),
    'border-radius': Tok.radiusXl,
    'scrollbar-width': 'none',
  }),
  rule('.gallery__track::-webkit-scrollbar', {'display': 'none'}),
  rule('.gallery__slide', {
    'flex': '0 0 100%',
    'scroll-snap-align': 'center',
    'margin': '0',
    'border': '1px solid var(--border)',
    'border-radius': Tok.radiusXl,
  }),
  rule('.gallery__thumbs', {'display': 'flex', 'gap': Tok.space(2)}),
  rule('.gallery__thumb', {
    'width': '4.5rem',
    'height': '4.5rem',
    'border': '1px solid var(--border)',
    'border-radius': Tok.radiusLg,
    'opacity': '0.8',
  }),
  rule('.gallery__thumb:hover, .gallery__thumb:focus-visible', {'opacity': '1', 'border-color': Tok.ring}),
  rule('.pdp__info', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(4), 'min-width': '0'}),
  rule('.pdp__title', {'font-size': 'clamp(1.75rem, 1.3rem + 1.6vw, 2.25rem)'}),
  rule('.pdp__summary', {'color': Tok.mutedForeground, 'line-height': '1.65'}),
  rule('.pdp__reviews-link:hover', {'text-decoration': 'underline'}),
  rule('.pdp__price', {'gap': Tok.space(3)}),
  rule('.buy', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(4),
    'padding': '${Tok.space(5)} 0',
    'border-block': '1px solid var(--border)',
  }),
  rule('.variants', {'border': '0', 'padding': '0', 'margin': '0', 'min-width': '0'}),
  rule('.variants .label', {'margin-bottom': Tok.space(2.5), 'padding': '0'}),
  rule('.variants__list', {'display': 'flex', 'flex-wrap': 'wrap', 'gap': Tok.space(2)}),
  rule('.variant', {'position': 'relative'}),
  rule('.variant__input', {
    'position': 'absolute',
    'opacity': '0',
    'inset': '0',
    'width': '100%',
    'height': '100%',
    'margin': '0',
    'cursor': 'pointer',
  }),
  rule('.variant__label', {
    'display': 'inline-flex',
    'align-items': 'center',
    'justify-content': 'center',
    'min-width': '3rem',
    'height': '2.5rem',
    'padding': '0 ${Tok.space(4)}',
    'border': '1px solid var(--input)',
    'border-radius': Tok.radiusMd,
    'font-size': 'var(--text-sm)',
    'font-weight': '500',
    'background': Tok.background,
    'box-shadow': Tok.shadowXs,
    'transition': 'background-color 150ms var(--ease), border-color 150ms var(--ease)',
  }),
  rule('.variant:hover .variant__label', {'background': Tok.accent}),
  rule('.variant__input:checked + .variant__label', {
    'background': Tok.primary,
    'color': Tok.primaryForeground,
    'border-color': Tok.primary,
  }),
  rule('.variant__input:focus-visible + .variant__label', {
    'box-shadow': '0 0 0 3px color-mix(in oklab, var(--ring) 50%, transparent)',
  }),
  rule('.variant.is-soldout .variant__label', {
    'color': Tok.mutedForeground,
    'text-decoration': 'line-through',
    'background': Tok.muted,
    'box-shadow': 'none',
  }),
  rule('.variant.is-soldout .variant__input', {'cursor': 'not-allowed'}),
  rule('.buy__row', {
    'display': 'grid',
    'grid-template-columns': '6rem minmax(0, 1fr)',
    'gap': Tok.space(3),
    'align-items': 'start',
  }),
  rule('.buy__submit', {'padding-top': '1.375rem', 'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(2)}),
  rule('.buy__submit .btn', {'height': '2.25rem'}),
  rule('.add-status', {'font-size': 'var(--text-sm)', 'min-height': '1.25rem', 'color': Tok.success}),
  rule('.add-status a', {'text-decoration': 'underline'}),
  rule('.add-status--error', {'color': Tok.destructive}),
  rule('.pdp__perks', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(2),
    'font-size': 'var(--text-sm)',
    'color': Tok.mutedForeground,
  }),
  rule('.pdp__perks li', {'display': 'flex', 'gap': Tok.space(2.5), 'align-items': 'center'}),
  rule('.pdp-about', {'padding-block': '${Tok.space(12)} ${Tok.space(4)}'}),
  rule('.reviews', {'display': 'grid', 'gap': Tok.space(10)}),
  atMin('64rem', [
    rule('.reviews', {'grid-template-columns': '18rem minmax(0, 1fr)', 'gap': Tok.space(16)}),
  ]),
  rule('.reviews__summary', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(2.5),
    'align-items': 'flex-start',
  }),
  rule('.reviews__score', {'font-size': 'var(--text-4xl)', 'font-weight': '600', 'letter-spacing': '-0.03em'}),
  rule('.dist', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(1.5),
    'width': '100%',
    'margin-top': Tok.space(2),
    'font-size': 'var(--text-xs)',
  }),
  rule('.dist li', {
    'display': 'grid',
    'grid-template-columns': '3.5rem 1fr 1.5rem',
    'gap': Tok.space(2),
    'align-items': 'center',
  }),
  rule('.dist__bar', {
    'height': '0.5rem',
    'border-radius': '9999px',
    'background': Tok.secondary,
    'overflow': 'hidden',
    'display': 'block',
  }),
  rule('.dist__fill', {'display': 'block', 'height': '100%', 'background': Tok.star}),
  rule('.dist__count', {'text-align': 'right', 'color': Tok.mutedForeground}),
  rule('.reviews__list', {'display': 'flex', 'flex-direction': 'column'}),
  rule('.review', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(2),
    'padding-block': Tok.space(6),
    'border-bottom': '1px solid var(--border)',
  }),
  rule('.review:first-child', {'padding-top': '0'}),
  rule('.review__title', {'font-size': 'var(--text-base)'}),
];
