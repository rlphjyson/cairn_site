/// URL hygiene, redirects, status codes, caching headers and error pages.
library;

import 'package:cairn_template_jaspr_store/core/config/store_config.dart';
import 'package:test/test.dart';

import '../support/harness.dart';

void main() {
  late TestApp app;
  late Browser visitor;
  setUpAll(() async => app = await TestApp.create());
  setUp(() => visitor = Browser(app));

  group('canonical redirects (301)', () {
    final cases = <String, String>{
      '/products?page=1': '/products',
      '/products?sort=featured': '/products',
      '/products?q=': '/products',
      '/products?page=0': '/products',
      '/products?page=abc': '/products',
      '/products?page=1&sort=featured&q=': '/products',
      '/products?page=02': '/products?page=2',
      '/products?sort=bogus': '/products',
      '/products?q=%20%20leather%20%20bag': '/products?q=leather+bag',
      '/products?category=audio': '/categories/audio',
      '/products?category=audio&sort=price-asc': '/categories/audio?sort=price-asc',
      '/products?category=nonexistent': '/products',
      '/categories/audio?page=1': '/categories/audio',
      '/search': '/products',
      '/search?q=watch': '/products?q=watch',
      '/search?q=watch&sort=name': '/products?q=watch&sort=name',
    };
    for (final entry in cases.entries) {
      test('${entry.key} -> ${entry.value}', () async {
        final r = await visitor.get(entry.key);
        expect(r.status, 301);
        expect(r.location, entry.value);
        expect(r.header('cache-control'), contains('max-age'));
      });
    }

    test('parameter order is normalised in the canonical tag, not by redirect', () async {
      final r = await visitor.get('/products?page=2&q=leather&sort=price-asc');
      expect(r.status, 404); // only 3 leather results: page 2 does not exist
      final ok = await visitor.get('/products?sort=price-asc&q=a');
      expect(ok.status, 200);
      expect(ok.canonical, 'https://shop.example/products?q=a&sort=price-asc');
    });

    test('trailing slash is removed', () async {
      for (final path in ['/products/', '/about/', '/categories/bags/', '/products/stride-knit-sneaker/']) {
        final r = await visitor.get(path);
        expect(r.status, 301, reason: path);
        expect(r.location, path.substring(0, path.length - 1));
      }
    });

    test('doubled slashes collapse', () async {
      final r = await visitor.get('//products//stride-knit-sneaker');
      expect(r.status, 301);
      expect(r.location, '/products/stride-knit-sneaker');
    });

    test('the query string survives a trailing-slash redirect', () async {
      final r = await visitor.get('/products/?page=2');
      expect(r.status, 301);
      expect(r.location, '/products?page=2');
    });

    test('a renamed product slug 301s to the current URL', () async {
      final r = await visitor.get('/products/classic-watch');
      expect(r.status, 301);
      expect(r.location, '/products/classic-38-watch');
      expect((await visitor.get(r.location!)).status, 200);
    });

    test('canonical URLs do not redirect', () async {
      for (final path in ['/', '/products', '/products?page=2', '/categories/bags', '/about', '/products?q=a']) {
        expect((await visitor.get(path)).status, 200, reason: path);
      }
    });
  });

  group('real 404s', () {
    test('unknown path', () async {
      final r = await visitor.get('/nope');
      expect(r.status, 404);
      expect(r.meta('robots'), 'noindex, nofollow');
      expect(r.header('x-robots-tag'), contains('noindex'));
      expect(r.qa('h1'), hasLength(1));
      expect(r.q('form[role="search"]'), isNotNull);
      expect(r.text, contains('We could not find that page'));
    });

    test('unknown product, category, order and extra segments', () async {
      for (final path in [
        '/products/does-not-exist',
        '/categories/nope',
        '/checkout/confirmation/ord_doesnotexist',
        '/products/a/b',
        '/cart/unknown',
        '/checkout/other/x',
        '/wp-login.php',
        '/.env',
      ]) {
        expect((await visitor.get(path)).status, 404, reason: path);
      }
    });

    test('malformed slugs are 404, not 500', () async {
      for (final path in ['/products/UPPER', '/products/a--b', '/categories/..%2f', "/products/'%20OR%201=1"]) {
        final r = await visitor.get(path);
        expect(r.status, anyOf(404, 301), reason: path);
        expect(r.status, isNot(500), reason: path);
      }
    });

    test('a page past the end of a listing is a 404', () async {
      expect((await visitor.get('/products?page=3')).status, 404);
      expect((await visitor.get('/categories/audio?page=2')).status, 404);
      expect((await visitor.get('/products?page=99999999999')).status, 404);
    });

    test('the 404 page is not cacheable for long and is never in the index', () async {
      final r = await visitor.get('/nope');
      expect(r.header('cache-control'), 'public, max-age=60');
      expect(r.body, contains('noindex'));
    });
  });

  group('server errors', () {
    test('an exception becomes a real 500 page, reported, with no stack trace', () async {
      final errors = <Object>[];
      final failing = await TestApp.createFailing(errors);
      final r = await failing.send('GET', '/products');
      expect(r.status, 500);
      expect(r.text, contains('Something went wrong'));
      expect(r.body, isNot(contains('Exception')));
      expect(r.body, isNot(contains('StateError')));
      expect(r.body, isNot(contains('catalogue is down')));
      expect(r.header('cache-control'), 'no-store');
      expect(r.meta('robots'), 'noindex, nofollow');
      expect(errors, isNotEmpty);
    });
  });

  group('methods', () {
    test('unsupported methods are 405', () async {
      for (final m in ['PUT', 'DELETE', 'PATCH']) {
        expect((await app.send(m, '/products')).status, 405, reason: m);
      }
    });

    test('GET on a POST-only endpoint is 405 with Allow', () async {
      final r = await visitor.get('/cart/add');
      expect(r.status, 405);
      expect(r.header('allow'), 'POST');
    });

    test('POST on a GET-only page is 405', () async {
      final r = await visitor.post('/products', {});
      expect(r.status, 405);
      expect((await visitor.post('/', {})).status, 405);
      expect((await visitor.post('/cart', {})).status, 405);
    });

    test('HEAD is served like GET', () async {
      final r = await app.send('HEAD', '/products');
      expect(r.status, 200);
    });
  });

  group('caching headers', () {
    test('catalogue pages are publicly cacheable with an ETag and Vary', () async {
      for (final path in ['/', '/products', '/products/stride-knit-sneaker', '/categories/bags', '/about']) {
        final r = await visitor.get(path);
        expect(r.header('cache-control'), contains('public'), reason: path);
        expect(r.header('cache-control'), contains('max-age=60'), reason: path);
        expect(r.header('cache-control'), contains('s-maxage'), reason: path);
        expect(r.header('etag'), startsWith('W/"'), reason: path);
        expect(r.header('vary'), contains('Cookie'), reason: path);
        expect(r.header('content-type'), 'text/html; charset=utf-8', reason: path);
        expect(r.header('content-language'), 'en', reason: path);
      }
    });

    test('a matching If-None-Match yields 304 with no body', () async {
      final first = await visitor.get('/products');
      final second = await visitor.get('/products', headers: {'if-none-match': first.header('etag')!});
      expect(second.status, 304);
      expect(second.body, isEmpty);
      expect(second.header('etag'), first.header('etag'));
      expect(second.header('cache-control'), contains('public'));
    });

    test('a stale validator gets the full page', () async {
      final r = await visitor.get('/products', headers: {'if-none-match': 'W/"stale"'});
      expect(r.status, 200);
    });

    test('different pages have different ETags', () async {
      final a = await visitor.get('/products');
      final b = await visitor.get('/about');
      expect(a.header('etag'), isNot(b.header('etag')));
    });

    test('cart, checkout, newsletter and JSON endpoints are never stored', () async {
      for (final path in ['/cart', '/newsletter', '/cart/summary']) {
        final r = await visitor.get(path);
        expect(r.header('cache-control'), 'no-store', reason: path);
        expect(r.header('etag'), isNull, reason: path);
      }
    });

    test('robots.txt, sitemap and manifest are cacheable', () async {
      for (final path in ['/robots.txt', '/sitemap.xml', '/manifest.webmanifest']) {
        final r = await visitor.get(path);
        expect(r.status, 200, reason: path);
        expect(r.header('cache-control'), contains('max-age'), reason: path);
      }
    });

    test('redirects after a POST are not cacheable', () async {
      final r = await visitor.post('/newsletter', {'email': 'a@b.co'});
      expect(r.status, 303);
      expect(r.header('cache-control'), 'no-store');
    });
  });

  group('health check', () {
    test('GET /healthz is 200 ok and never cached', () async {
      final r = await visitor.get('/healthz');
      expect(r.status, 200);
      expect(r.body, 'ok');
      expect(r.header('cache-control'), 'no-store');
    });
  });

  group('robots.txt and manifest over HTTP', () {
    test('robots.txt', () async {
      final r = await visitor.get('/robots.txt');
      expect(r.header('content-type'), startsWith('text/plain'));
      expect(r.body, contains('Sitemap: https://shop.example/sitemap.xml'));
      expect(r.body, contains('Disallow: /cart'));
    });

    test('manifest', () async {
      final r = await visitor.get('/manifest.webmanifest');
      expect((r.json as Map)['short_name'], 'Northgate');
    });

    test('robots.txt follows SITE_URL', () async {
      final other = await TestApp.create(config: const StoreConfig(siteUrl: 'https://staging.example'));
      expect((await other.send('GET', '/robots.txt')).body, contains('Sitemap: https://staging.example/sitemap.xml'));
    });
  });

  group('oversized or hostile input', () {
    test('a huge form body is rejected with 413', () async {
      final r = await app.send('POST', '/newsletter', form: {'email': 'x' * 40000});
      expect(r.status, 413);
    });

    test('a very long query string does not crash the listing', () async {
      final r = await visitor.get('/products?q=${'a' * 5000}');
      expect(r.status, anyOf(200, 301));
    });

    test('unicode and emoji searches are fine', () async {
      expect((await visitor.get('/products?q=%F0%9F%91%9F%20caf%C3%A9')).status, 200);
    });
  });
}
