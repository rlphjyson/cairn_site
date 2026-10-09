library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/utils/money.dart';
import '../../core/config/store_config.dart';
import '../../domain/cart/models/cart.dart';
import '../../domain/checkout/models/checkout.dart';
import '../components/buttons.dart';
import '../components/feedback.dart';
import '../components/forms.dart';
import '../components/html.dart';
import '../components/media.dart';
import '../theme/tokens.dart';

/// Field order, used for the error summary and for focus order.
const List<(String, String)> kCheckoutFields = [
  ('email', 'Email address'),
  ('fullName', 'Full name'),
  ('phone', 'Phone'),
  ('address1', 'Address'),
  ('address2', 'Address line 2'),
  ('country', 'Country'),
  ('city', 'City'),
  ('region', 'State / region'),
  ('postalCode', 'Postal code'),
  ('delivery', 'Delivery method'),
  ('acceptTerms', 'Demo confirmation'),
];

class CheckoutPage extends StatelessComponent {
  const CheckoutPage({
    required this.config,
    required this.cart,
    required this.values,
    this.errors = const {},
    this.formError,
    super.key,
  });

  final StoreConfig config;
  final PricedCart cart;
  final CheckoutForm values;
  final Map<String, String> errors;

  /// A non-field error (out of stock, stale cart).
  final String? formError;

  String _m(int c) => formatMoney(c, currency: config.currency);

