import 'dart:convert';

import 'package:cairn_template_jaspr_store/core/config/store_config.dart';
import 'package:cairn_template_jaspr_store/core/seo/seo_data.dart';
import 'package:cairn_template_jaspr_store/http/middleware.dart';
import 'package:cairn_template_jaspr_store/http/request_info.dart';
import 'package:cairn_template_jaspr_store/http/seo_endpoints.dart';
import 'package:cairn_template_jaspr_store/presentation/catalog/listing_page.dart';
import 'package:cairn_template_jaspr_store/presentation/catalog/listing_params.dart';
import 'package:cairn_template_jaspr_store/domain/catalog/models/product_query.dart';
import 'package:cairn_template_jaspr_store/presentation/seo/seo_head.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/harness.dart';

void main() {
  const config = StoreConfig(siteUrl: 'https://shop.example/', environment: AppEnvironment.production);

  group('StoreConfig', () {
    test('origin strips a trailing slash and absoluteUrl joins paths', () {
      expect(config.origin, 'https://shop.example');
      expect(config.absoluteUrl('/'), 'https://shop.example/');
      expect(config.absoluteUrl('/products/x'), 'https://shop.example/products/x');
      expect(config.absoluteUrl('products?a=1'), 'https://shop.example/products?a=1');
    });

    test('secureCookies follows the scheme', () {
      expect(config.secureCookies, isTrue);
      expect(const StoreConfig().secureCookies, isFalse);
    });

    test('findPromo normalises', () {
      expect(config.findPromo(' cairn10 ')!.percentOff, 10);
      expect(config.findPromo('x'), isNull);
    });

    test('fromEnvironment honours a runtime SITE_URL', () {
      expect(StoreConfig.fromEnvironment(siteUrl: 'https://x.test').siteUrl, 'https://x.test');
      expect(StoreConfig.fromEnvironment(siteUrl: '').siteUrl, 'http://localhost:8080');
    });
  });

  group('security headers', () {
    Future<Response> run(Handler h, {StoreConfig c = config}) async =>
        h(Request('GET', Uri.parse('https://shop.example/')));

    test('CSP forbids inline script, framing and foreign form targets', () {
      final csp = contentSecurityPolicy();
      expect(csp, contains("script-src 'self'"));
      expect(csp, isNot(contains("script-src 'self' 'unsafe-inline'")));
      expect(csp, contains("frame-ancestors 'none'"));
      expect(csp, contains("form-action 'self'"));
      expect(csp, contains("object-src 'none'"));
      expect(csp, contains("base-uri 'self'"));
    });

    test('middleware adds the full header set', () async {
      final h = const Pipeline().addMiddleware(securityHeaders(config)).addHandler((_) => Response.ok('x'));
      final r = await run(h);
      expect(r.headers['x-content-type-options'], 'nosniff');
      expect(r.headers['x-frame-options'], 'DENY');
      expect(r.headers['referrer-policy'], 'strict-origin-when-cross-origin');
      expect(r.headers['strict-transport-security'], contains('max-age=31536000'));
      expect(r.headers['permissions-policy'], contains('camera=()'));
      expect(r.headers['content-security-policy'], isNotEmpty);
    });

    test('HSTS is only sent over https', () async {
      final h = const Pipeline()
          .addMiddleware(securityHeaders(const StoreConfig()))
          .addHandler((_) => Response.ok('x'));
      expect((await run(h)).headers.containsKey('strict-transport-security'), isFalse);
    });
  });

  group('static caching', () {
    test('hashed assets are immutable', () {
      expect(staticCacheControl('/main.client.dart.1a2b3c4d5e.js'), contains('immutable'));
      expect(staticCacheControl('/assets/app-deadbeef12.css'), contains('immutable'));
    });

    test('images are cached for a week with revalidation', () {
      expect(staticCacheControl('/images/products/x.jpg'), contains('max-age=604800'));
      expect(staticCacheControl('/images/products/x.jpg'), contains('stale-while-revalidate'));
    });

    test('scripts always revalidate', () {
      expect(staticCacheControl('/main.client.dart.js'), 'public, max-age=0, must-revalidate');
    });

    test('icons are cached for a day; unknown files are left alone', () {
      expect(staticCacheControl('/icons/icon-192.png'), 'public, max-age=86400');
      expect(staticCacheControl('/favicon.ico'), 'public, max-age=86400');
      expect(staticCacheControl('/whatever.txt'), isNull);
    });

    test('middleware respects an existing Cache-Control', () async {
      final h = const Pipeline()
          .addMiddleware(staticCaching())
          .addHandler((_) => Response.ok('x', headers: {'cache-control': 'no-store'}));
      final r = await h(Request('GET', Uri.parse('https://shop.example/images/a.jpg')));
      expect(r.headers['cache-control'], 'no-store');
    });

    test('middleware labels static responses', () async {
      final h = const Pipeline().addMiddleware(staticCaching()).addHandler((_) => Response.ok('x'));
      final r = await h(Request('GET', Uri.parse('https://shop.example/images/a.jpg')));
      expect(r.headers['cache-control'], contains('max-age=604800'));
    });
  });

  group('same-origin guard', () {
    test('requests without Origin are allowed (curl, server to server)', () {
      expect(isSameOriginPost({}, config), isTrue);
    });

    test('the configured origin is allowed', () {
      expect(isSameOriginPost({'origin': 'https://shop.example'}, config), isTrue);
    });

    test('a matching Host is allowed (proxies, other deployments)', () {
      expect(isSameOriginPost({'origin': 'https://other.test', 'host': 'other.test'}, config), isTrue);
      expect(
        isSameOriginPost({
          'origin': 'https://other.test',
          'x-forwarded-host': 'other.test',
          'host': 'internal',
        }, config),
        isTrue,
      );
    });

    test('a foreign origin is rejected', () {
      expect(isSameOriginPost({'origin': 'https://evil.example', 'host': 'shop.example'}, config), isFalse);
      expect(isSameOriginPost({'origin': 'null'}, config), isFalse);
    });

    test('Sec-Fetch-Site: cross-site is rejected', () {
      expect(isSameOriginPost({'sec-fetch-site': 'cross-site'}, config), isFalse);
      expect(isSameOriginPost({'sec-fetch-site': 'same-site'}, config), isFalse);
      expect(isSameOriginPost({'sec-fetch-site': 'same-origin'}, config), isTrue);
    });
  });

  group('ListingParams', () {
    test('defaults', () {
      final p = ListingParams.parse({});
      expect(p.q, '');
      expect(p.sort, ProductSort.featured);
      expect(p.page, 1);
      expect(p.needsRedirect, isFalse);
      expect(p.isDefault, isTrue);
    });

    test('non-canonical spellings need a redirect', () {
      expect(ListingParams.parse({'page': '1'}).needsRedirect, isTrue);
      expect(ListingParams.parse({'page': '0'}).needsRedirect, isTrue);
      expect(ListingParams.parse({'page': 'abc'}).needsRedirect, isTrue);
      expect(ListingParams.parse({'page': '02'}).needsRedirect, isTrue);
      expect(ListingParams.parse({'sort': 'featured'}).needsRedirect, isTrue);
      expect(ListingParams.parse({'sort': 'bogus'}).needsRedirect, isTrue);
      expect(ListingParams.parse({'q': ''}).needsRedirect, isTrue);
      expect(ListingParams.parse({'q': '  a  b '}).needsRedirect, isTrue);
    });

    test('canonical spellings do not', () {
      expect(ListingParams.parse({'page': '2'}).needsRedirect, isFalse);
      expect(ListingParams.parse({'sort': 'price-asc'}).needsRedirect, isFalse);
      expect(ListingParams.parse({'q': 'a b'}).needsRedirect, isFalse);
      expect(ListingParams.parse({'utm_source': 'x', 'gclid': '1'}).needsRedirect, isFalse);
    });

    test('search text is collapsed and bounded', () {
      expect(ListingParams.parse({'q': '  a   b '}).q, 'a b');
      expect(ListingParams.parse({'q': 'x' * 300}).q.length, ListingParams.maxSearchLength);
    });

    test('hasSearch / isDefault', () {
      expect(ListingParams.parse({'q': 'a'}).hasSearch, isTrue);
      expect(ListingParams.parse({'sort': 'name'}).isDefault, isFalse);
    });
  });

  group('listingUrl', () {
    test('omits defaults', () {
      expect(listingUrl('/products'), '/products');
      expect(listingUrl('/products', page: 1), '/products');
      expect(listingUrl('/products', sort: ProductSort.featured), '/products');
    });

    test('includes meaningful state in a stable order', () {
      expect(
        listingUrl('/products', page: 2, sort: ProductSort.priceAsc, q: 'a b'),
        '/products?q=a+b&sort=price-asc&page=2',
      );
      expect(listingUrl('/categories/bags', page: 2), '/categories/bags?page=2');
    });
  });

  group('SEO head', () {
    test('titles carry the brand suffix and stay within 60 characters', () {
      const long = SeoData(
        title: 'An extremely long product name that goes on and on forever and ever',
        description: 'd',
        path: '/',
      );
      expect(documentTitle(long).length, lessThanOrEqualTo(60));
      expect(documentTitle(long), endsWith('| Northgate Goods'));
      expect(documentTitle(const SeoData(title: 'Cart', description: 'd', path: '/')), 'Cart | Northgate Goods');
      expect(
        documentTitle(const SeoData(title: 'Brand: tagline', description: 'd', path: '/', fullTitle: true)),
        'Brand: tagline',
      );
    });

    test('robots policy strings', () {
      expect(RobotsPolicy.indexed.isIndexable, isTrue);
      expect(RobotsPolicy.noIndexFollow.content, 'noindex, follow');
      expect(RobotsPolicy.noIndexNoFollow.content, 'noindex, nofollow');
      expect(RobotsPolicy.noIndexFollow.isIndexable, isFalse);
    });
  });

  group('robots.txt, manifest', () {
    test('robots disallows transactional pages and points at the sitemap', () {
      final txt = robotsTxt(config);
      for (final line in [
        'Disallow: /cart',
        'Disallow: /checkout',
        'Disallow: /newsletter',
        'Disallow: /search',
        'Disallow: /*?q=',
        'Disallow: /*?sort=',
      ]) {
        expect(txt, contains(line));
      }
      expect(txt, contains('Sitemap: https://shop.example/sitemap.xml'));
      expect(txt, contains('User-agent: *'));
      expect(txt, isNot(contains('Disallow: /products')));
    });

    test('manifest is valid JSON with icons', () async {
      final r = manifestResponse(config);
      final data = jsonDecode(await r.readAsString()) as Map<String, dynamic>;
      expect(data['name'], 'Northgate Goods');
      expect(data['start_url'], '/');
      expect(data['display'], 'standalone');
      expect((data['icons'] as List).length, greaterThanOrEqualTo(2));
      expect(r.headers['content-type'], contains('manifest+json'));
    });
  });

  group('RequestInfo', () {
    RequestInfo info(String url, {Map<String, String> headers = const {}}) => RequestInfo(
      method: 'GET',
      rawPath: Uri.parse(url).path,
      query: Uri.parse(url).queryParameters,
      cookieHeader: headers['cookie'],
      headers: headers,
    );

    test('theme: query beats cookie, cookie beats system', () {
      expect(info('/').theme, 'system');
      expect(info('/', headers: {'cookie': 'theme=dark'}).theme, 'dark');
      expect(info('/?theme=light', headers: {'cookie': 'theme=dark'}).theme, 'light');
      expect(info('/', headers: {'cookie': 'theme=evil'}).theme, 'system');
      expect(info('/?theme=evil').theme, 'system');
    });

    test('path is normalised', () {
      expect(info('/products/').path, '/products');
    });

    test('wantsJson reads Accept', () {
      expect(info('/', headers: {'accept': 'application/json'}).wantsJson, isTrue);
      expect(info('/', headers: {'accept': 'text/html'}).wantsJson, isFalse);
    });

    test('form bodies are parsed and bounded', () async {
      final ok = await RequestInfo.from(
        Request(
          'POST',
          Uri.parse('https://x.test/a'),
          body: 'a=1&b=hello+world%21',
          headers: {'content-type': 'application/x-www-form-urlencoded'},
        ),
      );
      expect(ok.form, {'a': '1', 'b': 'hello world!'});
      expect(
        () => RequestInfo.from(
          Request(
            'POST',
            Uri.parse('https://x.test/a'),
            body: 'a=${'x' * 20000}',
            headers: {'content-type': 'application/x-www-form-urlencoded'},
          ),
        ),
        throwsA(isA<PayloadTooLarge>()),
      );
    });

    test('malformed encoding becomes an empty form', () async {
      final r = await RequestInfo.from(
        Request(
          'POST',
          Uri.parse('https://x.test/a'),
          body: 'a=%ZZ',
          headers: {'content-type': 'application/x-www-form-urlencoded'},
        ),
      );
      expect(r.form, isEmpty);
    });

    test('non-form content types are ignored', () async {
      final r = await RequestInfo.from(
        Request('POST', Uri.parse('https://x.test/a'), body: '{"a":1}', headers: {'content-type': 'application/json'}),
      );
      expect(r.form, isEmpty);
    });
  });

  group('sitemap', () {
    test('covers home, listing, categories, products and about with absolute URLs and lastmod', () async {
      final app = await TestApp.create();
      final r = await app.send('GET', '/sitemap.xml');
      expect(r.status, 200);
      expect(r.header('content-type'), contains('application/xml'));
      final locs = RegExp(r'<loc>([^<]+)</loc>').allMatches(r.body).map((m) => m.group(1)!).toList();
      expect(locs, contains('https://shop.example/'));
      expect(locs, contains('https://shop.example/products'));
      expect(locs, contains('https://shop.example/about'));
      expect(locs.where((l) => l.contains('/categories/')), hasLength(5));
      expect(locs.where((l) => l.contains('/products/')), hasLength(12));
      expect(locs.toSet(), hasLength(locs.length));
      expect(RegExp('<lastmod>').allMatches(r.body).length, greaterThanOrEqualTo(locs.length));
      expect(r.body, contains('xmlns:image'));
      expect(r.body, contains('<image:loc>https://shop.example/images/products/'));
    });

    test('never lists private or noindex pages', () async {
      final app = await TestApp.create();
      final r = await app.send('GET', '/sitemap.xml');
      for (final path in ['/cart', '/checkout', '/newsletter', '/search']) {
        expect(r.body, isNot(contains('shop.example$path<')));
      }
    });

    test('uses the configured origin', () async {
      final app = await TestApp.create(config: const StoreConfig(siteUrl: 'https://other.example'));
      final r = await app.send('GET', '/sitemap.xml');
      expect(r.body, contains('https://other.example/products/'));
      expect(r.body, isNot(contains('shop.example')));
    });
  });
}
