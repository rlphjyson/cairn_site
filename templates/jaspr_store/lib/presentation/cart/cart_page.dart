library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/constants.dart';
import '../../common/utils/money.dart';
import '../../common/utils/text.dart';
import '../../core/config/store_config.dart';
import '../../domain/cart/models/cart.dart';
import '../components/buttons.dart';
import '../components/feedback.dart';
import '../components/forms.dart';
import '../components/html.dart';
import '../components/icons.dart';
import '../components/media.dart';
import '../components/commerce.dart';
import '../theme/tokens.dart';

/// Fixed notice copy for `?notice=`; query strings never inject text.
const Map<String, String> kCartNotices = {
  'added': 'Added to your cart.',
  'adjusted': 'We adjusted the quantity to what we have in stock.',
  'updated': 'Cart updated.',
  'removed': 'Item removed.',
  'promo_removed': 'Promo code removed.',
  'promo_applied': 'Promo code applied.',
};

class CartPage extends StatelessComponent {
  const CartPage({
    required this.config,
    required this.cart,
    this.notice,
    this.promoError,
    this.promoValue = '',
    super.key,
  });

  final StoreConfig config;
  final PricedCart cart;
  final String? notice;
  final String? promoError;
  final String promoValue;

  String _m(int cents) => formatMoney(cents, currency: config.currency);

  @override
  Component build(BuildContext context) {
    return div(classes: 'container cart-page', [
      div(classes: 'page-head', [
        h1([t('Your cart')]),
        if (!cart.isEmpty) p([t('${cart.itemCount} ${pluralize(cart.itemCount, 'item')}')]),
      ]),
      if (notice != null && kCartNotices.containsKey(notice))
        Alert(
          variant: notice == 'adjusted' ? AlertVariant.info : AlertVariant.success,
          live: true,
          children: [
            p([t(kCartNotices[notice]!)]),
          ],
        ),
      if (cart.isEmpty) _empty() else _body(),
    ]);
  }

  Component _empty() => div(classes: 'empty', [
    span(classes: 'empty__icon', [Icons.cart(size: 28)]),
    h2([t('Your cart is empty')]),
    p(classes: 'muted', [t('Add something you like and it will wait for you here.')]),
    const ButtonLink(href: '/products', label: 'Continue shopping'),
  ]);

  Component _body() {
    return div(classes: 'cart-layout', [
      div(classes: 'cart-main', [
        _shippingProgress(),
        ul(classes: 'cart-lines', [
          for (final l in cart.lines) li(classes: 'cart-line', [_line(l)]),
        ]),
        div(classes: 'cart-continue', [
          const ButtonLink(href: '/products', label: 'Continue shopping', variant: ButtonVariant.link),
        ]),
      ]),
      aside(
        classes: 'cart-summary',
        attributes: const {'aria-labelledby': 'summary-title'},
        [
          h2(id: 'summary-title', classes: 'summary-title', [t('Order summary')]),
          _promo(),
          dl(classes: 'totals', [
            _row('Subtotal', _m(cart.subtotalCents)),
            if (cart.discountCents > 0)
              _row('Discount (${cart.promoCode})', '-${_m(cart.discountCents)}', accent: true),
            _row('Shipping', cart.shippingCents == 0 ? 'Free' : _m(cart.shippingCents)),
            _row('Total', _m(cart.totalCents), total: true),
          ]),
          p(classes: 'muted text-sm', [t('Prices include tax. Standard shipping shown; choose express at checkout.')]),
          const ButtonLink(href: '/checkout', label: 'Go to checkout', size: ButtonSize.lg, block: true),
          p(classes: 'muted text-sm summary-demo', [
            t('This is a demo store. No payment is taken and no order is shipped.'),
          ]),
        ],
      ),
    ]);
  }

  Component _shippingProgress() {
    final remaining = cart.freeShippingRemainingCents;
    return div(classes: 'ship-progress', [
      p(
        classes: 'text-sm',
        attributes: const {'id': 'ship-text'},
        [
          cart.qualifiesForFreeShipping
              ? span(classes: 'ship-progress__ok', [Icons.check(), t(' You have free standard shipping.')])
              : t('You are ${_m(remaining)} away from free standard shipping.'),
        ],
      ),
      el(
        'progress',
        classes: 'ship-progress__bar',
        attrs: {'max': '100', 'value': '${(cart.freeShippingProgress * 100).round()}', 'aria-labelledby': 'ship-text'},
        children: [t('${(cart.freeShippingProgress * 100).round()}%')],
      ),
    ]);
  }