  @override
  Component build(BuildContext context) {
    final country = countryByCode(values.country) ?? kCountries.first;
    final standard = cart.qualifiesForFreeShipping ? 0 : config.shipping.standardCents;
    return div(classes: 'container checkout', [
      div(classes: 'page-head', [
        h1([t('Checkout')]),
        p([t('Demo checkout: we will not ask for a card or take any money.')]),
      ]),
      if (errors.isNotEmpty || formError != null)
        div(
          classes: 'error-summary',
          attributes: const {
            'role': 'alert',
            'aria-labelledby': 'error-summary-title',
            'tabindex': '-1',
            'id': 'error-summary',
          },
          [
            h2(id: 'error-summary-title', classes: 'error-summary__title', [
              t(formError ?? 'Please fix the highlighted fields'),
            ]),
            if (errors.isNotEmpty)
              ul([
                for (final (name, label) in kCheckoutFields)
                  if (errors[name] != null)
                    li([
                      a(href: '#f-$name', [t('$label: ${errors[name]}')]),
                    ]),
              ]),
          ],
        ),
      div(classes: 'checkout-layout', [
        form(
          action: '/checkout',
          method: FormMethod.post,
          classes: 'checkout-form',
          attributes: const {'novalidate': ''},
          [
            fieldset(classes: 'panel', [
              legend(classes: 'panel__title', [t('Contact')]),
              TextField(
                name: 'email',
                label: 'Email address',
                type: 'email',
                value: values.email,
                error: errors['email'],
                autocomplete: 'email',
                required: true,
                hint: 'We will send your order confirmation here.',
              ),
            ]),
            fieldset(classes: 'panel', [
              legend(classes: 'panel__title', [t('Delivery address')]),
              div(classes: 'grid-2', [
                TextField(
                  name: 'fullName',
                  label: 'Full name',
                  value: values.fullName,
                  error: errors['fullName'],
                  autocomplete: 'name',
                  required: true,
                ),
                TextField(
                  name: 'phone',
                  label: 'Phone (optional)',
                  type: 'tel',
                  value: values.phone,
                  error: errors['phone'],
                  autocomplete: 'tel',
                  inputMode: 'tel',
                ),
              ]),
              TextField(
                name: 'address1',
                label: 'Address',
                value: values.address1,
                error: errors['address1'],
                autocomplete: 'address-line1',
                required: true,
              ),
              TextField(
                name: 'address2',
                label: 'Apartment, suite, etc. (optional)',
                value: values.address2,
                error: errors['address2'],
                autocomplete: 'address-line2',
              ),
              SelectField(
                name: 'country',
                label: 'Country',
                value: values.country,
                error: errors['country'],
                autocomplete: 'country',
                options: {for (final c in kCountries) c.code: c.name},
              ),
              div(classes: 'grid-3', [
                TextField(
                  name: 'city',
                  label: 'City',
                  value: values.city,
                  error: errors['city'],
                  autocomplete: 'address-level2',
                  required: true,
                ),
                TextField(
                  name: 'region',
                  label: country.regionLabel,
                  value: values.region,
                  error: errors['region'],
                  autocomplete: 'address-level1',
                  required: true,
                ),
                TextField(
                  name: 'postalCode',
                  label: country.postalLabel,
                  value: values.postalCode,
                  error: errors['postalCode'],
                  autocomplete: 'postal-code',
                  required: true,
                ),
              ]),
            ]),
            fieldset(
              classes: 'panel',
              attributes: {if (errors['delivery'] != null) 'aria-describedby': 'f-delivery-error'},
              [
                legend(classes: 'panel__title', [t('Delivery method')]),
                div(classes: 'delivery', id: 'f-delivery', [
                  _delivery(DeliveryMethod.standard, standard),
                  _delivery(DeliveryMethod.express, config.shipping.expressCents),
                ]),
                if (errors['delivery'] != null) FieldError(id: 'f-delivery-error', message: errors['delivery']!),
              ],
            ),
            fieldset(classes: 'panel', [
              legend(classes: 'panel__title', [t('Payment')]),
              Alert(
                title: 'No payment is collected',
                children: [
                  p([
                    t(
                      'This template never takes real payment. In a real store this step redirects to your payment provider (for example Stripe Checkout); see the documentation.',
                    ),
                  ]),
                ],
              ),
              CheckboxField(
                name: 'acceptTerms',
                checked: values.acceptTerms,
                error: errors['acceptTerms'],
                label: t('I understand this is a demo order: nothing will be charged or shipped.'),
              ),
            ]),
            const SubmitButton(label: 'Place demo order', size: ButtonSize.lg, block: true),
          ],
        ),
        aside(
          classes: 'cart-summary checkout-summary',
          attributes: const {'aria-labelledby': 'co-summary-title'},
          [
            h2(id: 'co-summary-title', classes: 'summary-title', [t('Order summary')]),
            ul(classes: 'mini-lines', [
              for (final l in cart.lines)
                li(classes: 'mini-line', [
                  div(classes: 'media mini-line__media', [
                    ResponsiveImage(image: l.product.primaryImage, sizes: '4rem', altOverride: ''),
                  ]),
                  div(classes: 'mini-line__info', [
                    p(classes: 'mini-line__name', [t(l.product.name)]),
                    p(classes: 'muted text-sm', [t('${l.variant.label} · Qty ${l.quantity}')]),
                  ]),
                  p(classes: 'mini-line__price', [t(_m(l.totalCents))]),
                ]),
            ]),
            dl(classes: 'totals', [
              _row('Subtotal', _m(cart.subtotalCents)),
              if (cart.discountCents > 0)
                _row('Discount (${cart.promoCode})', '-${_m(cart.discountCents)}', accent: true),
              _row(
                'Shipping (${cart.delivery.label.toLowerCase()})',
                cart.shippingCents == 0 ? 'Free' : _m(cart.shippingCents),
              ),
              _row('Total', _m(cart.totalCents), total: true),
            ]),
            const ButtonLink(href: '/cart', label: 'Edit cart', variant: ButtonVariant.link, size: ButtonSize.sm),
          ],
        ),
      ]),
    ]);
  }

  Component _delivery(DeliveryMethod m, int cents) {
    final checked = values.deliveryMethod == m;
    return el(
      'label',
      classes: cx(['delivery__option', if (checked) 'is-selected']),
      children: [
        el(
          'input',
          attrs: {'type': 'radio', 'name': 'delivery', 'value': m.id, if (checked) 'checked': ''},
          classes: 'delivery__input',
        ),
        span(classes: 'delivery__text', [
          span(classes: 'delivery__name', [t(m.label)]),
          span(classes: 'muted text-sm', [t(m.eta)]),
        ]),
        span(classes: 'delivery__price', [t(cents == 0 ? 'Free' : _m(cents))]),
      ],
    );
  }

  Component _row(String label, String value, {bool total = false, bool accent = false}) =>
      div(classes: cx(['totals__row', if (total) 'totals__row--total', if (accent) 'totals__row--accent']), [
        dt([t(label)]),
        dd([t(value)]),
      ]);
}

