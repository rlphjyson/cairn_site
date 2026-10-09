/// JSON-LD builders (schema.org). Pure functions from domain data to
/// `Map<String, Object?>`, so every shape is unit-tested by parsing the JSON
/// and checking it, with no rendering involved.
///
/// Google's rich-result requirements these target:
///  * Product: `name`, `image`, and an `offers` with `price`, `priceCurrency`
///    and `availability`; `aggregateRating`/`review` are optional but valuable.
///  * BreadcrumbList: ordered `ListItem`s with `position`, `name`, `item`.
///  * WebSite: `potentialAction` SearchAction enables the sitelinks search box.
library;

import '../../common/utils/money.dart';
import '../../core/config/brand.dart';
import '../../core/config/store_config.dart';
import '../../domain/catalog/models/product.dart';
import '../../domain/reviews/models/review.dart';
import '../components/navigation.dart';

const String _ctx = 'https://schema.org';

Map<String, Object?> organizationLd(StoreConfig config) => {
  '@context': _ctx,
  '@type': 'Organization',
  '@id': '${config.origin}/#organization',
  'name': Brand.name,
  'legalName': Brand.legalName,
  'url': config.absoluteUrl('/'),
  'logo': {
    '@type': 'ImageObject',
    'url': config.absoluteUrl('/icons/icon-512.png'),
    'width': 512,
    'height': 512,
  },
  'image': config.absoluteUrl(Brand.ogImagePath),
  'email': Brand.supportEmail,
  'telephone': Brand.phone,
  'address': {
    '@type': 'PostalAddress',
    'streetAddress': Brand.address1,
    'addressLocality': Brand.addressCity,
    'addressRegion': Brand.addressRegion,
    'postalCode': Brand.addressPostal,
    'addressCountry': Brand.addressCountry,
  },
  'sameAs': Brand.sameAs,
};

Map<String, Object?> websiteLd(StoreConfig config) => {
  '@context': _ctx,
  '@type': 'WebSite',
  '@id': '${config.origin}/#website',
  'url': config.absoluteUrl('/'),
  'name': Brand.name,
  'description': Brand.description,
  'inLanguage': Brand.language,
  'publisher': {'@id': '${config.origin}/#organization'},
  'potentialAction': {
    '@type': 'SearchAction',
    'target': {'@type': 'EntryPoint', 'urlTemplate': '${config.origin}/products?q={search_term_string}'},
    'query-input': 'required name=search_term_string',
  },
};

Map<String, Object?> breadcrumbLd(StoreConfig config, List<Crumb> crumbs, {required String currentPath}) => {
  '@context': _ctx,
  '@type': 'BreadcrumbList',
  'itemListElement': [
    for (var i = 0; i < crumbs.length; i++)
      {
        '@type': 'ListItem',
        'position': i + 1,
        'name': crumbs[i].label,
        'item': config.absoluteUrl(crumbs[i].path ?? currentPath),
      },
  ],
};

Map<String, Object?> itemListLd(StoreConfig config, List<Product> products, {int startPosition = 1, String? name}) => {
  '@context': _ctx,
  '@type': 'ItemList',
  'name': ?name,
  'numberOfItems': products.length,
  'itemListElement': [
    for (var i = 0; i < products.length; i++)
      {
        '@type': 'ListItem',
        'position': startPosition + i,
        'url': config.absoluteUrl('/products/${products[i].slug}'),
        'name': products[i].name,
        'image': config.absoluteUrl(products[i].primaryImage.fallbackUrl),
      },
  ],
};

Map<String, Object?> productLd(
  StoreConfig config,
  Product product, {
  required List<Review> reviews,
  required DateTime now,
  String? categoryName,
}) {
  final url = config.absoluteUrl('/products/${product.slug}');
  // schema.org wants a date in the future; a year out is the usual convention
  // and is recomputed on every render, so it never goes stale.
  final validUntil = now.toUtc().add(const Duration(days: 365));
  final until =
      '${validUntil.year.toString().padLeft(4, '0')}-${validUntil.month.toString().padLeft(2, '0')}-${validUntil.day.toString().padLeft(2, '0')}';
  return {
    '@context': _ctx,
    '@type': 'Product',
    '@id': '$url#product',
    'name': product.name,
    'description': product.summary,
    'url': url,
    'sku': product.sku,
    'mpn': product.sku,
    'gtin13': product.gtin,
    'category': ?categoryName,
    'image': [for (final i in product.images) config.absoluteUrl(i.fallbackUrl)],
    'brand': {'@type': 'Brand', 'name': product.brand},
    'offers': {
      '@type': 'Offer',
      'url': url,
      'priceCurrency': config.currency,
      'price': decimalAmount(product.priceCents),
      'priceValidUntil': until,
      'availability': product.availability.schemaUrl,
      'itemCondition': 'https://schema.org/NewCondition',
      'seller': {'@id': '${config.origin}/#organization'},
      'shippingDetails': {
        '@type': 'OfferShippingDetails',
        'shippingRate': {
          '@type': 'MonetaryAmount',
          'value': decimalAmount(config.shipping.standardCents),
          'currency': config.currency,
        },
        'shippingDestination': {'@type': 'DefinedRegion', 'addressCountry': 'US'},
      },
      'hasMerchantReturnPolicy': {
        '@type': 'MerchantReturnPolicy',
        'applicableCountry': 'US',
        'returnPolicyCategory': 'https://schema.org/MerchantReturnFiniteReturnWindow',
        'merchantReturnDays': 30,
        'returnMethod': 'https://schema.org/ReturnByMail',
        'returnFees': 'https://schema.org/FreeReturn',
      },
    },
    if (product.rating.hasReviews)
      'aggregateRating': {
        '@type': 'AggregateRating',
        'ratingValue': product.rating.average,
        'reviewCount': product.rating.count,
        'bestRating': 5,
        'worstRating': 1,
      },
    if (reviews.isNotEmpty)
      'review': [
        for (final r in reviews.take(5))
          {
            '@type': 'Review',
            'author': {'@type': 'Person', 'name': r.author},
            'datePublished':
                '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}',
            'name': r.title,
            'reviewBody': r.body,
            'reviewRating': {'@type': 'Rating', 'ratingValue': r.rating, 'bestRating': 5, 'worstRating': 1},
          },
      ],
  };
}