  Component _line(PricedLine l) {
    final href = '/products/${l.product.slug}';
    return div(classes: 'line', [
      a(
        href: href,
        classes: 'media line__media',
        attributes: {'aria-label': l.product.name},
        [ResponsiveImage(image: l.product.primaryImage, sizes: '6rem', altOverride: '')],
      ),
      div(classes: 'line__info', [
        h3(classes: 'line__name', [
          a(href: href, [t(l.product.name)]),
        ]),
        p(classes: 'muted text-sm', [t('${l.product.variantLabel}: ${l.variant.label}')]),
        Price(cents: l.unitCents, compareAtCents: l.product.compareAtCents, currency: config.currency),
        if (l.overStock)
          p(classes: 'field__error', [t('Only ${l.variant.stock} left in stock. We will reduce the quantity.')]),
      ]),
      div(classes: 'line__actions', [
        form(action: '/cart/update', method: FormMethod.post, classes: 'qty-form', [
          el('input', attrs: {'type': 'hidden', 'name': 'variantId', 'value': l.variant.id}),
          el(
            'label',
            classes: 'sr-only',
            attrs: {'for': 'qty-${l.variant.id}'},
            children: [t('Quantity for ${l.product.name}, ${l.variant.label}')],
          ),
          el(
            'input',
            id: 'qty-${l.variant.id}',
            classes: 'input qty-input',
            attrs: {
              'type': 'number',
              'name': 'quantity',
              'value': '${l.quantity}',
              'min': '0',
              'max': '$kMaxLineQuantity',
              'inputmode': 'numeric',
            },
          ),
          SubmitButton(
            label: 'Update',
            variant: ButtonVariant.outline,
            size: ButtonSize.sm,
            ariaLabel: 'Update quantity for ${l.product.name}',
          ),
        ]),
        form(action: '/cart/remove', method: FormMethod.post, [
          el('input', attrs: {'type': 'hidden', 'name': 'variantId', 'value': l.variant.id}),
          SubmitButton(
            label: 'Remove',
            variant: ButtonVariant.ghost,
            size: ButtonSize.sm,
            icon: Icons.trash(),
            ariaLabel: 'Remove ${l.product.name}, ${l.variant.label} from cart',
          ),
        ]),
      ]),
      p(classes: 'line__total', [
        span(classes: 'sr-only', [t('Line total ')]),
        t(_m(l.totalCents)),
      ]),
    ]);
  }

  Component _promo() {
    if (cart.promoCode != null) {
      return div(classes: 'promo promo--applied', [
        span(classes: 'row', [
          Badge(cart.promoCode!, variant: BadgeVariant.success),
          span(classes: 'text-sm muted', [t(cart.promoLabel ?? '')]),
        ]),
        form(action: '/cart/promo', method: FormMethod.post, [
          el('input', attrs: {'type': 'hidden', 'name': 'action', 'value': 'remove'}),
          const SubmitButton(label: 'Remove', variant: ButtonVariant.link, size: ButtonSize.sm),
        ]),
      ]);
    }
    return form(action: '/cart/promo', method: FormMethod.post, classes: 'promo', [
      el('input', attrs: {'type': 'hidden', 'name': 'action', 'value': 'apply'}),
      div(classes: 'promo__row', [
        TextField(
          name: 'code',
          label: 'Promo code',
          value: promoValue,
          error: promoError,
          autocomplete: 'off',
          idPrefix: 'cart',
          hint: promoError == null ? 'Try CAIRN10 for 10% off.' : null,
        ),
        div(classes: 'promo__btn', [const SubmitButton(label: 'Apply', variant: ButtonVariant.secondary)]),
      ]),
    ]);
  }

  Component _row(String label, String value, {bool total = false, bool accent = false}) =>
      div(classes: cx(['totals__row', if (total) 'totals__row--total', if (accent) 'totals__row--accent']), [
        dt([t(label)]),
        dd([t(value)]),
      ]);
}

