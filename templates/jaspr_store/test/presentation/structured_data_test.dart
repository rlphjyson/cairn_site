import 'dart:convert';

import 'package:cairn_template_jaspr_store/common/utils/escape.dart';
import 'package:cairn_template_jaspr_store/core/config/store_config.dart';
import 'package:cairn_template_jaspr_store/core/seo/seo_data.dart';
import 'package:cairn_template_jaspr_store/data/catalog/catalog_repository_impl.dart';
import 'package:cairn_template_jaspr_store/backend/stores.dart';
import 'package:cairn_template_jaspr_store/domain/catalog/models/product.dart';
import 'package:cairn_template_jaspr_store/domain/reviews/models/review.dart';
import 'package:cairn_template_jaspr_store/presentation/components/navigation.dart';
import 'package:cairn_template_jaspr_store/presentation/seo/seo_head.dart';
import 'package:cairn_template_jaspr_store/presentation/seo/structured_data.dart';
import 'package:jaspr/server.dart' show renderComponent, Component;
import 'package:test/test.dart';

import '../support/harness.dart';

const config = StoreConfig(siteUrl: 'https://shop.example');

Map<String, dynamic> roundTrip(Map<String, Object?> ld) => jsonDecode(safeJsonForScript(ld)) as Map<String, dynamic>;

