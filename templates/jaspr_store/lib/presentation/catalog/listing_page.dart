library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../common/utils/text.dart';
import '../../core/config/store_config.dart';
import '../../core/seo/url_policy.dart';
import '../../domain/catalog/models/product.dart';
import '../../domain/catalog/models/product_query.dart';
import '../components/buttons.dart';
import '../components/commerce.dart';
import '../components/forms.dart';
import '../components/html.dart';
import '../components/navigation.dart';
import '../theme/tokens.dart';

/// Builds the URL of a listing page. Defaults (`sort=featured`, `page=1`) are
/// omitted so each state has exactly one spelling.
String listingUrl(String basePath, {String? q, ProductSort sort = ProductSort.featured, int page = 1}) => buildUrl(
  basePath,
  {
    'q': (q ?? '').trim().isEmpty ? null : q!.trim(),
    'sort': sort == ProductSort.defaultSort ? null : sort.param,
    'page': page <= 1 ? null : '$page',
  },
  order: const ['q', 'sort', 'page'],
);

class ListingPage extends StatelessComponent {
  const ListingPage({
    required this.config,
    required this.listing,
    required this.categories,
    required this.basePath,
    required this.heading,
    required this.crumbs,
    this.category,
    this.intro,
    super.key,
  });

  final StoreConfig config;
  final ProductListing listing;
  final List<Category> categories;

  /// `/products` or `/categories/<slug>`; the form posts back here.
  final String basePath;
  final String heading;
  final String? intro;
  final Category? category;
  final List<Crumb> crumbs;

  ProductQuery get _q => listing.query;

  @override
  Component build(BuildContext context) {
    final filtered = _q.hasSearch || _q.sort != ProductSort.defaultSort;
    return Component.fragment([
      div(classes: 'container page-head', [
        Breadcrumb(crumbs),
        div(classes: 'page-head__title', [
          h1([t(heading)]),
          if (intro != null) p([t(intro!)]),
        ]),
      ]),
      div(classes: 'container', [
        nav(
          classes: 'chips',
          attributes: const {'aria-label': 'Categories'},
          [
            _chip('/products', 'All', category == null),
            for (final c in categories) _chip('/categories/${c.slug}', c.name, category?.slug == c.slug),
          ],
        ),
        form(
          action: basePath,
          method: FormMethod.get,
          classes: 'toolbar',
          attributes: const {'role': 'search', 'aria-label': 'Filter products'},
          [
            div(classes: 'toolbar__search', [
              TextField(
                name: 'q',
                label: 'Search',
                type: 'search',
                value: _q.normalisedSearch,
                placeholder: 'Search products',
                autocomplete: 'off',
                idPrefix: 'listing',
              ),
            ]),
            div(classes: 'toolbar__sort', [
              SelectField(
                name: 'sort',
                label: 'Sort by',
                value: _q.sort.param,
                options: {for (final s in ProductSort.values) s.param: s.label},
                idPrefix: 'listing',
              ),
            ]),
            div(classes: 'toolbar__actions', [
              const SubmitButton(label: 'Apply', variant: ButtonVariant.secondary),
              if (filtered) ButtonLink(href: basePath, label: 'Clear', variant: ButtonVariant.ghost),
            ]),
          ],
        ),
        div(classes: 'results-meta', [
          p(attributes: const {'role': 'status', 'aria-live': 'polite'}, [t(_summary())]),
        ]),
        if (listing.isEmpty)
          _empty()
        else ...[
          h2(classes: 'sr-only', [t('Products')]),
          ul(classes: 'product-grid', [
            for (var i = 0; i < listing.items.length; i++)
              li([
                ProductCard(product: listing.items[i], currency: config.currency, priority: i < 4 && listing.page == 1),
              ]),
          ]),
        ],
        Pagination(
          page: listing.page,
          pageCount: listing.pageCount,
          hrefFor: (n) => listingUrl(basePath, q: _q.search, sort: _q.sort, page: n),
        ),
      ]),
    ]);
  }

  String _summary() {
    if (listing.isEmpty) return _q.hasSearch ? 'No products match "${_q.normalisedSearch}".' : 'No products here yet.';
    final range = '${listing.firstIndex}-${listing.lastIndex} of ${listing.total}';
    return _q.hasSearch
        ? 'Showing $range ${pluralize(listing.total, 'result')} for "${_q.normalisedSearch}"'
        : 'Showing $range ${pluralize(listing.total, 'product')}';
  }

  Component _chip(String href, String label, bool active) => a(
    href: href,
    classes: cx(['chip', if (active) 'is-active']),
    attributes: {if (active) 'aria-current': 'page'},
    [t(label)],
  );

  Component _empty() => div(classes: 'empty', [
    h2([t('Nothing found')]),
    p(classes: 'muted', [
      t(_q.hasSearch ? 'Check the spelling, try a more general word, or browse a category.' : 'Check back soon.'),
    ]),
    div(classes: 'row', [
      const ButtonLink(href: '/products', label: 'See all products'),
      for (final c in categories.take(3))
        ButtonLink(href: '/categories/${c.slug}', label: c.name, variant: ButtonVariant.outline),
    ]),
  ]);
}

@css
List<StyleRule> get listingStyles => [
  rule('.page-head__title', {'margin-top': Tok.space(5)}),
  rule('.chips', {'display': 'flex', 'flex-wrap': 'wrap', 'gap': Tok.space(2), 'margin-bottom': Tok.space(5)}),
  rule('.chip', {
    'display': 'inline-flex',
    'align-items': 'center',
    'height': '2rem',
    'padding': '0 ${Tok.space(3.5)}',
    'border': '1px solid var(--input)',
    'border-radius': '9999px',
    'font-size': 'var(--text-sm)',
    'font-weight': '500',
    'background': Tok.background,
    'transition': 'background-color 150ms var(--ease)',
  }),
  rule('.chip:hover', {'background': Tok.accent}),
  rule('.chip.is-active', {'background': Tok.primary, 'color': Tok.primaryForeground, 'border-color': Tok.primary}),
  rule('.toolbar', {
    'display': 'grid',
    'grid-template-columns': '1fr',
    'gap': Tok.space(3),
    'align-items': 'end',
    'padding': Tok.space(4),
    'border': '1px solid var(--border)',
    'border-radius': Tok.radiusXl,
    'background': Tok.card,
  }),
  atMin('40rem', [
    rule('.toolbar', {'grid-template-columns': '1fr 14rem auto'}),
  ]),
  rule('.toolbar__actions', {'display': 'flex', 'gap': Tok.space(2)}),
  rule('.results-meta', {
    'margin': '${Tok.space(5)} 0 ${Tok.space(5)}',
    'font-size': 'var(--text-sm)',
    'color': Tok.mutedForeground,
  }),
  rule('.empty', {
    'display': 'flex',
    'flex-direction': 'column',
    'gap': Tok.space(3),
    'align-items': 'center',
    'text-align': 'center',
    'padding': '${Tok.space(16)} ${Tok.space(4)}',
    'border': '1px dashed var(--border)',
    'border-radius': Tok.radiusXl,
  }),
];