@css
List<StyleRule> get checkoutStyles => [
  rule('.checkout-layout', {
    'display': 'grid',
    'gap': Tok.space(8),
    'grid-template-columns': 'minmax(0, 1fr)',
    'align-items': 'start',
    'margin-top': Tok.space(4),
  }),
  atMin('64rem', [
    rule('.checkout-layout', {'grid-template-columns': 'minmax(0, 1fr) 24rem', 'gap': Tok.space(12)}),
  ]),
  rule('.checkout-form', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(5)}),
  rule('.panel', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(4),
    'margin': '0',
    'min-width': '0',
    'padding': Tok.space(5),
    'border': '1px solid var(--border)',
    'border-radius': Tok.radiusXl,
    'background': Tok.card,
  }),
  rule('.panel__title', {
    'padding': '0 ${Tok.space(2)}',
    'margin-left': '-0.5rem',
    'font-weight': '600',
    'font-size': 'var(--text-lg)',
    'letter-spacing': '-0.01em',
  }),
  rule('.grid-2', {'display': 'grid', 'gap': Tok.space(4), 'grid-template-columns': 'minmax(0, 1fr)'}),
  rule('.grid-3', {'display': 'grid', 'gap': Tok.space(4), 'grid-template-columns': 'minmax(0, 1fr)'}),
  atMin('40rem', [
    rule('.grid-2', {'grid-template-columns': 'repeat(2, minmax(0, 1fr))'}),
    rule('.grid-3', {'grid-template-columns': 'repeat(3, minmax(0, 1fr))'}),
  ]),
  rule('.delivery', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(2.5)}),
  rule('.delivery__option', {
    'display': 'flex',
    'align-items': 'center',
    'gap': Tok.space(3),
    'padding': Tok.space(4),
    'border': '1px solid var(--input)',
    'border-radius': Tok.radiusLg,
    'cursor': 'pointer',
    'transition': 'border-color 150ms var(--ease), background-color 150ms var(--ease)',
  }),
  rule('.delivery__option:hover', {'background': Tok.accent}),
  rule('.delivery__option:has(.delivery__input:checked)', {
    'border-color': Tok.primary,
    'box-shadow': '0 0 0 1px var(--primary)',
  }),
  rule('.delivery__option:has(.delivery__input:focus-visible)', {
    'box-shadow': '0 0 0 3px color-mix(in oklab, var(--ring) 50%, transparent)',
  }),
  rule('.delivery__input', {
    'width': '1rem',
    'height': '1rem',
    'accent-color': 'var(--primary)',
    'flex': 'none',
    'margin': '0',
  }),
  rule('.delivery__text', {'display': 'flex', 'flex-direction': 'column', 'flex': '1'}),
  rule('.delivery__name', {'font-weight': '500', 'font-size': 'var(--text-sm)'}),
  rule('.delivery__price', {
    'font-weight': '600',
    'font-size': 'var(--text-sm)',
    'font-variant-numeric': 'tabular-nums',
  }),
  rule('.error-summary', {
    'padding': Tok.space(4),
    'margin-bottom': Tok.space(4),
    'border': '1px solid var(--destructive)',
    'border-radius': Tok.radiusLg,
    'color': Tok.destructive,
  }),
  rule('.error-summary__title', {'font-size': 'var(--text-base)', 'margin-bottom': Tok.space(2)}),
  rule('.error-summary ul', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(1),
    'font-size': 'var(--text-sm)',
    'list-style': 'disc',
    'padding-left': Tok.space(5),
  }),
  rule('.error-summary a', {'text-decoration': 'underline'}),
  rule('.mini-lines', {'display': 'flex', 'flex-direction': 'column', 'gap': Tok.space(3)}),
  rule('.mini-line', {
    'display': 'grid',
    'grid-template-columns': '3.5rem minmax(0, 1fr) auto',
    'gap': Tok.space(3),
    'align-items': 'center',
  }),
  rule('.mini-line__media', {'border-radius': Tok.radiusMd, 'border': '1px solid var(--border)'}),
  rule('.mini-line__name', {'font-size': 'var(--text-sm)', 'font-weight': '500', 'line-height': '1.3'}),
  rule('.mini-line__price', {'font-size': 'var(--text-sm)', 'font-variant-numeric': 'tabular-nums'}),
];
