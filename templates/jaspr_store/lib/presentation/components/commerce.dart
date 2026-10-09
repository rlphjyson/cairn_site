/// Commerce primitives: Rating, Price, StockBadge, ProductCard.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/utils/money.dart';
import '../../common/utils/text.dart';
import '../../domain/catalog/models/product.dart';
import '../../domain/reviews/models/review.dart';
import '../theme/tokens.dart';
import 'feedback.dart';
import 'html.dart';
import 'media.dart';

/// Star rating. The five glyphs are decorative (`aria-hidden`); the accessible
/// name is a single sentence on the wrapper, so a screen reader hears
/// "Rated 4.5 out of 5 from 4 reviews" once instead of five stars.
class Rating extends StatelessComponent {
  const Rating({required this.summary, this.showCount = true, this.large = false, super.key});
  final RatingSummary summary;
  final bool showCount;
  final bool large;

  @override
  Component build(BuildContext context) {
    if (!summary.hasReviews) {
      return span(classes: 'rating rating--none', [Component.text('No reviews yet')]);
    }
    final pct = (summary.average / 5 * 100).clamp(0, 100).toStringAsFixed(0);
    return span(
      classes: cx(['rating', if (large) 'rating--lg']),
      attributes: {
        'role': 'img',
        'aria-label': 'Rated ${summary.average} out of 5 from ${summary.count} ${pluralize(summary.count, 'review')}',
      },
      [
        span(
          classes: 'rating__stars',
          attributes: {'aria-hidden': 'true', 'style': '--pct:$pct%'},
          [Component.text('★★★★★')],
        ),
        if (showCount)
          span(
            classes: 'rating__count',
            attributes: const {'aria-hidden': 'true'},
            [Component.text('${summary.average.toStringAsFixed(1)} (${summary.count})')],
          ),
      ],
    );
  }
}

class Price extends StatelessComponent {
  const Price({required this.cents, this.compareAtCents, this.currency = 'USD', this.large = false, super.key});
  final int cents;
  final int? compareAtCents;
  final String currency;
  final bool large;

  @override
  Component build(BuildContext context) {
    final onSale = compareAtCents != null && compareAtCents! > cents;
    return span(classes: cx(['price', if (large) 'price--lg']), [
      span(classes: 'price__now', [
        if (onSale) span(classes: 'sr-only', [Component.text('Sale price ')]),
        Component.text(formatMoney(cents, currency: currency)),
      ]),
      if (onSale)
        span(classes: 'price__was', [
          span(classes: 'sr-only', [Component.text('Regular price ')]),
          el('del', children: [Component.text(formatMoney(compareAtCents!, currency: currency))]),
        ]),
    ]);
  }
}

class StockBadge extends StatelessComponent {
  const StockBadge(this.product, {super.key});
  final Product product;

  @override
  Component build(BuildContext context) {
    return switch (product.availability) {
      Availability.inStock => const Badge('In stock', variant: BadgeVariant.success),
      Availability.lowStock => Badge('Only ${product.totalStock} left', variant: BadgeVariant.outline),
      Availability.outOfStock => const Badge('Sold out', variant: BadgeVariant.secondary),
    };
  }
}

class ProductCard extends StatelessComponent {
  const ProductCard({
    required this.product,
    this.currency = 'USD',
    this.priority = false,
    this.sizes = '(min-width: 64rem) 22vw, (min-width: 40rem) 30vw, 46vw',
    super.key,
  });
  final Product product;
  final String currency;
  final bool priority;
  final String sizes;

