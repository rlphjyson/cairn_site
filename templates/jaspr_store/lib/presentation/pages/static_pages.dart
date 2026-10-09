library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/utils/money.dart';
import '../../core/config/brand.dart';
import '../../core/config/store_config.dart';
import '../../domain/catalog/models/product.dart';
import '../components/buttons.dart';
import '../components/forms.dart';
import '../components/html.dart';
import '../components/icons.dart';
import '../components/navigation.dart';
import '../theme/tokens.dart';

class AboutPage extends StatelessComponent {
  const AboutPage({required this.config, super.key});
  final StoreConfig config;

  @override
  Component build(BuildContext context) {
    final threshold = formatMoney(config.shipping.freeThresholdCents, currency: config.currency);
    return div(classes: 'container', [
      div(classes: 'page-head', [
        const Breadcrumb([Crumb('Home', '/'), Crumb('About')]),
        div(classes: 'page-head__title', [
          h1([t('About ${Brand.name}')]),
          p([t(Brand.description)]),
        ]),
      ]),
      div(classes: 'prose about', [
        h2([t('Why we exist')]),
        p([
          t(
            '${Brand.name} started with a simple complaint: most things are made to be replaced. We pick a small number of objects, ask the people who make them hard questions, and sell the ones that survive. If something can be repaired, we sell the spare parts.',
          ),
        ]),
        h2([t('How we choose')]),
        ul([
          li([t('We buy what we would use ourselves, and keep using it for a year before we decide to stock it.')]),
          li([t('We prefer materials that age well: leather, steel, stoneware, recycled canvas.')]),
          li([t('We publish every review from a verified order, good or bad.')]),
        ]),
        h2(id: 'shipping', [t('Shipping and returns')]),
        p([
          t(
            'Standard delivery takes 3-5 business days and is free on orders over $threshold (otherwise ${formatMoney(config.shipping.standardCents, currency: config.currency)}). Express delivery takes 1-2 business days for ${formatMoney(config.shipping.expressCents, currency: config.currency)}. Returns are free within 30 days if the item is unworn.',
          ),
        ]),
        h2([t('Get in touch')]),
        p([
          t('Write to '),
          a(href: 'mailto:${Brand.supportEmail}', [t(Brand.supportEmail)]),
          t(
            ' or call ${Brand.phone}. ${Brand.legalName}, ${Brand.address1}, ${Brand.addressCity}, ${Brand.addressRegion} ${Brand.addressPostal}.',
          ),
        ]),
        div(classes: 'about__note', [
          Icons.info(),
          p(classes: 'text-sm', [
            t(
              '${Brand.name} is a fictional shop. This site is a template demo: nothing here can be bought, and the company, address and reviews are invented.',
            ),
          ]),
        ]),
      ]),
    ]);
  }
}

class NewsletterPage extends StatelessComponent {
  const NewsletterPage({
    this.email = '',
    this.error,
    this.subscribed = false,
    this.alreadySubscribed = false,
    super.key,
  });
  final String email;
  final String? error;
  final bool subscribed;
  final bool alreadySubscribed;

  @override
  Component build(BuildContext context) {
    if (subscribed) {
      return div(classes: 'container narrow', [
        div(classes: 'page-head', [
          h1([t(alreadySubscribed ? 'You are already on the list' : 'You are subscribed')]),
          p([
            t(
              'Thanks. One short email a month, and you can unsubscribe at any time. (Demo: nothing is actually sent.)',
            ),
          ]),
        ]),
        const ButtonLink(href: '/products', label: 'Keep shopping'),
      ]);
    }
    return div(classes: 'container narrow', [
      div(classes: 'page-head', [
        h1([t('Letters from the shop')]),
        p([t('New arrivals, restocks and a repair tip. One email a month.')]),
      ]),
      form(action: '/newsletter', method: FormMethod.post, classes: 'stack', [
        TextField(
          name: 'email',
          label: 'Email address',
          type: 'email',
          value: email,
          error: error,
          autocomplete: 'email',
          required: true,
          placeholder: 'you@example.com',
          idPrefix: 'news',
        ),
        const SubmitButton(label: 'Subscribe'),
      ]),
    ]);
  }
}

/// Used for 404 and 500. The status code is set by the controller, not here.
class ErrorPage extends StatelessComponent {
  const ErrorPage({
    required this.status,
    required this.title,
    required this.message,
    this.suggestions = const [],
    super.key,
  });

  final int status;
  final String title;
  final String message;
  final List<Product> suggestions;

  @override
  Component build(BuildContext context) {
    return div(classes: 'container error-page', [
      p(classes: 'error-page__code', [t('$status')]),
      h1([t(title)]),
      p(classes: 'muted', [t(message)]),
      div(classes: 'row', [
        const ButtonLink(href: '/', label: 'Back to home'),
        const ButtonLink(href: '/products', label: 'Browse products', variant: ButtonVariant.outline),
      ]),
      form(
        action: '/products',
        method: FormMethod.get,
        classes: 'error-page__search',
        attributes: const {'role': 'search'},
        [
          const TextField(
            name: 'q',
            label: 'Search the shop',
            type: 'search',
            idPrefix: 'err',
            placeholder: 'Search products',
          ),
          const SubmitButton(label: 'Search', variant: ButtonVariant.secondary),
        ],
      ),
    ]);
  }
}

@css
List<StyleRule> get staticPageStyles => [
  rule('.narrow', {'max-width': '40rem'}),
  rule('.about__note', {
    'display': 'flex',
    'gap': Tok.space(3),
    'padding': Tok.space(4),
    'border': '1px solid var(--border)',
    'border-radius': Tok.radiusLg,
    'background': Tok.muted,
    'align-items': 'flex-start',
  }),
  rule('.about__note .icon', {'flex': 'none', 'margin-top': '0.125rem'}),
  rule('.error-page', {
    'display': 'flex',
    'flex-direction': 'column',
    'align-items': 'center',
    'text-align': 'center',
    'gap': Tok.space(4),
    'padding-block': Tok.space(20),
  }),
  rule('.error-page__code', {
    'font-size': 'var(--text-sm)',
    'font-weight': '600',
    'padding': '${Tok.space(1)} ${Tok.space(3)}',
    'border-radius': '9999px',
    'background': Tok.secondary,
  }),
  rule('.error-page__search', {
    'display': 'grid',
    'grid-template-columns': 'minmax(0, 1fr) auto',
    'gap': Tok.space(2),
    'align-items': 'end',
    'width': '100%',
    'max-width': '26rem',
    'margin-top': Tok.space(6),
    'text-align': 'left',
  }),
];