@css
List<StyleRule> get cartStyles => [
  rule('.cart-layout', {
    'display': 'grid',
    'gap': Tok.space(8),
    'grid-template-columns': 'minmax(0, 1fr)',
    'align-items': 'start',
    'margin-top': Tok.space(6),
  }),
  atMin('64rem', [
    rule('.cart-layout', {'grid-template-columns': 'minmax(0, 1fr) 24rem', 'gap': Tok.space(12)}),
  ]),
  rule('.cart-main', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(5)}),
  rule('.ship-progress', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(2),
    'padding': Tok.space(4),
    'border': '1px solid var(--border)',
    'border-radius': Tok.radiusXl,
    'background': Tok.card,
  }),
  rule('.ship-progress__ok', {
    'display': 'inline-flex',
    'align-items': 'center',
    'gap': Tok.space(1.5),
    'color': Tok.success,
    'font-weight': '500',
  }),
  rule('.ship-progress__bar', {
    'width': '100%',
    'height': '0.5rem',
    'appearance': 'none',
    '-webkit-appearance': 'none',
    'border': '0',
    'border-radius': '9999px',
    'background': Tok.secondary,
    'overflow': 'hidden',
  }),
  rule('.ship-progress__bar::-webkit-progress-bar', {'background': Tok.secondary}),
  rule('.ship-progress__bar::-webkit-progress-value', {'background': Tok.primary, 'border-radius': '9999px'}),
  rule('.ship-progress__bar::-moz-progress-bar', {'background': Tok.primary, 'border-radius': '9999px'}),
  rule('.cart-lines', {'display': 'flex', 'flex-direction': 'column'}),
  rule('.cart-line', {'padding-block': Tok.space(5), 'border-bottom': '1px solid var(--border)'}),
  rule('.cart-line:first-child', {'border-top': '1px solid var(--border)'}),
  rule('.line', {
    'display': 'grid',
    'grid-template-columns': '5rem minmax(0, 1fr) auto',
    'grid-template-areas': '"media info total" "media actions actions"',
    'gap': '${Tok.space(2)} ${Tok.space(4)}',
    'align-items': 'start',
  }),
  atMin('40rem', [
    rule('.line', {
      'grid-template-columns': '6rem minmax(0, 1fr) auto auto',
      'grid-template-areas': '"media info actions total"',
      'align-items': 'center',
    }),
  ]),
  rule('.line__media', {'grid-area': 'media', 'border-radius': Tok.radiusLg, 'border': '1px solid var(--border)'}),
  rule('.line__info', {
    'grid-area': 'info',
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(1),
    'align-items': 'flex-start',
    'min-width': '0',
  }),
  rule('.line__name', {'font-size': 'var(--text-base)', 'font-weight': '500'}),
  rule('.line__name a:hover', {'text-decoration': 'underline'}),
  rule('.line__actions', {
    'grid-area': 'actions',
    'display': 'flex',
    'flex-wrap': 'wrap',
    'gap': Tok.space(3),
    'align-items': 'center',
  }),
  rule('.line__total', {
    'grid-area': 'total',
    'font-weight': '600',
    'font-variant-numeric': 'tabular-nums',
    'text-align': 'right',
    'min-width': '4.5rem',
  }),
  rule('.qty-form', {'display': 'flex', 'gap': Tok.space(2), 'align-items': 'center'}),
  rule('.qty-input', {'width': '4.25rem', 'text-align': 'center'}),
  rule('.cart-summary', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(4),
    'padding': Tok.space(6),
    'border': '1px solid var(--border)',
    'border-radius': Tok.radiusXl,
    'background': Tok.card,
    'box-shadow': Tok.shadowSm,
  }),
  atMin('64rem', [
    rule('.cart-summary', {'position': 'sticky', 'top': '5.5rem'}),
  ]),
  rule('.summary-title', {'font-size': 'var(--text-lg)'}),
  rule('.promo__row', {
    'display': 'grid',
    'grid-template-columns': 'minmax(0, 1fr) auto',
    'gap': Tok.space(2),
    'align-items': 'start',
  }),
  rule('.promo__btn', {'padding-top': '1.4rem'}),
  rule('.promo--applied', {
    'display': 'flex',
    'justify-content': 'space-between',
    'align-items': 'center',
    'gap': Tok.space(3),
    'padding': Tok.space(3),
    'border': '1px dashed var(--border)',
    'border-radius': Tok.radiusLg,
  }),
  rule('.totals', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(2.5), 'margin': '0'}),
  rule('.totals__row', {
    'display': 'flex',
    'justify-content': 'space-between',
    'gap': Tok.space(4),
    'font-size': 'var(--text-sm)',
  }),
  rule('.totals__row dt', {'color': Tok.mutedForeground}),
  rule('.totals__row dd', {'margin': '0', 'font-variant-numeric': 'tabular-nums'}),
  rule('.totals__row--accent dd', {'color': Tok.success}),
  rule('.totals__row--total', {
    'padding-top': Tok.space(3),
    'border-top': '1px solid var(--border)',
    'font-size': 'var(--text-lg)',
    'font-weight': '600',
  }),
  rule('.totals__row--total dt', {'color': Tok.foreground}),
  rule('.summary-demo', {'text-align': 'center'}),
  rule('.empty__icon', {
    'display': 'inline-flex',
    'padding': Tok.space(4),
    'border-radius': '9999px',
    'background': Tok.secondary,
  }),
];
