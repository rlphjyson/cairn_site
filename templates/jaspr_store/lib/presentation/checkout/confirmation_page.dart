library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/utils/money.dart';
import '../../core/config/store_config.dart';
import '../../domain/checkout/models/checkout.dart';
import '../components/buttons.dart';
import '../components/feedback.dart';
import '../components/html.dart';
import '../components/icons.dart';
import '../components/media.dart';
import '../../domain/catalog/models/product.dart';
import '../theme/tokens.dart';

class ConfirmationPage extends StatelessComponent {
  const ConfirmationPage({required this.config, required this.order, required this.imageByProductId, super.key});

  final StoreConfig config;
  final Order order;

  /// productId -> primary image, so the confirmation can show thumbnails.
  final Map<String, ProductImage> imageByProductId;

  String _m(int c) => formatMoney(c, currency: config.currency);

  @override
  Component build(BuildContext context) {
    final country = countryByCode(order.address.country);
    return div(classes: 'container confirmation', [
      div(classes: 'confirmation__head', [
        span(classes: 'confirmation__icon', [Icons.check(size: 28)]),
        p(classes: 'eyebrow', [t('Demo order placed')]),
        h1([t('Thank you, ${order.address.fullName.split(' ').first}')]),
        p(classes: 'muted', [
          t(
            'Order ${order.number} was recorded. We have not emailed anyone, taken payment or shipped anything: this is a demo.',
          ),
        ]),
      ]),
      Alert(
        title: 'This was a demo checkout',
        children: [
          p([
            t(
              'To take real payments, connect a payment provider as described in the documentation (Stripe Checkout and a webhook are the recommended path).',
            ),
          ]),
        ],
      ),
      div(classes: 'confirmation__grid', [
        section(
          classes: 'panel',
          attributes: const {'aria-labelledby': 'items-title'},
          [
            h2(id: 'items-title', classes: 'panel__title', [t('Items')]),
            ul(classes: 'mini-lines', [
              for (final l in order.lines)
                li(classes: 'mini-line', [
                  div(classes: 'media mini-line__media', [
                    if (imageByProductId[l.productId] case final img?)
                      ResponsiveImage(image: img, sizes: '4rem', altOverride: ''),
                  ]),
                  div(classes: 'mini-line__info', [
                    p(classes: 'mini-line__name', [t(l.name)]),
                    p(classes: 'muted text-sm', [t('${l.variantLabel} · Qty ${l.quantity}')]),
                  ]),
                  p(classes: 'mini-line__price', [t(_m(l.totalCents))]),
                ]),
            ]),
            dl(classes: 'totals', [
              _row('Subtotal', _m(order.subtotalCents)),
              if (order.discountCents > 0)
                _row('Discount (${order.promoCode})', '-${_m(order.discountCents)}', accent: true),
              _row(
                'Shipping (${order.delivery.label.toLowerCase()})',
                order.shippingCents == 0 ? 'Free' : _m(order.shippingCents),
              ),
              _row('Total', _m(order.totalCents), total: true),
            ]),
          ],
        ),
        section(
          classes: 'panel',
          attributes: const {'aria-labelledby': 'ship-title'},
          [
            h2(id: 'ship-title', classes: 'panel__title', [t('Delivery')]),
            el(
              'address',
              classes: 'address',
              children: [
                p([t(order.address.fullName)]),
                p([t(order.address.address1)]),
                if (order.address.address2.isNotEmpty) p([t(order.address.address2)]),
                p([t('${order.address.city}, ${order.address.region} ${order.address.postalCode}')]),
                p([t(country?.name ?? order.address.country)]),
              ],
            ),
            p(classes: 'text-sm', [
              span(classes: 'label', [t('Method: ')]),
              t('${order.delivery.label}, ${order.delivery.eta}'),
            ]),
            p(classes: 'text-sm', [
              span(classes: 'label', [t('Confirmation to: ')]),
              t(order.email),
            ]),
          ],
        ),
      ]),
      div(classes: 'row confirmation__actions', [
        const ButtonLink(href: '/products', label: 'Continue shopping'),
        const ButtonLink(href: '/', label: 'Back to home', variant: ButtonVariant.outline),
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
List<StyleRule> get confirmationStyles => [
  rule('.confirmation', {
    'padding-block': '${Tok.space(10)} ${Tok.space(4)}',
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(6),
  }),
  rule('.confirmation__head', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(3),
    'align-items': 'flex-start',
  }),
  rule('.confirmation__icon', {
    'display': 'inline-flex',
    'padding': Tok.space(3),
    'border-radius': '9999px',
    'background': 'color-mix(in oklab, var(--success) 15%, transparent)',
    'color': Tok.success,
  }),
  rule('.confirmation__grid', {
    'display': 'grid',
    'gap': Tok.space(5),
    'grid-template-columns': 'minmax(0, 1fr)',
    'align-items': 'start',
  }),
  atMin('48rem', [
    rule('.confirmation__grid', {'grid-template-columns': 'minmax(0, 3fr) minmax(0, 2fr)'}),
  ]),
  rule('.address', {
    'font-style': 'normal',
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(0.5),
    'font-size': 'var(--text-sm)',
  }),
  rule('.confirmation__actions', {'margin-top': Tok.space(2)}),
];