  @override
  Component build(BuildContext context) {
    final href = '/products/${product.slug}';
    final pct = discountPercent(price: product.priceCents, compareAt: product.compareAtCents);
    return article(classes: 'card-product', [
      div(classes: 'media card-product__media', [
        ResponsiveImage(image: product.primaryImage, sizes: sizes, priority: priority),
        div(classes: 'card-product__badges', [
          if (!product.inStock)
            const Badge('Sold out', variant: BadgeVariant.secondary)
          else if (pct > 0)
            Badge('-$pct%', variant: BadgeVariant.destructive),
          if (product.inStock && product.availability == Availability.lowStock)
            const Badge('Low stock', variant: BadgeVariant.outline),
        ]),
      ]),
      div(classes: 'card-product__body', [
        p(classes: 'card-product__brand', [Component.text(product.brand)]),
        h3(classes: 'card-product__name', [
          a(href: href, classes: 'card-product__link', [Component.text(product.name)]),
        ]),
        Rating(summary: product.rating),
        Price(cents: product.priceCents, compareAtCents: product.compareAtCents, currency: currency),
      ]),
    ]);
  }
}

@css
List<StyleRule> get commerceStyles => [
  rule('.rating', {
    'display': 'inline-flex',
    'align-items': 'center',
    'gap': Tok.space(1.5),
    'font-size': 'var(--text-sm)',
    'line-height': '1',
  }),
  rule('.rating--none', {'color': Tok.mutedForeground, 'font-size': 'var(--text-xs)'}),
  rule('.rating__stars', {
    'letter-spacing': '1px',
    'font-size': '0.9375rem',
    'background':
        'linear-gradient(90deg, var(--star) var(--pct), color-mix(in oklab, var(--foreground) 18%, transparent) var(--pct))',
    '-webkit-background-clip': 'text',
    'background-clip': 'text',
    '-webkit-text-fill-color': 'transparent',
    'color': 'transparent',
  }),
  rule('.rating--lg .rating__stars', {'font-size': '1.125rem'}),
  rule('.rating__count', {'color': Tok.mutedForeground, 'font-size': 'var(--text-xs)'}),
  rule('.rating--lg .rating__count', {'font-size': 'var(--text-sm)'}),
  rule('.price', {
    'display': 'inline-flex',
    'align-items': 'baseline',
    'gap': Tok.space(2),
    'font-variant-numeric': 'tabular-nums',
  }),
  rule('.price__now', {'font-weight': '600'}),
  rule('.price__was', {'color': Tok.mutedForeground, 'font-size': 'var(--text-sm)'}),
  rule('.price--lg .price__now', {'font-size': 'var(--text-2xl)', 'letter-spacing': '-0.02em'}),
  rule('.price--lg .price__was', {'font-size': 'var(--text-base)'}),
  rule('.card-product', {
    'position': 'relative',
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(3),
    'min-width': '0',
  }),
  rule('.card-product__media', {'border-radius': Tok.radiusXl, 'border': '1px solid var(--border)'}),
  rule('.card-product__media img', {'transition': 'transform 400ms var(--ease)'}),
  rule('.card-product:hover .card-product__media img', {'transform': 'scale(1.04)'}),
  rule('.card-product__badges', {
    'position': 'absolute',
    'top': Tok.space(2.5),
    'left': Tok.space(2.5),
    'display': 'flex',
    'flex-wrap': 'wrap',
    'gap': Tok.space(1.5),
  }),
  rule('.card-product__body', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(1.5),
    'align-items': 'flex-start',
  }),
  rule('.card-product__brand', {
    'font-size': 'var(--text-xs)',
    'color': Tok.mutedForeground,
    'text-transform': 'uppercase',
    'letter-spacing': '0.06em',
  }),
  rule('.card-product__name', {
    'font-size': 'var(--text-base)',
    'font-weight': '500',
    'letter-spacing': '-0.01em',
    'line-height': '1.3',
  }),
  // The whole card is one tap target: the name link stretches over it.
  rule('.card-product__link::after', {'content': '""', 'position': 'absolute', 'inset': '0'}),
  rule('.card-product__link:focus-visible', {'box-shadow': 'none', 'outline': 'none'}),
  rule('.card-product:has(.card-product__link:focus-visible) .card-product__media', {
    'box-shadow': '0 0 0 3px color-mix(in oklab, var(--ring) 50%, transparent)',
  }),
];