void main() {
  late List<Product> products;
  setUpAll(() async => products = await CatalogRepositoryImpl(CatalogStore(), ReviewStore()).allProducts());

  group('JSON-LD builders produce valid JSON with required properties', () {
    test('Organization', () {
      final o = roundTrip(organizationLd(config));
      expect(o['@context'], 'https://schema.org');
      expect(o['@type'], 'Organization');
      expect(o['name'], isNotEmpty);
      expect(o['url'], 'https://shop.example/');
      expect(o['address']['@type'], 'PostalAddress');
      expect(o['sameAs'], isA<List<dynamic>>());
    });

    test('WebSite with SearchAction', () {
      final w = roundTrip(websiteLd(config));
      expect(w['@type'], 'WebSite');
      expect(w['potentialAction']['target']['urlTemplate'], contains('{search_term_string}'));
      expect(w['publisher']['@id'], 'https://shop.example/#organization');
    });

    test('BreadcrumbList uses the current path for the last unlinked crumb', () {
      final b = roundTrip(
        breadcrumbLd(config, const [
          Crumb('Home', '/'),
          Crumb('Shop', '/products'),
          Crumb('Leaf'),
        ], currentPath: '/products/leaf'),
      );
      final items = b['itemListElement'] as List<dynamic>;
      expect(items.map((e) => e['position']), [1, 2, 3]);
      expect(items.last['item'], 'https://shop.example/products/leaf');
      expect(items.first['item'], 'https://shop.example/');
    });

    test('ItemList numbers from the start position', () {
      final l = roundTrip(itemListLd(config, products.take(3).toList(), startPosition: 9, name: 'All'));
      expect(l['numberOfItems'], 3);
      expect((l['itemListElement'] as List<dynamic>).map((e) => e['position']), [9, 10, 11]);
      expect(l['name'], 'All');
    });

    test('Product offer: price is a decimal string, currency, availability and a future validity date', () {
      final p = products.firstWhere((p) => p.slug == 'classic-38-watch');
      final ld = roundTrip(productLd(config, p, reviews: const [], now: DateTime.utc(2026, 3, 15)));
      final offer = ld['offers'] as Map<String, dynamic>;
      expect(offer['price'], '149.00');
      expect(offer['priceCurrency'], 'USD');
      expect(offer['availability'], 'https://schema.org/InStock');
      expect(offer['priceValidUntil'], '2027-03-15');
      expect(ld.containsKey('review'), isFalse);
    });

    test('Product with reviews includes at most five reviews with ratings', () {
      final p = products.firstWhere((p) => p.slug == 'classic-38-watch');
      final reviews = [
        for (var i = 0; i < 8; i++)
          Review(
            id: '$i',
            productId: p.id,
            author: 'A$i',
            rating: 5,
            title: 't',
            body: 'b',
            date: DateTime.utc(2026, 1, i + 1),
          ),
      ];
      final ld = roundTrip(productLd(config, p, reviews: reviews, now: DateTime.utc(2026)));
      expect(ld['review'], hasLength(5));
      expect(ld['aggregateRating']['bestRating'], 5);
    });

    test('hostile product names cannot break out of the script element', () async {
      final evil = products.first.copyWith().copyWith();
      final named = Product(
        id: evil.id,
        slug: evil.slug,
        name: '</script><script>alert(1)</script>',
        brand: evil.brand,
        categorySlug: evil.categorySlug,
        summary: 'x',
        description: evil.description,
        priceCents: evil.priceCents,
        sku: evil.sku,
        gtin: evil.gtin,
        images: evil.images,
        variants: evil.variants,
        createdAt: evil.createdAt,
        updatedAt: evil.updatedAt,
      );
      final seo = SeoData(
        title: 't',
        description: 'd',
        path: '/x',
        jsonLd: [productLd(config, named, reviews: const [], now: DateTime.utc(2026))],
      );
      initJaspr();
      final out = await renderComponent(Component.fragment(buildHead(seo, config)), standalone: true);
      final html = utf8.decode(out.body);
      expect(RegExp('<script').allMatches(html).length, RegExp('</script>').allMatches(html).length);
      expect(html, isNot(contains('</script><script>alert')));
      expect(html, contains('application/ld+json'));
    });
  });

  group('SeoData -> head', () {
    Future<String> head(SeoData seo) async {
      initJaspr();
      final out = await renderComponent(Component.fragment(buildHead(seo, config)), standalone: true);
      return utf8.decode(out.body);
    }

    test('og:title never gets the brand suffix twice and descriptions are clipped', () async {
      final html = await head(SeoData(title: 'T', description: 'word ' * 100, path: '/x'));
      final content = RegExp(r'name="description" content="([^"]*)"').firstMatch(html)!.group(1)!;
      expect(content.length, lessThanOrEqualTo(158));
      expect(content, endsWith('…'));
    });

    test('indexable pages get max-image-preview; noindex pages do not', () async {
      expect(await head(const SeoData(title: 'T', description: 'd', path: '/')), contains('max-image-preview:large'));
      final no = await head(const SeoData(title: 'T', description: 'd', path: '/', robots: RobotsPolicy.noIndexFollow));
      expect(no, contains('noindex, follow'));
      expect(no, isNot(contains('max-image-preview')));
    });

    test('custom hreflang entries replace the single-language default', () async {
      final html = await head(
        const SeoData(title: 'T', description: 'd', path: '/', hreflangPaths: {'en': '/', 'fr': '/fr'}),
      );
      expect(html, contains('hreflang="fr" href="https://shop.example/fr"'));
      expect(html, contains('hreflang="x-default"'));
    });

    test('prev/next links and extra Open Graph properties are emitted', () async {
      final html = await head(
        const SeoData(
          title: 'T',
          description: 'd',
          path: '/p?page=2',
          prevPath: '/p',
          nextPath: '/p?page=3',
          openGraph: {'product:price:amount': '1.00'},
        ),
      );
      expect(html, contains('rel="prev" href="https://shop.example/p"'));
      expect(html, contains('rel="next" href="https://shop.example/p?page=3"'));
      expect(html, contains('property="product:price:amount" content="1.00"'));
    });

    test('image dimensions default to the brand OG image only when the brand image is used', () async {
      final brand = await head(const SeoData(title: 'T', description: 'd', path: '/'));
      expect(brand, contains('og:image:width'));
      final custom = await head(
        const SeoData(title: 'T', description: 'd', path: '/', imagePath: '/images/products/x.jpg'),
      );
      expect(custom, isNot(contains('og:image:width')));
    });
  });
}
