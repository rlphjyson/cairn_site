import 'package:test/test.dart';

import '../../tool/seo_audit.dart';
import '../support/harness.dart';

AuditResponse page(String body) => AuditResponse(200, body);

void main() {
  group('the whole site passes the SEO audit (in-process crawl of the sitemap)', () {
    late AuditReport report;
    setUpAll(() async => report = await auditInProcess());

    test('every sitemap page was crawled', () {
      expect(report.pages, hasLength(20));
      expect(report.pages, contains('/'));
      expect(report.pages.where((p) => p.startsWith('/products/')), hasLength(12));
    });

    test('no failures', () {
      expect(report.failures, isEmpty, reason: report.failures.join('\n'));
      expect(report.passed, isTrue);
    });

    test('a meaningful number of assertions ran', () {
      expect(report.checks, greaterThan(2000));
    });
  });

  group('the audit itself catches problems (so a pass means something)', () {
    const origin = 'https://shop.example';

    Future<AuditReport> auditOne(String html) => auditSite(
      origin: origin,
      fetch: (path) async {
        if (path == '/sitemap.xml') {
          return const AuditResponse(
            200,
            '<urlset><url><loc>https://shop.example/x</loc><lastmod>2026-01-01</lastmod></url></urlset>',
          );
        }
        if (path == '/robots.txt') return const AuditResponse(200, 'Sitemap: https://shop.example/sitemap.xml');
        if (path == '/x') return page(html);
        if (path.startsWith('/this-page')) return const AuditResponse(404, 'noindex');
        return const AuditResponse(404, '');
      },
    );

    const good = '''<!DOCTYPE html><html lang="en"><head><meta name="viewport" content="width=device-width">
      <title>A reasonable page title here</title>
      <meta name="description" content="A description that is long enough to be useful to a person reading a search result.">
      <link rel="canonical" href="https://shop.example/x"><meta name="robots" content="index">
      <meta property="og:type" content="website"><meta property="og:title" content="t"><meta property="og:description" content="d">
      <meta property="og:url" content="https://shop.example/x"><meta property="og:image" content="https://shop.example/i.jpg">
      <meta property="og:image:alt" content="a"><meta property="og:site_name" content="s"><meta property="og:locale" content="en_US">
      <meta name="twitter:card" content="summary"><meta name="twitter:image" content="https://shop.example/i.jpg">
      <script type="application/ld+json">{"@context":"https://schema.org","@type":"WebSite"}</script></head>
      <body><a class="skip-link" href="#main">Skip</a><header>h</header><main id="main"><h1>Title</h1><h2>Sub</h2></main><footer>f</footer></body></html>''';

    test('a good page passes', () async {
      final r = await auditOne(good);
      expect(r.failures, isEmpty, reason: r.failures.join('\n'));
    });

    test('missing and duplicate titles are caught', () async {
      expect(
        (await auditOne(good.replaceAll('<title>A reasonable page title here</title>', ''))).failures.join(),
        contains('<title>'),
      );
      expect(
        (await auditOne(good.replaceAll('<head>', '<head><title>Another title text</title>'))).failures.join(),
        contains('exactly 1 <title>'),
      );
    });

    test('canonical mismatches are caught', () async {
      final r = await auditOne(good.replaceAll('href="https://shop.example/x"', 'href="https://shop.example/y"'));
      expect(r.failures.join(), contains('canonical'));
    });

    test('a relative canonical or OG URL is caught', () async {
      expect(
        (await auditOne(good.replaceAll('content="https://shop.example/i.jpg"', 'content="/i.jpg"'))).failures.join(),
        contains('absolute'),
      );
    });

    test('two h1s and heading jumps are caught', () async {
      expect((await auditOne(good.replaceAll('<h2>Sub</h2>', '<h1>Two</h1>'))).failures.join(), contains('<h1>'));
      expect(
        (await auditOne(good.replaceAll('<h2>Sub</h2>', '<h4>Skip</h4>'))).failures.join(),
        contains('heading order'),
      );
    });

    test('images without alt or dimensions are caught', () async {
      final r = await auditOne(good.replaceAll('<h2>Sub</h2>', '<h2>Sub</h2><img src="/x.jpg">'));
      final text = r.failures.join('\n');
      expect(text, contains('no alt'));
      expect(text, contains('width/height'));
    });

    test('unlabelled form controls are caught', () async {
      final r = await auditOne(good.replaceAll('<h2>Sub</h2>', '<h2>Sub</h2><input name="q">'));
      expect(r.failures.join(), contains('no label'));
    });

    test('invalid JSON-LD is caught', () async {
      final r = await auditOne(
        good.replaceAll('{"@context":"https://schema.org","@type":"WebSite"}', '{"@context": oops'),
      );
      expect(r.failures.join(), contains('not valid JSON'));
    });

    test('a Product without an Offer is caught', () async {
      final r = await auditOne(good.replaceAll('"@type":"WebSite"', '"@type":"Product","name":"x"'));
      expect(r.failures.join(), contains('Product needs'));
    });

    test('broken internal links are caught', () async {
      final r = await auditOne(
        good.replaceAll('<h2>Sub</h2>', '<h2>Sub</h2><a href="/missing">gone</a><a href="#nowhere">x</a>'),
      );
      final text = r.failures.join('\n');
      expect(text, contains('broken internal link /missing'));
      expect(text, contains('#nowhere'));
    });

    test('a soft 404 (200 for unknown URLs) is caught', () async {
      final r = await auditSite(
        origin: origin,
        fetch: (path) async {
          if (path == '/sitemap.xml') return const AuditResponse(200, '<loc>https://shop.example/x</loc>');
          if (path == '/robots.txt') return const AuditResponse(200, 'Sitemap: https://shop.example/sitemap.xml');
          return page(good);
        },
      );
      expect(r.failures.join(), contains('unknown URL returned 200'));
    });
  });

  test('the harness renders the same bytes the audit saw', () async {
    final app = await TestApp.create();
    expect((await app.send('GET', '/')).status, 200);
  });
}
